using eProcurementNext.CommonModule;

namespace eProcurementNext.HTML
{
    public class ButtonBar
    {

        public static int SubmitButton = 1;
        public static int ResetButton = 2;

        public string id;
        public string Height;
        public string width;
        public string Style;
        public bool ShowBackGround;

        public int ShowButtons;


        public string OnSubmit;
        public string OnReset;
        public string CaptionSubmit;
        public string CaptionReset;
        private IEprocResponse response;

        public ButtonBar()
        {

            Height = "";
            width = "100%";
            Style = "ButtonBar";
            ShowBackGround = false;
            OnSubmit = "";
            CaptionSubmit = "Submit";
            CaptionReset = "Reset";

            OnReset = "resetFormFiltro(this.form);";

            //TODO: il vecchio codice faceva 'SubmitButton or ResetButton', la variabile veniva anche settata da fuori ? capire perchè è stato cablato a 999.
            ShowButtons = 999; // forzato per mostrare i button! default era a 0// (SubmitButton || ResetButton); /

        }



        //'-- avvalora la collezione con i javascript necessari al corretto
        //'-- funzionamento del controllo
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
        {
            //On Error Resume Next
        }



        //'-- ritorna il codice html per rappresentare la riga di un gruppo
        public string Html(IEprocResponse objResp)
        {

            response = objResp;

            //'---- disegno la toolbar con tutti i link
            return LocalDrawToolBar();

        }



        //' -- disegna la toolbar
        string LocalDrawToolBar()
        {

            //On Error Resume Next

            string strApp;

            strApp = "";

            //'-- apertura della tabella HTML
            response.Write($@"<table width=""{width}"" cellpadding=""0"" cellspacing=""0"" class=""{Style}_Table""> ");

            //'-- apertura della riga
            response.Write($@"<tr>");

            //'-- disegno la prima cella a sinistra
            if (ShowBackGround)
            {
                response.Write($@"<td> ");
                response.Write($@"<img alt="""" src=""Left.gif""/>");
                response.Write($@"</td> ");
            }

            //' -- disegno i bottoni

            if (ShowButtons != 0 && SubmitButton != 0)
            {
                LocalDrawButton(SubmitButton);
            }
            if (ShowButtons != 0 && ResetButton != 0)
            {
                LocalDrawButton(ResetButton);
            }




            //' -- disegno la cella di separazione
            if (ShowBackGround)
            {
                response.Write($@"<td> ");
                response.Write($@"<img alt="""" src=""Middle.gif""/> ");
                response.Write($@"</td> ");
            }

            //' -- disegno la penultima cella

            response.Write($@"<td class=""width_100_percent"" ");

            if (ShowBackGround)
            {
                response.Write($@"background=""back.gif"" ");
            }
            response.Write($@" >");
            response.Write($@"&nbsp;");
            response.Write($@"</td> ");


            //' -- disegno l'ultima cella di chiusura

            if (ShowBackGround)
            {
                response.Write("<td> ");
                response.Write($@"<img alt="""" src=""Right.gif""/>");
                response.Write("</td> ");
            }

            //'-- chiusura della riga
            response.Write("</tr>");

            //'-- chiusura della tabella HTML
            response.Write("</table> ");

            //'-- ritorna la stringa dei gruppi
            return strApp;

        }

        //' -- disegna la cella di separazione e la cella che contiene il link
        string LocalDrawButton(int Button)
        {

            //On Error Resume Next

            string strApp;
            string strTooltip;
            string CaptionControl;
            string strOnClick;

            strApp = "";

            //' -- disegno la cella di separazione
            if (ShowBackGround)
            {
                response.Write($@"<td> ");
                response.Write($@"<img alt="""" src=""Middle.gif""/> ");
                response.Write($@"</td> ");
            }
            else
            {

                response.Write($@"<td class=""td_button_bar"" > ");

                response.Write($@"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td> ");
            }

            //' -- disegno la cella con il bottone
            response.Write($@"<td class=""nowrap""  ");

            response.Write($@"> ");

            //'-- disegno il bottone
            if (Button == SubmitButton)
            {

                if (String.IsNullOrEmpty(OnSubmit))
                {
                    response.Write($@"<input alt=""invia il form"" type=""submit"" value=""{CaptionSubmit}"" name=""{id}_submit"" id=""{id}_submit""  class=""{Style}_Button""/> ");
                }
                else
                {
                    response.Write($@"<input alt=""invia il form"" type=""submit"" value=""{CaptionSubmit}"" name=""{id}_submit"" id=""{id}_submit""  class=""{Style}_Button"" ");
                    response.Write($@" onclick=""Javascript:{OnSubmit}""/> ");
                }

            }

            if (Button == ResetButton)
            {


                //'If OnReset = "" Then
                //'    response.Write "<input alt=""pulisci il form"" type=""reset"" value=""" & CaptionReset & """ name=""" & id & "_reset""  id=""" & id & "_reset""  class=""" & Style & "_Button""/>"
                //'Else
                response.Write($@"<input alt=""pulisci il form"" type=""button"" value=""{CaptionReset}"" name=""{id}_reset""  id=""{id}_reset""  class=""{Style}_Button"" ");
                response.Write($@" onclick=""Javascript:{OnReset}""/>");
                //'End If

            }



            response.Write("</td> ");

            return strApp;


        }




    }
}

