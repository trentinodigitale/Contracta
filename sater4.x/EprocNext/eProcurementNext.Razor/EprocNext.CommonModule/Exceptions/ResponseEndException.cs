using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Primitives;

namespace eProcurementNext.CommonModule
{
    public class ResponseEndException : EprocNextException
    {
        public ResponseEndException(string htmlToReturn, HttpResponse resp, string message)
            : base(message)
        {
            this.Data.Add("htmlToReturn", htmlToReturn);
            StringValues cookies = resp.Headers["set-cookie"];
            this.Data.Add("cookies", cookies);
        }

        public ResponseEndException(string htmlToReturn, HttpResponse resp, string message, Exception inner)
            : base(message, inner)
        {
            this.Data.Add("htmlToReturn", htmlToReturn);
            StringValues cookies = resp.Headers["set-cookie"];
            this.Data.Add("cookies", cookies);
        }
    }
}
