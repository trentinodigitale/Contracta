using eProcurementNext.CommonModule;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Fld_RadioButton : Field, IField
    {


        private string mp_id;//'-- identifica il radio button in un gruppo di nome "Name"

        public Fld_RadioButton()
        {
            /* nel costruttore di tutti i field va inizializzato l'mp_itype con il proprio tipo di riferimento */
            this.mp_iType = 10;
            Style = "";
            Editable = true;
        }


        //'-- contenogono il nome della funzione JS da chiamare sul campo per l'evento considerato

        public override void Init(int iType, string oName = "", object? oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {
            base.Init(iType, oName, oValue, oDom, oumDom, oFormat, oEditable, oObbligatory, oValidazioneFormale);
        }

        public void Init(string oName = "", object? oValue = null, bool oEditable = true, string oiD = "1")
        {
            //'-- inizializza tutti gli attributi della classe
            mp_id = oiD;
        }

        public override void Html(IEprocResponse objResp, bool? pEditable = null)
        {

            bool? vEditable;
            vEditable = Editable;
            if (pEditable == null)
            {
                vEditable = pEditable;
            }


            //'-- apertura del controllo
            objResp.Write($@"<input type=""radio"" name=""{Name}""  id=""{Name}"" ");
            objResp.Write($@" value=""{HtmlEncodeValue(mp_id)}"" ");

            if (this.Value == "1")
            {
                objResp.Write(@"checked=""checked"" ");
            }

            objResp.Write("/>");
        }





        public void setId(string id)
        {
            mp_id = id;
        }

        public override void toPrint(CommonModule.IEprocResponse objResp, bool? pEditable = null)
        {
            base.toPrint(objResp, pEditable);
            string strVal = IIF(IsNull(this.Value), "", this.Value);
            this.Value = strVal;
            if (!string.IsNullOrEmpty(mp_row))
            {
                this.setId(MidVb6(mp_row, 2, Len(mp_row) - 2));
            }

            this.Html(objResp, (pEditable == null) ? Editable : pEditable);

        }

        public override void CaptionHtmlCenter(IEprocResponse objResp)
        {
            objResp.Write(@" for=""" + HtmlEncode(this.Name) + @"""");
        }

        public override void ValueHtml(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueHtml(objResp, pEditable);
            string strVal = IIF(IsNull(this.Value), "", this.Value);
            this.Value = strVal;
            if (!string.IsNullOrEmpty(mp_row))
            {
                this.setId(MidVb6(mp_row, 2, Len(mp_row) - 2));
            }

            this.Html(objResp, (pEditable == null) ? Editable : pEditable);

            this.Name = originaleName;

        }

        public override void ValueExcel(IEprocResponse objResp, bool? pEditable = null)
        {
            base.ValueExcel(objResp, pEditable);
            string strVal = IIF(IsNull(this.Value), "", this.Value);
            this.Value = strVal;
            if (!string.IsNullOrEmpty(mp_row))
            {
                this.setId(MidVb6(mp_row, 2, Len(mp_row) - 2));
            }


            this.Html(objResp, (pEditable == null) ? Editable : pEditable);
        }

        public override void toPrintExtraContent(IEprocResponse objResp, object OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {
            base.toPrintExtraContent(objResp, OBJSESSION, params_, startPage, strHtmlHeader, strHtmlFooter, contaPagine);
            string strVal = IIF(IsNull(this.Value), "", this.Value);
            this.Value = strVal;
            if (!string.IsNullOrEmpty(mp_row))
            {
                this.setId(MidVb6(mp_row, 2, Len(mp_row) - 2));
            }
        }

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
            return (Value == null ? "" : Value).Replace(@"'", @"''");

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
        public override void UpdateFieldVisual(IEprocResponse objResp, string strDocument = "") { }





    }
}

