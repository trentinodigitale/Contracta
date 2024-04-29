using AutoMapper;
//using eProcurementNext.Core.PDND;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using eProcurementNext.WebAPI.Model;
using eProcurementNext.WebAPI.Utils;
using Microsoft.Extensions.Primitives;
using DocumentFormat.OpenXml.Office.CustomUI;
using eProcurementNext.Core.PDND;
using static eProcurementNext.WebAPI.Model.RispostaServizi;

namespace eProcurementNext.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AusaController : TsControllerBase
    {
        private readonly ILogger<ProcessController> _logger;
        private readonly IConfiguration _configuration;
        private readonly IMapper _mapper;
        //private readonly IAuthHandlerCustom _authHandler;
        private readonly eProcurementNext.Session.ISession _session;
        private string domain;
        private readonly int idpfu;
        private IHttpContextAccessor _contextAccessor;
        private HttpContext _context;

        public AusaController(ILogger<ProcessController> logger,
            IConfiguration configuration,
            IMapper mapper,
            eProcurementNext.Session.ISession session, IHttpContextAccessor accessor)
        {
            _logger = logger;
            _configuration = configuration;
            _mapper = mapper;
            _session = session;
            _contextAccessor = accessor;
            _context = _contextAccessor.HttpContext; //.Request.Host
            domain = _context.Request.Host.ToString();
            domain = _context.Request.Scheme.ToString() + @"://" + domain;
        }

        [HttpGet("centroDiCosto")]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        public async Task<IActionResult> centroDiCosto(int idDoc, string cfSA, string codAusa)
        {
            WebAPI.Utils.PDNDUtils pu = new WebAPI.Utils.PDNDUtils(_configuration);
            WebAPI.Utils.PDNDService ps = new Utils.PDNDService();

            Dati_PCP dati = pu.recuperataDatiPerVoucher(idDoc, "Servizi comuni", "/esito-operazione");

            Model.PCPPayloadWithData payload; // = new PCPPayloadWithData();

            payload = pu.getDatiPerVoucher(dati);
            PDNDClient client = new PDNDClient(_configuration, payload);
            client.clientId = dati.clientId;
            string jwtWithData = client.composeComplementaryJWT(payload, dati);
            string hashedjwt = client.computeHash(jwtWithData);

            Model.PCPPayloadWithHash mainPcpPayLoad = new Model.PCPPayloadWithHash();
            mainPcpPayLoad.purposeId = payload.purposeId;

            string ploadJson = JsonSerializer.Serialize(mainPcpPayLoad);
            string stringJws = client.composeJWT(ploadJson, hashedjwt, dati);

            HttpMethod method = HttpMethod.Post;
            Task<string> PDNDResponse = pu.GetVoucher(client, stringJws, method);

            string voucher = PDNDResponse.Result;

            method = HttpMethod.Get;

            string endpointContesto = "https://apigw-test.anticorruzione.it/modi/rest/AUSA/v1";
            string endpointContestuale = $"{endpointContesto}/api/ausa/getBy";

            PCPPayload payLoad = new PCPPayload();
            //payload.aud = dati.aud;
            payload.aud = "https://apigw-test.anticorruzione.it/modi/rest/AUSA/v1";
            payload.purposeId = "72c192aa-aa01-4cd0-8de2-4e02de3b79cb"; // dati.purposeId;

            string finalJwt = client.composeJWT(payLoad, dati, "72c192aa-aa01-4cd0-8de2-4e02de3b79cb");
            string esito = string.Empty;
            string result = string.Empty;
            if (method == HttpMethod.Get)
            {
                Dictionary<string, string> data = new Dictionary<string, string>();
                //foreach (KeyValuePair<string, StringValues> key in Request.Query)
                //{
                //}
                data.Add("codiceFiscale", cfSA);
                data.Add("codiceAusa", codAusa);
                Task<string> finalResponse = pu.sendRequest(client, endpointContestuale, finalJwt, voucher, jwtWithData, method, parametri: data);
                result = finalResponse.Result;
            }
            else if (method == HttpMethod.Post)
            {
                Task<string> esitoOperazione = pu.postRequest(client, endpointContestuale, finalJwt, voucher, jwtWithData, method);
                result = esitoOperazione.Result;
            }

            try
            {
                WebAPI.Model.RispostaServizi risposta = JsonSerializer.Deserialize<WebAPI.Model.RispostaServizi>(result);
                if (risposta.status == 200)
                {
                   
                    //string rispostaJson = JsonSerializer.Serialize(risposta);
                    //int records = pu.inserisciLogIntegrazione(idDoc, "esito-operazione", "Elaborato", "idAppalto", "", jwtWithData, rispostaJson, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");
                    //// eseguire EXEC INSERT_SERVICE_REQUEST 'INTEROPERABILITA' 'esitoOperazione' ippfu idDoc
                    //pu.avviaEsitoOperazione(idpfu, idDoc);
                }
            }
            catch (Exception ex)
            {
                result = "0#" + ex.Message;
            }

            //result = messaggioEsito;
            //var result = new { status = "OK", result = json };
            return Ok(result);

        }
    }
}
