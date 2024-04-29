using eProcurementNext.CommonModule;
using Microsoft.VisualBasic;
using System.Net;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.HTML
{
    public class Fld_Hidden
    {


        public Fld_Hidden()
        {

        }

        public string Name;          //'-- valore tecnico del campo
        public dynamic Value;      //'-- valore tecnico del campo

        //'-- contenogono il nome della funzione JS da chiamare sul campo per l'evento considerato
        private string mp_OnFocus;
        private string mp_OnBlur;
        private string mp_OnChange;
        private string response;

        //Public Sub JScript(JS As Collection, Optional Path As String = "../CTL_Library/")
        //    On Error Resume Next
        //End Sub


        public void Init(string oName = "", dynamic? oValue = null)
        {

            //'-- inizializza tutti gli attributi della classe
            Value = (oValue == null) ? "" : oValue;
            Name = oName;

        }



        //'-- ritorna il codice html del valore
        public string Html(IEprocResponse _response)
        {


            _response.Write($@"<input type=""hidden"" name=""{Name}""  id=""{Name}"" ");
            _response.Write($@" value=""{WebUtility.HtmlEncode(CStr(this.Value))}"" "); //'--w3c
            _response.Write($@"/>{Environment.NewLine}");
            return _response.Out();
        }

        //'-- ritorna il valore del campo espresso correttamente per l'SQL
        public string SQLValue()
        {

            //'SQLValue = Value
            return Strings.Replace(Value, "'", "''");

        }


        public void setOnFocus(string JS)
        {

            mp_OnFocus = JS;

        }

        public void setOnBlur(string JS)
        {

            mp_OnBlur = JS;

        }


        public void setOnChange(string JS)
        {

            mp_OnChange = JS;

        }


        //public void setOnClick(String JS)

        //}

        public string TxtValue()
        {

            return Value;

        }

        public dynamic RSValue()
        {
            return Value;
        }

        public string toPrint(IEprocResponse objResp)
        {
            return Html(objResp);
        }

        //public Function toPrintExtraContent(response As Object, OBJSESSION As Variant, Optional ByVal params As String = "", Optional ByRef startPage As String = "", Optional ByVal strHtmlHeader As String = "", Optional ByVal strHtmlFooter As String = "", Optional ByVal contaPagine As Boolean = False) As String

        //}


    }
}

