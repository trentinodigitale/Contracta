using eProcurementNext.CommonModule;
using eProcurementNext.Security;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Fld_Number : Field, IField
    {

        public static int Base = 2;
        public static int ColorSigned = 7;

        public int NumberTipology;

        private string mp_ConditionalStyle;
        private new int MaxLen = 0;

        public Fld_Number()
        {
            /* nel costruttore di tutti i field va inizializzato l'mp_itype con il proprio tipo di riferimento */
            this.mp_iType = 2; //'-- 2 = numerico , 7 = numerico colorato
            Style = "Fld_Number";
            Editable = true;
            strFormat = "";


            msg_errore_validate = "Valore non valido";
            regExp = "";
            disattivaValidazioneFormale = false;

        }

        public override void CaptionHtmlCenter(CommonModule.IEprocResponse objResp)
        {
            if (Editable)
                objResp.Write($@" for=""{HtmlEncode(this.Name)}_V""");
        }

        public override void Html(IEprocResponse objResp, bool? pEditable = null)
        {
            string strCause = string.Empty;

            try
            {

                bool? vEditable;

                strCause = "Setto vEditable";

                vEditable = Editable;
                if (pEditable != null)
                {
                    vEditable = pEditable;
                }

                string strLocFormat;
                strLocFormat = CStr(strFormat).Replace("~", "");

                dynamic tecnicalData;
                string viewDate;

                strCause = "Setto il tecnicalData";
                tecnicalData = this.Value;

                strCause = "Faccio la replace di ',' con il '.' su tecnicalData";
                tecnicalData = CStr(tecnicalData).Replace(",", ".");

                //'-- nel caso il valore numerico sia una stringa, siccome la forma tecnica è sempre espressa con il punto
                //'-- occorre verificare che il regional settings non indichi virgola, altrimenti falsa la conversione in numerico
                if (Value is string)
                {

                    strCause = "Tipo vbString. setto viewDate con format: " + strLocFormat;

                    if (CStr(0.5).Contains(",", StringComparison.Ordinal))
                    {
                        if (tecnicalData.Replace(".", ",") != "")
                        {
                            viewDate = Strings.Format(CDbl(tecnicalData.Replace(".", ",")), strLocFormat);
                        }
                        else
                        {
                            viewDate = "";
                        }
                    }
                    else
                    {
                        if (!string.IsNullOrEmpty(this.Value))
                        {
                            viewDate = Strings.Format(CDbl(this.Value), strLocFormat);
                        }
                        else
                        {
                            viewDate = "";
                        }
                    }

                }
                else
                {

                    viewDate = Strings.Format(this.Value, strLocFormat);

                }

                if (!CStr(0.5).Contains(CStr(sepDecimal), StringComparison.Ordinal))
                {
                    strCause = "sostituzioni su viewDate";
                    viewDate = viewDate.Replace(".", "A");
                    viewDate = viewDate.Replace(",", ".");
                    viewDate = viewDate.Replace("A", ",");
                }

                mp_ConditionalStyle = "";
                if (NumberTipology == ColorSigned)
                {
                    if (CDbl(this.Value) < 0)
                    {
                        mp_ConditionalStyle = "_NEG";
                    }
                    if (CDbl(this.Value) > 0)
                    {
                        mp_ConditionalStyle = "_POS";
                    }
                }

                strCause = "Inizio a scrivere l'html";
                //'-- campo nascosto per il recupero dei dati in formato tecnico
                objResp.Write($@"<input type=""hidden"" name=""{Name}""  id=""{Name}""");


                objResp.Write($@" class=""display_none attrib_base""");


                objResp.Write($@" value=""{tecnicalData}"" ");
                objResp.Write($@"/> ");

                strCause = "Aggiungo campo tecnico nascosto";

                //'-- inserisco un input hidden contenente informazioni tecniche di varia natura. questo per eliminare
                //'-- attributi non esistenti nello standard w3c. Gli attributi estesi saranno presenti come value
                //'-- della input hidden nella forma nomeAttributo#=#valoreAttributo#@#nomeAttributo#=#valoreAttributo
                try
                {
                    objResp.Write($@"<input type=""hidden"" id=""{Name}_extraAttrib"" value=""nd#=#{HtmlEncodeValue(CStr(numDecimal))}#@#ds#=#{HtmlEncodeValue(CStr(sepDecimal))}#@#format#=#{HtmlEncodeValue(strLocFormat)}""/>");
                }
                catch
                {

                }

                if (vEditable == false)
                {

                    strCause = "IF di non-editabile";


                    objResp.Write($@"<span ");

                    objResp.Write($@"class=""{Style}{mp_ConditionalStyle}"" id=""{Name}_V"">");

                    if (string.IsNullOrEmpty(viewDate))
                    {
                        objResp.Write($@"&nbsp;");
                    }
                    else
                    {
                        objResp.Write(HtmlEncode(viewDate));
                    }

                    objResp.Write($@"</span>");

                }
                else
                {

                    strCause = "IF di editabile. disegno campo a video";

                    //'-- campo visuale per la rappresentazione e l'input
                    objResp.Write($@"<input type=""text"" name=""{Name}_V"" id=""{Name}_V"" class=""{Style}{mp_ConditionalStyle}"" ");
                    objResp.Write($@" onblur=""ck_VN( this ,'{sepDecimal}',{numDecimal} );{mp_OnBlur}"" ");
                    objResp.Write($@" onfocus=""of_VN( this ,'{sepDecimal}',{numDecimal} );{mp_OnFocus}"" ");

                    objResp.Write($@" onchange=""try{{oc_VN( this ,'{sepDecimal}', {numDecimal} );}}catch(e){{}}");

                    //'-- se � presente un'espressione regolare per validare il campo aggiunto anche la validazione lato client
                    if (!string.IsNullOrEmpty(regExp) && disattivaValidazioneFormale == false)
                    {
                        objResp.Write($@"validateField('{EscapeSequenceJS(regExp)}',this);");
                    }

                    objResp.Write(mp_OnChange + @""" ");

                    if (this.MaxLen > 0)
                    {
                        objResp.Write($@" maxlength=""{this.MaxLen}"" ");
                    }
                    if (width > 0)
                    {
                        if (IsMasterPageNew())
                        {
                            objResp.Write($@" size=""{width}"" disableminwidth=""yes"" ");
                        }
                        else
                        {
                            objResp.Write($@" size=""{width}"" ");

                        }
                    }
                    objResp.Write($@" value=""");
                    objResp.Write(viewDate);
                    objResp.Write($@"""/>");

                }

            }
            catch (Exception ex)
            {
                throw new Exception($"Fld_number.html() - {strCause} - {ex.Message}", ex);
            }

        }
        public override void Init(int iType, string oName = "", object? oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {
            base.Init(iType, oName, oValue, oDom, oumDom, oFormat, oEditable, oObbligatory, oValidazioneFormale);

            this.NumberTipology = iType;
        }
        public override void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/")
        {
            if (!js.ContainsKey("getObj"))
            {
                js.Add("getObj", $@"<script src=""{Path}jscript/getObj.js"" ></script>");
            }
            if (!js.ContainsKey("ck_VN"))
            {
                js.Add("ck_VN", $@"<script src=""{Path}jscript/Field/ck_VN.js"" ></script>");
            }
        }
        public override dynamic? RSValue()
        {
            base.RSValue();
            if (this.Value.GetType() == typeof(string))
            {
                string a;
                a = Value;
                if (CStr(0.5).Contains(",", StringComparison.Ordinal))
                {
                    a = a.Replace(".", ",");
                }

                if (IsNumeric(a))
                {
                    return CDbl(a);
                }
                else
                {
                    if (strFormat.Contains("~", StringComparison.Ordinal))
                    {
                        return null; //'0#
                    }
                    else
                    {
                        return 0;//RSValue = 0#
                    }
                }
            }
            else
            {
                return Value;
            }
        }
        public override string SQLValue()
        {
            string strToReturn;

            Value = base.SQLValue();
            if (string.IsNullOrEmpty(Value) || IsNull(Value))
            {
                strToReturn = "null";
            }
            else
            {
                string strVal;
                strVal = Value;

                strToReturn = strVal.Replace(",", ".");

                //' Controllo se il valore non ha soltanto numeri,punti o "-" (segno di sottrazione)
                if (!IsNumeric(strToReturn))
                {
                    strToReturn = "null";
                }

            }
            return strToReturn;
        }
        public override string TechnicalValue()
        {

            if (this.Value == null)
            {
                return String.Empty;
            }
            else
            {
                return Strings.Replace(CStr(this.Value), ",", ".");
            }

        }
        public override void toPrint(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.toPrint(objResp, pEditable);
            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga
            this.Value = IIF(IsNull(Value), "", Value);

            this.Html(objResp, (pEditable == null) ? Editable : pEditable);

            this.Name = originaleName;

        }
        public override void toPrintExtraContent(IEprocResponse objResp, dynamic OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false) { }
        public override string TxtValue()
        {
            Value = base.TxtValue();
            string tecnicalData;
            string viewDate = "";

            string strLocFormat;
            strLocFormat = CStr(strFormat).Replace("~", "");

            tecnicalData = CStr(this.Value);
            if (!string.IsNullOrEmpty(CStr(tecnicalData)))
            {
                if (CStr(0.5).Contains(",", StringComparison.Ordinal))
                {
                    viewDate = Strings.Format(CDbl(tecnicalData.Replace(".", ",")), strLocFormat);
                }
                else
                {
                    viewDate = Strings.Format(CDbl(tecnicalData.Replace(",", ".")), strLocFormat);
                }
            }

            if (!CStr(0.5).Contains(CStr(sepDecimal), StringComparison.Ordinal))
            {
                viewDate = viewDate.Replace(".", "A");
                viewDate = viewDate.Replace(",", ".");
                viewDate = viewDate.Replace("A", ",");
            }


            return viewDate;
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
            //Dim tecnicalData As Variant
            dynamic SQLValue;


            if (!string.IsNullOrEmpty(CStr(Value)) && IsNull(Value) == false)
            {

                string strVal;
                strVal = CStr(Value);

                SQLValue = strVal.Replace(",", ".");

                //' Controllo se il valore non ha soltanto numeri,punti o "-" (segno di sottrazione)
                if (IsNumeric(SQLValue))
                {
                    objResp.Write(CStr(SQLValue));
                }

            }
            objResp.Write($@"</{XmlEncode(UCase(Name))}>");
        }
        public override void UpdateFieldVisual(IEprocResponse objResp, string strDocument = "")
        {

            string originaleName = this.Name;

            base.UpdateFieldVisual(objResp, strDocument);

            string locVal;

            locVal = CStr(Value).Replace(",", ".");

            mp_ConditionalStyle = "";
            if (NumberTipology == ColorSigned)
            {
                if (this.Value < 0)
                {
                    mp_ConditionalStyle = "_NEG";
                }
                if (this.Value > 0)
                {
                    mp_ConditionalStyle = "_POS";
                }
            }

            objResp.Write($@"<script language=""JavaScript""> ");


            if (!string.IsNullOrEmpty(strDocument))
            {
                objResp.Write($@"try{{{strDocument}.getObj('{Name}').className='{Style}{mp_ConditionalStyle}'}}catch(e){{}}; ");
                objResp.Write($@"try{{{strDocument}.getObj('{Name}_V').className='{Style}{mp_ConditionalStyle}'}}catch(e){{}}; ");
                objResp.Write($@"{strDocument}.SetNumericValue('{Name}','{locVal}'); ");
            }
            else
            {
                objResp.Write($@"try{{getObj('{Name}').className='{Style}{mp_ConditionalStyle}'}}catch(e){{}}; ");
                objResp.Write($@"try{{getObj('{Name}_V').className='{Style}{mp_ConditionalStyle}'}}catch(e){{}}; ");
                objResp.Write($@"SetNumericValue('{Name}','{locVal}'); ");
            }

            objResp.Write("</script>");

            this.Name = originaleName;
        }
        public override bool validate()
        {
            bool esito = true;

            Validation util = new Validation();

            if (!string.IsNullOrEmpty(CStr(this.Value)) && !string.IsNullOrEmpty(regExp))
            {

                return util.isValidValue(CStr(this.Value), 0, regExp);

            }

            return esito;
        }
        public override void Excel(CommonModule.IEprocResponse objResp, bool? pEditable = null)
        {
            bool? vEditable;
            vEditable = Editable;
            if (pEditable != null)
            {
                vEditable = pEditable;
            }

            //'Dim strApp As String
            dynamic tecnicalData;
            string viewDate;

            string strLocFormat;
            strLocFormat = strFormat.Replace("~", "");

            tecnicalData = CStr(this.Value);
            tecnicalData = tecnicalData.Replace(",", ".");

            //'-- nel caso il valore numerico sia una stringa, siccome la forma tecnica è sempre espressa con il punto
            //'-- occorre verificare che il regional settings non indichi virgola, altrimenti falsa la conversione in numerico
            if (Value is string)
            {

                if (CStr(0.5).Contains(",", StringComparison.Ordinal))
                {
                    if (tecnicalData.Replace(".", ",") != "")
                    {
                        viewDate = Strings.Format(CDbl(tecnicalData.Replace(".", ",")), strLocFormat);
                    }
                    else
                    {
                        viewDate = "";
                    }
                }
                else
                {
                    if (!string.IsNullOrEmpty(this.Value))
                    {
                        viewDate = Strings.Format(CDbl(this.Value), strLocFormat);
                    }
                    else
                    {
                        viewDate = "";
                    }
                }

            }
            else
            {

                viewDate = Strings.Format(this.Value, strLocFormat);

            }

            if (!CStr(0.5).Contains(sepDecimal, StringComparison.Ordinal))
            {
                viewDate = viewDate.Replace(".", "A");
                viewDate = viewDate.Replace(",", ".");
                viewDate = viewDate.Replace("A", ",");
            }

            objResp.Write(viewDate);
        }


    }
}

