using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Text;

namespace eProcurementNext.Razor.TestPages
{
    public class testModel : PageModel
    {

        //public async Task<IActionResult> OnGetAsync()
        //{
        //    await _context.SaveChangesAsync();
        //}

        public void OnGet()
        {

            var path = Request.Path.ToString();

            var str = "hello world";
            byte[] bytes = Encoding.ASCII.GetBytes(str);



            //Request.Body.BeginWrite(bytes, 0, bytes.Length, null, null);



            //var sw = new StringWriter();

            //StreamWriter("")
            //.WriteLine(sw.ToString());




            //var ms = new MemoryStream();
            //this.Response.Body = ms;
            //ms.Write(bytes, 0, bytes.Length);



            //var body = this.Response.Body;
            //if (body != null)
            //{
            //    body.WriteAsync(bytes);
            //    body.Close();
            //}


            //await this.Response.Body.WriteAsync(bytes);

            //await HttpContext.Response.Body.WriteAsync(bytes);



            //this.Response.WriteAsync("1#OK");
            //HttpContext.Response.WriteAsync("1#OK");
        }
    }
}
