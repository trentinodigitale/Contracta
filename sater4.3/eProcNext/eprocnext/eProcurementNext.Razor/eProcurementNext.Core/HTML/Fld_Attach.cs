using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.HTML.Basic;
using static eProcurementNext.HTML.BasicFunction;

namespace eProcurementNext.HTML
{
    public class Fld_Attach : Field, IField
    {

        private string ToolTip = "";
        public string OnClick = "";              //'-- funzione associata al click

        //'-- contenogono il nome della funzione JS da chiamare sul campo per l'evento considerato
        private string strFormatRipulita = "";

        private bool PrintMode = false;     //'-- indica che siamo in modalit� di stampa quindi non vanno aggiunti
                                            //'-- i meccanismi di interazione utente come gli eventi di onClick

        private readonly CommonDbFunctions cdf = new();

        public Fld_Attach()
        {
            /* nel costruttore di tutti i field va inizializzato l'mp_itype con il proprio tipo di riferimento */
            this.mp_iType = 18;
            Path = "../"; //'-- percorso relativo che serve per tornare alla radice dell'applicazione
            PathImage = "../CTL_Library/images/Domain/"; //'-- percorso dove sono le foto a partire dalla radice
            Style = "Attach";
            PrintMode = false;
        }
        public override void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/")
        {
            if (!js.ContainsKey("ExecFunction"))
            {
                js.Add("ExecFunction", $@"<script src=""{Path}jscript/ExecFunction.js"" ></script>");
            }
            if (!js.ContainsKey("ck_Attach"))
            {
                js.Add("ck_Attach", $@"<script src=""{Path}jscript/Field/ck_Attach.js"" ></script>");
            }
        }

        public override void Init(int iType, string oName = "", object? oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false)
        {
            base.Init(iType, oName, oValue, oDom, oumDom, oFormat, oEditable, oObbligatory, oValidazioneFormale);
            strFormatRipulita = oFormat;
        }

