using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web.Http;

namespace INIPEC.Controllers
{
    public class PingController : ApiController
    {
	    [HttpGet]
	    public HttpResponseMessage ping(string id = "", string operation = "")
	    {
		    return new HttpResponseMessage()
		    {
			    Content = new StringContent(
				    "1#PONG",
				    Encoding.UTF8,
				    "text/html"
			    )
		    };
	    }
	}
}
