using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.DOCUMENT
{
    public class print_document_nomenModel : PageModel
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
        //'-- deve essere invocata alla fine delle pagine per liberare la memoria dal docuemnto
        //'DESC=funzione per il caricamneto del documento
        public dynamic DOC_GetFromMem(string TypeDoc, int idDoc, eProcurementNext.Session.ISession session, HttpContext context, EprocResponse htmlToReturn)
        {
            //'On Error Resume Next
            //
            //'Set DOC_GetFromMem = Nothing
            //'Set DOC_GetFromMem = session("DOC_" & TypeDoc & "_" & idDoc)
            //'err.Clear
            //
            //'if DOC_GetFromMem is nothing then

            //'--carico il documento
            return DOC_LoadFromDB(TypeDoc, idDoc, session, context, htmlToReturn);

            //'end if

        }
        //'DESC=funzione che carica il documento dalla base dati
        public static dynamic DOC_LoadFromDB(string TypeDoc, int idDoc, eProcurementNext.Session.ISession session, HttpContext context, EprocResponse htmlToReturn)
        {

            string Permission = "";
            string strConnectionString = "";
            string suffix = "";
            string User = "";
            Lib_dbDocument objDB = new Lib_dbDocument(context, session, htmlToReturn);
            eProcurementNext.Document.CTLDOCOBJ.Document objDoc;
            int nCodRet = 0;

            Permission = session["Funzionalita"];
            strConnectionString = ApplicationCommon.Application["ConnectionString"];
            suffix = session["strSuffLing"];
            User = session["IdPfu"];
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
            if (Strings.Left(CStr(idDoc), 3) == "new")
            {
                objDoc.InitializeNew(session, CStr(idDoc)); //nCodRet = objDoc.InitializeNew(session, CStr(idDoc));
            }
            else
            {
                objDoc.Load(session, CStr(idDoc)); //nCodRet = objDoc.Load(session, CStr(idDoc));
            }
            //'-- aggiorno la memoria con eventuali cambiamenti
            //'objDoc.UpdateContentInMem ObjSession
            return objDoc;

        }

        // 10/01/2023
        // Metododo commentato da Claudio in quanto con 0 riferimenti
        //public dynamic Print_Document_Nomem(EprocResponse htmlToReturn, EprocNext.Session.ISession session, HttpContext context)
        //{
        //    string Oldsuffix;
        //    Oldsuffix = "";

        //    //'function validate (nomeParametro, valoreDaValidare, tipoDaValidare, sottoTipoDaValidare, regExp, obblig )

        //    validate("TYPEDOC", GetParamURL(Request.QueryString.ToString(), "TYPEDOC"), TIPO_PARAMETRO_STRING, SOTTO_TIPO_PARAMETRO_TABLE, "", 0, HttpContext, session);
        //    validate("IDDOC", GetParamURL(Request.QueryString.ToString(), "IDDOC"), TIPO_PARAMETRO_STRING, SOTTO_TIPO_PARAMETRO_TABLE, "", 0, HttpContext, session);

        //    //'--recupero parametri dal chiamante
        //    string TypeDoc = GetParamURL(Request.QueryString.ToString(), "TYPEDOC");
        //    int idDoc = CInt(GetParamURL(Request.QueryString.ToString(), "IDDOC"));

        //    //'--controllo permesso apertura documento
        //    DocPermission(idDoc, TypeDoc, CStr(""),session,htmlToReturn ,Request,Response);
        //    //'-- cambio la lingua di sessione se esplicitamente richiesto
        //    string PrintLanguageSuffix = "";
        //    if (!string.IsNullOrEmpty(PrintLanguageSuffix))
        //    {
        //        Oldsuffix = session["strSuffLing"];
        //        session["strSuffLing"] = PrintLanguageSuffix;

        //    }
        //    else
        //    {
        //        if(!string.IsNullOrEmpty(GetParamURL(Request.QueryString.ToString(), "LanguageSuffix")))
        //        {
        //            Oldsuffix = session["strSuffLing"];
        //            session["strSuffLing"] = GetParamURL(Request.QueryString.ToString(), "LanguageSuffix");
        //        }
        //    }
        //    //'--recupero documento
        //    //'STOP
        //    EprocNext.Document.CTLDOCOBJ.Document objDoc = DOC_GetFromMem(TypeDoc, idDoc,session,context,htmlToReturn);
        //    if(!string.IsNullOrEmpty(Oldsuffix))
        //    {
        //        session["strSuffLing"] = Oldsuffix;

        //    }
        //    htmlToReturn.Write($@"< meta http - equiv = content - type content = ""text / html; charset = UTF - 8"" > """);
        //    return objDoc;
        //}





    }
}
