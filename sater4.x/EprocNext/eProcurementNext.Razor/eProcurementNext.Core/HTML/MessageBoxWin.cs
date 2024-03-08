using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Http;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;


namespace eProcurementNext.HTML
{
    public class MessageBoxWin
    {

        //' MSG = messaggio da visualizzare
        //' CAPTION = caption
        //' TITLE 0 titolo finestra
        //' ICO = 1-info,2-errore,3-question,4-warning
        //' ON_OK = azione sul tasto ok altrimenti chiude la finestra su ok
        //' ML = applica il multilinguismo
        //' NO_CANCEL =1 non inserisce il tasto cancel altrimenti lo inserisce per chiudere la finestra
        //' ON_KO = azione sul tasto Cancel altrimenti chiude la finestra su ok
        //' CAPTION_OK = caption tasto ok
        //' CAPTION_CANEL = caption tasto cancel

        private string mp_strcause;
        private string mp_MsgText;
        private string mp_caption;
        private string mp_Title;

        string Request_QueryString;
        private string mp_modale;


        public MessageBoxWin(HttpContext _context)
        {
            Request_QueryString = GetQueryStringFromContext(_context.Request.QueryString);
        }


        public void run(eProcurementNext.Session.ISession session, EprocResponse response/*session As Variant, response As Object*/)
        {

            //EprocResponse _response = new EprocResponse();

            MsgBox ObjMsgBox = new MsgBox();

            Dictionary<string, string> JS = new Dictionary<string, string>();

            //'-- recupero variabili di sessione
            InitLocal(session);

            if (mp_modale != "YES")
            {

                //'-- recupera i javascript necessari dagli oggetti dell'interfaccia
                mp_strcause = "recupera i javascript necessari dagli oggetti dell'interfaccia";
                ObjMsgBox.JScript(JS);


                //'-- inserisce i java script necessari
                mp_strcause = "inserisce i java script necessari";
                response.Write(eProcurementNext.CommonModule.Basic.JavaScript(JS));


            }



            if (GetParamURL(Request_QueryString, "ICO") != "")
            {
                switch (CInt(GetParamURL(Request_QueryString, "ICO")))
                {
                    case 1:
                        ObjMsgBox.Icon = "info.gif";
                        break;
                    case 2:
                        ObjMsgBox.Icon = "err.gif";
                        break;
                    case 3:
                        ObjMsgBox.Icon = "ask.gif";
                        break;
                    case 4:
                        ObjMsgBox.Icon = "warning.gif";
                        break;
                    default:
                        break;
                }

            }

            if (mp_modale != "YES")
            {
                response.Write($@"<title>{HtmlEncode(mp_caption)}</title>");
                response.Write($@"</head><body  onblur=""self.focus();"" > ");
            }

            ObjMsgBox.ActionScript = GetParamURL(Request_QueryString, "ON_OK");

            //'--setto azione on ko
            ObjMsgBox.ActionCancel = GetParamURL(Request_QueryString, "ON_KO");

            //'--setto path se passato
            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "PATH")))
            {
                ObjMsgBox.strPath = $@"{GetParamURL(Request_QueryString, "PATH")}CTL_Library/images/MsgBox/";
            }

            //'--setto caption tasto ok
            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "CAPTION_OK")))
            {
                ObjMsgBox.CaptionOK = GetParamURL(Request_QueryString, "CAPTION_OK");
            }

            //'--setto caption tasto cancel
            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString, "CAPTION_KO")))
            {
                ObjMsgBox.CaptionCancel = GetParamURL(Request_QueryString, "CAPTION_KO");
            }


            if (GetParamURL(Request_QueryString, "ML").ToLower() == "yes")
            {
                ObjMsgBox.CaptionCancel = Application.ApplicationCommon.CNV(ObjMsgBox.CaptionCancel, session);
                ObjMsgBox.CaptionOK = Application.ApplicationCommon.CNV(ObjMsgBox.CaptionOK, session);
            }

            //'--controllo se non voglio il tasto cancel
            if (GetParamURL(Request_QueryString, "NO_CANCEL") == "1")
            {
                ObjMsgBox.CaptionCancel = "";
            }


            ObjMsgBox.mp_modale = mp_modale;

            response.Write(ObjMsgBox.Init(mp_MsgText, (long)Constants.vbOK, mp_caption));

            //return response.Out();

        }


        private void InitLocal(eProcurementNext.Session.ISession session)
        {


            //Set Request_QueryString = session(0)

            //'CAMBIATO IN QUANTO LA GETPARAMURL GENERAVA UN ERRORE NEL MSG CON CARATTERI ACCENTATI
            //'mp_MsgText = GetParamURL(Request_QueryString, "MSG")
            mp_MsgText = GetParamURL(Request_QueryString, "MSG");
            mp_caption = GetParamURL(Request_QueryString, "CAPTION");
            mp_Title = GetParamURL(Request_QueryString, "TITLE");


            //'ActionScript = Request_QueryString("ON_OK")

            if (GetParamURL(Request_QueryString, "ML").ToLower() == "yes")
            {
                mp_MsgText = Application.ApplicationCommon.CNV(mp_MsgText, session);
                mp_caption = Application.ApplicationCommon.CNV(mp_caption, session);
                mp_Title = Application.ApplicationCommon.CNV(mp_Title, session);
            }
            else
            {
                mp_MsgText = HtmlEncode(mp_MsgText);
                mp_caption = HtmlEncode(mp_caption);
                mp_Title = HtmlEncode(mp_Title);
            }

            mp_modale = GetParamURL(Request_QueryString, "MODALE");

        }

    }
}

