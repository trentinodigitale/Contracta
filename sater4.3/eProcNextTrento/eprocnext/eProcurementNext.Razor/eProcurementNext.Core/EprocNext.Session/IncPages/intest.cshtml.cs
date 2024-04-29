using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System.Reflection;

namespace eProcurementNext.Core.Pages.CTL_LIBRARY.functions
{

    public class IgnoreErrorPropertiesResolver : DefaultContractResolver
    {

        protected override JsonProperty CreateProperty(MemberInfo member, MemberSerialization memberSerialization)
        {
            JsonProperty property = base.CreateProperty(member, memberSerialization);



            List<string> temp2 = new List<string>();

            temp2.Add("InputStream");
            temp2.Add("Filter");
            temp2.Add("Length");
            temp2.Add("Position");
            temp2.Add("ReadTimeout");
            temp2.Add("WriteTimeout");
            temp2.Add("LastActivityDate");
            temp2.Add("LastUpdatedDate");
            temp2.Add("Session");


            if (property.PropertyName != null && temp2.Contains(property.PropertyName))
            {
                property.Ignored = true;
            }
            return property;
        }
    }
    public class intestModel : PageModel
    {
        public void OnGet()
        {
        }

        //Per la traduzione della Viewer.asp traduzione non necessaria perchè questo metodo viene chiamato nella versione non accessibile
        public static void StartPage(EprocResponse htmlToReturn)
        {
            htmlToReturn.Write("<html>");
            htmlToReturn.Write("<head>");
            htmlToReturn.Write(@"<meta http-equiv=""Content-Type"" content=""text/html;charset=UTF-8"">");
        }

    
    }
}
