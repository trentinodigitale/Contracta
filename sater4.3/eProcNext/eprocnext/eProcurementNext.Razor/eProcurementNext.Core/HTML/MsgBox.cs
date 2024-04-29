using eProcurementNext.CommonModule;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.HTML
{
    public class MsgBox
    {
        public string strPath;
        public string Style;
        public string Link;
        public string Target;

        public string Caption;
        public string Title;
        public string Message;
        public long Button;      //'-- rappresenta i bottoni da visualizzare come fatto per la msgbox di VB

        public string CaptionOK;
        public bool Resize;
        public string Icon;

        //private string Height;// usato solo nella versione non accessibile
        private string width;
        //private string response As Object//non usato nel MsgBox
        public string id;

        public string ActionScript;
        public string CaptionCancel;
        public string ActionCancel;

        public string mp_modale;

        public MsgBox()
        {
            //Height = "100%";
            width = "100%";
            Style = "MsgBox";
            strPath = "../images/MsgBox/";
            CaptionOK = "Ok";
            CaptionCancel = "Cancel";
            Resize = true;
            Icon = "info.gif";
            ActionScript = "";
            mp_modale = "NO";
        }



        //'-- avvalora la collezione con i javascript necessari al corretto
        //'-- funzionamento del controllo
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
        {


            try
            {
                JS.Add("getObj", $@"<script src=""{Path}jscript/getObj.js"" ></script>");
            }
            catch { }
            try
            {
                JS.Add("ExecFunction", $@"<script src=""{Path}jscript/ExecFunction.js"" ></script>");
            }
            catch { }


        }


        //'-- ritorna il codice html
        public void Html(IEprocResponse objResp)
        {

            objResp.Write(LocalHtml());

        }

        private string LocalHtml()
        {

            string strApp = "";

            if (mp_modale != "YES" && Resize == true)
            {

                strApp = $@"{strApp}<script type=""text/javascript"" language=""javascript""> ";
                strApp = $@"{strApp}    const_width=400;";
                strApp = $@"{strApp}    const_height=250;";
                strApp = $@"{strApp}    sinistra=(screen.width-const_width)/2;";
                strApp = $@"{strApp}    alto=(screen.height-const_height)/2;";

                strApp = $@"{strApp}   window.moveTo( sinistra, alto ); ";
                strApp = $@"{strApp}   window.resizeTo( 400 , 250 ); ";
                strApp = $@"{strApp}   window.focus(); ";

                strApp = $@"{strApp} ";
                strApp = $@"{strApp}</script> ";

            }


            //'-- apertura della tabella HTML
            strApp = $@"{strApp}<table id=""{id}"" name=""{id}"" width=""{width}"" cellpadding=""0"" cellspacing=""0"" class=""{Style}""> ";


            //'-- apertura della riga per la caption
            strApp = $@"{strApp}<tr>";
            strApp = $@"{strApp}<td valign=""middle"" align=""center""> ";

            //'-- disegno della caption
            strApp = $@"{strApp}<table width=""100%"" cellpadding=""0"" cellspacing=""0"" class=""{Style}_Caption""> ";


            strApp = $@"{strApp}<tr> ";

            if (CaptionOK == "")
            {
                //'-- disegno della bitmap
                strApp = $@"{strApp}<td valign=""middle"" align=""center""> ";
                strApp = $@"{strApp}<img alt="""" src=""{strPath}{Icon}""/> ";
                strApp = $@"{strApp}</td> ";
            }

            strApp = $@"{strApp}<td width=""100%"" valign=""middle"" align=""center""> ";

            if (Caption.Contains("???", StringComparison.Ordinal))
            {
                strApp = $@"{strApp}{HtmlEncode(Caption)} ";
            }
            else
            {
                strApp = $@"{strApp}{Caption} ";
            }

            strApp = $@"{strApp}</td> ";
            strApp = $@"{strApp}</tr> ";
            strApp = $@"{strApp}</table> ";

            strApp = $@"{strApp}</td> ";
            strApp = $@"{strApp}</tr> ";

            //'-- apertura della riga per la bitmap ed il testo
            strApp = $@"{strApp}<tr> ";
            strApp = $@"{strApp}<td > ";

            strApp = $@"{strApp}<table border=""0"" cellpadding=""0"" cellspacing=""0""> ";
            strApp = $@"{strApp}<tr> ";


            if (CaptionOK != "")
            {
                //'-- disegno della bitmap
                strApp = $@"{strApp}<td valign=""middle"" align=""center""> ";
                strApp = $@"{strApp}<img alt="""" src=""{strPath}{Icon}""/> ";
                strApp = $@"{strApp}</td> ";
            }

            //'-- disegno il testo del messaggio
            strApp = $@"{strApp}<td valign=""middle"" align=""center"" class=""{Style}_Message""> ";

            if (Message.Contains("???", StringComparison.Ordinal))
            {
                strApp = $@"{strApp}{HtmlEncode(Message)}";
            }
            else
            {
                strApp = $@"{strApp}{Message} ";
            }

            if (Link != "")
            {
                strApp = $@"{strApp}<br/>{Link} ";
            }

            strApp = $@"{strApp}</td> ";
            strApp = $@"{strApp}</tr> ";
            strApp = $@"{strApp}</table> ";


            strApp = $@"{strApp}</td> ";
            strApp = $@"{strApp}</tr> ";

            if (mp_modale.ToUpper() != "YES")
            {

                //'-- disegno dei bottoni di uscita
                if (CaptionOK != "")
                {

                    strApp = $@"{strApp}<tr> ";
                    strApp = $@"{strApp}<td valign=""middle"" align=""center""> ";
                    strApp = $@"{strApp}<form>";

                    if (ActionScript == "")
                    {

                        strApp = $@"{strApp}<input type=""button"" value=""{CaptionOK}"" name=""submit"" id=""submit""  class=""{Style}_ButtonOK"" ";
                        strApp = $@"{strApp} onclick=""Javascript:self.close();""/>  ";

                    }
                    else
                    {

                        strApp = $@"{strApp}<input type=""button"" value=""{CaptionOK}"" name=""submit""  id=""submit""  class=""{Style}_ButtonOK"" ";
                        strApp = $@"{strApp} onclick=""Javascript:{ActionScript}self.close();""/>  ";

                        if (CaptionCancel != "")
                        {
                            strApp = $@"{strApp}<input type=""button"" value=""{CaptionCancel}"" name=""cancel""  id=""cancel""  class=""{Style}_ButtonOK"" ";


                            if (ActionCancel == "")
                            {
                                strApp = $@"{strApp} onclick=""Javascript:self.close();""/>  ";
                            }
                            else
                            {
                                strApp = $@"{strApp} onclick=""Javascript:{ActionCancel}self.close();""/>  ";
                            }

                        }

                    }

                    strApp = $@"{strApp}</form>";
                    strApp = $@"{strApp}</td> ";
                    strApp = $@"{strApp}</tr> ";

                }

            }

            strApp = $@"{strApp}</table> ";

            if (mp_modale != "YES")
            {
                if (CaptionOK != "")
                {
                    strApp = $@"{strApp}<script type=""text/javascript""> ";
                    strApp = $@"{strApp}document.forms[0].elements[0].focus();";
                    strApp = $@"{strApp}</script> ";
                }
            }

            return strApp;


        }



        //'-- inizializza e ritorna immediatamente il codice html, la formattazione rispecchia quella del VB
        public string Init(string pMessage, long pButton, string pCaption)
        {

            Caption = pCaption;
            Message = pMessage;
            Button = pButton;

            return LocalHtml();

        }


        public void SetLink(string strLink)
        {

            Link = strLink;

        }



    }
}

