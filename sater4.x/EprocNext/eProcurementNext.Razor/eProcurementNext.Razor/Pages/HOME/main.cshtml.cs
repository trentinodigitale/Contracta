using eProcurementNext.Application;
using eProcurementNext.CommonModule;
//using EprocNext.Response;

namespace eProcurementNext.Razor.Pages.HOME
{
    //[Authorize]// funziona solo se nella razor page ho dichiarato @model thisModel
    public class mainModel : eProcNextPage
    {
        public mainModel(IConfiguration configuration, IEprocResponse eprocResponse) : base(configuration, eprocResponse)
        {
        }

        public void OnGet()
        {

        }
    }
}
