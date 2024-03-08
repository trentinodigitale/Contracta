using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Document.CtlDocument;
using eProcurementNext.HTML;
using eProcurementNext.Razor;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualBasic;
using System.Linq;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.Core.Pages.CTL_LIBRARY.functions.securityModel;

namespace eProcurementNext.Core.Pages.CTL_LIBRARY.DOCUMENT
{
    public class CommonModel : PageModel
    {
        //'--ENUMRATO TIPO ATTRIBUTO

        public const int TIPOATTRIB_TEXT = 1;
        public const int TIPOATTRIB_NUMBER = 2;
        public const int TIPOATTRIB_TEXTAREA = 3;
        public const int TIPOATTRIB_DOMAIN = 4;
        public const int TIPOATTRIB_HIERARCHY = 5;
        public const int TIPOATTRIB_DATE = 6;
        public const int TIPOATTRIB_NUMBER_COLORED = 7;
        public const int TIPOATTRIB_DOMAIN_EXTENDED = 8;
        public const int TIPOATTRIB_CHECKBOX = 9;
        public const int TIPOATTRIB_RADIOBUTTON = 10;
        public const int TIPOATTRIB_LABEL = 11;
        public const int TIPOATTRIB_FOTO = 12;
        public const int TIPOATTRIB_URL = 13;
        public const int TIPOATTRIB_MAIL = 14;
        public const int TIPOATTRIB_STATIC = 15;
        public const int TIPOATTRIB_HR = 16;
        public const int TIPOATTRIB_ATTACH = 18;
        public const int TIPOATTRIB_LOGO_AZIENDA = 19;
        public const int TIPOATTRIB_LEGALPUB = 20;
        public const int TIPOATTRIB_DESC_DB = 21;
        public const int TIPOATTRIB_DATE_EXTENDED = 22;
        //-- deve essere invocata alla fine delle pagine per liberare la memoria dal docuemnto
        //da capire tipo Document
        public static eProcurementNext.Document.CTLDOCOBJ.Document? objDoc;
        public void OnGet()
        {
        }
        public static void FreeMemDocument(eProcurementNext.Session.ISession session)
        {

            try
            {
                if (objDoc != null)
                {
                    objDoc.RemoveMem(session);
                    objDoc.Destroy();
                }
            }
            catch
            {

            }

            //    set objDoc = nothing
            //    err.Clear

            // 	'--faccio abandon se sessione utente vuota o -20
            if (string.IsNullOrEmpty(CStr(session["IdPfu"])) || CStr(session["IdPfu"]) == "-20" || CStr(session["IdPfu"]) == "-10")
            {
                MainGlobalAsa.SessionAbandon(session);
                //session.abandon()
            }

        }
        public static void FreeMemDocumentNoAbandon(eProcurementNext.Session.ISession session)
        {
            try
            {
                objDoc.RemoveMem(session);
            }
            catch
            {

            }

            if (objDoc != null)
            {
                objDoc.Destroy();
            }
            // set objDoc = nothing
            // err.Clear
        }
        //'DESC=funzione per recupero valore attributo
        //'objDoc=documento
        //'strSectionName=nome sezione
        //'strAttrib=nome attributo
        //'nNumRiga=numero riga utilizzato per le griglie
        //'strTechValue= di output contiene il valore in forma tecnica
        public static void DOC_AttribValue(string strSectionName, string strAttrib, string strNumRiga, string strTechValue, EprocResponse htmlToReturn)
        {
            string strVisualValue = "";
            strTechValue = "";

            try
            {


                if (string.IsNullOrEmpty(strNumRiga))
                {
                    //'--attributo di testata

                    strVisualValue = objDoc.Sections[strSectionName].mp_Mod.Fields[strAttrib].TxtValue();
                    strTechValue = objDoc.Sections[strSectionName].mp_Mod.Fields[strAttrib].Value;
                }
                else
                {
                    //'--attributo di griglia
                    //'--recupero posizione attributo nella matrice

                    int nPosColAttrib = objDoc.Sections[strSectionName].GetIndexColumn(strAttrib);

                    //'--matrice dei valori

                    dynamic[,] MatrixValue = objDoc.Sections[strSectionName].mp_Matrix;


                    //'--recupero valore tecnico

                    strTechValue = MatrixValue[nPosColAttrib - 1, CInt(strNumRiga)];


                    //'--recupero valore visuale

                    Field objField = objDoc.Sections[strSectionName].mp_Columns.ElementAt(nPosColAttrib - 1).Value;


                    objField.Value = strTechValue;


                    strVisualValue = objField.TxtValue();
                }
            }
            catch
            {

            }
            htmlToReturn.Write(strVisualValue);


        }
        public static string DOC_FieldHTML(string strSectionName, string strAttrib)
        {
            return DOC_Field(strSectionName, strAttrib);
        }
        //'-- dato il campo di una copertina si ritorna il valore visuale
        //'-- 	SE SERVE PORTARE IN OUTPUT UN CONTENUTO HTML DI UN FIELD SENZA FARNE L'ENCODE CHIAMARE IL METODO DOC_Field_NoEncode
        public static dynamic DOC_Field(string strSectionName, string strAttrib)
        {
            string strVisualValue = string.Empty;
            string _DOC_Field = string.Empty;

            //'DOC_Field = DOC_Field_NoEncode( strSectionName, strAttrib )
            //
            //'exit function

            string attribStyle = string.Empty;
            try
            {
                attribStyle = objDoc.Sections[strSectionName].mp_Mod.Fields[strAttrib].Style.ToUpper();
            }
            catch
            {
                attribStyle = "";
            }

            //'--attributo di testata

            try
            {
                strVisualValue = objDoc.Sections[strSectionName].mp_Mod.Fields[strAttrib].TxtValue();
            }
            catch
            {
                strVisualValue = "";
            }
            //'-- se il campo è di tipo rich text edit non ne faccio l'html encode a meno della bonifica dei tag pericolosi
            if (attribStyle == "RTE")
            {
                strVisualValue = eProcurementNext.CommonModule.Basic.bonificaHtmlDaXSS(strVisualValue);
            }
            else
            {
                int temp = 0;
                try
                {
                    temp = Strings.InStr(objDoc.Sections[strSectionName].mp_Mod.Fields[strAttrib].strFormat, "nl");
                }
                catch
                {

                }
                if (temp > 0)
                {
                    strVisualValue = NL_To_BR(Myhtmlencode(strVisualValue));
                }
                else
                {
                    strVisualValue = Myhtmlencode(strVisualValue);
                }

            }
            _DOC_Field = strVisualValue;

            return _DOC_Field;
            //err.clear
        }

        public static string DOC_Field_NoEncode(string strSectionName, string strAttrib)
        {
            try
            {
                return 
                    (objDoc.Sections[strSectionName].mp_Mod.Fields[strAttrib].TxtValue());
            }
            catch
            {
                return "";
            }
            //err.clear
        }

        public static string DOC_Field_LabelHTML(string strSectionName, string strAttrib)
        {
            return Myhtmlencode(DOC_Field_Label(strSectionName, strAttrib));
        }
        //'-- dato il campo di una copertina si ritorna la label associata all'attributo
        public static string DOC_Field_Label(string strSectionName, string strAttrib)
        {
            string strVisualValue = "";


            //'--attributo di testata
            try
            {
                strVisualValue = objDoc.Sections[strSectionName].mp_Mod.Fields[strAttrib].Caption;
            }
            catch
            {

            }
            //err.clear
            return strVisualValue;
        }

        public static string DOC_FieldTecnicalHTML(string strSectionName, string strAttrib)
        {
            return Myhtmlencode(DOC_FieldTecnical(strSectionName, strAttrib));
        }
        //'-- dato il campo di una copertina ritorna il valore tecnico
        public static dynamic DOC_FieldTecnical(string strSectionName, string strAttrib)
        {
            dynamic strVisualValue = null;
            try
            {
                if (objDoc.Sections[strSectionName].mp_Mod.Fields[strAttrib].getType() == 6 || objDoc.Sections[strSectionName].mp_Mod.Fields[strAttrib].getType() == 22)
                {
                    strVisualValue = objDoc.Sections[strSectionName].mp_Mod.Fields[strAttrib].SQLValue().Replace("'", "");
                }
                else
                {
                    strVisualValue = objDoc.Sections[strSectionName].mp_Mod.Fields[strAttrib].Value;
                }
            }
            catch
            {

            }

            return strVisualValue;
        }

        public static string DOC_FieldRowHTML(string strSectionName, string strAttrib, int strNumRiga)
        {
            return DOC_FieldRow(strSectionName, strAttrib, strNumRiga);
        }
        public static string Myhtmlencode(string valore)
        {
            string _Myhtmlencode = "";
            if (IsNull(valore))
            {
                _Myhtmlencode = valore;
            }
            else
            {
                if (valore == "&nbsp;")
                {
                    _Myhtmlencode = valore;
                }
                else
                {
                    _Myhtmlencode = HtmlEncode(valore);
                }
                _Myhtmlencode = _Myhtmlencode.Replace("&lt;br&gt;", "<br>");
                _Myhtmlencode = _Myhtmlencode.Replace("&lt;br/&gt;", "<br/>");

            }
            return _Myhtmlencode;
        }
        //'-- dato il campo di una sezione dettagli si ritorna il valore visuale
        public static string DOC_FieldRow(string strSectionName, string strAttrib, int strNumRiga)
        {
            string strVisualValue = "";


            string strTechValue = "";


            //'--attributo di griglia

            //'--recupero posizione attributo nella matrice

            int nPosColAttrib = objDoc.Sections[strSectionName].GetIndexColumn(strAttrib);

            //'--matrice dei valori

            dynamic[,] MatrixValue = objDoc.Sections[strSectionName].mp_Matrix;

            //'--recupero valore tecnico
            if (MatrixValue != null)//gestione on error resume next
            {
                strTechValue = CStr(MatrixValue[nPosColAttrib - 1, strNumRiga]);
            }
            //'--recupero valore visuale

            Field objField = null;
            try
            {
                objField = objDoc.Sections[strSectionName].mp_Columns.ElementAt(nPosColAttrib - 1).Value;
                objField.Value = strTechValue;
                strVisualValue = objField.TxtValue();
            }
            catch
            {

            }
            //   err.clear

            if (objField != null && (objField.strFormat).Contains("nl", StringComparison.Ordinal))
            {
                return NL_To_BR(Myhtmlencode(strVisualValue));
            }
            else
            {
                return Myhtmlencode(strVisualValue);
            }

        }

        public static string DOC_FieldRow_LabelHTML(string strSectionName, string strAttrib)
        {
            return Myhtmlencode(DOC_FieldRow_Label(strSectionName, strAttrib));
        }
        //'-- dato il campo di una sezione dettagli si ritorna la caption 
        public static string DOC_FieldRow_Label(string strSectionName, string strAttrib)
        {
            string strVisualValue = "";


            string strTechValue = "";
            //'--recupero posizione attributo nella matrice

            int nPosColAttrib = 0;
            Field objField = null;
            try
            {
                nPosColAttrib = objDoc.Sections[strSectionName].GetIndexColumn(strAttrib);

                //'--matrice dei valori

                //'MatrixValue=objDoc.Sections(strSectionName).mp_Matrix

                //'--recupero valore tecnico

                //'strTechValue = MatrixValue(nPosColAttrib-1, strNumRiga)

                //'--recupero valore visuale

                objField = objDoc.Sections[strSectionName].mp_Columns.ElementAt(nPosColAttrib - 1).Value;
                strVisualValue = objField.Caption;
            }
            catch
            {

            }
            //'objField.value=strTechValue

            return strVisualValue;
        }

        public static string DOC_FieldRowTecnicalHTML(string strSectionName, string strAttrib, int strNumRiga)
        {
            return Myhtmlencode(DOC_FieldRowTecnical(strSectionName, strAttrib, strNumRiga));
        }
        //'-- dato il campo di una sezione dettagli si ritorna il valore tecnico
        public static dynamic DOC_FieldRowTecnical(string strSectionName, string strAttrib, int strNumRiga)
        {
            string strVisualValue;

            string strTechValue = "";
            // '--attributo di griglia

            //'--recupero posizione attributo nella matrice

            int nPosColAttrib = 0;
            dynamic MatrixValue = null;
            try
            {


                nPosColAttrib = objDoc.Sections[strSectionName].GetIndexColumn(strAttrib);


                //'--matrice dei valori

                MatrixValue = objDoc.Sections[strSectionName].mp_Matrix;
                strTechValue = CStr(MatrixValue[nPosColAttrib - 1, strNumRiga]);
            }
            catch
            {

            }
            //'--recupero valore tecnico




            //err.clear

            return strTechValue;
        }

