using eProcurementNext.CommonModule;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.HTML
{
    public class Fld_Button
    {

        string Name;          //'-- valore tecnico del campo
        private dynamic? _value; //Backing field

        public dynamic? Value //'-- valore tecnico del campo
        {
            get
            {
                return _value;
            }
            set
            {
                try
                {
                    //if (value == DBNull.Value)
                    if (value == null || value.GetType() == typeof(DBNull))
                        _value = null;
                    else
                        _value = value;
                }
                catch (Exception)
                {
                    _value = value;
                }

            }
        }
        public bool Editable;
        public string mp_id;

        public string Style; //'-- percorso degli style sheet

        //'-- contenogono il nome della funzione JS da chiamare sul campo per l'evento considerato
        private string mp_OnFocus;
        private string mp_OnBlur;
        private string mp_OnChange;
        private string mp_OnClick;


        //'-- avvalora la collezione con i javascript necessari al corretto
        //'-- funzionamento del controllo
        public void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/")
        {

        }
        public void Init(string oName = "", dynamic oValue = null, bool oEditable = true)
        {
            if (oValue == null)
                oValue = "";
            //'-- inizializza tutti gli attributi della classe
            this.Value = oValue;
            Name = oName;
            Editable = oEditable;
        }


        //'-- ritorna il valore del campo espresso correttamente per l'SQL
        public string SQLValue()
        {

            return "'" + (CStr(Value).Replace("'", "''")) + "'";

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

        public void setOnClick(string JS)
        {


            mp_OnClick = JS;

        }
        public string TxtValue()
        {
            return Value;
        }

        public dynamic? RSValue()
        {
            return Value;
        }

        public void toPrint(IEprocResponse objResp, bool? pEditable)
        {
            this.Html(objResp, pEditable);
        }

        public string toPrintExtraContent(IEprocResponse objResp, dynamic OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {
            return "";
        }



        public Fld_Button()
        {
            Style = "button";
            Editable = true;
            mp_id = "1";
        }


        public void Html(IEprocResponse objResp, dynamic? pEditable = null)
        {

            bool vEditable;
            vEditable = Editable;
            if (pEditable != null)
            {
                vEditable = pEditable;
            }



            //'-- apertura del controllo
            objResp.Write($@"<input type=""button"" name=""{Name}""  id=""{Name}"" ");
            objResp.Write($@" class=""{Style}"" ");
            objResp.Write($@" value=""{HtmlEncode(this.Value)}"" ");
            objResp.Write($@" onclick=""{mp_OnClick}"" ");

            if (vEditable == false)
            {
                objResp.Write(@" disabled=""disabled"" ");
            }

            objResp.Write("/>");


        }


    }
}

