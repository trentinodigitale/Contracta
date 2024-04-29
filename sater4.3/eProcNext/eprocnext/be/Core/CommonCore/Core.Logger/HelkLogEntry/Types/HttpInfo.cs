using Core.Logger.Types;
using System.Net;

namespace Core.Logger.HelkLogEntry.Types
{
    public class HttpResponseInfo
    {
        /// <summary>
        /// Response status code received from server
        /// for the current HTTP Request.
        /// </summary>
        public HttpStatusCode Status_code { get; set; }
    }

    public class HttpRequestInfo
    {
        /// <summary>
        /// HTTP Method used to the current request
        /// </summary>
        public HttpRequestMethod Method { get; set; }
        /// <summary>
        /// Total size in bytes of the request
        /// </summary>
        public long? Bytes { get; set; }
    }

    public class HttpInfo
    {
        public HttpRequestInfo Request { get; set; }
        public HttpResponseInfo Response { get; set; }
    }
}
