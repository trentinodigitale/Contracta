using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;
using static eProcurementNext.HTML.BasicFunction;


namespace eProcurementNext.HTML
{
    public class Fld_TextArea : Field, IField
    {

        public int Rows; //'-- righe della textarea

        public Fld_TextArea()
        {
            /* nel costruttore di tutti i field va inizializzato l'mp_itype con il proprio tipo di riferimento */
            this.mp_iType = 3;
            Style = "TextArea";
            Editable = true;
            Rows = 3;
            msg_errore_validate = "Valore non valido";
            regExp = "";
        }

        public override void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/")
        {
            if (!js.ContainsKey("ck_TextArea"))
            {
                js.Add("ck_TextArea", $@"<script src=""{Path}jscript/Field/ck_TextArea.js"" ></script>");

            }
            if (!js.ContainsKey("ck_Text"))
            {
                js.Add("ck_Text", $@"<script src=""{Path}jscript/Field/ck_Text.js"" ></script>");
            }
        }



        public override void Init(int iType, string oName = "", object? oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {
            base.Init(iType, oName, oValue, oDom, oumDom, oFormat, oEditable, oObbligatory, oValidazioneFormale);
            this.Value = CStr(oValue).Trim();
            Condition = " like ";
        }

        public override void Html(IEprocResponse objResp, bool? pEditable = null)
        {

            bool? vEditable;
            string strTempDesc;
            string strDesc;

            vEditable = Editable;
            if (pEditable != null)
            {
                vEditable = pEditable;
            }



            if (vEditable == false)
            {

                if (string.IsNullOrEmpty(this.Value))
                {


                    objResp.Write($@"<span id=""{Name} _V"">");
                    objResp.Write($@"&nbsp;");
                    objResp.Write($@"</span>");

                }
                else
                {

                    if (CStr(strFormat).Contains("nl", StringComparison.Ordinal))
                    {


                        objResp.Write($@"<span id=""{Name}_V""  class=""{Style}_NotEditable"" >");

                        objResp.Write((HtmlEncode(this.Value)));

                        objResp.Write($@"</span>");

                    }
                    else
                    {

                        long nC;
                        int iZ;

                        iZ = InStrVb6(1, strFormat, "Z");
                        if (iZ > 0)
                        {
                            nC = CInt(MidVb6(CStr(strFormat), iZ + 1, 2));
                        }
                        else
                        {
                            nC = 2000000000;
                        }




                        if ((CStr(this.Value).Length) > nC)
                        {

                            strDesc = this.Value;

                            objResp.Write($@"<span ");

                            objResp.Write($@"id=""{Name}_V"" title=""{HtmlEncodeValue(strDesc)}"" class=""{Style} _NotEditable""  >");

                            strDesc = Strings.Left(strDesc, (int)nC - 1) + "...";

                            if (strFormat.Contains("H", StringComparison.Ordinal))
                            {

                                //'-- Bonifico l'output per prevenire XSS
                                //'-- a meno che non � passata la format S che restituisce l'output cos� com'�
                                if (!string.IsNullOrEmpty(CStr(strDesc).Trim()) && (!strFormat.Contains("S", StringComparison.Ordinal)))
                                {
                                    strDesc = bonificaHtmlDaXSS(strDesc);
                                }

                                objResp.Write(strDesc);

                            }
                            else
                            {
                                objResp.Write(HtmlEncode(strDesc));
                            }


                            objResp.Write("</span>");

                        }
                        else
                        {


                            objResp.Write("<span ");

                            if (IsMasterPageNew())
                            {
                                objResp.Write($@"id=""{Name}_V"" title=""{ExtractTextFromHtml(bonificaHtmlDaXSS(this.Value))}"" class=""{Style}_NotEditable"" >");
                            }
                            else
                            {
                                objResp.Write($@"id=""{Name}_V"" class=""{Style}_NotEditable"" >");
                            }
                           

                            if (CStr(strFormat).Contains("H", StringComparison.Ordinal))
                            {

                                strDesc = this.Value;

                                //'-- Controllo di sicurezza sul valore contenuto nella text per prevenire xss
                                if (!string.IsNullOrEmpty(CStr(strDesc).Trim()) && (!strFormat.Contains("S", StringComparison.Ordinal)))
                                {
                                    strDesc = bonificaHtmlDaXSS(strDesc);
                                }


                                objResp.Write(strDesc);

                            }
                            else
                            {
                                objResp.Write(HtmlEncode(this.Value));
                            }


                            objResp.Write("</span>");

                        }

                    }
                }

                //'--se rischiesto dalla format (presenza acronimo TEC ) aggiungo il campo hidden che in questo caso �
                //'--una textarea nascosta
                if (CStr(strFormat).Contains("TEC", StringComparison.Ordinal))
                {

                    objResp.Write($@"<textarea width=""100%"" cols=""20"" rows=""{this.Rows}"" name=""{Name}"" id=""{Name}""");


                    objResp.Write($@" class=""display_none attrib_base""");

                    objResp.Write($@">");



                    objResp.Write(HtmlEncode(this.Value));

                    objResp.Write($@"</textarea>");

                }

            }
            else
            {

                //'-- per validazione w3c aggiungo attributo cols e gli assegno il suo valore di default (20)
                objResp.Write($@"<textarea width=""100%"" cols=""20"" rows=""{this.Rows}"" name=""{Name}"" id=""{Name}"" class=""{Style} width_100_percent"" ");
                if (MaxLen > 0)
                {
                    objResp.Write($@" onkeypress=""TA_MaxLen(this,{MaxLen} );"" ");
                    objResp.Write($@" onblur=""TA_MaxLen(this,{MaxLen} );"" ");
                }

                //'-- se � presente un'espressione regolare per validare il campo aggiunto anche la validazione lato client
                if (!string.IsNullOrEmpty(regExp) && disattivaValidazioneFormale == false)
                {
                    objResp.Write($@" onchange=""validateField('{EscapeSequenceJS(regExp)}',this);""");
                }

                objResp.Write(">");

                if (strFormat.Contains("H", StringComparison.Ordinal))
                {

                    strTempDesc = this.Value;

                    //'-- Controllo di sicurezza sul valore contenuto nella text per prevenire xss
                    if ((!string.IsNullOrEmpty(CStr(strTempDesc).Trim())) && (!strFormat.Contains("S", StringComparison.Ordinal)))
                    {
                        strTempDesc = bonificaHtmlDaXSS(strTempDesc);
                    }

                    objResp.Write(strTempDesc);


                }
                else
                {
                    objResp.Write(HtmlEncode(this.Value));
                }

                objResp.Write("</textarea>");

            }


        }

        public override void Excel(IEprocResponse objResp, bool? pEditable = null)
        {

            if (strFormat.Contains("H", StringComparison.Ordinal))
            {
                string strDesc;

                strDesc = this.Value;

                //'-- Bonifico l'output per prevenire XSS
                //'-- a meno che non � passata la format S che restituisce l'output cos� com'�
                if (!string.IsNullOrEmpty(CStr(strDesc).Trim()) && (!strFormat.Contains("S", StringComparison.Ordinal)))
                {
                    strDesc = bonificaHtmlDaXSS(strDesc);
                }

                objResp.Write(strDesc);

            }
            else
            {

                if (IsNumeric(HtmlEncode(this.Value)))
                {
                    objResp.Write($@"&nbsp;{HtmlEncode(this.Value)}");
                }
                else
                {
                    objResp.Write(HtmlEncode(this.Value));
                }

            }

        }

        /// <summary>
        /// '-- Funzione booleana atta a validare formalmente il campo
        /// </summary>
        public override bool validate()
        {

            var util = new Security.Validation();//CreateObject("CtlSecurity.Validation")    
            bool boolToReturn = true;

            if (CStr(this.Value) != "" && !string.IsNullOrEmpty(regExp)){

                boolToReturn = util.isValidValue(CStr(this.Value), 0, regExp);

            } 
    
            return boolToReturn;

        }

        public override void HtmlExtended2(IEprocResponse objResp, dynamic? Request = null, dynamic? session = null) { }
        public override void CaptionHtmlCenter(CommonModule.IEprocResponse objResp)
        {
            if (Editable || CStr(this.strFormat).Contains("TEC", StringComparison.Ordinal))
            {
                objResp.Write($@" for=""{HtmlEncode(this.Name)}""");
            }
        }
        public override void HtmlExtended3(IEprocResponse objResp, dynamic? Request = null, dynamic? session = null) { }

        public override void SetFilterDomain(string strFilter, string strSep = ",", bool InOut = true) { }
        public override void SetPrintDescription(string str) { }
        public override void SetSelectDescription(string str) { }
        public override void SetSelezionatiDescription(string str) { }
        public override void SetSenzaModali(string str) { }
        public override string SQLValue()
        {
            string temp = base.SQLValue();
            return "'" + temp.Replace("'", "''") + "'";
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
            Html(objResp, (pEditable == null) ? Editable : pEditable);
            this.Name = originaleName;

        }
        public override void toPrintExtraContent(IEprocResponse objResp, dynamic OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false) { }
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
            //strCause = "Entro nel case della textArea";
            this.Name = mp_row + Name; //' -- il nome viene passato perch� puo cambiare ad esempio nelle griglie per indicare la riga

            this.Value = CStr(IIF(IsNull(Value), "", Value));

            this.MaxLen = MaxLen;
            this.strFormat = strFormat;

            this.regExp = this.regExp;
            this.disattivaValidazioneFormale = !validazioneFormale;

            this.Html(objResp, (pEditable == null) ? Editable : pEditable);

            this.Name = originaleName;

        }
        public override void xml(IEprocResponse objResp, string tipo)
        {
            objResp.Write($@"<{XmlEncode(UCase(Name))} desc=""{XmlEncode(Caption)}"" type=""{getFieldTypeDesc(mp_iType)}"">");
            objResp.Write($@"{XmlEncode(CStr(Value).Trim())}");
            objResp.Write($@"</{XmlEncode(UCase(Name))}> ");
        }
        public override void UpdateFieldVisual(string objResp, string strDocument = "") { }

        public override void SetRows(int numRows)
        {
            base.SetRows(numRows);
            this.Rows = numRows;
        }


    }
}

