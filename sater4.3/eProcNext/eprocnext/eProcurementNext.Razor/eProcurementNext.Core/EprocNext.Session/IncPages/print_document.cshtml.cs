using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.Core.Pages.CTL_LIBRARY.functions.DocumentPermissionModel;
using static eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel;

namespace eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT
{
    public class print_documentModel : PageModel
    {


        public void OnGet()
        {
        }
        //'--INCLUDE DI FUNZIONI PER LA GESTIONE DELLE STAMPE PERSONALIZZATE SUL DOCUMENTO 

        //'-- Lista delle funzioni da utilizzare nelle stampe suddivise per sezioni
        //
        //'------------------------------
        //'-- TESTATA ( COPERTINA )
        //'------------------------------
        //'-- Public function DOC_Field( strSectionName, strAttrib )
        //'-- Public function DOC_FieldTecnical( strSectionName, strAttrib )
        //'-- Public Sub DOC_PubLegale( strSectionName, strAttrib)
        //'-- Public Sub DOC_PubLegalePlant( strSectionName, strAttrib)
        //'-- Public sub DOC_Logo( strSectionName, strAttrib,width,height)
        //
        //
        //'------------------------------
        //'-- DETTAGLI ( PRODOTTI )
        //'------------------------------
        //'-- Public function DOC_NumRow( strSectionName, "" )
        //'-- Public function DOC_FieldRow( strSectionName, strAttrib, strNumRiga )
        //
        //
        //'------------------------------
        //'-- APPROVAL ( sezione per ciclo di approvazione )
        //'------------------------------
        //'-- Public function DOC_NumRow( strSectionName, area )
        //'-- Public function DOC_GetRsArea( strSectionName,  Area )
        //'-- Public function DOC_FieldArea( strSectionName, strAttrib, Area , RecordSet )
        //
        //
        //'------------------------------
        //'-- Funzioni di uso comune
        //'------------------------------
        //'-- Public function AziInfo( azi , strAttrib)
        //'-- Public function AziOptional( azi , strAttrib)
        //'-- Public Sub SaltoPagina()
        //'-- Public Sub CNV( testo )
        //'-- Public sub FreeMemDocument
        //'-- Public function GetRS( strSql)
        //'-- Public function Relation( RelType , ValInput )
        //'-- Public Sub PubLegaleAZI( idAzi)
        //'-- 
        //
        //'DESC=funzione per il caricamneto del documento
        public static eProcurementNext.Document.CTLDOCOBJ.Document DOC_GetFromMem(string TypeDoc, string idDoc, eProcurementNext.Session.ISession session, HttpContext context, EprocResponse htmlToReturn)
        {
            //'On Error Resume Next


            //'Set DOC_GetFromMem = Nothing
            //'Set DOC_GetFromMem = session("DOC_" & TypeDoc & "_" & idDoc)
            //'err.Clear
            //
            //
            //'if DOC_GetFromMem is nothing then
            //
            //
            //    '--carico il documento
            //
            return DOC_LoadFromDB(TypeDoc, idDoc, session, context, htmlToReturn);
            //
            //
            //'end if
        }
        //'DESC=funzione che carica il documento dalla base dati
        public static eProcurementNext.Document.CTLDOCOBJ.Document DOC_LoadFromDB(string TypeDoc, string idDoc, eProcurementNext.Session.ISession session, HttpContext context, EprocResponse htmlToReturn)
        {
            Lib_dbDocument objDB;

            eProcurementNext.Document.CTLDOCOBJ.Document? objDoc;

            //'On Error Resume Next

            //set ObjSession(0) = Request.QueryString

            //set ObjSession(1) = Request.form
            //
            //set ObjSession(5) = session
            //
            //set ObjSession(6) = application
            //
            //ObjSession(9) = application("Server_RDS")
            //
            //set ObjSession(13) = objNewDizMlng("MultiLinguismo")
            string Permission = CStr(session["Funzionalita"]);
			string strConnectionString = ApplicationCommon.Application.ConnectionString;
            string suffix = CStr(session["strSuffLing"]);
            int User = CInt(session["IdPfu"]);

            if (string.IsNullOrEmpty(CStr(session["IdPfu"])))
            {
                User = -20;
            }
            objDB = new Lib_dbDocument(context, session, htmlToReturn);
            //'GetDocument(strDocName As String, strPermission As String, suffix As String, Context As Integer, session As Variant, strConnectionString As String) As Variant
            //'-- recupero la struttura del documento
            if (IsEmpty(suffix))
            {
                suffix = "I";
            }
            if (IsEmpty(Permission))
            {
                Permission = "";
            }

            objDoc = objDB.GetDocument(CStr(TypeDoc), CStr(Permission), CStr(suffix), CInt(0), session, CStr(strConnectionString));
            objDoc.PrintMode = true;

            //'--carico tutte le sezioni del documento
            if (Strings.Left(idDoc, 3) == "new")
            {
                objDoc.InitializeNew(session, idDoc); //nCodRet = objDoc.InitializeNew(session, CStr(idDoc));
            }
            else
            {
                objDoc.Load(session, idDoc); //nCodRet = objDoc.Load(session, CStr(idDoc));
            }
            //'-- aggiorno la memoria con eventuali cambiamenti
            //'--solo se documento non � readonly
            if (!objDoc.ReadOnly)
            {
                objDoc.UpdateContentInMem(session, context.Request.HasFormContentType ? context.Request.Form : null);
            }
            return objDoc;
        }
        public static eProcurementNext.Document.CTLDOCOBJ.Document PrintDocument(eProcurementNext.Session.ISession session, EprocResponse htmlToReturn, HttpContext context, HttpResponse Response, HttpRequest Request)
        {
            string Oldsuffix;
            Oldsuffix = "";

            //'function validate (nomeParametro, valoreDaValidare, tipoDaValidare, sottoTipoDaValidare, regExp, obblig )
            validate("TYPEDOC", GetParamURL(Request.QueryString.ToString(), "TYPEDOC"), TIPO_PARAMETRO_STRING, SOTTO_TIPO_PARAMETRO_TABLE, "", 0, context, session);
            validate("IDDOC", GetParamURL(Request.QueryString.ToString(), "IDDOC").Replace("-", ""), TIPO_PARAMETRO_STRING, SOTTO_TIPO_PARAMETRO_TABLE, "", 0, context, session);

            //'--recupero parametri dal chiamante
            string TypeDoc = GetParamURL(Request.QueryString.ToString(), "TYPEDOC");
            string idDoc = GetParamURL(Request.QueryString.ToString(), "IDDOC");
            string docToValidate = TypeDoc;

            if (string.IsNullOrEmpty(docToValidate))
            {
                docToValidate = CStr(GetParamURL(Request.QueryString.ToString(), "DOCUMENT"));
            }
            //'-------------------------------------------
            //'--CONTROLLO PERMESSO APERTURA DOCUMENTO ---
            //'-------------------------------------------
            string extraParam = CStr(GetParamURL(Request.QueryString.ToString(), "PARAM"));
            string strCommand = CStr(GetParamURL(Request.QueryString.ToString(), "COMMAND"));

            //'Response.Write extraParam
            //'Response.end

            if (string.IsNullOrEmpty(extraParam) && !string.IsNullOrEmpty(strCommand))
            {
                extraParam = extraParam + "@@@" + strCommand;
            }
            //'--controllo permesso apertura documento
            DocPermission(context, CInt(GetParamURL(Request.QueryString.ToString(), "IDDOC")), CStr(docToValidate), extraParam, session, htmlToReturn, Request, Response);
            //'-- cambio la lingua di sessione se esplicitamente richiesto
            string PrintLanguageSuffix = "";
            if (!string.IsNullOrEmpty(PrintLanguageSuffix))
            {
                //ObjSes = session("Session")
                Oldsuffix = CStr(session["strSuffLing"]);
                session["strSuffLing"] = PrintLanguageSuffix;
                //session("Session") = ObjSes 
            }
            else
            {
                if (!string.IsNullOrEmpty(GetParamURL(Request.QueryString.ToString(), "LanguageSuffix")))
                {
                    //ObjSes = session("Session")
                    Oldsuffix = CStr(session["strSuffLing"]);
                    session["strSuffLing"] = GetParamURL(Request.QueryString.ToString(), "LanguageSuffix");
                    //session("Session") = ObjSes 
                }
            }
            //'--recupero documento

            //'STOP
            eProcurementNext.Document.CTLDOCOBJ.Document objDoc = DOC_GetFromMem(TypeDoc, idDoc, session, context, htmlToReturn);
            CommonDbFunctions cdf = new CommonDbFunctions();
            if (!string.IsNullOrEmpty(CStr(session["IdPfu"])))
            {
                if (!string.IsNullOrEmpty(TypeDoc) && !string.IsNullOrEmpty(CStr(idDoc)) && IsNumeric(idDoc))
                {
                    TSRecordSet rsDocNotRead = cdf.GetRSReadFromQuery_("select id_Doc from CTL_DOC_READ with(nolock) where  DOC_NAME = '" + TypeDoc.Replace("'", "''") + "' AND id_Doc = " + idDoc + " AND  idPfu = " + session["IdPfu"], ApplicationCommon.Application["ConnectionString"]);
                    if (rsDocNotRead.RecordCount == 0)
                    {
                        cdf.Execute("if not exists (  select id_Doc from CTL_DOC_READ with(nolock) where " +
                        " DOC_NAME = '" + TypeDoc.Replace("'", "''") + "' AND id_Doc = " + idDoc + " AND  idPfu = " + session["IdPfu"] +
                        ") insert into CTL_DOC_READ ( DOC_NAME , id_Doc , idPfu ) values ('" + TypeDoc.Replace("'", "''") + "', " + idDoc + " , " + session["IdPfu"] + " )", ApplicationCommon.Application["ConnectionString"]);
                    }
                }
                if (!string.IsNullOrEmpty(Oldsuffix))
                {
                    session["strSuffLing"] = Oldsuffix;
                }

            }
            return objDoc;
        }

        public static void addMetaTag(EprocResponse htmlToReturn)
        {
            htmlToReturn.Write($@"<meta http-equiv=""content-type"" content=""text/html; charset=utf-8"" />");
            htmlToReturn.Write($@"<meta http-equiv=""pragma"" content=""no-cache""/>");
            htmlToReturn.Write($@"<meta http-equiv=""expires"" content=""-1""/>");
        }
    }
}
