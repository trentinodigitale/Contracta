using EprocNext.Response;
using EprocNext.DashBoard;
using Microsoft.AspNetCore.Html;

namespace eProcurementNext.Razor
{
    public class MenuService : IMenuService
    {
        private IConfiguration _configuration;
        private IEprocResponse _response;
        public HtmlString GetMenu(IConfiguration configuration, IEprocResponse response)
        {
            _configuration = configuration;
            _response = response;
            GRFunz gr = new GRFunz(_configuration, _response);

            string result = gr.drawGruppi();
            HtmlString hString = new HtmlString(result);

            return hString;
        }
    }
}