        public static string DOC_FieldAreaHTML(string strSectionName, string strAttrib, string Area, TSRecordSet RS)
        {
            return Myhtmlencode(DOC_FieldArea(strSectionName, strAttrib, Area, RS));
        }
        //'-- data il campo di una sezione approvazione
        public static string DOC_FieldArea(string strSectionName, string strAttrib, string Area, TSRecordSet RS)
        {
            string strVisualValue = "";

            string strTechValue = "";

            Field objField = null;
            try
            {


                if (Area == "CYCLE")
                {
                    //'objDoc.Sections(strSectionName).mp_rsCicle.AbsolutePosition =  clng(strNumRiga) + 1

                    strTechValue = CStr(RS[strAttrib]);

                    objField = objDoc.Sections[strSectionName].mp_ColumnsC[strAttrib];
                }
                if (Area == "STEP")
                {
                    //'objDoc.Sections(strSectionName).mp_rsCicleStep.AbsolutePosition =  clng(strNumRiga )+ 1
                    strTechValue = CStr(RS[strAttrib]);
                    objField = objDoc.Sections[strSectionName].mp_ColumnsS[strAttrib];
                }

                objField.Value = strTechValue;

                strVisualValue = objField.TxtValue();
            }
            catch
            {

            }
            return strVisualValue;

        }
        //'-- data il campo di una sezione approvazione
        public static string DOC_FieldArea2(string strSectionName, string strAttrib, string Area)
        {
            string strVisualValue = "";

            string strTechValue = "";



            Field objField = null;

            try
            {


                if (Area == "CYCLE")
                {
                    //'objDoc.Sections(strSectionName).mp_rsCicle.AbsolutePosition =  clng(strNumRiga) + 1

                    objDoc.Sections[strSectionName].mp_rsCicle.MoveNext();
                    objDoc.Sections[strSectionName].mp_rsCicle.MoveNext();
                    strTechValue = CStr(objDoc.Sections[strSectionName].mp_rsCicle.Fields[strAttrib]);
                    objField = objDoc.Sections[strSectionName].mp_ColumnsC[strAttrib];

                }
                if (Area == "STEP")
                {
                    //'objDoc.Sections(strSectionName).mp_rsCicleStep.AbsolutePosition =  clng(strNumRiga )+ 1

                    strTechValue = CStr(objDoc.Sections[strSectionName].mp_rsCicleStep.Fields[strAttrib]);
                    objField = objDoc.Sections[strSectionName].mp_ColumnsS[strAttrib];
                }
                objField.Value = strTechValue;
                strVisualValue = objField.TxtValue();
            }
            catch
            {

            }
            //err.clear
            return strVisualValue;


        }

        //'-- muove il record corrente sull'area di una sezione di tipo approvazione
        public static void DOC_AreaMoveRec(string strSectionName, string Area, string move)
        {
            TSRecordSet? rs = null;
            try
            {
                //dynamic objDoc = null;
                if (Area == "CYCLE")
                {
                    //'set rs = objDoc.Sections(strSectionName).mp_rsCicle
                    if (move == "first")
                    {
                        objDoc.Sections[strSectionName].mp_rsCicle.MoveFirst();
                    }
                    if (move == "next")
                    {
                        objDoc.Sections[strSectionName].mp_rsCicle.MoveNext();
                    }

                }
                if (Area == "STEP")
                {
                    //'set rs = objDoc.Sections(strSectionName).mp_rsCicleStep

                    if (move == "first")
                    {
                        objDoc.Sections[strSectionName].mp_rsCicleStep.MoveFirst();
                    }
                    if (move == "next")
                    {
                        objDoc.Sections[strSectionName].mp_rsCicleStep.MoveNext();
                    }
                }
            }
            catch
            {

            }
        }
        //da capire tipo di ritorno della funzione da controllare
        public static TSRecordSet? DOC_GetRsArea(string strSectionName, string Area)
        {
            TSRecordSet? _DOC_GetRsArea = null;
            if (Area == "CYCLE")
            {
                return objDoc.Sections[strSectionName].mp_rsCicle;
            }
            if (Area == "STEP")
            {
                return objDoc.Sections[strSectionName].mp_rsCicleStep;
            }
            return null;


        }
        //'-- data il campo di una sezione dettagli si esegue la scrittura del valore testuale
        //capire tipo di ritorno
        public static int DOC_NumRow(string strSectionName, string area)
        {
            int _DOC_NumRow = 0;
            string strVisualValue = "";

            string strTechValue = "";
            try
            {

                switch (objDoc.Sections[strSectionName].TypeSection)
                {
                    case "DETTAGLI":
                        //'--attributo di griglia


                        // '--matrice dei valori

                        _DOC_NumRow = objDoc.Sections[strSectionName].mp_numRec;
                        break;
                    case "APPROVAL":
                        if (area == "CYCLE")
                        {
                            _DOC_NumRow = objDoc.Sections[strSectionName].mp_rsCicle.RecordCount;
                        }
                        if (area == "STEP")
                        {
                            _DOC_NumRow = objDoc.Sections[strSectionName].mp_rsCicleStep.RecordCount;
                        }

                        break;
                }
            }
            catch
            {

            }
            return _DOC_NumRow;
            //err.clear 
        }
        //'-- ritorna il valore di un attributo sui dati azienda, ad esempio ragione sociale

        public static string AziInfo(string azi, string strAttrib)
        {
            string strTechValue = azi;
            CommonDbFunctions cdf = new();
            TSRecordSet? rsAzi = null;

            try
            {
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@strTechValue", CInt(strTechValue));
                rsAzi = cdf.GetRSReadFromQuery_("select * from Aziende where IdAzi = @strTechValue", ApplicationCommon.Application.ConnectionString, sqlParams);
            }
            catch
            {

            }
            return CStr(rsAzi[strAttrib]);
            //err.clear
        }
        //'-- ritorna il valore di un attributo sui dati opzionali azienda, ad esempio codice cliente

        public static string AziOptional(string azi, string strAttrib)
        {
            CommonDbFunctions cdf = new();

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@strTechValue", CInt(azi));
            sqlParams.Add("@strAttrib", strAttrib);

            TSRecordSet rsAzi = cdf.GetRSReadFromQuery_("select vatValore_FT from DM_Attributi with(nolock) where idApp = 1 and lnk = @strTechValue and dztNome = @strAttrib", ApplicationCommon.Application.ConnectionString, sqlParams);

            if (rsAzi is not null && rsAzi.RecordCount > 0)
            {
                return CStr(rsAzi["vatValore_FT"]);
            }

            return string.Empty;
        }

        /// <summary>
        /// ritorna il valore di un attributo sui dati opzionali azienda, ad esempio codice cliente
        /// </summary>
        /// <param name="RelType"></param>
        /// <param name="ValInput"></param>
        /// <returns></returns>
        public static string Relation(string RelType, string ValInput)
        {
            CommonDbFunctions cdf = new();

            var sqlP = new Dictionary<string, object?>();
            sqlP.Add("@RelType", RelType);
            sqlP.Add("@ValInput", ValInput);

            TSRecordSet rsAzi = cdf.GetRSReadFromQuery_("select REL_ValueOutput from ctl_relations with(nolock) where REL_Type = @RelType and REL_ValueInput = @ValInput", ApplicationCommon.Application.ConnectionString, sqlP);

            if (rsAzi is not null && rsAzi.RecordCount > 0)
            {
                return CStr(rsAzi["REL_ValueOutput"]);
            }

            return string.Empty;
        }

        public static string RelationTime(string RelType, string ValInput, DateTime t)
        {
            string RelationTime = "";
            string FT;
            FT = t.Year + "-" + Strings.Right("00" + t.Month, 2) + "-" + Strings.Right("00" + t.Day, 2) + " " + Strings.Right("00" + t.Hour, 2) + ":" + Strings.Right("00" + t.Minute, 2) + ":" + Strings.Right("00" + t.Second, 2);

            string connectionString = ApplicationCommon.Application.ConnectionString;
            CommonDbFunctions cdb = new();
			var sqlParams = new Dictionary<string, object?>();
			sqlParams.Add("@RelType", RelType);
			sqlParams.Add("@ValInput", ValInput);
			sqlParams.Add("@FT", FT);
			TSRecordSet rsAzi = cdb.GetRSReadFromQuery_("select REL_ValueOutput from CTL_RelationsTime with(nolock) where REL_Type = @RelType and REL_ValueInput = @ValInput and convert( varchar , REL_Data_I , 121 ) <= @FT and @FT <= convert( varchar , REL_Data_F , 121 )", connectionString, sqlParams);

            if (rsAzi.RecordCount == 0)
            {
                RelationTime = "";
            }
            else
            {
                RelationTime = CStr(rsAzi["REL_ValueOutput"]);
            }

            return RelationTime;
        }
        //'-- ritorna un rs passata la query

