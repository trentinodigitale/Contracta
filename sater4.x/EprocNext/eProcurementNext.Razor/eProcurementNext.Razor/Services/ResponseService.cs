using EprocNext.Response;
using EprocNext.DashBoard;
using Microsoft.AspNetCore.Html;

namespace eProcurementNext.Razor
{
    public class ResponseService : IResponseService
    {
        private IConfiguration _configuration;
        private IEprocResponse _response;
        public HtmlString GetResponse(IConfiguration configuration, IEprocResponse response )
        {
            _configuration = configuration;
            _response = response;
            GRFunz gr = new GRFunz(configuration, _response);

               string result = gr.drawGruppi();
            HtmlString hString = new HtmlString(result);

            //return result;
            return hString;
        }
    }
}
