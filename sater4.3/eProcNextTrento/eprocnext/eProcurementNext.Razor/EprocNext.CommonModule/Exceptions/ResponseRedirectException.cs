using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Primitives;

namespace eProcurementNext.CommonModule
{
    public class ResponseRedirectException : EprocNextException
    {
        public ResponseRedirectException(string redirectPath, HttpResponse resp)
            : base(redirectPath)
        {
            StringValues cookies = resp.Headers["set-cookie"];
            this.Data.Add("cookies", cookies);
        }

        public ResponseRedirectException(string redirectPath, HttpResponse resp, Exception inner)
            : base(redirectPath, inner)
        {
            StringValues cookies = resp.Headers["set-cookie"];
            this.Data.Add("cookies", cookies);
        }

    }
}
