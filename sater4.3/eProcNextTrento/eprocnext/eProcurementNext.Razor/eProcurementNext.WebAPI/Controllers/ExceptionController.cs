using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;

namespace eProcurementNext.WebAPI.Controllers
{
    [ApiController]
    public class ExceptionController : ControllerBase
    {

        ILogger<ProcessController> _logger;
        public ExceptionController(ILogger<ProcessController> logger)
        {
            _logger = logger;
        }
        /*Questo handler rispetta "automaticamente" lo standard degli errori web RFC*/

        [HttpGet]
        [HttpPost]
        [Route("/apierror-development")]
        public IActionResult HandleErrorDevelopment([FromServices] IHostEnvironment hostEnvironment)
        {
            var exceptionHandlerFeature =
                HttpContext.Features.Get<IExceptionHandlerFeature>()!;

            _logger.Log(LogLevel.Error, message:
                "Message" + exceptionHandlerFeature.Error.Message + Environment.NewLine +
                "StackTrace" + exceptionHandlerFeature.Error.StackTrace
                );
            if (!hostEnvironment.IsDevelopment())
            {
                if (exceptionHandlerFeature?.Error is AuthorizedException)
                {
                    return Unauthorized();
                }
                //HERE aggiungi qui altre Exception

            }


            return Problem(
                detail: exceptionHandlerFeature.Error.StackTrace,
                title: exceptionHandlerFeature.Error.Message);
        }

        [HttpGet]
        [HttpPost]
        [Route("/apierror")]
        public IActionResult HandleError()
        {
            var exceptionHandlerFeature =
                HttpContext.Features.Get<IExceptionHandlerFeature>()!;
            _logger.Log(LogLevel.Error, message: exceptionHandlerFeature.Error.Message);

			if (exceptionHandlerFeature?.Error is AuthorizedException)
			{
				return Unauthorized();
			}
			//HERE aggiungi qui altre Exception


			return Problem();
        }



    }
}