        public static TSRecordSet GetRS(string strSql, Dictionary<string, object?>? SqlParameters = null)
        {

            CommonDbFunctions cdf = new();
            if (SqlParameters is not null)
            {
                return cdf.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, SqlParameters);
            }
            else
            {
                return cdf.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString);
            }
        }

        //'DESC=disegna la pub legale di una azienda
        public static void DOC_PubLegale(string strSectionName, string strAttrib, EprocResponse htmlToReturn)
        {
            string strTechValue = "";
            try
            {
                strTechValue = objDoc.Sections[strSectionName].mp_Mod.Fields[strAttrib].Value;
                PubLegaleAZI(strTechValue, "1111", htmlToReturn);
            }
            catch
            {

            }

        }
        public static void PubLegaleAZI(string idAzi, string strP, EprocResponse htmlToReturn)
        {
            string strTechValue = idAzi;

            CommonDbFunctions cbf = new();
            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@strTechValue", CInt(strTechValue));

            TSRecordSet rsAzi = cbf.GetRSReadFromQuery_("select aziPartitaIVA,aziRagioneSociale,aziIndirizzoLeg,aziCAPLeg,aziLocalitaLeg,aziProvinciaLeg,aziStatoLeg,aziTelefono1,aziFAX,aziSitoWeb from aziende with(nolock) where idazi = @strTechValue", ApplicationCommon.Application.ConnectionString, sqlParams);

            htmlToReturn.Write($@"<div id=""PUBLEG"">");
            htmlToReturn.Write($@"<table border = ""0"" cellspacing = ""0"" cellpadding = ""0"" class=""FldPubLeg_Tab"" >");
            if (Strings.Mid(strP, 1, 1) == "1")
            {
                htmlToReturn.Write("<tr>");
                htmlToReturn.Write("<td><b>" + CStr(rsAzi["aziRagioneSociale"]) + "</b></td>");
                htmlToReturn.Write("</tr>");

            }
            if (Strings.Mid(strP, 2, 1) == "1")
            {
                htmlToReturn.Write("<tr>");

                htmlToReturn.Write("<td>" + CStr(rsAzi["aziIndirizzoLeg"]) + " &nbsp;" + CStr(rsAzi["aziCAPLeg"]) + " &nbsp;" + CStr(rsAzi["aziLocalitaLeg"]) + " &nbsp;" + (CStr(rsAzi["aziProvinciaLeg"])) + CStr(rsAzi["aziStatoLeg"]) + "</td>");

                htmlToReturn.Write("</tr >");
            }
            if (Strings.Mid(strP, 3, 1) == "1")
            {
                htmlToReturn.Write("<tr>");
                htmlToReturn.Write("<td> Tel" + CStr(rsAzi["aziTelefono1"]) + " &nbsp; -&nbsp; Fax" + CStr(rsAzi["aziFAX"]) + $@"-+ <a href = ""http://""" + CStr(rsAzi["aziSitoWeb"]) + $@""">" + CStr(rsAzi["aziSitoWeb"]) + "</a> </td>");
                htmlToReturn.Write("</tr>");
            }
            if (Strings.Mid(strP, 4, 1) == "1")
            {
                htmlToReturn.Write("<tr>");
                htmlToReturn.Write("<td>");
                string piva = "";
                string codfisc = "";
                //'--CARCodFis

                codfisc = AziOptional(idAzi, "CARCodFis").Trim();
                if (!string.IsNullOrEmpty(CStr(rsAzi["aziPartitaIVA"])))
                {
                    piva = CStr(rsAzi["aziPartitaIVA"]).Trim();
                }
                if (!string.IsNullOrEmpty(codfisc))
                {
                    htmlToReturn.Write($"C.F. {codfisc}");
                }
                if (!string.IsNullOrEmpty(piva))
                {
                    htmlToReturn.Write($"  P.IVA {piva}");
                }
                if (string.IsNullOrEmpty(codfisc) && string.IsNullOrEmpty(piva))
                {
                    htmlToReturn.Write("C.F.  P.IVA");
                }
                htmlToReturn.Write("</td>");
                htmlToReturn.Write("</tr>");

            }
            htmlToReturn.Write("</table>");
            htmlToReturn.Write("</div>");
        }


        /// <summary>
        /// inserisce il salto pagina
        /// </summary>
        /// <param name="htmlToReturn"></param>
        public static void SaltoPagina(EprocResponse htmlToReturn)
        {
            htmlToReturn.Write($@"<div style = ""page-break-after : always"" ></div>");
        }

        /// <summary>
        /// inserisce nella tabella TRACE_MULTILINGUISMO le chiavi del vecchio multilinguismo
        /// </summary>
        /// <param name="strKey"></param>
        public static void TraceMultilinguismo(string strKey)
        {
            TSRecordSet? rs = null;
            CommonDbFunctions cdf = new();
            cdf.Execute("insert into TRACE_MULTILINGUISMO (idMultilng,Type) values ('" + strKey.Replace("'", "''") + "','O')", ApplicationCommon.Application["ConnectionString"]);
        }
        public static void MsgError(string path, string ErrText, HttpResponse httpResponse)
        {
            throw new ResponseRedirectException(path + "../MessageBoxWin.asp?ML=yes&MSG=" + URLEncode(TruncateMessage(ErrText)) + "&CAPTION=Errore&ICO=2", httpResponse);
        }
        public static void CheckCanSign(EprocResponse htmlToReturn, eProcurementNext.Session.ISession session, HttpContext HttpContext, HttpRequest Request)
        {
            if ((GetParamURL(HttpContext.Request.QueryString.ToString(), "SIGN").ToUpper()) == "YES")
            {
                string TABLE = "";
                string IDENTITY = "";
                string AREA = "";
                string IDDOC = "";
                string PDF_FileName = "";
                string SIGN_LOCK = "";
                int idPfu = 0;

                validate("TABLE_SIGN", CStr(GetParamURL(Request.QueryString.ToString(), "TABLE_SIGN")), TIPO_PARAMETRO_STRING, SOTTO_TIPO_PARAMETRO_PAROLASINGOLA, "", 0, HttpContext, session);
                validate("DOCUMENT", CStr(GetParamURL(Request.QueryString.ToString(), "DOCUMENT")), TIPO_PARAMETRO_STRING, SOTTO_TIPO_PARAMETRO_PAROLASINGOLA, "", 0, HttpContext, session);
                validate("IDENTITY_SIGN", CStr(GetParamURL(Request.QueryString.ToString(), "IDENTITY_SIGN")), TIPO_PARAMETRO_STRING, SOTTO_TIPO_PARAMETRO_PAROLASINGOLA, "", 0, HttpContext, session);
                validate("AREA_SIGN", CStr(GetParamURL(Request.QueryString.ToString(), "AREA_SIGN")), TIPO_PARAMETRO_STRING, SOTTO_TIPO_PARAMETRO_PAROLASINGOLA, "", 0, HttpContext, session);
                validate("IDDOC", CStr(GetParamURL(Request.QueryString.ToString(), "IDDOC")), TIPO_PARAMETRO_NUMERO, 0, "", 0, HttpContext, session);
                idPfu = session["IdPfu"];
                htmlToReturn.Write($@"<input type=""hidden"" name=""INSIGNPRINT""  id=""INSIGNPRINT""  value=""1"" >");
                //'-- preparo i campi necessari per il meccanismo di firma)
                TABLE = GetParamURL(HttpContext.Request.QueryString.ToString(), "TABLE_SIGN");
                TSRecordSet? rs = null;
                CommonDbFunctions cdf = new();
                if (string.IsNullOrEmpty(TABLE))
                {

                    rs = cdf.GetRSReadFromQuery_("select DOC_Table from LIB_Documents where DOC_ID = '" + GetParamURL(HttpContext.Request.QueryString.ToString(), "DOCUMENT").Replace("'", "''") + "'", ApplicationCommon.Application["ConnectionString"]);
                    TABLE = GetValueFromRS(rs.Fields["DOC_Table"]);
                }
                IDENTITY = GetParamURL(HttpContext.Request.QueryString.ToString(), "IDENTITY_SIGN");
                if (string.IsNullOrEmpty(IDENTITY))
                {
                    IDENTITY = "id";
                }
                AREA = GetParamURL(HttpContext.Request.QueryString.ToString(), "AREA");
                if (!string.IsNullOrEmpty(AREA))
                {
                    SIGN_LOCK = AREA + "_SIGN_LOCK";
                }
                else
                {
                    SIGN_LOCK = "SIGN_LOCK";
                }
                IDDOC = GetParamURL(HttpContext.Request.QueryString.ToString(), "IDDOC");
                PDF_FileName = GetParamURL(HttpContext.Request.QueryString.ToString(), "PDF_FileName_SIGN");
                if (string.IsNullOrEmpty(PDF_FileName))
                {
                    PDF_FileName = "Signed Document.pdf";
                }
                //'-- controllo per evitare l'operazione
                rs = cdf.GetRSReadFromQuery_("select isnull( " + SIGN_LOCK + " , 0 ) as " + SIGN_LOCK + "  from " + TABLE + " where " + IDENTITY + " = " + IDDOC, ApplicationCommon.Application["ConnectionString"]);
                if (GetValueFromRS(rs.Fields[SIGN_LOCK]) != 0)
                {
                    MsgError("", "Operazione non consentita,  gia in corso una firma", HttpContext.Response);
                }
                //'-- lock della tabella
                string strSql = "update  " + TABLE + " set " + SIGN_LOCK + " = " + idPfu + " where " + IDENTITY + " = " + IDDOC + " and " + SIGN_LOCK + " = 0 ";
                cdf.Execute(CStr(strSql), CStr(ApplicationCommon.Application["ConnectionString"]));
                rs = cdf.GetRSReadFromQuery_("select isnull( " + SIGN_LOCK + " , 0 ) as " + SIGN_LOCK + "  from " + TABLE + " where " + IDENTITY + " = " + IDDOC, ApplicationCommon.Application["ConnectionString"]);
                if (GetValueFromRS(rs.Fields[SIGN_LOCK]) != idPfu)
                {
                    MsgError("", "Operazione non consentita,  gia in corso una firma", HttpContext.Response);
                }
            }
        }

        //'-- la funzione recupera dal parametro passato l'elemento 
        //'-- da stampare per poi chiamare la funzione specifica
        public static string GetHtmlData(string strDataElem, eProcurementNext.Session.ISession session)
        {
            string strToReturn;
            string[] vElem = null;
            string strsource = "";
            string strProtocol = "";
            Field objfield = null;

            string strSuffix = "";
            LibDbDictionary objDiz = new LibDbDictionary();
            strToReturn = "EMPTY";
            //'--controllo se ha la caratteristica Source
            string strSource = GetValueOfAttribElem(strDataElem, "source='");

            //'-- recupera l'elemento di cui si vuole il valore
            string strElem = GetValueOfAttribElem(strDataElem, "id='");
            //'-- suddivide l'elemento nelle sue componenti sezione.area.nome
            vElem = strElem.Split(".");

            string strSection = vElem[0];
            try
            {
                switch (strsource)
                {
                    case "auction":
                        //GetHtmlData = GetHtmlDataFromAuction( lIdmp , vElem , strDataElem ,ObjDictContenitore)		
                        break;
                    default:
                        //'-- se l'elemento richiesto è di base
                        if (strSection == "document")
                        {
                            switch (vElem[1].ToUpper())
                            {
                                case "NOW":
                                    string strFormat = GetValueOfAttribElem(strDataElem, "format='");
                                    //'strYearNow=year(now())
                                    //'strMonthNow=addZero(month(now()))
                                    //'strDayNow=addZero(day(now()))
                                    //'strTimeNow=time()
                                    //'strHourNow=addZero(hour(time()))
                                    //'strMinNow=addZero(minute(time()))
                                    //'strSecNow=addZero(second(time()))
                                    //' calcolo della data attuale in formato stringa aaaa-mm-ggThh:mm:ss
                                    //'strvalue=strYearNow & "-" & strMonthNow & "-" & strDayNow & "T" & strHourNow & ":" & strMinNow & ":" & strSecNow 
                                    Fld_Date objFieldData = new Fld_Date();
                                    objFieldData.Init(0, "Data", DateTime.Now, null, null, strFormat, false);
                                    strToReturn = objFieldData.TxtValue();
                                    break;
                                default:
                                    strToReturn = "";
                                    break;

                            }
                        }
                        else
                        {
                            switch (strSection.ToUpper())
                            {
                                case "CNV":
                                    //'--multilinguismo

                                    strToReturn = ApplicationCommon.CNV(vElem[1]);
                                    break;
                                case "SYS":
                                    //   '--variabile di sistema

                                    objfield = objDiz.GetFilteredFieldExt(CStr(vElem[1]), CStr(strSuffix), CLng(0), session, CStr(ApplicationCommon.Application["ConnectionString"]), CStr(""), CInt(0));
                                    if (!string.IsNullOrEmpty(CStr(objfield)))
                                    {
                                        strToReturn = objfield.TxtValue();
                                    }
                                    break;
                                case "LEGALPUB":
                                    //'-- dati della publicità legale di una azienda

                                    strToReturn = GetHtmlDataLegalPub(strDataElem);
                                    break;
                                case "NUMROW":
                                    //    '--ritorna il numero di righe di una sezione dettagli

                                    strToReturn = objDoc.Sections[vElem[1]].mp_numRec.ToString();
                                    break;
                                default:
                                    //'-- altrimenti chiede alla specifica sezione
                                    strToReturn = GetHtmlDataFromSection(strDataElem);
                                    break;

                            }
                        }
                        break;
                }
            }
            catch
            {

            }

            return strToReturn;

        }
        //'-- la funzione recupera da un determinato elemento passato il suo valore ritornandolo come stringa
        //'-- vElem = è un array che contiene in zero il nome della sezione, in 1 il nome dell'area
        //'-- strDataElem = è una stringa che contiene la chiamata completa fatta per l'elemento richiesto fatta in questo modo:
        //'-- id='SECTIONNAME.ATTRIB' 
        //'-- format='year' format='month-literal' ecc...
        public static string GetHtmlDataFromSection(string strDataElem)
        {
            string _GetHtmlDataFromSection = "";
            string strTempHtml = "";
            string[] aInfoElem = null;
            string strSectionName = "";
            string strAreaName = "";
            string strAttrib = "";
            string strFormat = "";
            string strTempHtmlCaption = "";
            string strTempHtmlDettagli = "";
            string strElem = "";
            //'-- recupera l'elemento di cui si vuole il valore
            strElem = GetValueOfAttribElem(strDataElem, "id='");
            //'--recupero nome Sezione

            aInfoElem = strElem.Split(".");
            strSectionName = aInfoElem[0];

            strTempHtml = "";
            try
            {
                switch (objDoc.Sections[strSectionName].TypeSection)
                {
                    case "CAPTION":
                        //'--sezione posizionale
                        //'--recupero nome attributo
                        strAttrib = "";
                        strAttrib = aInfoElem[1];

                        strFormat = GetValueOfAttribElem(strDataElem, "format='");

                        if (strFormat.Contains("T", StringComparison.Ordinal))
                        {
                            //'--forma tecnica

                            //strTempHtmlCaption = DOC_FieldTecnical(null, strAttrib)
                            throw new NotImplementedException("Codice ASP errato. Format T non gestita per la Caption. Verificare!");
                        }
                        else
                        {
                            //'--forma visuale

                            strTempHtmlCaption = DOC_FieldFormat(strSectionName, strAttrib, strFormat);
                        }
                        _GetHtmlDataFromSection = strTempHtmlCaption;
                        break;
                    case "DETTAGLI":

                        // '--sezione dettagli

                        strTempHtmlDettagli = GetHtmlData_Dettagli(strSectionName, strDataElem);
                        _GetHtmlDataFromSection = strTempHtmlDettagli;
                        break;
                    case "STATIC":

                        //'--sezione static	

                        break;
                    case "APPROVAL":
                        //'--sezione approvazione

                        strAreaName = aInfoElem[1];
                        if (strAreaName == "CYCLE")
                        {

                        }
                        if (strAreaName == "STEP")
                        {

                        }

                        break;
                    case "TOTAL":
                        break;

                }
            }
            catch
            {

            }
            return _GetHtmlDataFromSection;
        }
        //'-- dato il campo di una sezione CAPTION si ritorna il valore visuale
        public static string DOC_FieldFormat(string strSectionName, string strAttrib, string strFormat)
        {
            string strVisualValue = "";
            int strTypeAttrib = 0;
            string strTechValue = "";
            string strCont = "";
            try
            {
                //'--attributo di testata
                if (string.IsNullOrEmpty(strFormat))
                {
                    strVisualValue = objDoc.Sections[strSectionName].mp_Mod.Fields[strAttrib].TxtValue();
                }
                else
                {
                    //'--se un attributo di tipo DATETIME gestisco delle format specifiche
                    strTypeAttrib = objDoc.Sections[strSectionName].mp_Mod.Fields[strAttrib].getType();
                    if (strTypeAttrib == TIPOATTRIB_DATE || strTypeAttrib == TIPOATTRIB_DATE_EXTENDED)
                    {
                        strTechValue = DOC_FieldTecnical(strSectionName, strAttrib);
                        strVisualValue = Date_Format(strTechValue, strFormat);
                        // '--se non ha applicato nessuna formattazione applica quella di default sul campo
                        if (strTechValue == strVisualValue)
                        {
                            strVisualValue = objDoc.Sections[strSectionName].mp_Mod.Fields[strAttrib].TxtValue();
                        }

                    }
                }

            }
            catch
            {

            }
            return strVisualValue;
        }
        //'--effettua la formattazione custom per le date
        public static string Date_Format(string strTechValue, string strFormat)
        {
            string strTemp = "";
            switch (strFormat.ToLower())
            {
                case "year":


                    strTemp = Strings.Left(strTechValue, 4);
                    break;

                case "year-literal":


                    strTemp = Strings.Left(strTechValue, 4);

                    strTemp = ApplicationCommon.CNV("year-" + strTemp);
                    break;

                case "day":

                    strTemp = Strings.Mid(strTechValue, 9, 2);
                    break;

                case "day-literal":

                    strTemp = Strings.Mid(strTechValue, 9, 2);
                    strTemp = ApplicationCommon.CNV("day-" + strTemp);
                    break;

                case "month":


                    string strCont = Strings.Mid(strTechValue, 6, 2);
                    break;

                case "month-literal":
                    strTemp = Strings.Mid(strTechValue, 6, 2);
                    strTemp = ApplicationCommon.CNV("month-" + strTemp);
                    break;

                case "time":

                    strTemp = Strings.Right(strTechValue, 8);
                    break;

                case "timehh":

                    strTemp = Strings.Right(strTechValue, 8);
                    strTemp = Strings.Left(strTemp, 2);
                    break;
                case "timehhmm":

                    strTemp = Strings.Right(strTechValue, 8);

                    strTemp = Strings.Left(strTemp, 5);
                    break;
                default:

                    //  '--ritorno la forma visuale classica							
                    //
                    //'strVisualValue = strTechValue


                    Fld_Date objFieldData = new Fld_Date();
                    objFieldData.Init(0, "Data", strTechValue, null, null, strFormat, false);
                    strTemp = objFieldData.TxtValue();
                    break;

            }
            return strTemp;
        }
        //'--Restituisce html di una griglia secondo quanto indicato in strDataElem fatto come segue:
        //'--#DATADOC 
        //'--id='Commissione.griglia' 
        //'--filter='RuoloCommissione=15540'
        //'--orderby='ReceivedDataMsg'
        //'--col='NominativoCommissione' 
        //'--pagebreak='20'
        //'--commandbreak='@@@SALTOPAGINA@@@'
        //'--layout='list'
        //'--value='<li>Con nota prot.....del.....chiarimenti all’operatore economico<RAGSOC> in merito a <HISTORYMOTIVATION> ;</li>'
        //'--/#
        public static string GetHtmlData_Dettagli(string strSectionName, string strDataElem)
        {
            string strTemHtml;
            string objDictProperty;
            string strFilter;
            string strDeletedRow;
            string strOrderBy;
            string strColShow;
            string strColHide;
            string strShowCell;
            string strPageBreak;
            string strCommandBreak;
            string strReplace_Expression;
            string strLayoutGrid;
            string strTemplateRow;
            string strSortedRow;


            strFilter = "";
            strDeletedRow = "";
            strOrderBy = "";
            strColShow = "";
            strColHide = "";
            strPageBreak = "";
            strCommandBreak = "";
            strReplace_Expression = "";
            strLayoutGrid = "grid";
            strTemplateRow = "";
            strSortedRow = "";
            strShowCell = "";
            //'set objDictProperty = Server.CreateObject("Scripting.Dictionary")
            strTemHtml = "";
            dynamic[,] MatrixValue;
            MatrixValue = objDoc.Sections[strSectionName].mp_Matrix;
            Dictionary<string, Field> mp_Columns = new Dictionary<string, Field>();
            //'-- DETERMINO LA RICHIESTA DI FILTRO sulle righe

            if (Convert.ToBoolean(Strings.InStr(1, strDataElem, "filter='")))
            {
                strFilter = GetValueOfAttribElem(strDataElem, "filter='");
                strDeletedRow = GetDeletedRowsFromFilter(MatrixValue, objDoc.Sections[strSectionName].mp_Columns, strFilter);

            }
            //'-- DETERMINO LA RICHIESTA DI ordinamento delle righe sulle righe
            if (Convert.ToBoolean(Strings.InStr(1, strDataElem, "orderby='")))
            {
                strOrderBy = GetValueOfAttribElem(strDataElem, "orderby='");
                strSortedRow = GetSortedRowsFromCriteria(MatrixValue, objDoc.Sections[strSectionName].mp_Columns, strOrderBy, GetValueOfAttribElem(strDataElem, "sort='"));

            }
            //'-- DETERMINO LE COLONNE DA VISUALIZZARE
            if (Convert.ToBoolean(Strings.InStr(1, strDataElem, "col='")))
            {
                strColShow = GetValueOfAttribElem(strDataElem, "col='");
            }

            // '-- determino le colonne da nascondere
            if (Convert.ToBoolean(Strings.InStr(1, strDataElem, "colhide='")))
            {
                strColHide = GetValueOfAttribElem(strDataElem, "colhide='");
            }
            //'-- determino se ritornare una cella o tutta la griglia
            if (Convert.ToBoolean(Strings.InStr(1, strDataElem, "cell='")))
            {
                strShowCell = GetValueOfAttribElem(strDataElem, "cell='");
            }

            //'-- determino se è necessario spezzare la tabella in pagine ripetendo l'intestazione ed invocando su ogni rottura

            //'-- una rottura di pagina

            if (Convert.ToBoolean(Strings.InStr(1, strDataElem, "pagebreak='")))
            {
                strPageBreak = GetValueOfAttribElem(strDataElem, "pagebreak='");
            }

            //'-- determino il tipo di salto pagina; se nn presente inserisce div con salto altrimenti

            //'-- una direttiva @@@SALTOPAGINA@@@ che verrà poi risolta dopo

            if (Convert.ToBoolean(Strings.InStr(1, strDataElem, "commandbreak='")))
            {
                strCommandBreak = GetValueOfAttribElem(strDataElem, "commandbreak='");
            }
            //'-- ricavo se presente una replace da applicare al valore di una o più cella/e
            //'-- fatta come: <ListCols>;<find1>@@@<replace1>-@-......-@-<findN>@@@<replaceN> dove
            //'-- <ListCols è la lista delle colonne su cui applicare la replace col1,col2,...,colN
            // '-- <find1>@@@<replace1>-@-......-@-<findN>@@@<replaceN> è la lista delle replace da applicare

            if (Convert.ToBoolean(Strings.InStr(1, strDataElem, "replace_expression='")))
            {
                strReplace_Expression = GetValueOfAttribElem(strDataElem, "replace_expression='");
            }

            //'--verifico il layout che devo restituire per la griglia

            if (Convert.ToBoolean(Strings.InStr(1, strDataElem, "layout='")))
            {
                strLayoutGrid = GetValueOfAttribElem(strDataElem, "layout='");
            }

            //'--RECUPERO HTML GRIGLIA

            switch (strLayoutGrid.ToLower())
            {
                //'case "list" 
                //'--restituisce le righe della griglia in una lista 
                //'	strTemHtml = GetHtmlData_Dettagli_LIST(  strSectionName, strFilter, strOrderBy, strColShow, strColHide, strPageBreak , strCommandBreak , strReplace_Expression )

                //'case "comma"		
                //'--restituisce le righe della griglia separate da una virgola
                //'	strTemHtml = GetHtmlData_Dettagli_COMMA(  strSectionName, strFilter, strOrderBy, strColShow, strColHide, strPageBreak , strCommandBreak , strReplace_Expression  )

                case "custom":
                    //'--ci sarà una proprietà pattern che contiene una costante con le colonne da risolvere (<COL>)
                    if (Convert.ToBoolean(Strings.InStr(1, strDataElem, "value='")))
                    {
                        strTemplateRow = GetValueOfAttribElem(strDataElem, "value='");
                    }
                    //'--restituisce per ogni riga il pattern costante passato risolto delle colonne indicate

                    strTemHtml = GetHtmlData_Dettagli_CUSTOM(strSectionName, strDeletedRow, strSortedRow, strColShow, strColHide, strShowCell, strPageBreak, strCommandBreak, strReplace_Expression, strTemplateRow);

                    break;
                default:
                    //'--restituisce una griglia rappresentata con una TABELLA

                    strTemHtml = GetHtmlData_Dettagli_TABLE(strSectionName, strDeletedRow, strSortedRow, strColShow, strColHide, strShowCell, strPageBreak, strCommandBreak, strReplace_Expression, strTemplateRow);
                    break;
            }
            return strTemHtml;
        }
        //'--restituisce una griglia rappresentata con una TABELLA
        //'-- strSectionName = NOME SEZIONE
        //'-- strDeletedRow = righe da non disegnare
        //'-- strRowsSort = ordine delle righe
        //'-- strColShow = col da visualizzare
        //'-- strColHide = col da nascondere
        //'-- strShowCell = indice riga  della cella da ritornare
        //'-- strPageBreak = quando fare il salto pagina
        //'-- strCommandBreak = direttiva per il salto pagina
        //'-- strReplace_Expression = replace da applicare alle colonne nella forma
        //'-- strTemplateRow = template di riga da utilizzare per disegnare la griglia:VERTICALE disegna ogni riga in verticale col=valore
        public static string GetHtmlData_Dettagli_TABLE(string strSectionName, string strDeletedRow, string strRowsSort, string strColShow, string strColHide, string strShowCell, string strPageBreak, string strCommandBreak, string strReplace_Expression, string strTemplateRow)
        {
            string strGrid = "";
            dynamic[,] MatrixValue;
            int NumRow = 0;
            int NumCol = 0;
            int indRow = 0;
            int indCol = 0;
            int indiceRiga = 0;
            bool bShowCol = false;
            Field objField = null;
            string strTechValue = "";
            string strVisualValue = "";
            string strClassCell = "";

            //'--CONTROLLO SE CI SONO CAPTION CUSTOM DA USARE PER LE COLONNE
            //'--e le memorizzo in una MAPPA mappaKeyCaption
            string[] aInfoCol;
            string[] aInfoKeyCol;
            Dictionary<string, string> mappaKeyCaption;
            mappaKeyCaption = new Dictionary<string, string>();
            string strCopyColumnsShow = "";
            int k = 0;
            aInfoCol = strColShow.Split(",");
            for (k = 0; k < aInfoCol.Length - 1; k++)
            {
                aInfoKeyCol = aInfoCol[k].Split(";");
                if (aInfoKeyCol.Length - 1 > 0)
                {
                    mappaKeyCaption.Add(CStr(aInfoKeyCol[0]), ApplicationCommon.CNV(aInfoKeyCol[1]));
                }
                //'--costruisco la lista solo dei nomi di colonna da visualizzare
                if (string.IsNullOrEmpty(strCopyColumnsShow))
                {
                    strCopyColumnsShow = aInfoKeyCol[0];
                }
                else
                {
                    strCopyColumnsShow = strCopyColumnsShow + "," + aInfoKeyCol[0];
                }

            }
            strColShow = strCopyColumnsShow;
            //'--costruisco la lista di replace da applicare alle colonne
            //'--memorizzate in una MAPPA objmappaReplace
            string[] aInfoReplace;
            string strColReplace = "";
            string[] aInfoListaReplace;
            string[] aReplace;
            string[] VetPageBreak = null;

            Dictionary<string, string> objmappaReplace;
            objmappaReplace = new Dictionary<string, string>();
            if (!string.IsNullOrEmpty(strReplace_Expression))
            {
                aInfoReplace = strReplace_Expression.Split(";");
                //'--ricavo le colonne su cui applicare le replace
                strColReplace = "," + aInfoReplace[0] + ",";
                //'--ricavo la lista di replace

                aInfoListaReplace = aInfoReplace[1].Split("-@-");
                for (k = 0; k < aInfoListaReplace.Length - 1; k++)
                {
                    aReplace = aInfoListaReplace[k].Split("@@@");
                    objmappaReplace.Add(CStr(aReplace[0]), CStr(aReplace[1]));
                }
                //'Response.Write "strColReplace=" & strColReplace
            }
            //'--CONSERVO SE DEVO VISUALIZZARE SOLO UNA CELLA 
            int iCellR = 0;
            if (!string.IsNullOrEmpty(strShowCell))
            {
                iCellR = CInt(strShowCell);
            }
            int CountRow = -1;


            //'dim  DrawCaption
            //
            //'DrawCaption = true
            //
            bool bPrintRow = false;
            string strTempHtml = "";
            NumRow = objDoc.Sections[strSectionName].mp_numRec - 1;
            NumCol = objDoc.Sections[strSectionName].mp_Columns.Count;
            MatrixValue = objDoc.Sections[strSectionName].mp_Matrix;
            if (IsEmpty(MatrixValue))
            {
                NumRow = -1;
            }
            //'-- determina le righe da stampare ed il loro ordine
            string[] vetRowsSort = null;
            if (!string.IsNullOrEmpty(strRowsSort))
            {
                vetRowsSort = strRowsSort.Split("#");
                NumRow = vetRowsSort.Length - 1;
            }
            //'-- recupera se presente le interruzioni di pagina previste per la tabella
            int numPage = 0;
            bool bBreak = false;
            int iPageRow = 0;
            int iPage = 0;
            if (!string.IsNullOrEmpty(strPageBreak))
            {
                VetPageBreak = strPageBreak.Split(",");
                numPage = VetPageBreak.Length - 1;
                bBreak = true;
                iPageRow = 0;
            }
            else
            {
                numPage = 0;
                bBreak = false;
            }
            iPage = 0;
            //'--SETTO SALTO PAGINA DI DEFAULT
            if (string.IsNullOrEmpty(strCommandBreak))
            {
                strCommandBreak = $@"<div style=""page-break-after : always""  ></div>";
            }
            //'--APRO TABELLA
            if (string.IsNullOrEmpty(strShowCell))
            {
                strGrid = $@"<table class=""GridPrintProducts"">";
            }
            //'--CICLO SULLE RIGHE
            for (indRow = -1; indRow < NumRow; indRow++)
            {
                //'-- se le righe sono ordinate le prendo nell'ordine richiesto
                if (!string.IsNullOrEmpty(strRowsSort) && indRow != -1)
                {
                    indiceRiga = CInt(vetRowsSort[indRow]);
                }
                else
                {
                    indiceRiga = indRow;
                }
                bPrintRow = false;
                //'-- se la riga non è da cancellare allora la disegnamo
                if (Strings.InStr(1, strDeletedRow, "," + indiceRiga + ",") == 0)
                {
                    bPrintRow = true;
                    CountRow = CountRow + 1;
                }
                //'-- se ho chiesto di stampare una cella verifico se è la riga corretta
                if (!string.IsNullOrEmpty(strShowCell))
                {
                    if (CountRow != iCellR)
                    {
                        bPrintRow = false;
                    }
                }
                if (bPrintRow == true)
                {
                    //'-- se è richiesta SALTO PAGINA
                    if (bBreak)
                    {
                        iPageRow = iPageRow + 1;
                        if (iPageRow > CInt(VetPageBreak[iPage]))
                        {
                            indiceRiga = -1;// '-- setto l'indice di riga della testata
                            //'-- riporto indietro di una riga il ciclo per stamparla successivamente

                            indRow = indRow - 1;

                            iPageRow = 0;
                            iPage = iPage + 1;
                            if (iPage > numPage)
                            {
                                iPage = numPage;
                            }
                            //'-- CHIUDO  TABELLA
                            strGrid = strGrid + "</table>" + Environment.NewLine;
                            //'-- inserisco il salto pagina
                            strGrid = strGrid + strCommandBreak;
                            //'-- RIAPRO TABELLA
                            strGrid = strGrid + $@"<table class=""GridPrintProducts"" >";
                            //'DrawCaption = true 
                        }
                    }
                    //'--APRO UNA NUOVA RIGA
                    if (string.IsNullOrEmpty(strShowCell) && string.IsNullOrEmpty(strTemplateRow))
                    {
                        strGrid = strGrid + $@"<tr class=""CellRow"">";
                    }
                    //'if strShowCell = "" then strGrid=strGrid & "<tr class="""">"
                    indCol = 1;

                    //'--CICLO SULLE COLONNE

                    while (indCol <= NumCol)
                    {
                        objField = objDoc.Sections[strSectionName].mp_Columns.ElementAt(indCol - 1).Value;
                        string strAttrib = objField.Name;
                        //'-- controlla se la colonna è da visualizzare 
                        if (!string.IsNullOrEmpty(strColShow))
                        {
                            //'--controllo se ho indicato la visualizzazione di colonne esplicite
                            bShowCol = false;
                            if ((("," + strColShow + ",").ToUpper()).Contains(("," + strAttrib + ",").ToUpper(), StringComparison.Ordinal))
                            {
                                bShowCol = true;
                            }
                        }
                        else
                        {
                            //'--controllo se è da nascondere
                            if (!string.IsNullOrEmpty(strColHide))
                            {
                                bShowCol = true;
                                if ((("," + strColHide + ",").ToUpper()).Contains(("," + strAttrib + ",").ToUpper(), StringComparison.Ordinal))
                                {
                                    bShowCol = false;
                                }
                            }
                            else
                            {
                                bShowCol = true;
                            }
                        }

                        if (bShowCol)
                        {
                            //'--DISEGNO INTESTAZIONE
                            if (indiceRiga == -1)
                            {
                                if (string.IsNullOrEmpty(strTemplateRow))
                                {
                                    //'DrawCaption =  false
                                    if (string.IsNullOrEmpty(strShowCell))
                                    {
                                        strGrid = strGrid + $@"<td class=""CellIntestGrid"">";
                                        //'--caption della colonna
                                        if (mappaKeyCaption.ContainsKey(strAttrib))
                                        {
                                            strGrid = strGrid + mappaKeyCaption[strAttrib];
                                        }
                                        else
                                        {
                                            strGrid = strGrid + DOC_FieldRow_Label(strSectionName, strAttrib);
                                        }
                                        strGrid = strGrid + "</td>" + Environment.NewLine;
                                    }
                                }
                            }
                            else
                            {
                                strClassCell = "CellGridPrintProducts";
                                //'--se si tratta di un attributo numerico cambio classe di stile	
                                if (objField.getType() == TIPOATTRIB_NUMBER)
                                {
                                    strClassCell = "CellGridNumericPrintProducts";
                                }
                                if (strTemplateRow == "VERTICALE")
                                {
                                    //'--metto la cella della caption della colonna prima del valore
                                    strGrid = strGrid + $@"<tr class=""CellRow""><td class=""CellIntestGrid"">";
                                    //'--caption della colonna
                                    if (mappaKeyCaption.ContainsKey(strAttrib))
                                    {
                                        strGrid = strGrid + mappaKeyCaption[strAttrib];
                                    }
                                    else
                                    {
                                        strGrid = strGrid + DOC_FieldRow_Label(strSectionName, strAttrib);

                                    }
                                    strGrid = strGrid + "</td>" + Environment.NewLine;
                                }
                                if (string.IsNullOrEmpty(strShowCell))
                                {
                                    strGrid = strGrid + $@"<td class=""" + strClassCell + $@""">";
                                }
                                //'--valore visuale della colonna
                                strTechValue = "";
                                strTechValue = MatrixValue[indCol - 1, indRow];
                                objField.Value = strTechValue;
                                strVisualValue = "";
                                strVisualValue = objField.TxtValue();
                                //'--se richiesto applico le replace alla colonna corrente

                                if ((("," + strColReplace + ",").ToUpper()).Contains(("," + strAttrib + ",").ToUpper(), StringComparison.Ordinal))
                                {
                                    foreach (string strKey in objmappaReplace.Keys)
                                    {
                                        strVisualValue = strVisualValue.Replace(strKey, objmappaReplace[strKey]);
                                    }
                                }
                                strGrid = strGrid + strVisualValue;
                                if (string.IsNullOrEmpty(strShowCell))
                                {
                                    strGrid = strGrid + "</td>" + Environment.NewLine;
                                }
                                //'if strTemplateRow="VERTICALE" then
                                //'--chiudo la riga per ogni colonna
                                //'	strGrid=strGrid & "</tr>" & vbCrLf 
                                //'end if
                            }
                        }
                        indCol = indCol + 1;
                    }
                    //'--CHIUDO LA RIGA CORRENTE
                    if (string.IsNullOrEmpty(strShowCell) && string.IsNullOrEmpty(strTemplateRow))
                    {
                        strGrid = strGrid + "</tr>" + Environment.NewLine;
                    }
                }
            }
            //'--CHIUDO LA TABELLA
            if (string.IsNullOrEmpty(strShowCell))
            {
                strGrid = strGrid + "</table>" + Environment.NewLine;
            }
            return strGrid;
        }
        //'--restituisce una griglia rappresentata con una DIV e risolvendo un template per ogni riga
        //'-- strSectionName = NOME SEZIONE
        //'-- strDeletedRow = righe da non disegnare
        //'-- strRowsSort = ordine delle righe
        //'-- strColShow = col da visualizzare
        //'-- strColHide = col da nascondere
        //'-- strShowCell = indice riga  della cella da ritornare
        //'-- strPageBreak = quando fare il salto pagina
        //'-- strCommandBreak = direttiva per il salto pagina
        //'-- strReplace_Expression = replace da applicare alle colonne nella forma
        //'-- strTemplateRow = template di riga da utilizzare per disegnare la griglia
        public static string GetHtmlData_Dettagli_CUSTOM(string strSectionName, string strDeletedRow, string strRowsSort, string strColShow, string strColHide, string strShowCell, string strPageBreak, string strCommandBreak, string strReplace_Expression, string strTemplateRow)
        {
            string strGrid = "";
            dynamic[,] MatrixValue = null;
            int NumRow = 0;
            int NumCol = 0;
            int indRow = 0;
            int indCol = 0;
            int indiceRiga = 0;
            bool bShowCol = false;
            Field objField;
            string strTechValue = "";
            string strVisualValue = "";
            //'--CONTROLLO SE CI SONO CAPTION CUSTOM DA USARE PER LE COLONNE
            //'--e le memorizzo in una MAPPA mappaKeyCaption
            string[] aInfoCol;
            dynamic aInfoKeyCol;
            Dictionary<string, string> mappaKeyCaption;
            mappaKeyCaption = new Dictionary<string, string>();
            string strCopyColumnsShow = "";
            int k = 0;
            aInfoCol = strColShow.Split(",");
            for (k = 0; k < aInfoCol.Length - 1; k++)
            {
                aInfoKeyCol = aInfoCol[k].Split(";");
                if (aInfoKeyCol.Length - 1 > 0)
                {
                    mappaKeyCaption.Add(CStr(aInfoKeyCol[0]), ApplicationCommon.CNV(aInfoKeyCol[1]));
                }
                //'--costruisco la lista solo dei nomi di colonna da visualizzare
                if (string.IsNullOrEmpty(strCopyColumnsShow))
                {
                    strCopyColumnsShow = aInfoKeyCol[0];
                }
                else
                {
                    strCopyColumnsShow = strCopyColumnsShow + "," + aInfoKeyCol[0];
                }
            }
            strColShow = strCopyColumnsShow;
            //'--costruisco la lista di replace da applicare alle colonne
            //'--memorizzate in una MAPPA objmappaReplace
            string[] aInfoReplace;
            string strColReplace = "";
            string[] aInfoListaReplace;
            dynamic aReplace;
            Dictionary<string, string> objmappaReplace;
            objmappaReplace = new Dictionary<string, string>();
            if (!string.IsNullOrEmpty(strReplace_Expression))
            {
                aInfoReplace = strReplace_Expression.Split(";");
                //'--ricavo le colonne su cui applicare le replace
                strColReplace = "," + aInfoReplace[0] + ",";
                //'--ricavo la lista di replace
                aInfoListaReplace = aInfoReplace[1].Split("-@-");
                for (k = 0; k < aInfoListaReplace.Length - 1; k++)
                {
                    aReplace = aInfoListaReplace[k].Split("@@@");
                    objmappaReplace.Add(CStr(aReplace[0]), CStr(aReplace[1]));
                }
                //'Response.Write "strColReplace=" & strColReplace
            }
            bool bPrintRow = false;
            string strTempHtml = "";

            NumRow = objDoc.Sections[strSectionName].mp_numRec - 1;
            NumCol = objDoc.Sections[strSectionName].mp_Columns.Count;
            MatrixValue = objDoc.Sections[strSectionName].mp_Matrix;
            if (IsEmpty(MatrixValue))
            {
                NumRow = -1;
            }
            //'-- determina le righe da stampare ed il loro ordine
            string[] vetRowsSort = null;
            if (string.IsNullOrEmpty(strRowsSort))
            {
                vetRowsSort = strRowsSort.Split("#");
                NumRow = vetRowsSort.Length - 1;
            }
            //'-- recupera se presente le interruzioni di pagina previste per la tabella
            int numPage = 0;
            bool bBreak = false;
            int iPageRow = 0;
            int iPage = 0;
            string[] VetPageBreak = null;
            if (!string.IsNullOrEmpty(strPageBreak))
            {
                VetPageBreak = strPageBreak.Split(",");
                numPage = VetPageBreak.Length - 1;
                bBreak = true;
                iPageRow = 0;
            }
            else
            {
                numPage = 0;
                bBreak = false;
            }
            iPage = 0;
            //'--SETTO SALTO PAGINA DI DEFAULT
            if (string.IsNullOrEmpty(strCommandBreak))
            {
                strCommandBreak = $@"<DIV style=""page-break-after : always""  ></DIV>";
            }
            //'--APRO DIV

            strGrid = $@"<DIV class=""PrintDettagliCustom"">";
            //'--CICLO SULLE RIGHE

            for (indRow = 0; indRow < NumRow; indRow++)
            {
                //'-- se le righe sono ordinate le prendo nell'ordine richiesto
                if (!string.IsNullOrEmpty(strRowsSort))
                {
                    indiceRiga = CInt(vetRowsSort[indRow]);
                }
                else
                {
                    indiceRiga = indRow;
                }
                bPrintRow = false;
                //'-- se la riga non è da cancellare allora la disegnamo

                if (Strings.InStr(1, strDeletedRow, "," + indiceRiga + ",") == 0)
                {
                    bPrintRow = true;

                }
                if (bPrintRow == true)
                {
                    //'--INZIALIZZO TEMPLATE DI RIGA
                    string strCurrentTemplateRow = strTemplateRow;
                    //'-- se è richiesta SALTO PAGINA
                    if (bBreak)
                    {
                        iPageRow = iPageRow + 1;
                        if (iPageRow > CInt(VetPageBreak[iPage]))
                        {
                            indiceRiga = -1;// '-- setto l'indice di riga della testata
                            //'-- riporto indietro di una riga il ciclo per stamparla successivamente
                            indRow = indRow - 1;

                            iPageRow = 0;
                            iPage = iPage + 1;
                            if (iPage > numPage)
                            {
                                iPage = numPage;
                            }
                            //'-- CHIUDO  DIV
                            strGrid = strGrid + "</DIV>" + Environment.NewLine;

                            //'-- inserisco il salto pagina

                            strGrid = strGrid + strCommandBreak;

                            //'-- RIAPRO DIV

                            strGrid = strGrid + $@"<DIV class=""PrintDettagliCustom"">";


                        }
                    }
                    indCol = 1;
                    //'--CICLO SULLE COLONNE
                    while (indCol <= NumCol)
                    {
                        objField = objDoc.Sections[strSectionName].mp_Columns.ElementAt(indCol - 1).Value;
                        string strAttrib = objField.Name;
                        //'-- controlla se la colonna è da visualizzare 
                        if (!string.IsNullOrEmpty(strColShow))
                        {
                            //'--controllo se ho indicato la visualizzazione di colonne esplicite
                            bShowCol = false;
                            if (("," + strColShow + ",").ToUpper().Contains(("," + strAttrib + ",").ToUpper(), StringComparison.Ordinal))
                            {
                                bShowCol = true;
                            }
                        }
                        else
                        {
                            //'--altrimenti faccio la visualizzazione di tute le colonne

                            bShowCol = true;
                        }
                        if (bShowCol)
                        {
                            //'--valore visuale della colonna

                            strTechValue = "";
                            strTechValue = MatrixValue[indCol - 1, indRow];
                            objField.Value = strTechValue;
                            strVisualValue = "";
                            strVisualValue = objField.TxtValue();
                            // '--se richiesto applico le replace alla colonna corrente

                            if (("," + strColReplace + ",").ToUpper().Contains(("," + strAttrib + ",").ToUpper(), StringComparison.Ordinal))
                            {
                                foreach (string strKey in objmappaReplace.Keys)
                                {
                                    strVisualValue = strVisualValue.Replace(strKey, objmappaReplace[strKey]);
                                }
                            }
                            strCurrentTemplateRow = strCurrentTemplateRow.Replace("<" + (strAttrib).ToUpper() + ">", strVisualValue);
                        }

                        indCol = indCol + 1;

                    }
                    //'--ho risolto tutte le colonne e passo alla riga successiva

                    strGrid = strGrid + strCurrentTemplateRow;
                }
            }
            //'--CHIUDO LA DIV

            strGrid = strGrid + "</DIV>" + Environment.NewLine;
            return strGrid;
        }
        public static string GetValueOfAttribElem(string strDataElem, string attr)
        {
            string GetValueOfAttribElem = "";

            int iEls = Strings.InStr(1, strDataElem, attr);

            if (iEls > 0)
            {
                int iEle = Strings.InStr(iEls + attr.Length, strDataElem, "'");

                GetValueOfAttribElem = Strings.Mid(strDataElem, iEls + attr.Length, iEle - iEls - attr.Length);
            }

            return GetValueOfAttribElem;
        }
        public static string GetHtmlDataLegalPub(string strDataElem)
        {
            //'--recupero nome Sezione
            string[] aInfoElem;
            string strElem = "";
            string strSectionName = "";
            string strAttribSource = "";
            string strTechValue = "";
            string strAttrib = "";
            string strTempHTML = "";
            string strFields = "";
            string strSep = "";
            string strQuery = "";
            TSRecordSet? rsAzi = null;
            TSRecordSet? objRsAzi = null;
            TSRecordSet? objRsAziFromView = null;

            //CTLDOCOBJ.Document objDB;
            //'-- recupera l'elemento di cui si vuole il valore
            strElem = GetValueOfAttribElem(strDataElem, "id='");
            //'-- recupero proprietà fields dal tag che indica le colonne che voglio recuperare

            strFields = "";
            strFields = GetValueOfAttribElem(strDataElem, "fields='"); //'i nomi delle colonne fields separati da ","
            //'-- recupero proprietà sep dal tag che indica il separatore da utilizzare tra i fields

            strSep = " ";

            strSep = GetValueOfAttribElem(strDataElem, "sep='");
            aInfoElem = strElem.Split(".");
            strSectionName = aInfoElem[1];

            //'--recupero attributo sorgente dei dati per recuperare rs azienda
            strAttribSource = aInfoElem[2];
            //'--recupero se presente colonn da visualizzare
            if (aInfoElem.Length - 1 == 3)
            {
                strAttrib = aInfoElem[3];
            }

            strTechValue = DOC_FieldTecnical(strSectionName, strAttribSource);
            CommonDbFunctions cdf = new CommonDbFunctions();
            if (!string.IsNullOrEmpty(strTechValue))
            {
                rsAzi = cdf.GetRSReadFromQuery_(CStr("select * from aziende where idazi = " + CLng(strTechValue)), CStr(ApplicationCommon.Application["ConnectionString"]));
                //'--se presente recupero info azienda da una vista
                strQuery = "select * from DASHBOARD_VIEW_AZIENDE where idazi=" + CLng(strTechValue);
                try
                {
                    objRsAziFromView = cdf.GetRSReadFromQuery_(CStr(strQuery), ApplicationCommon.Application["ConnectionString"]);
                }
                catch
                {
                    objRsAzi = rsAzi;
                }
                objRsAzi = objRsAziFromView;
                strTempHTML = "";
                if (string.IsNullOrEmpty(strFields))
                {
                    if (!IsNull(GetValueFromRS(rsAzi.Fields[strAttrib])))
                    {
                        strTempHTML = GetValueFromRS(rsAzi.Fields[strAttrib]);
                    }
                    else
                    {
                        strTempHTML = "";
                    }
                    //'strTempHTML=rsAzi.fields( strAttrib )
                }
                else
                {
                    string[] aFields = strFields.Split(",");
                    int nNumCol = aFields.Length;
                    strTempHTML = strTempHTML + GetValueFromRS(objRsAzi.Fields[aFields[0]]);
                    string strHtmlCover = "";
                    for (int nIndCol = 1; nIndCol < nNumCol; nIndCol++)
                    {
                        strHtmlCover = strHtmlCover + strSep + GetValueFromRS(objRsAzi.Fields[aFields[nIndCol]]);
                    }

                }

            }
            return strTempHTML;
        }
        //'-- la funzione ritorna una stringa contenete tutte le righe che non rispettano la condizione passata
        //'-- gli indici delle righe sono racchiusi fra parentesi quadre esempio: "[1][12]"
        public static string GetDeletedRowsFromFilter(dynamic[,] MatriceProdotti, Dictionary<string, Field> cols, string strfilter)
        {
            string strToEval;

            int nR = MatriceProdotti.Length - 2;
            int nC = cols.Count();
            string _GetDeletedRowsFromFilter = "";
            //'-- per ogni riga
            for (int i = 0; i < nR; i++)
            {
                //'-- sostituisco i valori delle colonne nella formula 
                strToEval = strfilter.ToUpper();
                for (int c = 1; c < nC; c++)
                {
                    if (string.IsNullOrEmpty(cols.ElementAt(c - 1).Value.Name) && (strToEval.Contains(cols.ElementAt(c - 1).Value.Name.ToUpper(), StringComparison.Ordinal)))
                    {
                        string strVal = MatriceProdotti[c - 1, i];
                        int pT = Strings.InStr(1, strVal, "#~");
                        if (pT > 0)
                        {
                            strVal = Strings.Left(strVal, pT - 1);//'-- prende solo il codice in caso di domini chiudi e gerarchici
                        }
                        strToEval = strToEval.Replace((cols.ElementAt(c - 1).Value.Name).ToUpper(), strVal);
                    }
                }
                //'-- valuto il filtro con i valori sostituiti e se non supera il test lo inserisco fra gli eliminati
                try
                {
                    if (!BasicDocument.Eval(strToEval))
                    {
                        _GetDeletedRowsFromFilter = _GetDeletedRowsFromFilter + "," + i + ",";
                    }
                }
                catch
                {

                }


                //'Response.Write "riga" & i & " - valori espressione: " & strToEval & "<br>" ' & " - valutazione=" & eval(strToEval) & "<br>"


            }
            return _GetDeletedRowsFromFilter;
        }
        //'-- la funzione ritorna una stringa con l'indice delle righe ordinato secondo il criterio richiesto
        //'-- gli indici delle righe sono separate da # esempio : "1#3#2"
        public static string GetSortedRowsFromCriteria(dynamic[,] MatriceProdotti, Dictionary<string, Field> cols, string strOrderby, string strVerso)
        {
            string strToEval = "";
            int[] VetKey = null;

            int nR = MatriceProdotti.Length - 2;
            int nC = cols.Count();
            string _GetSortedRowsFromCriteria = "";

            Array.Resize(ref VetKey, nR);
            string[] ArrayDtzNome = null;
            //'-- per ogni riga
            for (int i = 1; i < nR; i++)
            {
                //'-- mi costruisco una stringa contente la chiave di ordinamento
                strToEval = strOrderby.ToUpper();
                for (int c = 1; c < nC; c++)
                {
                    if (!string.IsNullOrEmpty(ArrayDtzNome[c]) && strToEval.Contains(cols.ElementAt(c - 1).Value.Name.ToUpper(), StringComparison.Ordinal))
                    {
                        string strVal = MatriceProdotti[c, i];
                        int pT = Strings.InStr(1, strVal, "#~");
                        if (pT > 0)
                        {
                            strVal = Strings.Left(strVal, pT - 1);//'-- prende solo il codice in caso di domini chiudi e gerarchici
                        }
                        //'-- per i numerici si allinea a destra il valore

                        //'if ArrayTipoMemCol(c) = clng(TIPOMEM_LONG) then 
                        if (CInt(cols.ElementAt(c - 1).GetType()) == TIPOATTRIB_NUMBER)
                        {
                            if (cols.ElementAt(c - 1).Value.numDecimal == 0)
                            {
                                //'--numeri senza decimali
                                strVal = Strings.Right("00000000000000000000" + strVal, 20);
                            }
                            else
                            {
                                //'--numeri con decimali

                                strVal = strVal.Replace(",", ".");
                                int p = Strings.InStr(1, strVal, ".");
                                if (p > 0)
                                {
                                    strVal = Strings.Left("000000000000000000000", 20 - p + 1) + strVal;
                                }
                                else
                                {
                                    strVal = Strings.Right("00000000000000000000" + strVal, 20);
                                }
                            }
                        }
                        strToEval = strToEval.Replace((cols.ElementAt(c - 1).Value.Name).ToUpper(), strVal);
                    }
                }
                VetKey[i] = CInt(strToEval);

            }
            _GetSortedRowsFromCriteria = BubbleSortNumbers(VetKey, strVerso);
            return _GetSortedRowsFromCriteria;
        }
        public static string BubbleSortNumbers(int[] iArray, string strVerso)
        {
            int lLoop1 = 0;
            int lLoop2 = 0;
            int lTemp = 0;
            int[] index = null;
            int nR = iArray.Length - 1;
            for (lLoop1 = 0; lLoop1 < nR; lLoop1++)
            {
                index[lLoop1] = lLoop1;
            }
            for (lLoop1 = nR; lLoop1 < 1; lLoop1--)
            {
                for (lLoop2 = 2; lLoop2 < lLoop1; lLoop2++)
                {
                    if (iArray[lLoop2 - 1] > iArray[lLoop2])
                    {
                        lTemp = iArray[lLoop2 - 1];
                        iArray[lLoop2 - 1] = iArray[lLoop2];
                        iArray[lLoop2] = lTemp;
                        lTemp = index[lLoop2 - 1];
                        index[lLoop2 - 1] = index[lLoop2];
                        index[lLoop2] = lTemp;
                    }
                }
            }
            string _BubbleSortNumbers = "0";
            if (strVerso == "desc")
            {
                for (lLoop1 = nR; lLoop1 < 1; lLoop1--)
                {
                    _BubbleSortNumbers = _BubbleSortNumbers + "#" + index[lLoop1];
                }
            }
            else
            {
                for (lLoop1 = 1; lLoop1 < nR; lLoop1++)
                {
                    _BubbleSortNumbers = _BubbleSortNumbers + "#" + index[lLoop1];
                }
            }
            return _BubbleSortNumbers;
        }
        //'--restituisce una griglia rappresentata con una TABELLA
        //'-- PaginaCorrente = pagina da stampare
        //'-- strSectionName = NOME SEZIONE
        //'-- strDeletedRow = righe da non disegnare
        //'-- strRowsSort = ordine delle righe
        //'-- strColShow = col da visualizzare
        //'-- strColHide = col da nascondere
        //'-- strShowCell = indice riga  della cella da ritornare
        //'-- NumLineeForPage = numero linee da stampare per la pagina
        //'-- strCommandBreak = direttiva per il salto pagina
        //'-- strReplace_Expression = replace da applicare alle colonne nella forma
        //'-- strTemplateRow = template di riga da utilizzare per disegnare la griglia:
        //                     VERTICALE disegna ogni riga in verticale col=valore
        //                     ""(stringa vuota) disegna ogni riga per la griglia in ORIZZONTALE    
        //'-- NumLineeStampate = numero linee stampate nella pagina
        //'-- IndiceLastCol = indice di colonna da cui devo ripartire
        public static string GetHtmlData_Dettagli_TABLE_PERPAGINA(int PaginaCorrente, string strSectionName, string strDeletedRow, string strRowsSort, string strColShow, string strColHide, string strShowCell, int NumLineeForPage, string strCommandBreak, string strReplace_Expression, string strTemplateRow, ref int NumLineeStampate, ref int nNumLineeCurrent, int NumColDisplay, ref int LastRowDiplayed, ref int IndiceLastCol)
        {
            string strGrid = "";
            dynamic[,] MatrixValue;
            int NumRow = 0;
            int NumCol = 0;
            int indRow = 0;
            int indCol = 0;
            int indiceRiga = 0;
            bool bShowCol = false;
            Field objField;
            string strTechValue = "";
            string strVisualValue = "";
            string strClassCell = "";
            nNumLineeCurrent = 0;


            //'--CONTROLLO SE CI SONO CAPTION CUSTOM DA USARE PER LE COLONNE
            //'--e le memorizzo in una MAPPA mappaKeyCaption
            string[] aInfoCol;
            string[] aInfoKeyCol;
            Dictionary<string, string> mappaKeyCaption;
            mappaKeyCaption = new Dictionary<string, string>();

            string strCopyColumnsShow = "";
            int k = 0;
            aInfoCol = strColShow.Split(",");
            for (k = 0; k <= aInfoCol.Length - 1; k++)
            {
                aInfoKeyCol = aInfoCol[k].Split(";");
                if (aInfoKeyCol.Length - 1 > 0)
                {
                    mappaKeyCaption.Add(CStr(aInfoKeyCol[0]), ApplicationCommon.CNV(aInfoKeyCol[1]));
                }
                //'--costruisco la lista solo dei nomi di colonna da visualizzare
                if (string.IsNullOrEmpty(strCopyColumnsShow))
                {
                    strCopyColumnsShow = aInfoKeyCol[0];
                }
                else
                {
                    strCopyColumnsShow = strCopyColumnsShow + "," + aInfoKeyCol[0];
                }
            }
            strColShow = strCopyColumnsShow;
            //'Response.Write "listacolshow=" & strColShow & "<br>"


            //'--costruisco la lista di replace da applicare alle colonne
            //'--memorizzate in una MAPPA objmappaReplace
            string[] aInfoReplace = null;
            string strColReplace = "";
            string[] aInfoListaReplace = null;
            string[] aReplace = null;
            Dictionary<string, string> objmappaReplace;
            objmappaReplace = new Dictionary<string, string>();
            if (!string.IsNullOrEmpty(strReplace_Expression))
            {
                aInfoReplace = strReplace_Expression.Split(";");
                //'--ricavo le colonne su cui applicare le replace
                strColReplace = "," + aInfoReplace[0] + ",";
                //'--ricavo la lista di replace

                aInfoListaReplace = aInfoReplace[1].Split("-@-");
                for (k = 0; k <= aInfoListaReplace.Length - 1; k++)
                {
                    aReplace = aInfoListaReplace[k].Split("@@@");
                    objmappaReplace.Add(CStr(aReplace[0]), CStr(aReplace[1]));
                }
                //'Response.Write "strColReplace=" & strColReplace
            }
            //'--CONSERVO SE DEVO VISUALIZZARE SOLO UNA CELLA 
            int iCellR = 0;
            if (!string.IsNullOrEmpty(strShowCell))
            {
                iCellR = CInt(strShowCell);
            }
            int CountRow = -1;


            //'dim  DrawCaption
            //'DrawCaption = true
            bool bPrintRow = false;
            string strTempHtml = "";
            NumRow = objDoc.Sections[strSectionName].mp_numRec - 1;
            NumCol = objDoc.Sections[strSectionName].mp_Columns.Count;

            //'Response.write "numero di righe : " & NumRow
            //'Response.write "numero di colonne : " & NumCol
            MatrixValue = objDoc.Sections[strSectionName].mp_Matrix;
            if (IsEmpty(MatrixValue))
            {
                NumRow = -1;
                // 'Response.Write "NON TENGO NIENTE!!"
            }
            //'-- determina le righe da stampare ed il loro ordine
            string[] vetRowsSort = null;
            if (!string.IsNullOrEmpty(strRowsSort))
            {
                vetRowsSort = strRowsSort.Split("#");
                NumRow = vetRowsSort.Length - 1;
            }
            //'--APRO TABELLA
            if (string.IsNullOrEmpty(strShowCell))
            {
                strGrid = $@"<table class=""GridPrintProducts"">";
            }
            //'NumColDisplay 

            // '--determino la riga di partenza e la colonna di partenza
            int StartRow = 0;
            int EndRow = 0;
            if (PaginaCorrente == 1)
            {
                indCol = 1;
                //'if strTemplateRow = "VERTICALE" then
                StartRow = 0;
                //'else
                //'	StartRow=-1
                //'end if		
                if (string.IsNullOrEmpty(strTemplateRow))
                {
                    indiceRiga = -1;
                    StartRow = -1;
                }

            }
            else
            {
                if (strTemplateRow == "VERTICALE")
                {
                    //'StartRow = fix ( NumLineeStampate / NumColDisplay )
                    // 'indCol = ( NumLineeStampate mod NumColDisplay ) + 1 + (NumCol-NumColDisplay)
                    //'if (NumLineeStampate mod 2) =  0 then
                    //'	indCol = ( NumLineeStampate mod NumColDisplay ) + 1
                    // 'else
                    //'	indCol = ( NumLineeStampate mod NumColDisplay ) + 2	
                    // 'end if
                    StartRow = LastRowDiplayed;
                    indCol = IndiceLastCol;
                    //'Response.Write "<br>sColonna di partenza=" & indCol
                }
                else
                {
                    //'StartRow =  NumLineeStampate mod NumRow
                    if (LastRowDiplayed == 0)
                    {
                        StartRow = -1;
                    }
                    else
                    {
                        StartRow = LastRowDiplayed - 2;
                    }
                    indCol = 1;

                    indiceRiga = -1;
                }
            }
            // 'Response.Write  "NumLineeForPage=" & NumLineeForPage & "-NumLineeStampate=" & NumLineeStampate & "-STARTROW=" & StartRow  & "-STARTCOL=" & indCol & "-NumRow=" & NumRow & "-NumColDisplay=" & NumColDisplay & "-NumCol=" & NumCol &"<br>" 
            //'--CICLO SULLE RIGHE

            //'for indRow = -1 to NumRow
            for (indRow = StartRow; indRow <= NumRow; indRow++)
            {
                //'Response.Write "prodotto=" & indRow & "<br>"
                if (indRow > StartRow)
                {
                    indCol = 1;
                }
                if (string.IsNullOrEmpty(strTemplateRow))
                {
                    if (indRow > StartRow)
                    {
                        indiceRiga = 0;
                    }
                    LastRowDiplayed = LastRowDiplayed + 1;
                }
                //'-- se le righe sono ordinate le prendo nell'ordine richiesto
                //'if strRowsSort <> "" and indRow <> -1 then
                //'	indiceRiga = vetRowsSort(indRow)
                //'else 
                //'	indiceRiga = indRow
                //'end if
                //'Response.Write  "indiceRiga=" & indiceRiga & "<br>"
                //'bPrintRow = false

                //'-- se la riga non è da cancellare allora la disegnamo
                //'if instr( 1, strDeletedRow , "," & indiceRiga & "," ) = 0 then 
                bPrintRow = true;
                //'	CountRow = CountRow +1
                //'end if

                //'-- se ho chiesto di stampare una cella verifico se è la riga corretta
                //'if strShowCell <> ""  then
                //'	if CountRow <> iCellR then	bPrintRow = false
                //'end if
                if (bPrintRow == true)
                {
                    //'--APRO UNA NUOVA RIGA
                    if (string.IsNullOrEmpty(strShowCell) && string.IsNullOrEmpty(strTemplateRow))
                    {
                        strGrid = strGrid + $@"<tr class="""">";
                    }
                    if (strTemplateRow == "VERTICALE")
                    {
                        //'--tra una riga di prodotto e la successiva disegno due linee
                        if (string.IsNullOrEmpty(strShowCell))
                        {
                            strGrid = strGrid + $@"<tr class=""""><td class=""LineeSpazioProdotti"" colspan=2>&nbsp;</td></tr>";
                        }
                        if (indRow > StartRow)
                        {
                            NumLineeStampate = NumLineeStampate + 2;
                            if (nNumLineeCurrent >= NumLineeForPage)
                            {
                                //'LastRowDiplayed	= indRow		

                                //exit for
                                break;
                            }
                        }
                    }
                    bool bFine = false;
                    //'--CICLO SULLE COLONNE
                    while (indCol <= NumCol && !bFine)
                    {
                        bShowCol = false;
						//'Response.Write MatrixValue(indCol-1, indRow) & "<BR>";
						objField = objDoc.Sections[strSectionName].mp_Columns.ElementAt(indCol - 1).Value;
                        string strAttrib = objField.Name;
                        //'-- controlla se la colonna è da visualizzare 
                        if (!string.IsNullOrEmpty(strColShow))
                        {
                            //'--controllo se ho indicato la visualizzazione di colonne esplicite

                            bShowCol = false;
                            if (("," + strColShow + ",").ToUpper().Contains(("," + strAttrib + ",").ToUpper(), StringComparison.Ordinal))
                            {
                                bShowCol = true;
                            }
                        }
                        else
                        {
                            //'--altrimenti faccio la visualizzazione di tute le colonne

                            bShowCol = true;
                        }
                        if (!string.IsNullOrEmpty(strColHide))
                        {
                            if ((("," + strColHide + ",").ToUpper()).Contains(("," + strAttrib + ",").ToUpper(), StringComparison.Ordinal))
                            {
                                bShowCol = false;
                            }
                        }
                        else
                        {
                            bShowCol = true;
                        }
                        //'Response.Write objField.name & "shocol=" & bShowCol & "<BR>"
                        if (bShowCol)
                        {
                            //'--DISEGNO INTESTAZIONE
                            if (indiceRiga == -1)
                            {
                                if (string.IsNullOrEmpty(strTemplateRow))
                                {
                                    //'DrawCaption =  false
                                    if (string.IsNullOrEmpty(strShowCell))
                                    {
                                        strGrid = strGrid + $@"<td class=""CellIntestGrid_Horizontal"">";
                                        //'--caption della colonna
                                        if (mappaKeyCaption.ContainsKey(strAttrib))
                                        {
                                            strGrid = strGrid + mappaKeyCaption[strAttrib];
                                        }
                                        else
                                        {
                                            strGrid = strGrid + DOC_FieldRow_Label(strSectionName, strAttrib);
                                        }
                                        strGrid = strGrid + "</td>" + Environment.NewLine;

                                    }
                                }
                            }
                            else
                            {
                                strClassCell = "CellGridPrintProducts";
                                //	'--se si tratta di un attributo numerico cambio classe di stile	
                                if (CInt(objField.GetType()) == TIPOATTRIB_NUMBER)
                                {
                                    strClassCell = "CellGridNumericPrintProducts";
                                }
                                if (strTemplateRow == "VERTICALE")
                                {
                                    // '--metto la cella della caption della colonna prima del valore
                                    //'strGrid=strGrid & "<tr class=""CellRow""><td class=""CellIntestGrid"">-- LINEA " & nNumLineeCurrent & "--"

                                    //'strGrid=strGrid & "<tr class=""_CellRow""><td class=""CellIntestGrid"">--" & nNumLineeCurrent & "--" & indCol & "--"
                                    strGrid = strGrid + $@"<tr class=""_CellRow""><td class=""CellIntestGrid"">";
                                    //'--caption della colonna
                                    if (mappaKeyCaption.ContainsKey(strAttrib))
                                    {
                                        strGrid = strGrid + mappaKeyCaption[strAttrib];
                                    }
                                    else
                                    {
                                        strGrid = strGrid + DOC_FieldRow_Label(strSectionName, strAttrib);
                                    }
                                    strGrid = strGrid + "</td>" + Environment.NewLine;


                                }
                                //'if strShowCell = "" then strGrid=strGrid & "<td class=""" & strClassCell & """>" & indRow
                                if (string.IsNullOrEmpty(strShowCell))
                                {
                                    strGrid = strGrid + $@"<td class=""" + strClassCell + $@""">";
                                }
                                //'--valore visuale della colonna
                                strTechValue = "";
                                strTechValue = CStr(MatrixValue[(indCol - 1), indRow]);
                                objField.Value = strTechValue;
                                strVisualValue = "";
                                strVisualValue = objField.TxtValue();
                                //'--se richiesto applico le replace alla colonna corrente
                                if ((("," + strColReplace + ",").ToUpper()).Contains(("," + strAttrib + ",").ToUpper(), StringComparison.Ordinal))
                                {
                                    foreach (string strKey in objmappaReplace.Keys)
                                    {
                                        strVisualValue = strVisualValue.Replace(strKey, objmappaReplace[strKey]);
                                    }
                                }
                                strGrid = strGrid + HtmlEncode(CStr(strVisualValue));
                                if (string.IsNullOrEmpty(strShowCell))
                                {
                                    strGrid = strGrid + "</td>" + Environment.NewLine;
                                }
                                if (strTemplateRow == "VERTICALE")
                                {
                                    //'--chiudo la riga per ogni colonna

                                    strGrid = strGrid + "</tr>" + Environment.NewLine;

                                    // '--aggiorno il contatore delle linee stampate globale

                                    NumLineeStampate = NumLineeStampate + 1;
                                    //'--aggiorno il contatore delle linee stampate della pagina corrente

                                    nNumLineeCurrent = nNumLineeCurrent + 1;
                                    if (nNumLineeCurrent == NumLineeForPage)
                                    {
                                        bFine = true;
                                    }
                                }

                            }
                        }
                        indCol = indCol + 1;
                    }
                    IndiceLastCol = indCol;
                    //'--CHIUDO LA RIGA CORRENTE
                    if (string.IsNullOrEmpty(strShowCell) && string.IsNullOrEmpty(strTemplateRow))
                    {
                        strGrid = strGrid + "</tr>" + Environment.NewLine;
                    }
                    if (string.IsNullOrEmpty(strTemplateRow))
                    {
                        NumLineeStampate = NumLineeStampate + 1;
                        //'--aggiorno il contatore delle linee stampate della pagina corrente
                        nNumLineeCurrent = nNumLineeCurrent + 1;
                    }


                }

                //'--aggiorno il numero di linee stampate globali
                //'if nNumLineeCurrent + 2 < NumLineeForPage then
                //'	NumLineeStampate = NumLineeStampate + 2
                //'end if

                //'Response.Write "nNumLineeCurrent=" & nNumLineeCurrent & "<br>"
                //'--aggiorno il contatore delle linee stampate della pagina corrente
                //'nNumLineeCurrent = nNumLineeCurrent + 2
                if (nNumLineeCurrent >= NumLineeForPage)
                {
                    //'Response.Write  "NumLineeForPage=" & NumLineeForPage & "-NumLineeStampate=" & NumLineeStampate & "-STARTROW=" & StartRow  & "-ENDCOL=" & indCol & "-NumRow=" & NumRow & "-NumColDisplay=" & NumColDisplay & "-NumCol=" & NumCol &"<br>" 
                    LastRowDiplayed = indRow;


                    break;
                }

            }
            LastRowDiplayed = indRow;
            //'--CHIUDO LA TABELLA
            if (string.IsNullOrEmpty(strShowCell))
            {
                strGrid = strGrid + "</table>" + Environment.NewLine;
            }
            return strGrid;




        }
        //'DESC=funzione per salvare valore attributo
        //'objDoc=documento
        //'strSectionName=nome sezione
        //'strAttrib=nome attributo
        //'nNumRiga=numero riga utilizzato per le griglie
        //'strTechValue= di input contiene il valore in forma tecnica
        public static void Save_DOC_AttribValue(string strSectionName, string strAttrib, string strNumRiga, string strTechValue)
        {
            if (string.IsNullOrEmpty(strNumRiga))
            {
                //'--attributo di testata

                objDoc.Sections[strSectionName].mp_Mod.Fields[strAttrib].Value = strTechValue;
            }
            else
            {
                // '--attributo di griglia
                //'--recupero posizione attributo nella matrice

                int nPosColAttrib = objDoc.Sections[strSectionName].GetIndexColumn(strAttrib);


                //'--aggirono la cella della matrice in memoria
                objDoc.Sections[strSectionName].mp_Matrix[nPosColAttrib - 1, CInt(strNumRiga)] = strTechValue;
            }
        }
        /// <summary>
        /// Recupera il valore
        /// </summary>
        /// <param name="Contesto">stringa che identifica l'oggetto tecnico in cui faccio la chiamata: nomepagina.asp,ecc....</param>
        /// <param name="Oggetto">attributo o altro su cui voglio recuperare la proprietà</param>
        /// <param name="Prop">proprieta ( i nomi sono come quelli definiti sui modelli)</param>
        /// <param name="DefValue">valore didefault</param>
        /// <param name="Idpfu">default passare -1</param>
        /// <returns></returns>
        public static string? Get_Func_Property(string Contesto, string Oggetto, string Prop, string DefValue, int Idpfu = -1)
        {
            TSRecordSet rs;
            string? retVal;
            retVal = DefValue;

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@Contesto", Contesto);
            sqlParams.Add("@Oggetto", Oggetto);
            sqlParams.Add("@Prop", Prop);
            sqlParams.Add("@DefValue", DefValue);
            sqlParams.Add("@Idpfu", Idpfu);

            rs = GetRS(@"select dbo.parametri(@Contesto, @Oggetto, @Prop, @DefValue, @Idpfu) as Valore", sqlParams);
            if (rs.RecordCount > 0)
            {
                rs.MoveFirst();

                if (rs["Valore"] == null)
                    retVal = string.Empty;
                else
                    retVal = (string?)rs["Valore"];
            }

            return retVal;
        }
        public static string NL_To_BR(string value)
        {
            value = value.Replace(Environment.NewLine, "<br/>");

            value = value.Replace("\r", "<br/>");

            value = value.Replace("\n", "<br/>");
            return value;
        }
        public static string xmlEncode(string str)
        {
            string _out = str;
            if (!string.IsNullOrEmpty(CStr(_out)))
            {
                _out = HtmlEncode(_out);
                _out = _out.Replace("'", "&apos;");
            }
            return _out;
        }
        //'DESC=funzione per salvare valore attributo
        //'objDoc=documento
        //'strSectionName=nome sezione
        //'strAttrib=nome attributo
        //'nNumRiga=numero riga utilizzato per le griglie
        //'strTechValue= di input contiene il valore in forma tecnica
        public static void Save_DOC_MatrixValue(string TIPO_DOC, string ID_DOC_IN_MEM, string strSectionName, int strNumCol, int strNumRiga, string strTechValue, eProcurementNext.Session.ISession session)
        {
            string strSecName = "";
            string[,] Matrix = null;
            strSecName = "DOC_SEC_MEM_" + TIPO_DOC + "_" + ID_DOC_IN_MEM + "_" + strSectionName;

            //'--aggiorno la cella della matrice in memoria
            try
            {
                Matrix = session[strSecName + "_MATRIX"];
            }
            catch
            {

            }
            Matrix[strNumCol, strNumRiga] = strTechValue;

            session[strSecName + "_MATRIX"] = Matrix;


        }
        /// <summary>
        /// Dato il campo di una sezione dettagli si ritorna il valore visuale
        /// </summary>
        /// <param name="strSectionName"></param>
        /// <param name="strNumRiga"></param>
        /// <returns></returns>
        public static string DOC_FieldIdRowTab(string strSectionName, int strNumRiga)
        {
            string strTechValue = string.Empty; //valore di default

            
            //try
            //{
                //ho il documento in memoria ?
                if (objDoc != null)
                {
					//verifico se Esiste la sezione richiesta
					if (objDoc.Sections.ContainsKey(strSectionName))
					{
						//'--recupero numero colonne della matrice
						int nPosColAttrib = objDoc.Sections[strSectionName].mp_Columns.Count;

						//'--matrice dei valori
						dynamic[,] MatrixValue = objDoc.Sections[strSectionName].mp_Matrix;

						//'--recupero valore tecnico
						strTechValue = CStr(MatrixValue[nPosColAttrib + 1, strNumRiga]);
					}
				}      
            //}
            //catch(Exception ex)
            //{
            //    ;
            //}

            return strTechValue;

        }

    }
}










