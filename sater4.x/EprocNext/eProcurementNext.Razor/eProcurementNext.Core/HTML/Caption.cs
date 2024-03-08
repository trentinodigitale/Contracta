using eProcurementNext.Application;
using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using System.Web;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.HTML
{
    public class Caption
    {
        public string Text;
        public string Style;
        public string Icon;
        public string Func;
        public string id;
        public string strPath;
        private dynamic response;
        public string OnExit;
        public bool PrintMode; //'-- indica che la griglia � visualizzata per una stampa quindi non vanno messi
                               //'-- i meccanismi di eventi come onclick
        private string ShowImage; //'--ShowImage=0 senza immagini,altrimeti si
        private dynamic mp_session; //'--vettore sessione dell'utente
        public bool ShowExit; //'--indica se visualizzare exit

        public Caption()
        {
            Style = "Caption";
            strPath = "../CTL_Library/images/Caption/";
            ShowImage = "1";
            ShowExit = true;
        }

        public void JScript(Collection JS, String Path = "../CTL_Library/")
        {
            //On Error Resume Next
        }

        //'-- ritorna il codice html per rappresentare la riga di un gruppo
        public void Html(EprocResponse objResp)
        {
            objResp.Write(LocalHtml());
        }

        public string LocalHtml()
        {
            String strApp;
            String strGifLeft;
            String strGifRight;
            String strGifCenter;

            strGifLeft = "left.gif";
            strGifRight = "right.gif";
            strGifCenter = "center.gif";

            if (PrintMode)
            {
                strGifLeft = $"print_{strGifLeft}";
                strGifRight = $"print_{strGifRight}";
                strGifCenter = $"print_{strGifCenter}";
            }

            strApp = $@"<table width=""100%"" class=""{Style}"" ";

            if (CStr(id) != "")
            {
                strApp = $@"{strApp} Id = ""{id}""";
            }

            strApp = $@"{strApp} border=""0"" cellspacing=""0"" cellpadding=""0""> ";
            strApp = $@"{strApp}<tr>";


            strApp = $@"{strApp}<td ";

            if (ShowImage == "0")
            {
                strApp = $@"{strApp}> ";
            }
            else
            {

                strApp = $@"{strApp} background=""{strPath}{strGifCenter}"" > ";

            }

            strApp = $@"{strApp}{Text} ";
            strApp = $@"{strApp}</td> ";

            strApp = $@"{strApp}</tr> ";
            strApp = $@"{strApp}</table> ";

            return strApp;

        }

        //'-- avvalora in un unico passo tutti membri della classe e ritorna il codice HTML
        public String SetCaption(String aText, String aStyle = "", String aIcon = "", String aFunc = "", String aID = "")
        {

            if (aStyle != "")
            {
                Style = aStyle;
            }
            if (aIcon != "")
            {
                Icon = aIcon;
            }
            if (aFunc != "")
            {
                Func = aFunc;
            }
            if (aID != "")
            {
                id = aID;
            }

            Text = HttpUtility.HtmlEncode(aText);

            return LocalHtml();

        }


        private void Class_Initialize()
        {
            Style = "Caption";
            strPath = "../CTL_Library/images/Caption/";
            ShowImage = "1";
            ShowExit = true;
        }
        private void Class_Terminate()
        {
            //response = Nothing
        }


        public void Init(Session.ISession session)
        {
            ShowImage = ApplicationCommon.Application["ShowImages"];
            mp_session = session;
        }

    }
}

