using eProcurementNext.CommonModule;
using eProcurementNext.DashBoard;
using Microsoft.AspNetCore.Html;
using Microsoft.AspNetCore.Mvc;
using static eProcurementNext.Session.SessionMiddleware;

namespace eProcurementNext.Razor
{
    public class MenuViewComponent : ViewComponent
    {
        private IConfiguration _configuration;
        private IEprocResponse _response;

        private IHttpContextAccessor _accessor;

        private eProcurementNext.Session.ISession _session;


        public MenuViewComponent(IHttpContextAccessor Accessor, eProcurementNext.Session.ISession _Session)
        {
            _accessor = Accessor;
            _session = _Session;
            _response = new EprocResponse();

            HttpContext context = this._accessor.HttpContext;

            LoadSession(context, _session);

        }

        public IViewComponentResult Invoke()
        {
            var item = GetHtmlCode();

            return View(item);
        }


        private Model.MenuResponse GetHtmlCode()
        {

            Model.MenuResponse outputHtml = new Model.MenuResponse();
            //GRFunz gr = new GRFunz(_configuration, _response);
            GRFunz gr = new GRFunz(_session, this._accessor.HttpContext, _response);

            string result = gr.drawGruppi();

            HtmlString hString = new HtmlString(result);
            outputHtml.Content = hString;
            return outputHtml;
        }

    }
}
