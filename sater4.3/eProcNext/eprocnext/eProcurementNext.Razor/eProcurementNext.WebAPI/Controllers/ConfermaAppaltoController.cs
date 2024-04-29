using AutoMapper;
//using eProcurementNext.Core.PDND;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using eProcurementNext.WebAPI.Model;
using eProcurementNext.WebAPI.Utils;
using Microsoft.Extensions.Primitives;
using DocumentFormat.OpenXml.InkML;
using Microsoft.IdentityModel.Tokens;
using System.Text.Json.Nodes;
using Newtonsoft.Json.Linq;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;
using System.Text;

namespace eProcurementNext.WebAPI.Controllers
{
    [Route("api/v1/[controller]")]
    [ApiController]
    public class ConfermaAppaltoController : TsControllerBase
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

        public ConfermaAppaltoController(ILogger<ProcessController> logger,
            IConfiguration configuration,
            IMapper mapper,
            eProcurementNext.Session.ISession session, IHttpContextAccessor accessor
            )
        {
            //Proprietà recuperate con la dependency injection
            _logger = logger;
            _configuration = configuration;
            _mapper = mapper;
            _session = session;
            _contextAccessor = accessor;
            _context = _contextAccessor.HttpContext; //.Request.Host
            domain = _context.Request.Host.ToString();
            domain = _context.Request.Scheme.ToString() + @"://" + domain;

            //_authHandler = authHandler;

            //try
            //{
            //    _session.Load(_authHandler.Token);
            //}
            //catch
            //{
            //    throw new AuthorizedException();
            //}

            //idpfu = CInt(_session["idpfu"]);

            //if (idpfu <= 0)
            //{
            //    throw new AuthorizedException();
            //}

            //if (!_session["SessionIsAuth"])
            //{
            //    throw new AuthorizedException();
            //}
        }

