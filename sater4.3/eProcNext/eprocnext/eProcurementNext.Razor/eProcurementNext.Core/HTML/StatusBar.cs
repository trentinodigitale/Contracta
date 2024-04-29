using eProcurementNext.CommonModule;

namespace eProcurementNext.HTML
{
    public class StatusBar
    {
        public List<dynamic> Panels;
        private List<string> mp_PanelsWidth;
        public string width;
        public string strPath;          //'-- percorso per le immagini di default
        public string Style;            //'-- classe di default
        //private Response As Object

        public StatusBar()
        {

            Panels = new List<dynamic>();

            width = "100%";
            Style = "SB";
            strPath = "../CTL_Library/images/StatusBar/";
            mp_PanelsWidth = new List<string>();
            mp_PanelsWidth.Add("");
            //ReDim mp_PanelsWidth(1) As String

        }


        //'-- definisce la larghezza di un pannello
        public void SetPanelWidth(int ind, string width)
        {

            if (mp_PanelsWidth.Count < ind)
            {
                mp_PanelsWidth.RemoveRange(ind - 1, mp_PanelsWidth.Count - ind);
            }

            mp_PanelsWidth[ind - 1] = width;

        }

        //'-- avvalora la collezione con i javascript necessari al corretto
        //'-- funzionamento del controllo
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
        {

        }



        ////'-- ritorna il codice html per rappresentare la riga di un gruppo
        public void Html(IEprocResponse objResp)
        {

            ////'---- disegno la status bar
            LocalDrawStausBar(objResp);

        }



        //' -- disegna la toolbar
        void LocalDrawStausBar(IEprocResponse objResp)
        {

            try
            {

                dynamic panel;
                int i;



                //'-- apertura della tabella HTML
                objResp.Write($@"<table width=""{width}"" cellpadding=""0"" cellspacing=""0"" class=""{Style}_Bar"" > ");

                //'-- apertura della riga
                objResp.Write($@"<tr>");


                //' -- ciclo sugli oggetti contenuti nella status bar

                for (i = 1; i <= Panels.Count; i++)
                {

                    panel = Panels[i - 1];

                    objResp.Write($@"<td class=""{Style}_Panel"" ");

                    if (i < mp_PanelsWidth.Count)
                    {
                        if (!string.IsNullOrEmpty(mp_PanelsWidth[i - 1]))
                        {
                            objResp.Write($@" width=""{mp_PanelsWidth[i - 1]}"" ");
                        }
                    }
                    objResp.Write($@" id=""{panel.Name}"" ");
                    objResp.Write($@">");

                    //'-- invoco il disegno dell'oggetto
                    panel.Html(objResp);

                    objResp.Write($@"</td>");

                }


                //'-- chiusura della riga
                objResp.Write("</tr>");

                //'-- chiusura della tabella HTML
                objResp.Write("</table> ");

                //'-- ritorna la stringa dei gruppi
                //'LocalDrawStausBar = strApp

            }
            catch (Exception ex)
            {
                throw new NotImplementedException(ex.Message);
                //return ShowErr(err.number, err.source & " - StatusBar", err.description)
            }


        }

    }
}

