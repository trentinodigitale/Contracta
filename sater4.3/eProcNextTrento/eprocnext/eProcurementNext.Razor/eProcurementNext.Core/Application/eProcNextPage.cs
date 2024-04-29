using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;

namespace eProcurementNext.Application
{
    public class eProcNextPage : PageModel
    {
        public IConfiguration _configuration;

        public IEprocResponse _eprocResponse;

        public eProcNextPage(IConfiguration configuration, IEprocResponse eprocResponse)
        {
            _configuration = configuration;

            _eprocResponse = eprocResponse;

        }


    }
}