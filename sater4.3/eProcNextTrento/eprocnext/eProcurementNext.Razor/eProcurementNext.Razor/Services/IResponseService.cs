using EprocNext.Response;
using Microsoft.AspNetCore.Html;

namespace eProcurementNext.Razor
{
    public interface IResponseService
    {
        HtmlString GetResponse(IConfiguration configuration, IEprocResponse response);
    }
}