        /// <summary>
        /// Get: /api/v1/ConfermaAppalto/creaAppalto/{idDoc}
        /// </summary>
        /// <param name="idDoc">l'identificativo del bando di gara</param>
        /// <returns></returns>
        [HttpGet("creaAppalto")]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        public async Task<IActionResult> creaAppalto(int idDoc, int idpfu, string tipoScheda = "P1_16")
        {
            // recuperare i dati dell'azienda dall'iddoc in modo da poter recuperare tutti i dati necessari a ottenere il token autorizzativo
            // questa operazione va fatta dopo aver recuperato tutti i dati necessari anche alla formazione del json dell scheda
            // altrimenti si rischia di utilizzare un token scaduto (i token hanno durata di 10 secondi)

            WebAPI.Utils.PDNDUtils pu = new WebAPI.Utils.PDNDUtils(_configuration);
            //TODO: aggiungere log
            WebAPI.Utils.PDNDService ps = new Utils.PDNDService();

            string espd = ""; //funzione per recupero espd
            string eform = string.Empty;



            eform = pu.recuperaEFormXml(idDoc); // System.IO.File.ReadAllText(@"c:\temp\CONTRACT_NOTICE.xml");

            if (string.IsNullOrEmpty(eform))
            {

                //return Problem(detail: eform, statusCode: StatusCodes.Status400BadRequest); // BadRequest(failMessage[1]);
                return BadRequest(eform);
            }

            espd = pu.recuperaESPDXml(idDoc);

            if (String.IsNullOrEmpty(espd))
            {
                return BadRequest(espd);
            }

            var eformBytes = System.Text.Encoding.UTF8.GetBytes(eform);
            
            var eform64 = Convert.ToBase64String(eformBytes);// System.Text.Encoding.UTF8.GetBytes(eform);
            var espdXmlBytes = Convert.ToBase64String(Encoding.UTF8.GetBytes(espd)); //System.Text.Encoding.UTF8.GetBytes(espd);


            //var plainTextBytes = System.Text.Encoding.UTF8.GetBytes(eform);

            //System.Convert.ToBase64String(plainTextBytes);




            //char[]? inArray = eform.ToCharArray();// as byte[];

            //var eformBytes = Convert.ToBase64String(inArray);// System.Text.Encoding.UTF8.GetBytes(eform);

            //byte[]? eformBytes = eform as byte[];

            //eform = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(eform));

            //espd = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(espd));


            //eform = await Task.Run(() => ps.eForm_Request(idDoc, idpfu, "https://localhost:7246/application/eForms/cn16.asp"));



            //int idTemplate = pu.testEspdTemplate(idDoc);  // verifico se posso procedere alla richiesta dell'xml dell'espd
            //if (idTemplate == 0)
            //{
            //    //return Problem(detail: "0#Template Espd assente", statusCode: StatusCodes.Status400BadRequest);
            //    return BadRequest("0#Template Espd assente");
            //}
            //else
            //{
            //    espdXml = await Task.Run(() => ps.ESPD_Request(idDoc, "https://localhost:7246/application/report/ESPD_REQUEST.ASP"));
            //}


            Dati_PCP dati = pu.recuperataDatiPerVoucher(idDoc);

            Scheda s = new Scheda();
            try
            {
                s = await Task.Run(() => pu.compilaScheda(idDoc, tipoScheda, eform64, espdXmlBytes, dati));
            }
            catch (Exception ex)
            {
                string errore = ex.Message;
                //TODO: aggiungere log
            }

            BaseModel basemodel = new BaseModel();
            basemodel.scheda = s;
            string json = string.Empty;
            //try
            //{
            //    JsonSerializerOptions options = new()
            //    {
            //        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
            //    };

            json = JsonSerializer.Serialize(basemodel);

            //System.IO.File.WriteAllText(@"c:\temp\esitoPCP.json", json);


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

            method = pu.recuperaMetodoDaServizio("/crea-appalto");

            string endpointContesto = dati.aud;
            string endpointContestuale = $"{endpointContesto}/crea-appalto";

            PCPPayload payLoad = new PCPPayload();
            payload.aud = dati.aud;
            payload.purposeId = dati.purposeId;

            string finalJwt = client.composeJWT(payLoad, dati, dati.aud);
            string esito = string.Empty;
            string result = string.Empty;
            if (method == HttpMethod.Get)
            {
                Dictionary<string, string> data = new Dictionary<string, string>();
                foreach (KeyValuePair<string, StringValues> key in Request.Query)
                {
                    data.Add(key.Key, (string)key.Value);
                    Task<string> finalResponse = pu.sendRequest(client, endpointContestuale, finalJwt, voucher, jwtWithData, method, parametri: data);
                }
            }
            else if (method == HttpMethod.Post)
            {
                Task<string> creaAppalto = pu.postRequest(client, endpointContestuale, finalJwt, voucher, jwtWithData, method, body: json);
                result = creaAppalto.Result;
            }

            try
            {
                WebAPI.Model.Risposta risposta = JsonSerializer.Deserialize<WebAPI.Model.Risposta>(result);
                if (risposta.status == 200) // && risposta.title.ToUpper() == "OK")
                {
                    string rispostaJson = JsonSerializer.Serialize(risposta);
                    // salvare IdAppalto in tabella
                    // chiamare /conferma-appalto
                    string idAppalto = risposta.idAppalto;
                    pu.AggiornaIdAppalto(idDoc, idAppalto);
                    int records = pu.inserisciLogIntegrazione(idDoc, "crea-appalto", "Elaborato", "idAppalto", "", jwtWithData, rispostaJson, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");
                    string redirection = domain + $@"/api/v1/ConfermaAppalto/confermaAppalto?idpfu={idpfu}&idAppalto={idAppalto}&idDoc={idDoc}";

                    UriBuilder ub = new UriBuilder(redirection);
                    return new RedirectResult(redirection);
                }
                else
                {
                    /// gestire diversa situazione ??
                }
            }
            catch (Exception ex)
            {
                return BadRequest("0#Ricevuto Errore da /crea-appalto");
            }

            //var result = new { status = "OK", result = json };
            //return Ok(result);
            return Ok(result);
        }


        [HttpGet("confermaAppalto")]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        public async Task<IActionResult> confermaAppalto(int idDoc, int idpfu, string idAppalto)
        {
            WebAPI.Utils.PDNDUtils pu = new WebAPI.Utils.PDNDUtils(_configuration);
            WebAPI.Utils.PDNDService ps = new Utils.PDNDService();

            Dati_PCP dati = pu.recuperataDatiPerVoucher(idDoc);

            string json = JsonSerializer.Serialize(new IdAppalto { idAppalto = idAppalto });


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

            method = pu.recuperaMetodoDaServizio("/conferma-appalto");

            string endpointContesto = dati.aud;
            string endpointContestuale = $"{endpointContesto}/conferma-appalto";

            PCPPayload payLoad = new PCPPayload();
            payload.aud = dati.aud;
            payload.purposeId = dati.purposeId;

            string finalJwt = client.composeJWT(payLoad, dati, dati.aud);
            string esito = string.Empty;
            string result = string.Empty;
            if (method == HttpMethod.Get)
            {
                Dictionary<string, string> data = new Dictionary<string, string>();
                //foreach (KeyValuePair<string, StringValues> key in Request.Query)
                //{

                //}
                data.Add("idAppalto", idAppalto);
                Task<string> finalResponse = pu.sendRequest(client, endpointContestuale, finalJwt, voucher, jwtWithData, method, parametri: data);
                result = finalResponse.Result;
            }
            else if (method == HttpMethod.Post)
            {
                Task<string> confermaAppalto = pu.postRequest(client, endpointContestuale, finalJwt, voucher, jwtWithData, method, body: json);
                result = confermaAppalto.Result;
            }

            try
            {
                string rispostaJson = string.Empty;
                WebAPI.Model.RispostaServizi risposta = JsonSerializer.Deserialize<WebAPI.Model.RispostaServizi>(result);
                if (risposta.status == 200) // && risposta.title.ToUpper() == "OK")
                {
                    rispostaJson = JsonSerializer.Serialize(risposta);

                    int records = pu.inserisciLogIntegrazione(idDoc,"conferma-appalto", "Elaborato", "idAppalto", "", jwtWithData, rispostaJson, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");
                    //string redirection = domain + $@"/api/v1/ServiziComuni/confermaAppalto?dDoc={idDoc}&idpfu={idpfu}&idAppalto={idAppalto}";
                    pu.avviaEsitoOperazione(idpfu, idDoc);
                }
                else
                {

                    /// gestire diversa situazione ??
                    int records = pu.inserisciLogIntegrazione(idDoc,"conferma-appalto", "Elaborato", "idAppalto", risposta.detail, jwtWithData, rispostaJson, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");

                }
            }
            catch (Exception ex)
            {
                return BadRequest("0#Ricevuto Errore da /conferma-appalto");
            }


            return Ok(result);
        }

        [HttpGet("recuperaCig")]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        public async Task<IActionResult> recuperaCig(int idDoc, int idpfu, string idAppalto, int page, int perPage)
        {

            //string json = JsonSerializer.Serialize(new IdAppalto { idAppalto = idAppalto }); ;
            WebAPI.Utils.PDNDUtils pu = new WebAPI.Utils.PDNDUtils(this._configuration);
            WebAPI.Utils.PDNDService ps = new Utils.PDNDService();

            Dati_PCP dati = pu.recuperataDatiPerVoucher(idDoc);



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

            method = pu.recuperaMetodoDaServizio("/recupera-cig");

            string endpointContesto = dati.aud;
            string endpointContestuale = $"{endpointContesto}/recupera-cig";

            PCPPayload payLoad = new PCPPayload();
            payload.aud = dati.aud;
            payload.purposeId = dati.purposeId;

            string finalJwt = client.composeJWT(payLoad, dati, dati.aud);
            string esito = string.Empty;
            string result = string.Empty;
            if (method == HttpMethod.Get)
            {
                Dictionary<string, string> data = new Dictionary<string, string>();
                //foreach (KeyValuePair<string, StringValues> key in Request.Query)
                //{
                //    data.Add(key.Key, (string)key.Value);

                //}

                data.Add("idAppalto", idAppalto);
                data.Add("page", page.ToString());
                data.Add("perPage", perPage.ToString());

                Task<string> finalResponse = pu.sendRequest(client, endpointContestuale, finalJwt, voucher, jwtWithData, method, parametri: data);
                result = finalResponse.Result;
            }
            else if (method == HttpMethod.Post)
            {
                Task<string> confermaAppalto = pu.postRequest(client, endpointContestuale, finalJwt, voucher, jwtWithData, method);
                result = confermaAppalto.Result;
            }

            try
            {
                string rispostaJson = string.Empty;
                WebAPI.Model.RispostaCig risposta = JsonSerializer.Deserialize<WebAPI.Model.RispostaCig>(result);
                if (risposta.status == 200) // && risposta.title.ToUpper() == "OK")
                {
                    List<Tipologica> rCig = risposta.result;
                    foreach (Tipologica valCIG in rCig)
                    {
                        string lotto = valCIG.lotIdentifier;
                        string cig = valCIG.cig;
                        int idLotto = Convert.ToInt32(Regex.Match(lotto, @"\d+").Value);
                        rispostaJson = JsonSerializer.Serialize(risposta);

                        int records = pu.inserisciLogIntegrazione(idDoc, "recupera-cig", "Elaborato", "CIG", "", jwtWithData, rispostaJson, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");
                    }

                }
                else
                {
                    //foreach(var item in risposta.errori)
                    //{
                    //   item.dettaglio 
                    //}
                    /// gestire diversa situazione ??
                    int records = pu.inserisciLogIntegrazione(idDoc, "recupera-cig", "Elaborato", "CIG", "messaggio di errore da verificare", jwtWithData, rispostaJson, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");

                }
            }
            catch (Exception ex)
            {
                return BadRequest("0#Ricevuto Errore da /crea-appalto");
            }


            return Ok(result);
        }
    }
}
