using AutoMapper;
using Microsoft.AspNetCore.Mvc;

namespace eProcurementNext.WebAPI.Controllers
{
    [Route("api/v1/[controller]")]     //Questa route contiene il place holder [controller], così facendo la rotta risponderà al nome 'Process'
    [ApiController]                 //mette una serie di comportamenti di default ai nostri controller. ad es. ci permette l'uso delle rotte
    public class ProcessController : TsControllerBase
    {
        private readonly ILogger<ProcessController> _logger;
        private readonly IConfiguration _configuration;
        private readonly IMapper _mapper;

        public ProcessController(ILogger<ProcessController> logger, IConfiguration configuration, IMapper mapper)
        {
            //Proprietà recuperate con la dependency injection
            _logger = logger;
            _configuration = configuration;
            _mapper = mapper;
        }

        //[HttpPost(Name = "Elaborate")]
        //public async Task<ProcessResponseModel> elaborateAsync(ProcessRequestModel model)
        //{
        //    return null!;
        //}

        /// <summary>
        /// Ex: /api/v1/Process
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public string ping() //i metodi prendono il nome di AZIONE/ACTION
        {
            return "pong";
        }

        //[HttpGet]
        //[Route("{id}")]
        //public async Task<int> sendBack(int id, [FromQuery]int sum = 0)
        //{
        //    return id + sum;
        //}

        /// <summary>
        /// Ex: /api/v1/Process/1234
        /// </summary>
        /// <param name="num"></param>
        /// <returns></returns>
        [HttpGet("{num}")]
        public async Task<IActionResult> GetNumber(int num)
        {
            try
            {
                var result = new { status = "OK", number = num };
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"{ex.Message}");
            }
        }


    }
}
