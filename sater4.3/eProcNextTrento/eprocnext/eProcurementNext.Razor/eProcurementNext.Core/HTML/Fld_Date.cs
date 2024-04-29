using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Fld_Date : Field, IField
    {

        public const int Base = 6;
        public const int Extended = 22;

        public int DataTipology;

        private string mp_PredefiniteVisualDescription;
        private string pathScript;
        private new int MaxLen;

        public Fld_Date()
        {
            /* nel costruttore di tutti i field va inizializzato l'mp_itype con il proprio tipo di riferimento */
            this.mp_iType = 6;// anche 22 
            Style = "Date";
            Editable = true;
            strFormat = "";
            this.MaxLen = 10;
            mp_PredefiniteVisualDescription = "";
            pathScript = "../ctl_library/";
        }

        public override void CaptionHtmlCenter(CommonModule.IEprocResponse objResp)
        {
            if (Editable)
                objResp.Write($@" for=""{HtmlEncode(this.Name)}""");
        }
        public override void Html(IEprocResponse objResp, bool? pEditable = null)
        {
            string strApp;
            bool? vEditable;
            string[] aInfo;
            string tecnicalData = String.Empty;

            vEditable = Editable;
            if (pEditable != null)
            {
                vEditable = pEditable;
            }

            SetDefault();


            if (vEditable == false)
            {


                objResp.Write($@"<span ");


                objResp.Write($@"id=""{Name}_L"">");

                if (string.IsNullOrEmpty(CStr(this.Value)) || IsNull(this.Value))
                {
                    objResp.Write($@"&nbsp;");
                }
                else
                {

                    if (this.Value.GetType() == typeof(DateTime))
                    {
                        tecnicalData = DateToStr(this.Value);

                    }
                    else
                    {
                        tecnicalData = IIF(IsNull(this.Value), "", this.Value);

                    }

                    //se � una data estesa x il valore minimo recupero il multiliguismo associato al valore
                    if (DataTipology == Extended && Strings.Left(tecnicalData, 10) == "1900-01-01")
                    {

                        objResp.Write(mp_PredefiniteVisualDescription);

                    }
                    else
                    {

                        if (this.Value.GetType() == typeof(DateTime))
                        {
                            objResp.Write(Strings.Format(this.Value, strFormat));

                        }
                        else
                        {

                            objResp.Write(Strings.Format(StrToDate(this.Value), strFormat));

                        }

                    }

                }


                objResp.Write($@"</span>");


                // campo nascosto per il recupero dei dati in formato tecnico
                if (this.Value.GetType() == typeof(DateTime))
                {
                    tecnicalData = DateToStr(this.Value);

                }
                else
                {
                    tecnicalData = IIF(IsNull(this.Value), "", this.Value);

                }

                objResp.Write($@"<input type=""hidden""");


                objResp.Write($@" class=""display_none attrib_base""");


                objResp.Write($@" name=""{Name}""  id=""{Name}"" ");

                objResp.Write($@" value=""{tecnicalData}"" ");
                objResp.Write($@"/> ");

                //// inserisco un input hidden contenente informazioni tecniche di varia natura. questo per eliminare
                //// attributi non esistenti nello standard w3c. Gli attributi estesi saranno presenti come value
                //// della input hidden nella forma nomeAttributo#=#valoreAttributo#@#nomeAttributo#=#valoreAttributo
                objResp.Write($@"<input type=""hidden"" id=""{Name}_extraAttrib"" value=""f#=#{HtmlEncodeValue(CStr(strFormat))}""/>");


            }
            else
            {


                string viewDate = "";
                string strFormatData = "";
                string strFormatTime = "";

                string[] ainfo1;


                ainfo1 = Strings.Split(strFormat, " ");
                if (ainfo1.Length > 0)
                {
                    strFormatData = Trim(ainfo1[0]);
                    if (ainfo1.Length == 2)
                    { // UBound(ainfo1) = 1
                        strFormatTime = Trim(ainfo1[1]);
                    }

                    if (Value.GetType() == typeof(DateTime))
                    {
                        try
                        {
                            tecnicalData = DateToStr(this.Value);
                            viewDate = Strings.Format(this.Value, strFormatData);
                        }
                        catch (Exception ex)
                        {

                        }
                    }
                    else
                    {
                        tecnicalData = IIF(IsNull(this.Value), "", this.Value);
                        if (this.Value != "")
                        {
                            viewDate = Strings.Format(StrToDate(this.Value), strFormatData);
                        }
                    }
                }
                else
                {
                    tecnicalData = "1900-01-01";
                }



                if (Strings.Left(tecnicalData, 10) == "1900-01-01" && DataTipology == Extended)
                {
                    viewDate = mp_PredefiniteVisualDescription;
                }

                // campo nascosto per il recupero dei dati in formato tecnico
                objResp.Write($@"<input type=""hidden"" ");


                objResp.Write($@" class=""display_none attrib_base""");


                objResp.Write($@" name=""{Name}""  id=""{Name}"" ");

                objResp.Write($@" value=""{tecnicalData}"" ");
                objResp.Write($@"/> ");

                //// inserisco un input hidden contenente informazioni tecniche di varia natura. questo per eliminare
                //// attributi non esistenti nello standard w3c. Gli attributi estesi saranno presenti come value
                //// della input hidden nella forma nomeAttributo#=#valoreAttributo#@#nomeAttributo#=#valoreAttributo
                objResp.Write($@"<input type=""hidden"" id=""{Name}_extraAttrib"" value=""f#=#{HtmlEncodeValue(CStr(strFormat))}""/>");

                // campo visuale per la rappresentazione e l'input
                if (IsMasterPageNew())
                {
                    objResp.Write($@"<input type=""text"" name=""{Name}_V""  id=""{Name}_V"" class=""{Style} date_width DateFaseII"" onclick=""showDatePickerFaseII('{Name}');return false;"" ");

                }
                else
                {
                    objResp.Write($@"<input type=""text"" name=""{Name}_V""  id=""{Name}_V"" class=""{Style} date_width"" ");

                }

                if (DataTipology == Extended)
                {
                    objResp.Write($@" onblur=""javascript:ck_VD_Ext( this );"" PredefiniteVisualDescription=""{mp_PredefiniteVisualDescription}""");
                }
                else
                {
                    objResp.Write($@" onblur=""javascript:ck_VD( this );"" ");
                }

                // se passato onchange lo aggiungo al controllo
                if (!String.IsNullOrEmpty(mp_OnChange))
                {

                    //aggiungo funzione per aggiornare il campo tecnico
                    if (DataTipology == Extended)
                    {

                        objResp.Write($@" onchange=""ck_VD_Ext( this ); {CStr(mp_OnChange)}"" ");

                    }
                    else
                    {

                        objResp.Write($@" onchange=""ck_VD( this ); {CStr(mp_OnChange)}"" ");

                    }
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


                objResp.Write($@" value=""{viewDate}"" ");
                objResp.Write($@"/>");
                if (IsMasterPageNew())
                {
                    objResp.Write($@"<input type=""button"" class=""FldExtDom_button DateFaseII"" alt=""Inserisci data"" value=""...""  id=""{Name}_button"" name=""{Name}_button"" onclick=""showDatePickerFaseII('{Name}');return false;""/>");
                }
                else
                {
                    objResp.Write($@"<input type=""button"" class=""FldExtDom_button"" alt=""Inserisci data"" value=""...""  id=""{Name}_button"" name=""{Name}_button"" onclick=""Run_Calendario( '{Name}', '{pathScript}../Functions' , '');""/>");
                }
                

                //campi per rappresentare il time
                if (strFormatTime.Contains("hh", StringComparison.Ordinal) || strFormatTime.Contains("HH", StringComparison.Ordinal))
                {
                    if (IsMasterPageNew())
                    {
                        objResp.Write($@" hh <input type=""text"" name=""{Name}_HH_V""  id=""{Name}_HH_V"" class=""TextTime DateFaseII"" ");
                    }
                    else
                    {
                        objResp.Write($@" hh <input type=""text"" name=""{Name}_HH_V""  id=""{Name}_HH_V"" class=""TextTime"" ");

                    }
                    objResp.Write($@" onblur=""javascript:ck_HH_VD( '{Name}' );"" maxlength=""2"" value=""{Strings.Mid(tecnicalData, 12, 2)}""/>");
                }

                if (strFormatTime.Contains("mm", StringComparison.Ordinal))
                {
                    if (IsMasterPageNew())
                    {
                        objResp.Write($@" mm <input type=""text"" name=""{Name}_MM_V""  id=""{Name}_MM_V"" class=""TextTime DateFaseII"" ");
                    }
                    else
                    {
                        objResp.Write($@" mm <input type=""text"" name=""{Name}_MM_V""  id=""{Name}_MM_V"" class=""TextTime"" ");

                    }
                    objResp.Write($@" onblur=""javascript:ck_MM_VD ('{Name}' );"" maxlength=""2"" value=""{Strings.Mid(tecnicalData, 15, 2)}""/>");
                }

                if (strFormatTime.Contains("ss", StringComparison.Ordinal))
                {
                    if (IsMasterPageNew())
                    {
                        objResp.Write($@" ss <input type=""text"" name=""{Name}_SS_V""  id=""{Name}_SS_V"" class=""TextTime DateFaseII"" ");
                    }
                    else
                    {
                        objResp.Write($@" ss <input type=""text"" name=""{Name}_SS_V""  id=""{Name}_SS_V"" class=""TextTime"" ");
                    }

                    string Lsec;
                    Lsec = Strings.Mid(tecnicalData, 18, 2);
                    if (string.IsNullOrEmpty(Lsec))
                    {
                        Lsec = "00";
                    }

                    objResp.Write($@" onblur=""javascript:ck_SS_VD ('{Name}' );"" maxlength=""2"" value=""{Lsec}""/>");

                }
            }
        }
        public override void Init(int iType, string oName = "", object? oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {
            base.Init(iType, oName, oValue, oDom, oumDom, oFormat, oEditable, oObbligatory, oValidazioneFormale);

            this.DataTipology = 6;// || 22
        }
        public override void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/")
        {
            if (!js.ContainsKey("getObj"))
            {
                js.Add("getObj", $@"<script src=""{Path}jscript/getObj.js"" ></script>");

            }
            if (!js.ContainsKey("ck_VD"))
            {
                js.Add("ck_VD", $@"<script src=""{Path}jscript/Field/ck_VD.js"" ></script>");

            }

            pathScript = Path;
        }
        public override dynamic? RSValue()
        {
            Value = base.RSValue();
            SetDefault();

            if (string.IsNullOrEmpty(this.Value))
            {
                //DateAndTime d;
                return null; //'d
            }
            else
            {

                if ((this.Value.GetType()) == typeof(DateTime))
                {

                    return this.Value;

                }
                else
                {

                    return StrToDate(this.Value);

                }
            }
        }
        public override string SQLValue()
        {
            //Value = base.SQLValue();
            try
            {

                SetDefault();

                if (this.Value.GetType() != typeof(DateTime) && string.IsNullOrEmpty(this.Value))
                {
                    return " NULL ";
                }

                if (this.Value.GetType() == typeof(DateTime))
                {

                    return ("'" + Strings.Format(this.Value, "yyyy-MM-dd HH:mm:ss") + "'").Replace(".", ":");

                }
                else
                {

                    return ("'" + Strings.Format(StrToDate(this.Value), "yyyy-MM-dd HH:mm:ss") + "'").Replace(".", ":");

                }

            }
            catch
            {

                return "NULL";

            }
        }

        public override void toPrint(IEprocResponse objResp, bool? pEditable = null)
        {
            base.toPrint(objResp, pEditable);
            this.Html(objResp, pEditable);
        }
        public override void toPrintExtraContent(IEprocResponse objResp, dynamic OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false) { }

        public override string TxtValue()
        {
            //Value = base.TxtValue();
            string strToReturn;
            SetDefault();

            //Se value è null oppure è di tipo stringa ed è nullOrEmpy
            if (this.Value == null || (this.Value.GetType() == typeof(string) && string.IsNullOrEmpty(this.Value)))
            {
                strToReturn = "&nbsp;";
            }
            else
            {

                if (this.Value.GetType() == typeof(string) && this.Value == "1900-01-01" && DataTipology == Extended)
                {
                    strToReturn = mp_PredefiniteVisualDescription;
                    return strToReturn;
                }

                DateTime dtCompare = DateAndTime.DateSerial(1900, 1, 1);
                if (this.Value.GetType() == typeof(DateTime) && this.Value == dtCompare)
                {
                    strToReturn = mp_PredefiniteVisualDescription;
                    return strToReturn;
                }


                if (this.Value.GetType() == typeof(DateTime))
                {
                    strToReturn = Strings.Format(this.Value, strFormat);
                }
                else
                {

                    strToReturn = Strings.Format(StrToDate(this.Value), strFormat);


                }
            }
            return strToReturn;
        }
        public override void ValueExcel(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueExcel(objResp, pEditable);
            this.Name = mp_row + Name;
            this.Excel(objResp, (pEditable == null) ? Editable : pEditable);

            this.Name = originaleName;

        }
        public override void ValueHtml(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueHtml(objResp, pEditable);
            this.Name = mp_row + Name;
            this.Html(objResp, (pEditable == null) ? Editable : pEditable);

            this.Name = originaleName;

        }
        public override void xml(IEprocResponse objResp, string tipo)
        {
            objResp.Write($@"<{XmlEncode(UCase(Name))} desc=""{XmlEncode(CStr(Caption))}"" type=""{getFieldTypeDesc(mp_iType)}"">");

            //On Error Resume Next

            //'-- Contenuto xml tra l'apertura e la chiusura del tag del field
            if (!string.IsNullOrEmpty(CStr(Value)))
            {


                //'-- campo nascosto per il recupero dei dati in formato tecnico
                if (this.Value.GetType() == typeof(DateTime))
                {

                    objResp.Write($@"{DateToStr(this.Value)}");

                }
                else
                {

                    objResp.Write($@"{IIF(IsNull(this.Value), "", this.Value)}");

                }


            }
            objResp.Write($@"</{XmlEncode(UCase(Name))}>");
        }
        public override void UpdateFieldVisual(IEprocResponse objResp, string strDocument = "")
        {
            string originaleName = this.Name;

            base.UpdateFieldVisual(objResp, strDocument);
            string tecnicalData;
            DateTime d;
            string strDoc;

            if (!string.IsNullOrEmpty(strDocument))
            {
                strDoc = strDocument + ".";
            }
            else
            {
                strDoc = "";
            }

            if (this.Value.GetType() == typeof(DateTime))
            {
                tecnicalData = DateToStr(this.Value);
                d = this.Value;
            }
            else
            {
                tecnicalData = IIF(IsNull(this.Value), "", this.Value);
                d = StrToDate(tecnicalData);
            }


            objResp.Write($@"<script language=""JavaScript""> ");

            if (string.IsNullOrEmpty(this.Value) || IsNull(this.Value))
            {

                objResp.Write($@"try{{{strDoc}getObj('{Name}_L').innerHTML='&nbsp;';}}catch(e){{}}; ");
                objResp.Write($@"try{{{strDoc}getObj('{Name}').value=''}}catch(e){{}}; ");
                if (CStr(strFormat).Contains("hh", StringComparison.Ordinal) || CStr(strFormat).Contains("HH", StringComparison.Ordinal))
                {

                    objResp.Write($@"try{{{strDoc}getObj('{Name}_V').value='';}}catch(e){{}}; ");
                    objResp.Write($@"try{{{strDoc}getObj('{Name}_HH_V').value='';}}catch(e){{}}; ");
                    objResp.Write($@"try{{{strDoc}getObj('{Name}_MM_V').value='';}}catch(e){{}}; ");
                    objResp.Write($@"try{{{strDoc}getObj('{Name}_SS_V').value='';}}catch(e){{}}; ");

                }
                else
                {
                    objResp.Write($@"try{{{strDoc}getObj('{Name}_V').value='';}}catch(e){{}}; ");
                }

            }
            else
            {

                objResp.Write($@"try{{{strDoc}getObj('{Name}_L').innerHTML='{Strings.Format(d, strFormat)}';}}catch(e){{}}; ");
                objResp.Write($@"try{{{strDoc}getObj('{Name}').value='{tecnicalData}'}}catch(e){{}}; ");
                if (CStr(strFormat).Contains("hh", StringComparison.Ordinal) || CStr(strFormat).Contains("HH", StringComparison.Ordinal))
                {

                    objResp.Write($@"try{{{strDoc}getObj('{Name}_V').value='{Strings.Format(d, Strings.Left(strFormat, 10))}';}}catch(e){{}}; ");
                    objResp.Write($@"try{{{strDoc}getObj('{Name}_HH_V').value='{MidVb6(tecnicalData, 12, 2)}';}}catch(e){{}}; ");
                    objResp.Write($@"try{{{strDoc}getObj('{Name}_MM_V').value='{MidVb6(tecnicalData, 15, 2)}';}}catch(e){{}}; ");
                    objResp.Write($@"try{{{strDoc}getObj('{Name}_SS_V').value='{MidVb6(tecnicalData, 18, 2)}';}}catch(e){{}}; ");

                }
                else
                {
                    objResp.Write($@"try{{{strDoc}getObj('{Name}_V').value='{Strings.Format(d, strFormat)}';}}catch(e){{}}; ");
                }
            }

            objResp.Write($@"</script>");

            this.Name = originaleName;

        }
        public override void Excel(CommonModule.IEprocResponse objResp, bool? pEditable = null)
        {
            SetDefault();

            if (this.Value.GetType() == typeof(string) && this.Value == "1900-01-01" && DataTipology == Extended)
            {
                objResp.Write(mp_PredefiniteVisualDescription);
                return;
            }

            if (this.Value.GetType() == typeof(string) && string.IsNullOrEmpty(this.Value))
            {
                objResp.Write("&nbsp;");
            }
            else
            {

                if ((this.Value.GetType()) == typeof(DateTime))
                {

                    objResp.Write(Strings.Format(this.Value, strFormat));

                }
                else
                {

                    objResp.Write(Strings.Format(StrToDate(this.Value), strFormat));

                }
            }
        }

        private void SetDefault()
        {

            if (this.Value != null)
            {
                if (this.Value.GetType() == typeof(String) && Len(this.Value) >= 3 && UCase(this.Value.Substring(0, 3)) == "NOW")
                {
                    string[] v;
                    int i;

                    v = Strings.Split(this.Value, " ");
                    this.Value = DateAndTime.Now;

                    //'-- azzero i secondi quando inizializzo una data con now
                    this.Value = new DateTime(
                        DateAndTime.DateSerial(DateAndTime.Year(this.Value), DateAndTime.Month(this.Value), DateAndTime.Day(this.Value)).Ticks
                        + DateAndTime.TimeSerial(DateAndTime.Hour(this.Value), DateAndTime.Minute(this.Value), 0).Ticks);


                    for (i = 1; i < v.Length; i++)
                    { //To UBound(v)){

                        //'-- data
                        if (v[i].ToUpper().Contains("DAY", StringComparison.Ordinal))
                        {
                            this.Value = DateAndTime.DateAdd("d", CDbl(Left(v[i], Len(v[i]) - 3)), this.Value);
                        }

                        if (v[i].ToUpper().Contains("MONTH", StringComparison.Ordinal))
                        {
                            this.Value = DateAndTime.DateAdd("m", CDbl(Left(v[i], Len(v[i]) - 5)), this.Value);
                        }

                        if (v[i].ToUpper().Contains("YEAR", StringComparison.Ordinal))
                        {
                            this.Value = DateAndTime.DateAdd("yyyy", CDbl(Left(v[i], Len(v[i]) - 4)), this.Value);
                        }

                        if (v[i].ToUpper().Contains("SET_D", StringComparison.Ordinal))
                        {
                            this.Value = DateAndTime.DateSerial(DateAndTime.Year(this.Value), DateAndTime.Month(this.Value), CInt(Left(v[i], Len(v[i]) - 5))) + DateAndTime.TimeSerial(DateAndTime.Hour(this.Value), DateAndTime.Minute(this.Value), DateAndTime.Second(this.Value));
                        }

                        if (v[i].ToUpper().Contains("SET_M", StringComparison.Ordinal))
                        {
                            this.Value = DateAndTime.DateSerial(DateAndTime.Year(this.Value), CInt(Left(v[i], Len(v[i]) - 5)), DateAndTime.Day(this.Value)) + DateAndTime.TimeSerial(DateAndTime.Hour(this.Value), DateAndTime.Minute(this.Value), DateAndTime.Second(this.Value));
                        }

                        if (v[i].ToUpper().Contains("SET_Y", StringComparison.Ordinal))
                        {
                            this.Value = DateAndTime.DateSerial(CInt(Left(v[i], Len(v[i]) - 5)), DateAndTime.Month(this.Value), DateAndTime.Day(this.Value)) + DateAndTime.TimeSerial(DateAndTime.Hour(this.Value), DateAndTime.Minute(this.Value), DateAndTime.Second(this.Value));
                        }

                        //'-- orario
                        if (v[i].ToUpper().Contains("MINUTE", StringComparison.Ordinal))
                        {
                            this.Value = DateAndTime.DateAdd("n", CDbl(Left(v[i], Len(v[i]) - 6)), this.Value);
                        }

                        if (v[i].ToUpper().Contains("HOUR", StringComparison.Ordinal))
                        {
                            this.Value = DateAndTime.DateAdd("h", CDbl(Left(v[i], Len(v[i]) - 4)), this.Value);
                        }

                        if (v[i].ToUpper().Contains("SECOND", StringComparison.Ordinal))
                        {
                            this.Value = DateAndTime.DateAdd("s", CDbl(Left(v[i], Len(v[i]) - 6)), this.Value);
                        }

                        if (v[i].ToUpper().Contains("SET_H", StringComparison.Ordinal))
                        {
                            this.Value = DateAndTime.DateSerial(DateAndTime.Year(this.Value), DateAndTime.Month(this.Value), DateAndTime.Day(this.Value)) + DateAndTime.TimeSerial(CInt(Left(v[i], Len(v[i]) - 5)), DateAndTime.Minute(this.Value), DateAndTime.Second(this.Value));
                        }

                        if (v[i].ToUpper().Contains("SET_N", StringComparison.Ordinal))
                        {
                            this.Value = DateAndTime.DateSerial(DateAndTime.Year(this.Value), DateAndTime.Month(this.Value), DateAndTime.Day(this.Value)) + DateAndTime.TimeSerial(DateAndTime.Hour(this.Value), CInt(Left(v[i], Len(v[i]) - 5)), DateAndTime.Second(this.Value));
                        }

                        if (v[i].ToUpper().Contains("SET_S", StringComparison.Ordinal))
                        {
                            this.Value = DateAndTime.DateSerial(DateAndTime.Year(this.Value), DateAndTime.Month(this.Value), DateAndTime.Day(this.Value)) + DateAndTime.TimeSerial(DateAndTime.Hour(this.Value), DateAndTime.Minute(this.Value), CInt(Left(v[i], Len(v[i]) - 5)));
                        }

                    }


                }
            }

            ////'--inizializza la format con un default se non settata
            if (string.IsNullOrEmpty(strFormat))
            {
                strFormat = "dd/MM/yyyy";
            }


        }

        public override string TechnicalValue()
        {
            dynamic tempValue = IIF(IsNull(this.Value), "", this.Value);

            if (tempValue.GetType() == typeof(System.DateTime))
            {
                return DateToStr(tempValue);


            }
            else
            {
                return IIF(IsNull(tempValue), "", tempValue);


            }
        }


    }
}

