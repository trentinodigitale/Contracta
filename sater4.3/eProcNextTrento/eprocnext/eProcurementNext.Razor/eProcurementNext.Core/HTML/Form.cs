using static eProcurementNext.HTML.Basic;

namespace eProcurementNext.HTML
{
    public class Form
    {
        //'Public Style    As String
        public string id;
        public string Method;
        public string Action;
        public string Target;

        public ButtonBar Button = new ButtonBar();
        public string EncType;

        public Form()
        {

            //'   Style = "Form"
            Method = "POST"; //'-- GET
            Action = ""; //'-- pagina da chiamare
            Target = ""; //'-- finestra di destinazione
            EncType = ""; //'--definisce il tipo di dati che il form invia
        }




        //'-- avvalora la collezione con i javascript necessari al corretto
        //'-- funzionamento del controllo
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
        {
            //On Error Resume Next
        }

        //'-- ritorna il codice html per rappresentare la riga di un gruppo
        public string OpenForm()
        {

            string strToReturn;

            strToReturn = $@"<form method=""{HtmlEncodeValue(Method).ToLower()}"" enctype=""{HtmlEncodeValue(EncType).ToLower()}"" action=""{HtmlEncodeValue(Action).ToLower()}"" ";


            strToReturn = $@"{strToReturn} id=""{HtmlEncodeValue(id)}"" ";


            strToReturn = $@"{strToReturn}> ";


            strToReturn = $@"{strToReturn}<fieldset>";


            Button.id = id;

            return strToReturn;

        }


        public string CloseForm()
        {

            string strToReturn;

            strToReturn = "</fieldset>";

            strToReturn = $@"{strToReturn}</form> ";

            return strToReturn;

        }

    }
}

