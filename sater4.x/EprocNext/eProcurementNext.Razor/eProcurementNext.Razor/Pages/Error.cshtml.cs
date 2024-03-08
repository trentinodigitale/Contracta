using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Primitives;
using System.Diagnostics;

namespace eProcurementNext.Razor.Pages
{
    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    [IgnoreAntiforgeryToken]
    public class ErrorModel : PageModel
    {
        public string? RequestId { get; set; }

        public bool ShowRequestId => !string.IsNullOrEmpty(RequestId);

        public Exception? Error = null;

        public string? Source { get; set; }

        public string? ExceptionMessage { get; set; }

        public string? ExceptionDescription { get; set; }

        private readonly ILogger<ErrorModel> _logger;

        public ErrorModel(ILogger<ErrorModel> logger)
        {
            _logger = logger;
        }

        public IActionResult OnGetPost()
        {
            RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier;

            var exceptionHandlerPathFeature =
            HttpContext.Features.Get<IExceptionHandlerPathFeature>();

            if (exceptionHandlerPathFeature?.Error is ResponseEndException)
            {
                if (exceptionHandlerPathFeature?.Error.Data.Contains("htmlToReturn") == true && exceptionHandlerPathFeature?.Error.Data["htmlToReturn"] != null)
                {
                    StringValues cookies = (StringValues)exceptionHandlerPathFeature?.Error.Data["cookies"];
                    Response.Headers["set-cookie"] = cookies;

                    HttpContext.Response.StatusCode = StatusCodes.Status200OK;
                    return Content(exceptionHandlerPathFeature?.Error.Data["htmlToReturn"].ToString(), "text/html");
                }
            }
            else if (exceptionHandlerPathFeature?.Error is ResponseRedirectException)
            {
                StringValues cookies = (StringValues)exceptionHandlerPathFeature?.Error.Data["cookies"];
                Response.Headers["set-cookie"] = cookies;

                return Redirect(exceptionHandlerPathFeature?.Error.Message);
            }
            else
            {
                Error = exceptionHandlerPathFeature?.Error;
                Source = exceptionHandlerPathFeature?.Error.Source;
                ExceptionMessage = exceptionHandlerPathFeature?.Error.Message;
                ExceptionDescription = exceptionHandlerPathFeature?.Error.ToString().Replace(":line", "<b>:line</b>");



                //if (Error != null)
                //{
                //    var sb = new StringBuilder();
                //    var st = new StackTrace(Error, true);

                //    // Get the top stack frame
                //    var firstFrame = st.GetFrame(0);
                //    // Get the line number from the stack frame
                //    int line = firstFrame.GetFileLineNumber();

                //    string? fileName = firstFrame.GetFileName();
                //    int column = firstFrame.GetFileColumnNumber();
                //    var method = firstFrame.GetMethod();

                //    foreach (StackFrame frame in st.GetFrames())
                //    {
                //        fileName = frame.GetFileName();
                //        line = frame.GetFileLineNumber();
                //        column = frame.GetFileColumnNumber();
                //        method = frame.GetMethod();

                //        sb.AppendLine($"{fileName}:{line}:{column}:{method}");
                //    }

                //    string stackDesc = sb.ToString();
                //}

                string qs;
                try
                {
                    qs = this.HttpContext.Request.QueryString.ToString();
                }
                catch
                {
                    qs = "Error Getting QueryString";

                }


                string loggerString =
                    "Unhandled exception: " + Environment.NewLine
                    + "PageRequested: " + (exceptionHandlerPathFeature != null ? exceptionHandlerPathFeature.Path : "unknown path") + Environment.NewLine
                    + "QueryString: " + qs + Environment.NewLine
                    + "Message: " + Environment.NewLine
                    + ExceptionDescription;

                _logger.LogError(loggerString);
            }

            return Page();


        }

        public IActionResult OnGet()
        {
            return OnGetPost();

            //RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier;

            //var exceptionHandlerPathFeature =
            //HttpContext.Features.Get<IExceptionHandlerPathFeature>();

            //if(exceptionHandlerPathFeature?.Error is ResponseEndException)
            //{
            //    if (exceptionHandlerPathFeature?.Error.Data.Contains("htmlToReturn") == true && exceptionHandlerPathFeature?.Error.Data["htmlToReturn"] != null)
            //    {
            //        return Content(exceptionHandlerPathFeature?.Error.Data["htmlToReturn"].ToString(), "text/html");
            //    }
            //}

            //if (exceptionHandlerPathFeature?.Error is ResponseRedirectException)
            //{
            //    return Redirect(exceptionHandlerPathFeature?.Error.Message);
            //}

            //return Page();


        }

        public IActionResult OnPost()
        {
            return OnGetPost();

            //RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier;

            //var exceptionHandlerPathFeature =
            //HttpContext.Features.Get<IExceptionHandlerPathFeature>();

            //if (exceptionHandlerPathFeature?.Error is ResponseEndException)
            //{
            //    if (exceptionHandlerPathFeature?.Error.Data.Contains("htmlToReturn") == true && exceptionHandlerPathFeature?.Error.Data["htmlToReturn"] != null)
            //    {
            //        return Content(exceptionHandlerPathFeature?.Error.Data["htmlToReturn"].ToString(), "text/html");
            //    }
            //}

            //if (exceptionHandlerPathFeature?.Error is ResponseRedirectException)
            //{
            //    return Redirect(exceptionHandlerPathFeature?.Error.Message);
            //}

            //return Page();


        }


    }
}