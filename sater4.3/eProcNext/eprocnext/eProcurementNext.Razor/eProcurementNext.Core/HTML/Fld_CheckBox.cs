using eProcurementNext.CommonModule;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Fld_CheckBox : Field, IField
    {

        public string mp_id;

        public Fld_CheckBox()
        {
            /* nel costruttore di tutti i field va inizializzato l'mp_itype con il proprio tipo di riferimento */
            this.mp_iType = 9;
            Style = "checkbox";
            Editable = true;
            mp_id = "1";
            PathImage = "../CTL_Library/images/Domain/";
        }

        public override void Html(IEprocResponse objResp, bool? pEditable = null)
        {

            bool? vEditable;
            vEditable = Editable;
            if (pEditable != null)
            {
                vEditable = pEditable;
            }


            if (vEditable == false && strFormat == "I")
            {

                objResp.Write($@"<input type=""hidden"" name=""{Name}""  id=""{Name}"" ");
                objResp.Write($@" value=""{this.Value}""/>");
                if (CStr(this.Value) == "1")
                {
                    if (IsMasterPageNew())
                    {
                        objResp.Write($@"<img alt=""check"" src=""{PathImage}checkedFaseII.png""/>");
                    }
                    else
                    {
                        objResp.Write($@"<img alt=""check"" src=""{PathImage}checked.gif""/>");
                    }
                }
                else
                {
                    if (IsMasterPageNew())
                    {
                        objResp.Write($@"<img alt=""uncheck"" src=""{PathImage}uncheckedFaseII.png""/>");
                    }
                    else
                    {
                        objResp.Write($@"<img alt=""uncheck"" src=""{PathImage}unchecked.gif""/>");
                    }
                }


            }
            else
            {


                //'-- apertura del controllo
                if (vEditable == false)
                {
                    objResp.Write($@"<input type=""checkbox"" name=""{Name}_V""  id=""{Name}_V"" ");
                }
                else
                {
                    objResp.Write($@"<input type=""checkbox"" name=""{Name}""  id=""{Name}"" ");
                }

                objResp.Write($@" value=""1"" ");

                //'-- mettendolo disabled non arriva al documento e il metodo UpdFieldsValue del Modello
                //'-- (per i checkBox) quando non trova il campo lo setta comunque ad empty, questo
                //'-- fa si che il valore venga messo a vuoto al salvataggio, e non va bene.
                //'-- quindi invece di mettere disabled e basta aggiunto anche un campo tecnico nascosto
                //'-- così da passarlo al documento

                if (vEditable == false)
                {
                    objResp.Write($@" disabled=""disabled"" ");
                }

                if (!string.IsNullOrEmpty(mp_OnClick))
                {
                    objResp.Write($@" onclick=""javascript:{mp_OnClick}"" ");
                }

                if (!string.IsNullOrEmpty(mp_OnChange))
                {
                    objResp.Write($@" onchange=""javascript:{mp_OnChange}"" ");
                }


                if (CStr(this.Value) == "1")
                {
                    objResp.Write($@"checked=""checked"" ");
                }

                objResp.Write("/>");

                if (vEditable == false)
                {

                    objResp.Write($@"<input type=""hidden"" name=""{Name}""  id=""{Name}"" ");
                    objResp.Write($@" value=""{this.Value}""/>");

                }

            }

        }

        public override void Excel(IEprocResponse objResp, bool? pEditable = null)
        {
            if (Value == "1")
            {
                objResp.Write("1");
            }
            else
            {
                objResp.Write("0");
            }
        }

        public override string SQLValue()
        {
            Value = base.SQLValue();

            if (Value == "1")
            {
                return Value;
            }
            else
            {
                return "0";
            }
        }

        public override dynamic RSValue()
        {
            Value = base.RSValue();
            if (Value == "1")
            {
                return 1;
            }
            else
            {
                return 0;
            }
        }

        public override void toPrint(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.toPrint(objResp, pEditable);

            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            this.Value = IIF(IsNull(Value), "", Value);
            Html(objResp, (pEditable == null) ? Editable : pEditable);
            this.Name = originaleName;

        }

        public override void CaptionHtmlCenter(IEprocResponse objResp)
        {
            if (Editable)
            {
                objResp.Write($@" for=""{HtmlEncode(this.Name)}""");
            }
        }

        public override void ValueHtml(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueHtml(objResp, pEditable);
            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            this.Value = IIF(IsNull(Value), "", Value);

            Html(objResp, (pEditable == null) ? Editable : pEditable);

            this.Name = originaleName;

        }

        public override void ValueExcel(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueExcel(objResp, pEditable);
            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            this.Value = IIF(IsNull(Value), "", Value);

            this.Excel(objResp, (pEditable == null) ? Editable : pEditable);

            this.Name = originaleName;
        }

        public override void toPrintExtraContent(IEprocResponse objResp, object OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {
            string originaleName = this.Name;

            base.toPrintExtraContent(objResp, OBJSESSION, params_, startPage, strHtmlHeader, strHtmlFooter, contaPagine);

            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            this.Value = IIF(IsNull(Value), "", Value);

            this.Name = originaleName;

        }

        public override void HtmlExtended(IEprocResponse objResp, dynamic? Request = null) { }
        public override void HtmlExtended2(IEprocResponse objResp, dynamic? Request = null, dynamic? session = null) { }
        public override void HtmlExtended3(IEprocResponse objResp, dynamic? Request = null, dynamic? session = null) { }
        public override void Init(int iType, string oName = "", object? oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {
            base.Init(iType, oName, oValue, oDom, oumDom, oFormat, oEditable, oObbligatory, oValidazioneFormale);
        }
        public override void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/") { }
        public override void SetFilterDomain(string strFilter, string strSep = ",", bool InOut = true) { }
        public override void SetPrintDescription(string str) { }
        public override void SetSelectDescription(string str) { }
        public override void SetSelezionatiDescription(string str) { }
        public override void SetSenzaModali(string str) { }
        public override void xml(IEprocResponse objResp, string tipo)
        {
            objResp.Write($@"<{XmlEncode(UCase(Name))} desc=""{XmlEncode(CStr(Caption))}"" type=""{getFieldTypeDesc(mp_iType)}"">");
            objResp.Write($@"{XmlEncode(CStr(Value).Trim())}");
            objResp.Write($@"</{XmlEncode(UCase(Name))}>");
        }
        public override void UpdateFieldVisual(string objResp, string strDocument = "") { }



    }
}

