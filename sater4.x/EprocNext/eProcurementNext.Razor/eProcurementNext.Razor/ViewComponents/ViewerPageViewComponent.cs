using eProcurementNext.DashBoard;
using Microsoft.AspNetCore.Html;
using Microsoft.AspNetCore.Mvc;
using static eProcurementNext.Session.SessionMiddleware;

namespace eProcurementNext.Razor.ViewComponents
{
    public class ViewerPageViewComponent : ViewComponent
    {
        private IHttpContextAccessor _accessor;

        private eProcurementNext.Session.ISession _session;

        private Model.ViewerTable vTable;
        private IConfiguration _configuration;

        public ViewerPageViewComponent(IConfiguration configuration, IHttpContextAccessor Accessor, eProcurementNext.Session.ISession _Session)
        {
            _accessor = Accessor;
            _session = _Session;
            _configuration = configuration;
            HttpContext context = this._accessor.HttpContext;
            LoadSession(context, _session);

        }

        public IViewComponentResult Invoke()
        {
            vTable = new();
            var item = GetHtmlCode();
            vTable.Content = new HtmlString(item.ToString());

            return View(vTable);
        }

        private System.Text.StringBuilder GetHtmlCode()
        {
            Viewer viewer = new Viewer(_configuration, _accessor, _session);
            System.Text.StringBuilder htmlResult = new System.Text.StringBuilder(viewer.run());

            return htmlResult;
        }
    }
}
