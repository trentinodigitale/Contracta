using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Fld_PubLeg : Field, IField
    {
        public string ToolTip;
        public string OnClick; //'-- funzione associata al click
        private bool PrintMode;
        CommonDbFunctions cdf = new CommonDbFunctions();

        public Fld_PubLeg()
        {
            /* nel costruttore di tutti i field va inizializzato l'mp_itype con il proprio tipo di riferimento */
            this.mp_iType = 20;
            PathImage = "../../CTL_Library/functions/FIELD/";
            Style = "FLdPubLeg";
            PrintMode = false;
        }


        public override void Html(IEprocResponse objResp, bool? pEditable = null)
        {
            objResp.Write($@"<div");
            objResp.Write($@" id=""{Name}_div"" ");

            if (!string.IsNullOrEmpty(OnClick) && PrintMode == false)
            {
                objResp.Write($@" onclick=""{OnClick}"" ");
            }

            objResp.Write($@" class=""{Style}_div"" >");

            TSRecordSet rsAzi;
            TSRecordSet rsML;

            if (!string.IsNullOrEmpty(CStr(Value)) && IsNumeric(Value))
            {

                if (GetParam(strFormat, "VIEW") == "")
                {
                    //Set obj = CreateObject("ctldb.clsTabManage")
                    rsAzi = cdf.GetRSReadFromQuery_($@"select * from aziende with(nolock) where idazi = {Value}", ConnectionString);

                    if (rsAzi != null)
                    {
                        if (rsAzi.RecordCount > 0)
                        {
                            objResp.Write($@"<table border=""0"" cellspacing=""0"" cellpadding=""0"" class=""{Style}_tab"" >");
                            objResp.Write($@"<tr>");
                            objResp.Write($@"<td><b>{HtmlEncode(getAziStrVal(rsAzi.Fields["aziRagioneSociale"]))}</b></td>");
                            objResp.Write($@"</tr>");
                            objResp.Write($@"<tr>");
                            objResp.Write($@"<td>{HtmlEncode(getAziStrVal(rsAzi.Fields["aziIndirizzoLeg"]))} {HtmlEncode(getAziStrVal(rsAzi.Fields["aziCAPLeg"]))} {HtmlEncode(getAziStrVal(rsAzi.Fields["aziLocalitaLeg"]))}");
                            if (UCase(CStr(rsAzi.Fields["aziProvinciaLeg"])) != "ND")
                            {
                                objResp.Write($@" ({HtmlEncode(getAziStrVal(rsAzi.Fields["aziProvinciaLeg"]))}) ");
                            }
                            objResp.Write($@" {HtmlEncode(getAziStrVal(rsAzi.Fields["aziStatoLeg"]))}</td>");
                            objResp.Write($@"</tr>");
                            objResp.Write($@"<tr>");
                            objResp.Write($@"<td>Tel {HtmlEncode(getAziStrVal(rsAzi.Fields["aziTelefono1"]))} - Fax {HtmlEncode(getAziStrVal(rsAzi.Fields["aziFAX"]))} - ");

                            if (PrintMode == false)
                            {
                                objResp.Write($@"<a href=""{HtmlEncodeValue(getAziStrVal(rsAzi.Fields["aziSitoWeb"]))}"">");
                            }

                            objResp.Write(HtmlEncode(getAziStrVal(rsAzi.Fields["aziSitoWeb"])));

                            if (PrintMode == false)
                            {
                                objResp.Write($@"</a>");
                            }

                            objResp.Write($@"</td>");
                            objResp.Write($@"</tr>");
                            objResp.Write($@"<tr>");

                            objResp.Write($@"<td>Cod. Fisc. e Part. IVA {HtmlEncode(getAziStrVal(rsAzi.Fields["aziPartitaIVA"]))}</td>");

                            objResp.Write($@"</tr>");
                            objResp.Write($@"</table>");
                        }
                    }


                }
                else
                {

                    //Set obj = CreateObject("ctldb.clsTabManage")
                    rsAzi = cdf.GetRSReadFromQuery_($@"select * from {GetParam(strFormat, "VIEW")} where idazi = {Value}", ConnectionString);
                    if (Language == "")
                    {
                        Language = "I";
                    }
                    rsML = cdf.GetRSReadFromQuery_($@"select * from LIB_Multilinguismo where ML_LNG = '{Language} ' and ML_KEY = '{GetParam(strFormat, "TEMPLATE")}'", ConnectionString);
                    string strTemplate;
                    strTemplate = CStr(rsML.Fields["ML_Description"]);
                    int c;
                    int i;

                    //if( rsAzi.RecordCount > 0 ){
                    //    c = rsAzi.Fields.Count - 1;
                    //    for (i = 0; i<  rsAzi.Fields.Count; i++) {
                    //        if( ! IsNull(rsAzi.Fields[i].Value) ){
                    //            strTemplate = strTemplate.Replace($@"<{rsAzi.Fields[i].Name}>", HtmlEncode(CStr(rsAzi.Fields[i].Value)));
                    //        }
                    //    }
                    //    objResp.Write(strTemplate);
                    //}

                    if (rsAzi.RecordCount > 0)
                    {
                        c = rsAzi.Columns.Count - 1;
                        for (i = 0; i < rsAzi.Columns.Count; i++)
                        {
                            if (!IsNull(rsAzi.Fields[i]))
                            {
                                strTemplate = strTemplate.Replace($@"<{rsAzi.Columns[i].ColumnName}>", HtmlEncode(CStr(rsAzi.Fields[i])));
                            }
                        }
                        objResp.Write(strTemplate);
                    }
                }

            }

            if (GetParam(strFormat, "VALUE") != "")
            {
                objResp.Write($@"<input type=""hidden"" name=""{Name}""  id=""{Name}"" ");
                objResp.Write($@" value=""{HtmlEncodeValue(CStr(Value))}"" ");
                objResp.Write($@"/> ");
            }

            objResp.Write($@"</div>");
        }
        public override void Init(int iType, string oName = "", object oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {
            base.Init(iType, oName, oValue, oDom, oumDom, oFormat, oEditable, oObbligatory, oValidazioneFormale);
        }
        public override void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/") { }
        public override string TechnicalValue()
        {
            return IIF(IsNull(this.Value), "", CStr(this.Value));
        }
        public override void toPrint(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.toPrint(objResp, pEditable);
            this.Name = mp_row + Name;
            this.Value = IIF(IsNull(Value), "", Value);
            PrintMode = true;
            this.Html(objResp);

            this.Name = originaleName;
        }
        public override void toPrintExtraContent(IEprocResponse objResp, dynamic OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {

        }
        public override void ValueExcel(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueExcel(objResp, pEditable);
            this.Name = mp_row + Name;
            this.Value = IIF(IsNull(Value), "", Value);
            this.Excel(objResp);

            this.Name = originaleName;

        }
        public override void ValueHtml(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueHtml(objResp, pEditable);
            this.Name = mp_row + Name;
            this.Value = IIF(IsNull(Value), "", Value);
            this.Html(objResp);

            this.Name = originaleName;

        }
        public override void xml(IEprocResponse objResp, string tipo)
        {
            objResp.Write($@"<{XmlEncode(UCase(Name))} desc=""{XmlEncode(CStr(Caption))}"" type=""{getFieldTypeDesc(mp_iType)}"">");
            objResp.Write($@"{XmlEncode(CStr(Value).Trim())}");
            objResp.Write($@"</{XmlEncode(UCase(Name))}>");
        }
        public override void Excel(CommonModule.IEprocResponse objResp, bool? pEditable = null)
        {
            this.Html(objResp);
        }

        private string getAziStrVal(dynamic? val)
        {

            if (IsNull(val))
            {
                return "";
            }
            else
            {
                return CStr(val);
            }
        }

        public override void UpdateFieldVisual(IEprocResponse objResp, string strDocument = "") { }


    }
}

