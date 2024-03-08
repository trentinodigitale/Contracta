using EprocNext.Response;
using Microsoft.AspNetCore.Html;

namespace eProcurementNext.Razor
{
    public interface IMenuService
    {
        HtmlString GetMenu(IConfiguration configuration, IEprocResponse response);
    }
}