        public override void Html(IEprocResponse objResp, bool? pEditable = null)
        {
            bool? vEditable;
            string strImg;
            string[] v;
            string strType = "";
            string signStatus = "";
            string nome_image = "";
            string guid = "";
            string[] aInfoMultiAttach;
            int i;
            string strValue_Attach;


            vEditable = Editable;
            if (pEditable != null)
            {
                vEditable = pEditable;
            }

            ToolTip = "";

            //'--Formattazione di default:Icona e nome
            if (strFormat == "")
            {
                strFormat = "I,N";
            }

            strFormatRipulita = strFormat;

            if (strFormatRipulita.Contains("EXT:", StringComparison.Ordinal))
            {
                string a;
                int ix;
                int ix2;
                ix = Strings.InStr(1, strFormatRipulita, "EXT:");
                ix2 = Strings.InStr(ix + 1, strFormatRipulita, "-");
                a = Strings.Mid(strFormatRipulita, ix, ix2 - ix + 1);
                strFormatRipulita = strFormatRipulita.Replace(a, "");

            }

            if (strFormatRipulita == "")
            {
                strFormatRipulita = "I,N";
            }




            //'--apertura div contenitore
            objResp.Write($@"<div id=""DIV_{Name}"" class=""DIV_ATTACH_CONTAINER"" >");

            //'-- campo nascosto per il recupero dei dati in formato tecnico
            objResp.Write($@"<input type=""hidden"" name=""{Name}""  id=""{Name}"" ");
            objResp.Write($@" value=""{HtmlEncode(this.Value)}"" ");

            //'--gestito onchange se settato
            if (!string.IsNullOrEmpty(mp_OnChange))
            {
                objResp.Write($@" onchange=""{mp_OnChange}"" ");
            }

            objResp.Write($@"/> ");


            objResp.Write($@"<table id=""TABLE_ATTACH_CONTAINER"" class=""ATTACH_CONTAINER"">");
            objResp.Write($@"<tr>");
            if (IsMasterPageNew() && string.IsNullOrEmpty(Value) && vEditable == false)
            {
               
            }
            else
            {
                objResp.Write($@"<td id=""TD_ATTACH_ALL"" class=""TD_ATTACH_ALL"">");
            }

            if (!string.IsNullOrEmpty(Value))
            {

                aInfoMultiAttach = Strings.Split(Value, "***");

                for (i = 0; i < aInfoMultiAttach.Length; i++)
                {

                    strValue_Attach = aInfoMultiAttach[i];

                    ToolTip = "";

                    //'-- Verifico se � un allegato con richiesta di verifica avanzata firma digitale o con jump check
                    if ((strFormatRipulita.Contains('V', StringComparison.Ordinal) || strFormatRipulita.Contains('J', StringComparison.Ordinal)) && !string.IsNullOrEmpty(strValue_Attach))
                    { //'--And Me.Value <> "" Then

                        signStatus = "";

                        //'-- Recupero il guid dell'allegato, Value= NAMEATTACH*TYPEATTACH*SIZEATTACH*GUID
                        v = Strings.Split(strValue_Attach, "*");

                        //'-- Se non ci sono minimo 4 elementi previsti per la parte tecnica del campo allegato
                        //'-- setto a vuoto il valore perch� corrotto
                        if (v.Length < 4)
                        {
                            strValue_Attach = "";
                        }
                        else
                        {

                            guid = v[3];

                            var sqlP = new Dictionary<string, object?>
                            {
                                { "@guid", guid }
                            };

                            var rs = cdf.GetRSReadFromQuery_($@"select statoFirma from CTL_SIGN_ATTACH_INFO with(nolock) where ATT_Hash = @guid order by statoFirma asc", ConnectionString, sqlP);

                            signStatus = "SIGN_WAIT";

                            if (rs != null)
                            {
                                if (!(rs.EOF && rs.BOF))
                                {
                                    rs.MoveFirst();

                                    //'-- Itero sugli N certificati dell'allegato (Nel caso di firme multiple)
                                    while (!rs.EOF)
                                    {
                                        signStatus = CStr(rs["statoFirma"]);

                                        //'-- Se trovo uno stato diverso da sign_ok posso fermarmi
                                        if (!IsNull(signStatus) && UCase(signStatus) != "SIGN_OK")
                                        {
                                            break;
                                            //rs.MoveLast(); //' forzo l'uscita dal while (con la successiva invocazione di moveNext)
                                        }

                                        rs.MoveNext();
                                    }

                                }
                            }

                            //'faccio coincidere lo stato con il nome dell'immagine che lo rappresenta
                            nome_image = LCase(signStatus);
                        }

                    }

                    //'-- recupero il nome dell'attach che visualizzo per default
                    //'-- Value= NAMEATTACH*TYPEATTACH*SIZEATTACH*GUID
                    if (!string.IsNullOrEmpty(strValue_Attach))
                    {

                        //'--v = Split(Value, "*")
                        v = Strings.Split(strValue_Attach, "*");

                        //'-- Se non ci sono minimo 4 elementi previsti per la parte tecnica del campo allegato
                        //'-- setto a vuoto il valore perch� corrotto
                        if (v.Length < 4)
                        {

                            strValue_Attach = "";

                        }
                        else
                        {

                            //'--verifico se costruire il tooltip
                            if (strFormatRipulita.Contains('T', StringComparison.Ordinal))
                            {

                                //'--se il nome non � visualizzato lo inserisco nel tooltip
                                if (!strFormatRipulita.Contains('N', StringComparison.Ordinal))
                                {
                                    ToolTip = "name: " + v[0] + " ";
                                }

                                if (Domain != null)
                                {
                                    strType = v[1] + " file";

                                    IDomElem? dmElem = Domain.FindCode(v[1]);

                                    if (dmElem is not null)
                                        strType = dmElem.Desc;
                                }

                                ToolTip = ToolTip + "type: " + strType + " ";

                                ToolTip = ToolTip + "size: " + Strings.Format(CInt(v[2]) / 1024, "###,##0.00") + " KB";
                            }

                        }
                    }
                    else
                    {

                        v = new string[4];
                        v[0] = "";
                        v[1] = "";
                        v[2] = "";
                        v[3] = "";
                        //ReDim v(4) As String

                    }




                    //'--apertura div contenitore di ogni singolo allegato
                    objResp.Write($@"<div id=""DIV_{Name}_Multivalore"" class=""DIV_ATTACH_SINGLE"" >");

                    //'-- disegna la parte visuale
                    objResp.Write($@"<table ");
                    objResp.Write($@" id=""{Name}_V"" ");


                    objResp.Write($@" class=""{Style}_Tab"" >");

                    objResp.Write($@"<tr>");

                    objResp.Write($@"<td>");

                    //'--If Value <> "" Then
                    if (!string.IsNullOrEmpty(strValue_Attach))
                    {

                        string strOnClick;
                        string strOnClickSenzaBusta;

                        if (!PrintMode)
                        {

                            strOnClickSenzaBusta = "";

                            //'-- Se � attiva la format di verifica estesa firma e l'allegato � stato elaborato
                            //'--     e lo stato di firma non � PENDING
                            if ((strFormatRipulita.Contains('V', StringComparison.Ordinal)) && signStatus != "SIGN_PENDING")
                            {
                                strOnClickSenzaBusta = $@" onclick=""javascript: DownloadFileSenzaBusta('{HtmlEncodeJSValue(v[3])}','{HtmlEncodeJSValue(v[0])}');""";
                            }

                            //'-- Se � stato chiesto il download senza busta sul nome del file
                            if (strFormatRipulita.Contains('B', StringComparison.Ordinal) && !string.IsNullOrEmpty(strOnClickSenzaBusta))
                            {
                                strOnClick = strOnClickSenzaBusta;
                            }
                            else
                            {
                                //'--javascript per aprire l'allegato integro
                                strOnClick = @" onclick=""javascript:";
                                strOnClick += $@"DisplayAttach( '{HtmlEncodeJSValue(Path)}' , '{HtmlEncodeJSValue(strValue_Attach)}' );""";

                            }



                        }
                        else
                        {

                            strOnClick = "";
                            strOnClickSenzaBusta = "";

                        }

                        //'--verifica se mostrare l'icona del tipo documento (prima del nome del file allegato)
                        //'-- (la mostro se non � attiva la verifica estesa di firma. perch� in quel caso non mostro l'icona del tipofile ma
                        //'-- un icona specifica per effettuare il download del file senza busta)
                        if (strFormatRipulita.Contains('I', StringComparison.Ordinal) && !strFormatRipulita.Contains('V', StringComparison.Ordinal))
                        {

                            if (Domain != null)
                            {

                                strImg = "defaultExt.gif";

                                IDomElem? dmElem = Domain.FindCode(v[1]);

                                if (dmElem is not null)
                                    strImg = dmElem.Image;

                                objResp.Write($@"<img alt="""" title=""{HtmlEncode(ToolTip)}"" id=""{Name}_V_I"" src=""{Path}CTL_Library/images/Domain/{strImg}"" {strOnClick}/>");

                            }

                        }

                        //'-- Verifico se � un allegato con firma digitale
                        //'--If InStr(1, strFormatRipulita, "V") > 0 And Me.Value <> "" Then
                        if (strFormatRipulita.Contains('V', StringComparison.Ordinal) && !string.IsNullOrEmpty(strValue_Attach))
                        {

                            //'-- se lo stato del file � sign pending non facciamo fare il download senza busta
                            if (signStatus != "SIGN_PENDING")
                            {
                                //'-- icona per scaricare il file privo di busta
                                objResp.Write($@"<img class=""img_label_alt"" alt=""{HtmlEncode("Scarica il file privo di busta firmata")}"" title=""{HtmlEncode("Scarica il file privo di busta firmata")}"" id=""{Name}_V_I"" src=""{Path}CTL_Library/images/Domain/dwnSenzaBusta.png"" {strOnClickSenzaBusta}/>");
                            }

                            //'-- La funzione javascript InfoSignCert prende 2 parametri, il path che eredita dal field. E altri 4 parametri
                            //'-- che gli permettono di raggiungere i certificati associati all'allegato:   infoSignCert( path, hash, attIdMsg, attOrderFile, attIdObj
                            //'-- per il documento nuovo sar� avvalorato solo hash, per il documento generico il primo sar� vuoto e gli altri 3 saranno avvalorati.
                            objResp.Write($@"&nbsp;&nbsp;");
                            objResp.Write($@"<img alt="""" ");

                            if (!PrintMode)
                            {
                                objResp.Write($@"onclick=""InfoSignCert( '','{HtmlEncodeValue(guid).Replace(@"'", @"\'")}','','','');"" ");
                            }

                            objResp.Write($@" class=""IMG_SIGNINFO"" src=""{Path}CTL_Library/images/Domain/{nome_image}.png""/> &nbsp; ");

                        }

                        //'--mostro il nome dell'allegato per default

                        objResp.Write($@"<span ");


                        objResp.Write($@"id=""{Name}_V_N"" ");

                        if (!PrintMode)
                        {
                            objResp.Write($@" class=""{Style}_label"" ");
                            objResp.Write(strOnClick);
                        }



                        objResp.Write($@" title=""{HtmlEncode(ToolTip)}"" ");

                        objResp.Write($@">");

                        //'--verifico se mostrare il nome
                        if (strFormatRipulita.Contains('N', StringComparison.Ordinal))
                        {
                            objResp.Write(HtmlEncode(v[0]));
                        }

                        //'--verifico se mostrare la size
                        if (strFormatRipulita.Contains('S', StringComparison.Ordinal))
                        {

                            objResp.Write($@"(size: {Strings.Format(CInt(v[2]) / 1024, "###,##0.00")} KB)");

                        }


                        objResp.Write($@"</span>");

                    }


                    objResp.Write($@"</td>");
                    objResp.Write($@"</tr>");

                    //'-- se � richiesta la visualizzazione dell'hash
                    //'--If InStr(1, strFormatRipulita, "H") > 0 And Value <> "" Then
                    if (strFormatRipulita.Contains('H', StringComparison.Ordinal) && !string.IsNullOrEmpty(strValue_Attach))
                    {

                        //'-- se nella forma tecnica � presente la posizione contenitore dell'hash
                        if (v.Length > 5)
                        {
                            string algoritmoHash;
                            string hashFile;

                            algoritmoHash = v[4];
                            hashFile = v[5];

                            objResp.Write($@"<tr>");
                            objResp.Write($@"<td>");

                            if (!string.IsNullOrEmpty(hashFile))
                            {

                                objResp.Write($@"<span class=""attach_info_hashfile"" title=""L'algoritmo di hash utilizzato &egrave; {algoritmoHash}"">");
                                objResp.Write(UCase(hashFile));

                            }
                            else
                            {

                                objResp.Write($@"<span class=""attach_info_hashfile TODO_CNV_CLIENT"">");
                                objResp.Write($@"hash di checksum non generato");

                            }

                            objResp.Write($@"</span>");
                            objResp.Write($@"</td>");
                            objResp.Write($@"</tr>");

                        }

                    }

                    //'-- se � richiesta la visualizzazione della data di acquisizione allegato
                    if (strFormatRipulita.Contains('D', StringComparison.Ordinal) && !string.IsNullOrEmpty(Value))
                    {

                        //'-- se nella forma tecnica � presente la data di acquisizione
                        if (v.Length > 6)
                        {

                            string dataAcquisizione;

                            dataAcquisizione = v[6];
                            dataAcquisizione = Strings.Format(StrToDate(dataAcquisizione), "dd/mm/yyyy hh:mm:ss");

                            objResp.Write($@"<tr>");

                            objResp.Write($@"<td>");

                            objResp.Write($@"<span class=""attach_info_datefile"">");

                            //'-- qui per il momentonon abbiamo l'application per sfruttare la cnv
                            objResp.Write($@"<span class=""TODO_CNV_CLIENT"">Data Acquisizione</span> : {dataAcquisizione}");

                            objResp.Write($@"</span>");

                            objResp.Write($@"</td>");

                            objResp.Write($@"</tr>");

                        }

                    }

                    objResp.Write("</table>");

                    //'--chiusura div contenitore di ogni allegato
                    objResp.Write("</div>");


                }

            }
            else
            {

                //'--se vuoto ed il campo � editabile metto una div con lo spazio assegnato per evidenziare lo spazio riservato all'allegato
                if (vEditable == true)
                {
                    objResp.Write($@"<div id=""DIV_{Name}_ATTACH_EMPTY"" class=""DIV_ATTACH_EMPTY"" >");
                    objResp.Write($@"&nbsp;");
                    objResp.Write($@"</div>");
                }
                else
                {
                    objResp.Write(@"<div id=""DIV_" + Name + @"_ATTACH_EMPTY"" class=""DIV_ATTACH_EMPTY_NOT_EDITABLE"" >");
                    objResp.Write("&nbsp;");
                    objResp.Write("</div>");
                }

            }


            if (IsMasterPageNew() && string.IsNullOrEmpty(Value) && vEditable == false)
            {

            }
            else
            {
                //'--chiudo la td che contiene lo spazio per gli allegati
                objResp.Write("</td>");
            }


            //'--se editabile inserisco il pulsante per la selezione
            if (vEditable == true && !PrintMode)
            {

                objResp.Write($@"<td id=""TD_ATTACH_BTN"" class=""TD_ATTACH_BTN"">");

                objResp.Write($@"<div id=""DIV_{Name}_BTN"" class=""DIV_ATTACH_BTN"" >");

                objResp.Write($@"<input class=""{Style}_button"" type=""button"" name=""{Name}_V_BTN"" id=""{Name}_V_BTN"" ");
                objResp.Write($@" alt=""Inserisci allegato"" value=""..."" ");
                objResp.Write($@" onclick=""javascript:");
                //'objResp.Write "ExecFunction( '"
                objResp.Write($@"ExecFunctionAttach( '");
                //'--objResp.Write HtmlEncode(Path & "CTL_Library/functions/field/UploadAttach.asp?OPERATION=INSERT&FIELD=" & Name & "&PATH=" & UrlEncode(Path) & "&TECHVALUE=" & UrlEncode(Me.Value) & "&FORMAT=" & UrlEncode(strFormat))
                objResp.Write($@"{HtmlEncode($@"{Path}CTL_Library/functions/field/UploadAttach.asp?OPERATION=INSERT&FIELD={Name}&PATH={UrlEncode(Path)}&TECHVALUE={UrlEncode(this.Value)}&FORMAT={UrlEncode(strFormat)}")}");

                if (Domain != null)
                {
                    objResp.Write(HtmlEncode("&DOMAIN=" + HtmlEncode(Domain.Id)));
                }

                //'-- se � richiesta la cifratura
                if (strFormatRipulita.Contains('C', StringComparison.Ordinal))
                {
                    objResp.Write(HtmlEncode("&IDDOC=' + getObjValue('IDDOC') + '&CIF=1"));
                }

                objResp.Write($@"' , 'UploadAttach' , ',height=300,width=600' );"" "); //'-- la dimensione della finestra viene ignorata in quanto passata dalla funzione ExecFunctionAttach
                objResp.Write($@"/> ");

                //'--chiusura div bottone per la selezione
                objResp.Write($@"</div>");

                //'--chiudo la td che contiene lo spazio per il bottone di selezione
                objResp.Write($@"</td>");

            }
            objResp.Write($@"</tr>");
            objResp.Write($@"</table>");

            //'--chiusura div contenitore totale
            objResp.Write($@"</div>");


        }
        public override string SQLValue()
        {
            Value = base.SQLValue();
            return "'" + CStr(Value).Replace("'", "''") + "'";
        }
        public override string TechnicalValue()
        {
            return IIF(IsNull(this.Value), "", this.Value);
        }
        public override void toPrint(IEprocResponse objResp, bool? pEditable = null)
        {
            base.toPrint(objResp, pEditable);
            this.Name = mp_row + Name;
            this.Value = IIF(IsNull(Value), "", Value);
            PrintMode = true;
            this.Html(objResp, pEditable);
        }
        public override void toPrintExtraContent(IEprocResponse objResp, dynamic OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false) { }
        public override string TxtValue()
        {
            Value = base.TxtValue();
            string[] v;

            if (!string.IsNullOrEmpty(CStr(this.Value)))
            {
                v = Strings.Split(Value, "*");
                if (CStr(this.Value).Contains("*", StringComparison.Ordinal))
                {
                    return v[0];
                }
            }
            return Value;
        }
        public override void ValueExcel(IEprocResponse objResp, bool? pEditable = null)
        {
            base.ValueExcel(objResp, pEditable);

            this.Name = mp_row + Name;
            this.Value = IIF(IsNull(Value), "", Value);

            objResp.Write(HtmlEncode(this.TxtValue()));
        }
        public override void ValueHtml(IEprocResponse objResp, bool? pEditable = null)
        {
            string originaleName = this.Name;

            base.ValueHtml(objResp, pEditable);
            this.Name = mp_row + Name;
            this.Value = IIF(IsNull(Value), "", Value);
            this.Html(objResp, (pEditable == null) ? Editable : pEditable);

            this.Name = originaleName;
        }
        public override void xml(IEprocResponse objResp, string tipo)
        {

            objResp.Write("<" + XmlEncode(UCase(Name)) + @" desc=""" + XmlEncode(Caption ?? "") + @""" type=""" + getFieldTypeDesc(mp_iType) + @""">");

            string[] aInfo;
            string strFileName;
            string strType;
            string strSize;
            string strHash;

            //'-- Contenuto del tag
            if (!IsNull(this.Value))
            {

                if (!string.IsNullOrEmpty(CStr(this.Value)))
                {

                    aInfo = Strings.Split(this.Value, "*");

                    //'--recupero nome file
                    strFileName = aInfo[0];

                    //'--recupero type file
                    strType = aInfo[1];

                    //'-- size
                    strSize = aInfo[2];

                    //'--recupero guid
                    strHash = aInfo[3];

                    int tipoAttacco;

                    objResp.Write($@" <FILENAME>{XmlEncode(strFileName)}</FILENAME> ");
                    objResp.Write($@"<FILESIZE type=""byte"">{XmlEncode(strSize)}</FILESIZE> ");
                    objResp.Write($@"<FILEKEY type=""guid"">{XmlEncode(strHash)}</FILEKEY> ");
                    objResp.Write($@"<FILEEXT>{XmlEncode(strType)}</FILEEXT> ");


                    tipoAttacco = objResp.getXmlAttachType();


                    //'-- Cambio la rappresentazione dell'allegato in base al tipo scelto dalla configurazione
                    switch (tipoAttacco)
                    {
                        case 1: //'-- 1 = Base64
                            objResp.Write($@"<BLOB> ");
                            cdf.base64attach(CStr(Value));
                            objResp.Write($@"</BLOB> ");
                            break;
                        case 2: //'-- 2 = FormaTecnica
                            objResp.Write($@"<TECNICAL_VALUE>{XmlEncode(CStr(this.Value))}</TECNICAL_VALUE>");
                            break;
                        case 3: //'-- 3 = hash SHA del file. da completare
                            objResp.Write($@"<HASH_VALUE>{XmlEncode(strHash)}</HASH_VALUE>");
                            break;
                        default:
                            break;
                    }



                }

            }

            objResp.Write("</" + XmlEncode(UCase(Name)) + ">" + Environment.NewLine);
        }

        private string StrToDate(string str)
        {
            DateTime dateToReturn;

            try
            {

                str = str.Trim();

                if (!str.Contains('T', StringComparison.Ordinal) && str.Length == 10)
                {
                    str += "T00:00:00";
                }

                if (!string.IsNullOrEmpty(str))
                {

                    dateToReturn = DateAndTime.DateSerial(CInt(Strings.Left(str, 4)), CInt(Strings.Mid(str, 6, 2)), CInt(Strings.Mid(str, 9, 2)));
                    dateToReturn = new DateTime(dateToReturn.Ticks + DateAndTime.TimeSerial(CInt(Strings.Mid(str, 12, 2)), CInt(Strings.Mid(str, 15, 2)), CInt(Strings.Mid(str, 18, 2))).Ticks);
                    return dateToReturn.ToString();
                }

            }
            catch
            {
            }

            return "";
        }

        public override void UpdateFieldVisual(IEprocResponse objResp, string strDocument = "") { }

    }
}

