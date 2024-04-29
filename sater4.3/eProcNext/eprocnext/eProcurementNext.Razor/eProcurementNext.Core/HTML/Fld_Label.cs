using eProcurementNext.CommonModule;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Fld_Label : Field, IField
    {

        public string Image; //'-- immagini

        public string ToolTip;

        public string OnClick; //'-- funzione associata al click

        private bool PrintMode;

        public Fld_Label()
        {
            /* nel costruttore di tutti i field va inizializzato l'mp_itype con il proprio tipo di riferimento */
            this.mp_iType = 11;
            PathImage = "../CTL_Library/images/Domain/";
            Style = "FLbl";
            PrintMode = false;
        }

        public override void Init(int iType, string oName = "", object? oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {
            base.Init(iType, oName, oValue, oDom, oumDom, oFormat, oEditable, oObbligatory, oValidazioneFormale);
            this.Value = IIF(oFormat != "I", oValue, "");
            this.Image = IIF(oFormat != "I", "", oValue);
            this.OnClick = "";
        }

        public override void Html(IEprocResponse objResp, bool? pEditable = null)
        {

            string strDesc;
            string strOnClickLabel;
            strOnClickLabel = "";

            if (!string.IsNullOrEmpty(OnClick) && !PrintMode)
            {

                objResp.Write("<table ");

                if (!string.IsNullOrEmpty(CStr(Name)))
                {
                    objResp.Write($@"id=""{Name}""");
                }

                if (IsMasterPageNew())
                {
                    if (OnClick.ToLower().Contains("opengeo") || Name.ToLower().Contains("aprigeo")) {
                        objResp.Write($@" data-type=""openGEOFaseII"" class=""{Style}_Tab"" ><tr>");
                    }
                    else
                    {
                        objResp.Write($@" class=""{Style}_Tab"" ><tr>");
                    }

                }
                else
                {
                    objResp.Write($@" class=""{Style}_Tab"" ><tr>");

                }

                strOnClickLabel = $@" onclick=""{OnClick};return false;""";

            }
            else
            {

                objResp.Write($@"<table ");

                if (!string.IsNullOrEmpty(CStr(Name)))
                {
                    objResp.Write($@"id=""{Name}""");
                }

                if (IsMasterPageNew())
                {
                    if (Name.ToLower().Contains("aprigeo"))
                    {
                        objResp.Write($@" data-type=""openGEOFaseII"" class=""{Style}_Tab"" ><tr>");
                    }
                    else
                    {
                        objResp.Write($@" class=""{Style}_Tab"" ><tr>");
                    }

                }
                else
                {
                    objResp.Write($@" class=""{Style}_Tab"" ><tr>");

                }

            }

            if (!string.IsNullOrEmpty(this.Image))
            {
                objResp.Write($@"<td title=""{HtmlEncodeValue(ToolTip)}"">");

                if (!string.IsNullOrEmpty(strOnClickLabel))
                {

                    objResp.Write($@"<a href=""#"" class=""fldLabel_link_img""");

                    if (!string.IsNullOrEmpty(CStr(Name)))
                    {
                        objResp.Write($@" id=""{Name}_link""");
                    }

                    objResp.Write(strOnClickLabel);
                    objResp.Write($@">");
                }

                objResp.Write($@"<img class=""img_label_alt"" alt=""{HtmlEncodeValue(CStr(Image))}"" src=""{PathImage}{Image}""/>");

                if (!string.IsNullOrEmpty(strOnClickLabel))
                {
                    objResp.Write($@"</a>");
                }

                objResp.Write($@"</td>");

            }


            objResp.Write($@"<td class=""nowrap {Style}_label"" id=""{Name}_label"">");


            if (CStr(strFormat).Contains('H', StringComparison.Ordinal))
            {

                strDesc = CStr(this.Value);

                //'-- Controllo di sicurezza sul valore contenuto nella text per prevenire xss
                if (!string.IsNullOrEmpty(CStr(strDesc.Trim())))
                {
                    strDesc = bonificaHtmlDaXSS(strDesc);
                }

                objResp.Write(strDesc);

            }
            else
            {
                if (!string.IsNullOrEmpty(strOnClickLabel) && (!string.IsNullOrEmpty(CStr(this.Value).Trim())))
                {
                    objResp.Write($@"<a href=""#"" class=""fldLabel_link""");
                    objResp.Write(strOnClickLabel);
                    objResp.Write($@">");
                }
                if (CStr(strFormat) != "I")
                {
                    objResp.Write(HtmlEncode(this.Value));
                }

                if (!string.IsNullOrEmpty(strOnClickLabel))
                {
                    objResp.Write("</a>");
                }


            }

            objResp.Write(@"</td></tr></table>");

        }

        public override void Excel(IEprocResponse objResp, bool? pEditable = null)
        {
            if (strFormat == "I")
            { //'-- nella rappresentazione in excel se � richiesta la format I IMAGE allora togliamo l'output
                objResp.Write("&nbsp;");
            }
            else
            {
                objResp.Write(HtmlEncode(this.Value));
            }
        }

        public override void setOnClick(string JS)
        {
            base.setOnClick(JS);
            OnClick = JS;
        }


        public override void ValueHtml(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueHtml(objResp, pEditable);

            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga

            dynamic? strVal = Value;
            this.Value = null;

            if (strFormat == "I")
            {
                this.Image = IIF(IsNull(strVal), "", strVal);
            }
            else
            {
                this.Value = IIF(IsNull(strVal), "", strVal);
            }

            this.Html(objResp);

            this.Name = originaleName;

        }

        public override void ValueExcel(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueExcel(objResp, pEditable);
            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            if (strFormat == "I")
            {
                this.Image = IIF(IsNull(Value), "", Value);
            }
            else
            {
                this.Value = IIF(IsNull(Value), "", Value);
            }

            this.Excel(objResp);

            this.Name = originaleName;

        }

        public override void toPrint(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.toPrint(objResp, pEditable);
            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga

            dynamic? strVal = Value;
            this.Value = null;
            if (strFormat == "I")
            {
                this.Image = IIF(IsNull(strVal), "", strVal);
            }
            else
            {
                this.Value = IIF(IsNull(strVal), "", strVal);
            }

            PrintMode = true;
            this.Html(objResp);

            this.Name = originaleName;


        }

        public override void toPrintExtraContent(IEprocResponse objResp, object OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {
            string originaleName = this.Name;

            base.toPrintExtraContent(objResp, OBJSESSION, params_, startPage, strHtmlHeader, strHtmlFooter, contaPagine);
            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            if (strFormat == "I")
            {
                this.Image = IIF(IsNull(Value), "", Value);
            }
            else
            {
                this.Value = IIF(IsNull(Value), "", Value);
            }

            this.Name = originaleName;

        }

        public override void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/") { }
        public override dynamic? RSValue()
        {
            Value = base.RSValue();
            return Value;
        }
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

        public override void UpdateFieldVisual(IEprocResponse objResp, string strDocument = "") { }


    }
}

