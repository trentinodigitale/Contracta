using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Fld_Url : Field, IField
    {

        private bool PrintMode;
        private new int MaxLen = 0;

        public Fld_Url()
        {
            /* nel costruttore di tutti i field va inizializzato l'mp_itype con il proprio tipo di riferimento */
            this.mp_iType = 13;
            Style = "Field_Url";
            Editable = true;
            PrintMode = false;
        }

        public override void CaptionHtmlCenter(CommonModule.IEprocResponse objResp)
        {
            if (Editable)
                objResp.Write($@" for=""{HtmlEncode(this.Name)}""");
        }
        public override void Html(IEprocResponse objResp, bool? pEditable = null)
        {
            bool? vEditable;
            vEditable = Editable;
            if (pEditable != null)
            {
                vEditable = pEditable;
            }

            if (vEditable == false)
            {


                objResp.Write("<span ");

                objResp.Write($@"class=""{Style}"" id=""{Name}_V"" ");

                if (string.IsNullOrEmpty(Value))
                {

                    objResp.Write($@">");
                    objResp.Write($@"&nbsp;");
                }
                else
                {

                    long nC;
                    int iZ;


                    iZ = InStrVb6(1, strFormat, "Z");
                    if (iZ > 0)
                    {
                        nC = CLng(MidVb6(strFormat, iZ + 1, 2));
                    }
                    else
                    {
                        nC = 2000000000;
                    }

                    string strDesc;
                    strDesc = CStr(this.Value);

                    if (Len(this.Value) > nC)
                    {


                        objResp.Write($@" title=""{HtmlEncodeValue(strDesc)}"">");
                        strDesc = Strings.Left(strDesc, CInt(nC) - 1) + "...";


                    }
                    else
                    {

                        objResp.Write(">");


                    }

                    //'--disegno ancora per il link
                    //'--nell'href metto il value intero altrimenti troncherei l'url
                    if (PrintMode == false)
                    {
                        objResp.Write($@"<a target=""_blank"" href=""{HtmlEncode(this.Value)}"">");
                    }

                    objResp.Write(HtmlEncode(strDesc));

                    if (PrintMode == false)
                    {
                        objResp.Write($@"</a>");
                    }



                }


                objResp.Write("</span> ");

                //'--campo nascosto che contiene il valore tecnico
                objResp.Write($@"<input type=""hidden"" name=""{Name}""  id=""{Name}"" ");
                objResp.Write($@" value=""{HtmlEncodeValue(this.Value)}"" ");
                objResp.Write($@"/> ");


            }
            else
            {


                objResp.Write($@"<input type=""text"" name=""{Name}"" id=""{Name}"" class=""{Style}"" ");

                //'-- se � presente un'espressione regolare per validare il campo aggiunto anche la validazione lato client
                if (!string.IsNullOrEmpty(regExp) && disattivaValidazioneFormale == false)
                {

                    objResp.Write($@" onchange=""validateField('{EscapeSequenceJS(regExp)}',this);{CStr(mp_OnChange)}"" ");

                }



                if (this.MaxLen > 0)
                {
                    objResp.Write($@" maxlength=""{this.MaxLen}"" ");
                }
                if (width > 0)
                {
                    if (IsMasterPageNew())
                    {

                    }
                    else
                    {
                        objResp.Write($@" size=""{width}"" ");

                    }
                }

                if (string.IsNullOrEmpty(regExp) && !string.IsNullOrEmpty(mp_OnChange))
                {
                    objResp.Write($@" onchange=""{mp_OnChange}"" ");
                }

                objResp.Write($@" value=""{HtmlEncodeValue(this.Value)}""/>");


            }
        }
        public override void Init(int iType, string oName = "", object? oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {
            base.Init(iType, oName, oValue, oDom, oumDom, oFormat, oEditable, oObbligatory, oValidazioneFormale);
            Condition = " like ";
        }
        public override void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/") { }
        public override string SQLValue()
        {
            base.SQLValue();
            return $@"'{CStr(Value).Replace("*", "%").Replace("'", "''")}'";
        }
        public override string TechnicalValue()
        {
            return IIF(IsNull(this.Value), "", this.Value);
        }
        public override void toPrint(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.toPrint(objResp, pEditable);
            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            this.Value = IIF(IsNull(Value), "", Value);

            PrintMode = true;
            this.Html(objResp, (pEditable == null) ? Editable : pEditable);

            this.Name = originaleName;
        }
        public override void ValueExcel(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueExcel(objResp, pEditable);
            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            this.Value = IIF(IsNull(Value), "", Value);

            objResp.Write(HtmlEncode(this.TxtValue()));

            this.Name = originaleName;
        }
        public override void ValueHtml(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueHtml(objResp, pEditable);

            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            this.Value = IIF(IsNull(Value), "", Value);
            this.disattivaValidazioneFormale = !validazioneFormale;

            this.Html(objResp, (pEditable == null) ? Editable : pEditable);

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
            objResp.Write(HtmlEncode(this.Value));
        }

        public override void UpdateFieldVisual(IEprocResponse objResp, string strDocument = "") { }


    }
}

