using AutoMapper;
using eProcurementNext.Authentication;
using eProcurementNext.WebAPI.Model;
using Microsoft.AspNetCore.Mvc;

namespace eProcurementNext.WebAPI.Controllers
{
    [Route("api/v1/[controller]")]     //Questa route contiene il place holder [controller], così facendo la rotta risponderà al nome 'Process'
    [ApiController]                 //mette una serie di comportamenti di default ai nostri controller. ad es. ci permette l'uso delle rotte
    public class AuthController : TsControllerBase
    {
        private readonly ILogger<ProcessController> _logger;
        private readonly IConfiguration _configuration;
        private readonly IMapper _mapper;
        private readonly IEprocNextAuthentication _jwt;
        private readonly eProcurementNext.Session.ISession _session;
        private readonly IHostEnvironment _hostEnvironment;

		public AuthController(
            ILogger<ProcessController> logger,
            IConfiguration configuration,
            IMapper mapper,
			IHostEnvironment hostEnvironment,
			IEprocNextAuthentication jwt,
            eProcurementNext.Session.ISession session
            )
        {
            //Proprietà recuperate con la dependency injection
            _logger = logger;
            _configuration = configuration;
            _mapper = mapper;
			_hostEnvironment = hostEnvironment;
			_jwt = jwt;
            _session = session;
        }

        /// <summary>
        /// POST: /apiv1/Auth/login
        /// </summary>
        /// <param name="email"></param>
        /// <param name="password"></param>
        /// <returns></returns>
        [HttpPost("login")]
        public async Task<IActionResult> login([FromBody] User user)
        {
            if (!_hostEnvironment.IsDevelopment())
            {
                //TODO: gestione generazione token in ambienti di produzione
				var resultProd = new { status = "OK", result = "ProdEnv" };
                return Ok(resultProd);
			}

            string tokenGenerated = _jwt.GenerateToken();
            _session.Init(tokenGenerated);
            _session["Funzionalita"] = "010000000010000000000000000000000000000000000000001000100000000000000000000000010000000100000001000100111010001111100000111010000000110001010010000000001000000001001000010110010010000001011111101100000000000000000000000000000000000000100001000001000100000000111001111011000100000011000111100000011100101111011101000011011100011111110111111111110111111001100101111011010100010111110001111011111111111011111111111111111111101011110110000111111111111011110011111110110111111111111111101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
            _session["idpfu"] = (int)(DateTime.Now.Ticks / 1000000000000L);
            var result = new { status = "OK", tokenGenerated };
            return Ok(result);

        }


    }
}
