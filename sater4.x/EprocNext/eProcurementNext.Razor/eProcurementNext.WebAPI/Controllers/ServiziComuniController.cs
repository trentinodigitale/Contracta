using AutoMapper;
//using eProcurementNext.Core.PDND;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using eProcurementNext.WebAPI.Model;
using eProcurementNext.WebAPI.Utils;
using Microsoft.Extensions.Primitives;
using DocumentFormat.OpenXml.Office.CustomUI;

namespace eProcurementNext.WebAPI.Controllers
{
    [Route("api/v1/[controller]")]
    [ApiController]
    public class ServiziComuniController : TsControllerBase
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

        public ServiziComuniController(ILogger<ProcessController> logger,
            IConfiguration configuration,
            IMapper mapper,
            eProcurementNext.Session.ISession session, IHttpContextAccessor accessor)
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

        [HttpGet("esitoOperazione")]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        public async Task<IActionResult> esitoOperazione(int idDoc, int idpfu, string idAppalto, string tipoOperazione = "AP_CONF", string tipoRicerca = "ULTIMO_ESITO")
        {
            string messaggioEsito = string.Empty;
            string erroreAppalto = string.Empty;

            // recuperare i dati dell'azienda dall'iddoc in modo da poter recuperare tutti i dati necessari a ottenere il token autorizzativo
            // questa operazione va fatta dopo aver recuperato tutti i dati necessari anche alla formazione del json dell scheda
            // altrimenti si rischia di utilizzare un token scaduto (i token hanno durata di 10 secondi)

            WebAPI.Utils.PDNDUtils pu = new WebAPI.Utils.PDNDUtils(_configuration);
            WebAPI.Utils.PDNDService ps = new Utils.PDNDService();

            Dati_PCP dati = pu.recuperataDatiPerVoucher(idDoc, "Servizi comuni","/esito-operazione");

            EsitoOperazione esitoOp = new EsitoOperazione() { idAppalto = idAppalto, tipoOperazione = tipoOperazione, tipoRicerca = tipoRicerca };

            string json = JsonSerializer.Serialize(esitoOp);


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

            method = pu.recuperaMetodoDaServizio("/esito-operazione");

            string endpointContesto = dati.aud;
            string endpointContestuale = $"{endpointContesto}/esito-operazione";

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
                data.Add("tipoOperazione", tipoOperazione);
                data.Add("tipoRicerca", tipoRicerca);
                Task<string> finalResponse = pu.sendRequest(client, endpointContestuale, finalJwt, voucher, jwtWithData, method, parametri: data);
                result = finalResponse.Result;
            }
            else if (method == HttpMethod.Post)
            {
                Task<string> esitoOperazione = pu.postRequest(client, endpointContestuale, finalJwt, voucher, jwtWithData, method, body: json);
                result = esitoOperazione.Result;
            }

            try
            {
                WebAPI.Model.RispostaServizi risposta = JsonSerializer.Deserialize<WebAPI.Model.RispostaServizi>(result);
                if (risposta.status == 200)
                {
                    //Esempio risposta
                    //listaEsiti deve avere lunghezza 1, migliorare il ciclo foreach successivo 
                    //"idAppalto=c40e1f2c-a5e0-4147-a488-4a9a1e253e23&tipoOperazione=AP_CONF&tipoRicerca=ULTIMO_ESITO"
                    //{
                    //    "status":200,
                    //    "title":"OK",
                    //    "detail":"Esecuzione avvenuta con successo",
                    //    "type":"about:blank",
                    //    "listaEsiti":[
                    //        {
                    //            "idAppalto":"c40e1f2c-a5e0-4147-a488-4a9a1e253e23",
                    //            "idScheda":"0891040b-87d0-45e3-86f8-bee9598d84ce",
                    //            "idAvviso":"afebdf01-c00b-47ac-89ce-436ad5a0a447",
                    //            "esito":{ "idTipologica":"esito","codice":"OK"},
                    //            "tipoOperazione":{ "idTipologica":"tipoOperazione","codice":"AP_CONF"},
                    //            "dataControllo":"2023-11-21T15:08:29.401+00:00","dettaglio":{ "idTipologica":"esitoOperazione","codice":"AP_CONF"}
                    //        }
                    //    ]
                    //}

                    foreach (var item in risposta.listaEsiti)
                    {
                        if(idAppalto == item.idAppalto)
                        {
                            if(item.dettaglio.codice.ToUpper() == "OK" && item.dettaglio.codice == "AP_CONF")
                            {
                                // possoritornare in risposta "1#" + i dati necessari al log e alla cronologia
                                messaggioEsito = $"1#{item.dettaglio.codice}";
                            }
                            else
                            {
                                // ritorno l'errore con la motivazione espressa in 
                                foreach(var err in item.errori)
                                {
                                    erroreAppalto += err.codice + ": " + err.dettaglio + Environment.NewLine;
                                }

                                messaggioEsito = "0#" + erroreAppalto.ToString();

                            }

                            
                        }
                    }
                    string rispostaJson = JsonSerializer.Serialize(risposta);
                    int records = pu.inserisciLogIntegrazione(idDoc, "esito-operazione", "Elaborato", "idAppalto", "", jwtWithData, rispostaJson, DateTime.Now, DateTime.Now, DateTime.Now, idpfu, dati.idAzi, "OUT");
                    // eseguire EXEC INSERT_SERVICE_REQUEST 'INTEROPERABILITA' 'esitoOperazione' ippfu idDoc
                    pu.avviaEsitoOperazione(idpfu, idDoc);//TODO: non devo creare una sentinella per l'"esitoOperazione" ma per il recupero cig!!!
                }
            }
            catch (Exception ex)
            {
                messaggioEsito = "0#" + ex.Message;
            }

            result = messaggioEsito;
            //var result = new { status = "OK", result = json };
            return Ok(result);
            
        }
    }
}
