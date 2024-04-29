using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Html;
using EprocNext.Response;

namespace eProcurementNext.Razor
{
    public class ResponseViewComponent : ViewComponent
    {
        private IResponseService _responseService;
        private IConfiguration _configuration;
        private IEprocResponse _response;


        public ResponseViewComponent(IResponseService responseService, IConfiguration configuration, IEprocResponse eResponse)
        {
            _responseService = responseService;
            _configuration = configuration;
            _response = eResponse;
        }

        public async Task<IViewComponentResult> InvokeAsync()
        {
            var item = await GetHtmlCodeAsync();
            return View(item);
        }

        private async Task<Model.MenuResponse> GetHtmlCodeAsync()
        {
            Task<HtmlString> esito = Task.Run(() => _responseService.GetResponse(_configuration, _response));
            Model.MenuResponse outputHtml = new Model.MenuResponse();
            outputHtml.Content = esito.Result;
            return outputHtml;
        }
    }
}
