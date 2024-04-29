using eProcurementNext.CommonModule;

namespace eProcurementNext.HTML
{
    public class ToolbarButton
    {
        public string Text;
        public string Style;
        public string Icon;
        public string Target;
        public string Id;
        public string URL;
        public string ToolTip;
        public string paramTarget;
        public string OnClick;
        public string Condition;

        //private response As Object

        public bool Enabled;

        //'-- per l'accessibilit�
        public string accessKey;

        //'-- ritorna il codice html per rappresentare la riga di un gruppo
        public void Html(IEprocResponse objResp)
        {


        }


        public ToolbarButton()
        {
            Style = "ToolBar_button";
            Enabled = true;
        }



    }
}

