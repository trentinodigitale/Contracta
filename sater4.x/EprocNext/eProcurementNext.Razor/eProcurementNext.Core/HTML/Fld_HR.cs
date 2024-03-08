using eProcurementNext.CommonModule;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Fld_HR : Field, IField
    {

        public Fld_HR()
        {
            /* nel costruttore di tutti i field va inizializzato l'mp_itype con il proprio tipo di riferimento */
            this.mp_iType = 16;
            PathImage = "../CTL_Library/images/Domain/";
            Style = "HR";
            Value = "";
        }

        public override void Html(IEprocResponse objResp, bool? pEditable = null)
        {
            objResp.Write("<hr/>");
        }

        public override void ValueHtml(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueHtml(objResp, pEditable);
            this.Name = mp_row + Name;
            this.Html(objResp);

            this.Name = originaleName;

        }

        public override void ValueExcel(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueExcel(objResp, pEditable);
            this.Name = mp_row + Name;
            this.Html(objResp);

            this.Name = originaleName;

        }

        public override void toPrint(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.toPrint(objResp, pEditable);
            this.Name = mp_row + Name;
            this.Html(objResp);

            this.Name = originaleName;

        }

        public override void toPrintExtraContent(IEprocResponse objResp, object OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {
            base.toPrintExtraContent(objResp, OBJSESSION, params_, startPage, strHtmlHeader, strHtmlFooter, contaPagine);

        }

        public override void Init(int iType, string oName = "", object? oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {
            base.Init(iType, oName, oValue, oDom, oumDom, oFormat, oEditable, oObbligatory, oValidazioneFormale);
        }
        public override void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/") { }
        public override dynamic? RSValue()
        {
            Value = base.RSValue();
            return Value;
        }
        public override void SetFilterDomain(string strFilter, string strSep = ",", bool InOut = true) { }
        public override void SetPrintDescription(string str) { }
        public override void SetSelectDescription(string str) { }
        public override void SetSelezionatiDescription(string str) { }
        public override void SetSenzaModali(string str) { }
        public override string SQLValue()
        {
            Value = base.SQLValue();
            return Value;
        }
        public override void xml(IEprocResponse objResp, string tipo)
        {
            objResp.Write($@"<{XmlEncode(UCase(Name))} desc=""{XmlEncode(CStr(Caption))}"" type=""{getFieldTypeDesc(mp_iType)}"">");
            objResp.Write($@"{XmlEncode(CStr(Value).Trim())}");
            objResp.Write($@"</{XmlEncode(UCase(Name))}>");
        }
        public override void UpdateFieldVisual(string objResp, string strDocument = "") { }


    }
}

