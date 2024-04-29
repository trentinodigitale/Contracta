using Microsoft.AspNetCore.Html;

namespace eProcurementNext.Razor.Model
{
    public class CommonHeaders
    {
        public string versioneAflink { get; set; }
        public string portaleCliente { get; set; }
        public string PATH_STYLE { get; set; }
        public string layout { get; set; }
        public string title { get; set; }
        public string path_root { get; set; }
        public dynamic idPfu { get; set; }
        public dynamic idAzi { get; set; }
        public dynamic logoutIAM { get; set; }
        public string retUrl { get; set; }
        public dynamic idToken { get; set; }

        public string FaseDiTest { get; set; }

        //CODICE TEMPORANEO SESSION, APPLICATION DA ELIMINARE
        public Dictionary<String, dynamic> session = new Dictionary<String, dynamic>();
        public Dictionary<String, dynamic> application = new Dictionary<String, dynamic>();

        public HtmlString headersRows { get; set; }
    }
}
