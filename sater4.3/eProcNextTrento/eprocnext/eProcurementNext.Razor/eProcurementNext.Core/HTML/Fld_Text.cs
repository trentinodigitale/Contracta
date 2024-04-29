using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Fld_Text : Field, IField
    {

        public Fld_Text()
        {
            /* nel costruttore di tutti i field va inizializzato l'mp_itype con il proprio tipo di riferimento */
            this.mp_iType = 1;

            Style = "Text";
            Editable = true;
            msg_errore_validate = "Valore non valido";
            regExp = "";
            disattivaValidazioneFormale = false;

        }

        public override void Init(int iType, string oName = "", object? oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {

            base.Init(iType, oName, oValue, oDom, oumDom, oFormat, oEditable, oObbligatory, oValidazioneFormale);

            this.Condition = " like ";

            if (oValue is not null)
	            this.Value = ((string)oValue).Trim();
        }

        /// <summary>
        /// metodo per attivare l'update del campo
        /// </summary>
        /// <param name="objResp"></param>
        /// <param name="strDocument"></param>
        public override void UpdateFieldVisual(CommonModule.IEprocResponse objResp, string strDocument = "")
        {
            string originaleName = this.Name;

            base.UpdateFieldVisual(objResp, strDocument);

            objResp.Write($@"<script type=""text/javascript""> ");

            if (strDocument != "")
            {

                objResp.Write($@"try{{{strDocument}.getObj('{Name}').className='{Style}'}}catch(e){{}}; ");
                objResp.Write($@"try{{{strDocument}.getObj('{Name}_V').className='{Style}'}}catch(e){{}}; ");

                objResp.Write($@"{strDocument}.SetTextValue('{Name}','{Strings.Replace(CStr(Value), "'", "\'")}'); ");
            }
            else
            {
                objResp.Write($@"try{{getObj('{Name}').className='{Style}'}}catch(e){{}}; ");
                objResp.Write($@"try{{getObj('{Name}_V').className='{Style}'}}catch(e){{}}; ");
                objResp.Write($@"SetTextValue('{Name}','{Strings.Replace(Value, "'", "\'")}'); ");
            }

            objResp.Write($@"</script>");

            this.Name = originaleName;

        }

        public override void toPrint(CommonModule.IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            bool? vEditable = Editable;
            string strVal = "";

            if (pEditable != null)
            {
                vEditable = pEditable;
            }

            string strValue = CStr(Value);

            if (string.IsNullOrEmpty(strValue))
            {
                Value = DefaultValue;
            }

            if (umDomain != null)
            {
                int ind = InStrVb6(1, Value, "#");
                strVal = MidVb6(Value, ind + 1);
            }
            else
            {
                strVal = IIF(IsNull(Value), "", Value);
            }

            this.Name = this.mp_row + Name; // -- il nome viene passato perchè puo cambiare ad esempio nelle griglie per indicare la riga
            this.Value = strVal;

            Html(objResp, pEditable);

            this.Name = originaleName;

        }


        /// <summary>
        /// Funzione per la validazione formale dei campi.
        /// Ritorna stringa vuota se tutto OK, viceversa il messaggio di errore
        /// </summary>
        /// <returns></returns>
        public override bool validate()
        {
            if (!string.IsNullOrEmpty(Value) && !string.IsNullOrEmpty(this.regExp))
            {
                eProcurementNext.Security.Validation util = new eProcurementNext.Security.Validation();
                return util.isValidValue(Value, 0, regExp);
            }

            return true;
        }

        public override void CaptionHtmlCenter(IEprocResponse objResp)
        {

            if (Editable)
                objResp.Write($@" for=""{HtmlEncode(this.Name)}""");

        }

        /// <summary>
        /// ritorna il codice html del valore
        /// </summary>
        /// <param name="objResp"></param>
        /// <param name="pEditable"></param>
        public void Html(CommonModule.IEprocResponse objResp, dynamic pEditable = null)
        {

            bool vEditable;
            vEditable = Editable;
            if (pEditable != null)
            {
                vEditable = pEditable;
            }

            if (vEditable == false)
            {

                objResp.Write($@"<span ");
                objResp.Write($@"class=""{Style}"" id=""{Name}_V"" ");

                if (string.IsNullOrEmpty(Value))
                {

                    objResp.Write($@">");
                    objResp.Write($@"&nbsp;");
                }
                else
                {

                    long nC = 0;
                    int iZ = 0;


                    iZ = Strings.InStr(1, strFormat, "Z");

                    //Se è presente la lettera Z nella format ed i suoi 2 caratteri successivi sono numerici
                    if (iZ > 0)
                    {
                        string strTmpLenZ = Strings.Mid(strFormat, iZ + 1, 2);
                        if (IsNumeric(strTmpLenZ))
                            nC = CInt(strTmpLenZ);
                    }
                    else
                    {
                        nC = 2000000000;
                    }

                    string strDesc;

                    if (Strings.Len(Value) > nC)
                    {
                        strDesc = Value;
                        objResp.Write($@" title=""{HtmlEncodeValue(strDesc)}"">");
                        strDesc = $"{Strings.Left(strDesc, (int)(nC - 1))}...";

                        if (Strings.InStr(strFormat, "H") > 0)
                        {
                            //'-- Controllo di sicurezza sul valore contenuto nella text per prevenire xss
                            if (Strings.Trim(CStr(strDesc)) != "")
                            {
                                strDesc = bonificaHtmlDaXSS(strDesc);
                            }

                            objResp.Write($@"{strDesc}");

                        }
                        else
                        {

                            objResp.Write(HtmlEncode(strDesc));

                        }

                    }
                    else
                    {

                        objResp.Write($@">");

                        if (Strings.InStr(strFormat, "H") > 0)
                        {

                            strDesc = Value;

                            //'-- Controllo di sicurezza sul valore contenuto nella text per prevenire xss
                            if (Strings.Trim(CStr(strDesc)) != "")
                            {
                                strDesc = bonificaHtmlDaXSS(strDesc);
                            }

                            objResp.Write($@"{strDesc}");

                        }
                        else
                        {

                            objResp.Write(HtmlEncode(Value));

                        }

                    }


                }


                objResp.Write($@"</span> ");


                objResp.Write($@"<input type=""hidden"" name=""{Name}""  id=""{Name}"" ");
                objResp.Write($@" value=""{HtmlEncodeValue(Value)}"" ");
                objResp.Write($@"/> ");


            }
            else
            {

                if (Strings.InStr(1, strFormat, "P") > 0)
                {
                    objResp.Write($@"<input type=""PASSWORD"" name=""{Name}"" id=""{Name}"" class=""{Style}"" ");
                }
                else
                {
                    if (IsMasterPageNew() && this.Value != null && !string.IsNullOrEmpty(this.Help))
                    {
                        objResp.Write($@"<input type=""text"" placeholder=""{this.Help}"" name=""{Name}"" id=""{Name}"" class=""{Style}"" ");
                    }
                    else
                    {
                        objResp.Write($@"<input type=""text"" name=""{Name}"" id=""{Name}"" class=""{Style}"" ");
                    }

                    //'-- se � presente un'espressione regolare per validare il campo aggiunto anche la validazione lato client
                    if (!string.IsNullOrEmpty(regExp) && disattivaValidazioneFormale == false)
                    {

                        objResp.Write($@" onchange=""validateField('{EscapeSequenceJS(regExp)}',this);{CStr(mp_OnChange)}"" ");

                    }

                }

                if (MaxLen > 0)
                {
                    objResp.Write($@" maxlength=""{MaxLen}"" ");
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

                if (string.IsNullOrEmpty(regExp) && !string.IsNullOrEmpty(mp_OnChange))
                {
                    objResp.Write($@" onchange=""{mp_OnChange}"" ");
                }

                objResp.Write($@" value=""{HtmlEncodeValue(Value)}""/>");


            }


        }
        public override void HtmlExtended(IEprocResponse objResp, dynamic? Request = null)
        {
        }

        public override void HtmlExtended2(IEprocResponse objResp, dynamic? Request = null, dynamic? session = null)
        {
        }

        public override void HtmlExtended3(IEprocResponse objResp, dynamic? Request = null, dynamic? session = null)
        {
        }

        public override void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/")
        {
            if (!js.ContainsKey("ck_Text"))
                js.Add("ck_Text", $@"<script src=""{Path}jscript/Field/ck_Text.js""></script>");
        }

        public override dynamic? RSValue()
        {
            return base.RSValue();
        }

        public override void SetFilterDomain(string strFilter, string strSep = ",", bool InOut = true)
        {
        }

        public override void SetPrintDescription(string str)
        {
        }

        public override void SetSelectDescription(string str)
        {

        }

        public override void SetSelezionatiDescription(string str)
        {
        }

        public override void SetSenzaModali(string str)
        {

        }

        /// <summary>
        /// ritorna il valore del campo espresso correttamente per l'SQL
        /// </summary>
        /// <returns></returns>
        public override string SQLValue()
        {
            Value = base.SQLValue();
            return $"'{Strings.Replace(Value, "'", "''")}'";
        }

        public override void toPrintExtraContent(IEprocResponse objResp, dynamic OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {
        }

        public override string TxtValue()
        {
            return base.TxtValue();
        }

        public override string validateField()
        {
            return base.validateField();
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

        public override void Excel(CommonModule.IEprocResponse objResp, bool? pEditable = null)
        {

            strFormat = strFormat == null ? "" : strFormat;

            if (strFormat.ToUpper().Contains('H', StringComparison.Ordinal))
            {
                string strDesc = this.Value;
                if (!string.IsNullOrEmpty(strDesc) && strFormat.ToUpper().Contains('S', StringComparison.Ordinal))
                {
                    strDesc = bonificaHtmlDaXSS(strDesc);
                }

                objResp.Write(CStr(strDesc));

            }
            else
            {
                if (IsNumeric(HtmlEncode(CStr(this.Value))))
                    objResp.Write("&nbsp;" + HtmlEncode(CStr(this.Value)));
                else
                    objResp.Write(HtmlEncode(this.Value));
            }

        }

        public override void ValueHtml(IEprocResponse objResp, bool? pEditable = null)
        {
            //dynamic strVal = IIF(IsNull(this.Value), "", this.Value);
            //dynamic strVal = String.IsNullOrEmpty(this.Value) ? "" : this.Value; // Claudio 01/06/2022: genera errore se viene passato un intero

            string strVal = CStr(this.Value);

            //if (this.Value != null)
            //{
            //    if (this.Value is int)
            //    {
            //        strVal = this.Value.ToString();
            //    }
            //    else if (this.Value is string)
            //    {
            //        if (!String.IsNullOrEmpty(this.Value))
            //        {
            //            strVal = this.Value;
            //        }
            //    }
            //}

            // = String.IsNullOrEmpty(this.Value.ToString()) ? "" : this.Value;

            string originaleName = this.Name;

            this.Name = mp_row + Name; // ' -- il nome viene passato perchè puo cambiare ad esempio nelle griglie per indicare la riga
            this.Value = CStr(strVal);
            this.disattivaValidazioneFormale = !validazioneFormale;

            Html(objResp, (pEditable == null) ? Editable : pEditable);

            this.Name = originaleName;

        }

        public override void xml(IEprocResponse objResp, string tipo)
        {
            objResp.Write($@"<{XmlEncode(UCase(Name))} desc=""{XmlEncode(CStr(Caption))}"" type=""{getFieldTypeDesc(mp_iType)}"">");
            objResp.Write($@"{XmlEncode(CStr(Value).Trim())}");
            objResp.Write($@"</{XmlEncode(UCase(Name))}>");
        }

    }
}

