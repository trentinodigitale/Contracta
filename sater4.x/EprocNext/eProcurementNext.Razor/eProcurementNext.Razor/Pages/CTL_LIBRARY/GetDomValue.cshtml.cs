using Microsoft.AspNetCore.Mvc.RazorPages;
using eProcurementNext.Application;
using eProcurementNext.Session;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.Session.SessionMiddleware;
using eProcurementNext.Core.Pages.CTL_LIBRARY.functions;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY
{
	public class getDomValueModel : PageModel
	{
		public SessionMiddleware _sessionMiddleware;
		public Session.ISession _session;
		readonly HttpContext _httpContext;
		readonly HttpRequest _request;

		public getDomValueModel(Session.ISession session, IHttpContextAccessor accessor)
		{
			_httpContext = accessor.HttpContext;
			_request = accessor.HttpContext.Request;
			RequestDelegate next = (HttpContext hc) => Task.CompletedTask;
			_sessionMiddleware = new(next, null);
			_session = session;
			LoadSession(_httpContext, _session);
			checkWhiteList();
		}

		public void checkWhiteList()
		{
			string dominio = GetParamURL(_request.QueryString.ToString(), "dominio");
			if (string.IsNullOrEmpty(dominio))
			{
				dominio = GetValueFromForm(_request, "dominio");
			}
			string SYS_Whitelist = CStr(ApplicationCommon.Application["DOMINI_NO_SESSION"]);
			string[] whiteList = SYS_Whitelist.Split("@");
			bool isFreePage = CheckSessionModel.IsFreePage(_httpContext);
			bool canPass = whiteList.Any(x => { return (x.ToUpper() == dominio.ToUpper()); });
			if (!canPass && isFreePage)
			{
				_sessionMiddleware.forceIsNotFreePage = true;
				_sessionMiddleware.Invoke(_httpContext, _session).Wait();
			}
		}

		public void OnGet()
		{
		}

	}
}
