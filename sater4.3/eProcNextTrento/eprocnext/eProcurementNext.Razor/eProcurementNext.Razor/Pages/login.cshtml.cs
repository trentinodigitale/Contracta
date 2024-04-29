using Microsoft.AspNetCore.Mvc.RazorPages;

namespace eProcurementNext.Razor.Pages
{
    public class loginModel : PageModel
    {
        public static Dictionary<string, dynamic> ObjUsersLogged = new Dictionary<string, dynamic>();

        public void OnGet()
        {
        }


    }
}
