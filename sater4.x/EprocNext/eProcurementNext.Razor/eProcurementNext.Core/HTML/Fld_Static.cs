using eProcurementNext.CommonModule;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Fld_Static : Field, IField
    {

        public string ToolTip;

        public string OnClick;//'-- funzione associata al click

        public Fld_Static()
        {
            /* nel costruttore di tutti i field va inizializzato l'mp_itype con il proprio tipo di riferimento */
            this.mp_iType = 15;

            Style = "Static";

        }

        public override void Init(int iType, string oName = "", object? oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {
            base.Init(iType, oName, oValue, oDom, oumDom, oFormat, oEditable, oObbligatory, oValidazioneFormale);
            this.OnClick = oName;
        }

        public override void ValueHtml(IEprocResponse objResp, bool? pEditable = null)
        {

            string originaleName = this.Name;

            base.ValueHtml(objResp, pEditable);

            Name = mp_row + Name;
            Value = Caption;

            this.Html(objResp);

            this.Name = originaleName;

        }

        public override void ValueExcel(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueExcel(objResp, pEditable);
            this.Name = mp_row + Name;
            this.Value = Caption;

            objResp.Write(HtmlEncode(this.TxtValue()));

            this.Name = originaleName;
        }


        public override void Html(IEprocResponse objResp, bool? pEditable = null)
        {
            objResp.Write(@"<table  ");
            objResp.Write(@" id=""" + Name + @""" ");
            if (!string.IsNullOrEmpty(OnClick))
            {
                objResp.Write(@" onclick=""" + OnClick + @""" ");
            }

            objResp.Write(@" class=""" + Style + @"_Tab"" >");
            objResp.Write(@"<tr>");


            objResp.Write("<td");

            objResp.Write(@" class=""" + Style + @"_label"" ");
            objResp.Write(@" id=""" + Name + @"_label"" >");

            objResp.Write(HtmlEncode(this.Value));

            objResp.Write(@"</td></tr></table>");
        }

        public override void setOnClick(string JS)
        {

        }

        public override void toPrint(CommonModule.IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.toPrint(objResp, pEditable);
            this.Name = mp_row + Name;
            this.Value = Caption;

            this.Html(objResp);

            this.Name = originaleName;
        }

        public override void toPrintExtraContent(IEprocResponse objResp, object OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {
            string originaleName = this.Name;

            base.toPrintExtraContent(objResp, OBJSESSION, params_, startPage, strHtmlHeader, strHtmlFooter, contaPagine);
            this.Name = mp_row + Name;
            this.Value = Caption;

            this.Name = originaleName;

        }

        public override void CaptionHtmlCenter(CommonModule.IEprocResponse objResp) { }
        public override void HtmlExtended(IEprocResponse objResp, dynamic? Request = null) { }
        public override void HtmlExtended2(IEprocResponse objResp, dynamic? Request = null, dynamic? session = null) { }
        public override void HtmlExtended3(IEprocResponse objResp, dynamic? Request = null, dynamic? session = null) { }
        public override void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/") { }
        public override dynamic? RSValue()
        {
            Value = base.RSValue();
            return this.Value;
        }
        public override void SetFilterDomain(string strFilter, string strSep = ",", bool InOut = true) { }
        public override void SetPrintDescription(string str) { }
        public override void SetSelectDescription(string str) { }
        public override void SetSelezionatiDescription(string str) { }
        public override void SetSenzaModali(string str) { }
        public override string SQLValue()
        {
            Value = base.SQLValue();
            return this.Value;
        }
        public override string TechnicalValue()
        {
            return IIF(IsNull(this.Value), "", this.Value);
        }
        public override void xml(IEprocResponse objResp, string tipo)
        {
            objResp.Write($@"<{XmlEncode(UCase(Name))} desc=""{XmlEncode(Caption)}"" type=""{getFieldTypeDesc(mp_iType)}"">");
            objResp.Write($@"{XmlEncode(CStr(Value).Trim())}");
            objResp.Write($@"</{XmlEncode(UCase(Name))}> ");
        }
        public override void UpdateFieldVisual(string objResp, string strDocument = "") { }



    }
}

