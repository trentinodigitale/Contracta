using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Fld_Mail : Field, IField
    {
        private bool PrintMode;
        private new int MaxLen = 0;

        CommonDbFunctions cdf = new CommonDbFunctions();
        public Fld_Mail()
        {
            /* nel costruttore di tutti i field va inizializzato l'mp_itype con il proprio tipo di riferimento */
            this.mp_iType = 14;
            Style = "Text";
            Editable = true;
            msg_errore_validate = "Email non valida";
            disattivaValidazioneFormale = false;
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

            string strApp;
            //Dim obj As Object
            TSRecordSet rs;
            bool bIsPec = false;
            string status = "";
            string nome_image = "";
            long idpec = 0;

            //''vede se � PEC
            if (CStr(strFormat).Contains("PEC", StringComparison.Ordinal) && !string.IsNullOrEmpty(this.Value))
            {

                bIsPec = false;
                status = "";

                rs = cdf.GetRSReadFromQuery_($@"select * from CTL_Pec_Verify where eMail = '{CStr(this.Value).Replace("'", "''")}' order by id desc", ConnectionString);

                if (rs != null)
                {
                    if (!(rs.EOF && rs.BOF))
                    {
                        rs.MoveFirst();

                        if (CInt(rs.Fields["ispec"]) == 1)
                        {
                            bIsPec = true;
                        }

                        status = CStr(rs.Fields["Status"]);
                        idpec = CLng(rs.Fields["id"]);

                    }
                }

                if (bIsPec)
                {
                    nome_image = "PEC_SI";
                }
                else
                {
                    if (status == "Elaborated")
                    {
                        nome_image = "PEC_NO";
                    }
                    else
                    {
                        nome_image = "PEC_INWAIT";
                    }
                }

            }


            if (vEditable == false)
            {

                objResp.Write($@"<span class=""{Style}"" id=""{Name}_V"">");

                if (string.IsNullOrEmpty(this.Value))
                {
                    objResp.Write("&nbsp;");
                }
                else
                {

                    if (PrintMode == false)
                    {
                        objResp.Write($@"<a href=""mailto:{HtmlEncode(this.Value)}"">");
                    }

                    objResp.Write(HtmlEncode(this.Value));

                    if (PrintMode == false)
                    {
                        objResp.Write("</a>");
                    }

                }

                objResp.Write("</span> ");

                if (CStr(strFormat).Contains("T", StringComparison.Ordinal))
                {
                    objResp.Write($@"<input type=""hidden"" name=""{Name}""  id=""{Name}"" ");
                    objResp.Write($@" value=""{HtmlEncodeValue(CStr(this.Value))}"" ");
                    objResp.Write($@"/> ");
                }


            }
            else
            {

                objResp.Write($@"<input type=""text"" name=""{Name}"" id=""{Name}"" class=""{Style}"" ");
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

                if (!string.IsNullOrEmpty(mp_OnChange))
                {
                    objResp.Write($@" onchange=""{HtmlEncode(mp_OnChange)}{IIF(disattivaValidazioneFormale == false, @";verifyEmail(this);"" ", @"""")}");
                }
                else
                {

                    if (disattivaValidazioneFormale == false)
                    {
                        objResp.Write($@" onchange=""verifyEmail(this);""");
                    }

                }

                objResp.Write($@" value=""{HtmlEncodeValue(this.Value)}"" ");
                objResp.Write($@"/>");


                objResp.Write($@"<input type=""hidden"" id=""val_{HtmlEncodeValue(Name)}_extraAttrib"" value=""format#=#{HtmlEncodeValue(strFormat)}""/>");

            }

            if (CStr(strFormat).Contains("PEC", StringComparison.Ordinal) && !string.IsNullOrEmpty(this.Value))
            {

                objResp.Write($@"&nbsp;&nbsp;");
                objResp.Write($@"<img alt=""");

                if (bIsPec)
                {
                    objResp.Write($@"l&apos;email &egrave; pec");
                }
                else
                {
                    if (status == "Elaborated")
                    {
                        objResp.Write($@"l&apos;email non &egrave; pec");
                    }
                    else
                    {
                        objResp.Write($@"l&apos;email &egrave; in attesa di verifica pec");
                    }
                }

                objResp.Write(@"""");

                if (PrintMode == false)
                {
                    //'--se presente aggiungo link pagina info pec
                    if (CStr(strFormat).Contains("PEC_I", StringComparison.Ordinal) && idpec > 0)
                    {
                        objResp.Write($@" onclick=""InfoMailPec('{Path}' , {idpec});"" ");
                    }
                }

                objResp.Write($@" class=""IMG_MAILPEC"" src=""{PathImage}{nome_image}.gif""/> ");

            }

            //Html = strApp
        }
        public override void Init(int iType, string oName = "", object? oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {
            base.Init(iType, oName, oValue, oDom, oumDom, oFormat, oEditable, oObbligatory, oValidazioneFormale);
            validazioneFormale = true;
            Condition = " like ";
        }
        public override void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/")
        {
            if (!js.ContainsKey("ck_mail"))
            {
                js.Add("ck_mail", $@"<script src=""{Path}jscript/Field/ck_mail.js"" ></script>");
            }
            if (!js.ContainsKey("ck_Text"))
            {
                js.Add("ck_Text", $@"<script src=""{Path}jscript/Field/ck_Text.js"" ></script>");
            }
        }
        public override string SQLValue()
        {
            Value = base.SQLValue();
            return "'" + CStr(Value).Replace("*", "%").Replace("'", "''") + "'";
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
        public override void toPrintExtraContent(IEprocResponse objResp, dynamic OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false) { }
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
        public override void UpdateFieldVisual(IEprocResponse objResp, string strDocument = "")
        {
            string originaleName = this.Name;

            base.UpdateFieldVisual(objResp, strDocument);

            objResp.Write($@"<script type=""text/javascript""> ");

            if (!string.IsNullOrEmpty(strDocument))
            {

                objResp.Write($@"try{{{strDocument}.getObj('{Name}').className='{Style}'}}catch(e){{}}; ");
                objResp.Write($@"try{{{strDocument}.getObj('{Name}_V').className='{Style}'}}catch(e){{}}; ");
                objResp.Write($@"{strDocument}.SetTextValue('{Name}','{CStr(Value).Replace(@"'", @"\'")}'); ");

            }
            else
            {

                objResp.Write($@"try{{getObj('{Name}').className='{Style}'}}catch(e){{}}; ");
                objResp.Write($@"try{{getObj('{Name}_V').className='{Style}'}}catch(e){{}}; ");
                objResp.Write($@"SetTextValue('{Name}','{CStr(Value).Replace(@"'", @"\'")}'); ");

            }

            objResp.Write("</script>");

            this.Name = originaleName;

        }
        public override bool validate()
        {
            string[] vet;
            int k;
            string tmpVal;

            if (!string.IsNullOrEmpty(this.Value))
            {

                //'-- se � un campo PEC e c'� un; (quindi presumibilmente si stanno inserendo pi� email nello stesso campo)
                if (CStr(strFormat).Contains("PEC", StringComparison.Ordinal) && CStr(this.Value).Contains(";", StringComparison.Ordinal))
                {

                    return false;

                }

                if (CStr(this.Value).Contains(";", StringComparison.Ordinal))
                {

                    vet = Strings.Split(this.Value, ";");

                    //'-- itero sulle N email inserite per validarle tutte
                    for (k = 0; k < vet.Length; k++)
                    {// To UBound(vet)

                        if (!string.IsNullOrEmpty(vet[k]))
                        {

                            tmpVal = CStr(vet[k]).Trim();

                            if (isValidEmail(tmpVal) == false)
                            {
                                return false;
                            }

                        }

                    }

                }
                else
                {

                    //'-- se c'� 1 sola email
                    return isValidEmail(this.Value);

                }

            }

            return true;
        }



        public bool isValidEmail(string strCheck)
        {

            bool bCK = false;
            string strDomainType;
            string strDomainName;
            int i;

            const string sInvalidChars = @"!#$%^&*()=+{}[]|\;:'/?>,< ";

            bCK = !strCheck.Contains("\"", StringComparison.Ordinal); //'Check to see if there is a double quote

            if (!bCK)
            {
                return bCK;
            }

            bCK = !strCheck.Contains("..", StringComparison.Ordinal); //'Check to see if there are consecutive dots

            if (!bCK)
            {
                return bCK;
            }

            //' Check for invalid characters.
            if (strCheck.Length > sInvalidChars.Length)
            {
                for (i = 0; i < sInvalidChars.Length; i++)
                {
                    if (strCheck.Contains(sInvalidChars[i], StringComparison.Ordinal))
                    { //(InStrVB6(strCheck, MidVB6(sInvalidChars, i, 1)) > 0) {
                        bCK = false;
                        return bCK;
                    }
                }
            }
            else
            {
                for (i = 0; i < strCheck.Length; i++)
                {//i = 1 To Len(strCheck) {
                    if (sInvalidChars.Contains(strCheck[i], StringComparison.Ordinal))
                    { //InStr(sInvalidChars, Mid(strCheck, i, 1)) > 0 {
                        bCK = false;
                        return bCK;
                    }
                }
            }

            if (strCheck.Contains("@", StringComparison.Ordinal))
            { //'Check for an @ symbol
                bCK = Len(Strings.Left(strCheck, InStrVb6(1, strCheck, "@") - 1)) > 0;
            }
            else
            {
                bCK = false;
            }

            if (!bCK)
            {
                return bCK;
            }

            strCheck = Strings.Right(strCheck, Len(strCheck) - InStrVb6(1, strCheck, "@"));
            bCK = !strCheck.Contains("@", StringComparison.Ordinal);//'Check to see if there are too many @'s
            if (!bCK)
            {
                return bCK;
            }

            strDomainType = Strings.Right(strCheck, Len(strCheck) - InStrVb6(1, strCheck, "."));
            bCK = Len(strDomainType) > 0 && InStrVb6(1, strCheck, ".") < Len(strCheck);
            if (!bCK)
            {
                return bCK;
            }

            strCheck = Strings.Left(strCheck, Len(strCheck) - Len(strDomainType) - 1);
            while (!(InStrVb6(1, strCheck, ".") <= 1))
            {
                if (Len(strCheck) >= InStrVb6(1, strCheck, "."))
                {
                    strCheck = Strings.Left(strCheck, Len(strCheck) - (InStrVb6(1, strCheck, ".") - 1));
                }
                else
                {
                    bCK = false;
                    return bCK;
                }
            }

            if (strCheck == "." || Len(strCheck) == 0)
            {
                bCK = false;
            }


            return bCK;
        }


    }
}

