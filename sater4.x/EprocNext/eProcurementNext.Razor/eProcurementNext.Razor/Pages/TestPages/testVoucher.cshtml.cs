using eProcurementNext.PDND;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;
using static eProcurementNext.Session.SessionMiddleware;

using System;
using System.Text.Json;
using NuGet.Packaging.Signing;
using System.Text;
using System.Configuration;
using System.IdentityModel.Tokens.Jwt;
using eProcurementNext.CommonDB;


namespace eProcurementNext.Razor.Pages.TestPages
{
    public class testVoucherModel : PageModel
    {
        CommonDbFunctions cdf = new CommonDbFunctions();
        HttpContext httpContext;
        private eProcurementNext.Session.ISession session;
        private IConfiguration Configuration;
        private PDNDClient client;

        public testVoucherModel(IConfiguration configuration)
        {
            Configuration = configuration;

        }


        public IActionResult OnGetTest()
        {

            var idazienda = Request.Query["idAzi"];
            TSRecordSet rs = new TSRecordSet();

            string strSql = "select IdContestoAzi, NomeContesto from PDND_Contesti with(nolock )";
            rs = cdf.GetRSReadFromQuery_(strSql, Application.ApplicationCommon.Application.ConnectionString);
            List<contesti> cont = new List<contesti>();
            if (rs != null && rs.RecordCount > 0)
            {
                rs.MoveFirst();
                while (!rs.EOF)
                {
                    contesti contesto = new contesti();
                    contesto.idContesto = rs["IdContestoAzi"].ToString();
                    contesto.NomeContesto = rs["NomeContesto"].ToString();
                    cont.Add(contesto);
                    rs.MoveNext();
                }
            }

            //JsonResponseModel rm = new JsonResponseModel();
            //if (pp != null)
            //{
            //    rm.ResponseCode = 0;
            //    rm.ResponseMessage = JsonSerializer.Serialize(cont);
            //}
            //else
            //{
            //    rm.ResponseCode = 1;
            //    rm.ResponseMessage = "Errore con recupero progressivo pratica";
            //}

            //string esito = JsonSerializer.Serialize(cont);
            return new JsonResult(cont);
        }

        public void OnPostVoucher(IFormCollection model)
        {

            PCPPayloadWithData pLoad = new PCPPayloadWithData();
            pLoad.userLoa = model["userLoa"].ToString();
            pLoad.purposeId = model["purposeId"].ToString();
            pLoad.regCodiceComponente = model["regCodiceComponente"].ToString();
            pLoad.regCodicePiattaforma = model["regCodicePiattaforma"].ToString();
            pLoad.userRole = model["userRole"].ToString();
            pLoad.userCodiceFiscale = model["userCodiceFiscale"].ToString();
            pLoad.userIdpType = model["userIdpType"].ToString();
            pLoad.userRole = model["userRole"].ToString();
            pLoad.SAcodiceAUSA = model["SAcodiceAUSA"].ToString();


            client = new PDNDClient(Configuration, pLoad);
            string audience = client.getAudForPurposeId(pLoad.purposeId);

            //string audience = client.getAudForPurposeId("72c192aa-aa01-4cd0-8de2-4e02de3b79cb"); test per api AUSA

            pLoad.aud = audience;

            string jwtWitData = client.composeComplementaryJWT(pLoad, audience);   // da cui ottenere l'hash da inserie nel JWS di richiesta del voucher

            string hashedjwt = client.computeHash(jwtWitData);
            //string hashedjwtNoBase64 = client.computeHash(jsonForAgidnoBase64);
            //ViewData["HashedJwt"] = hashedjwt;                  // jash del JWS con informazioni complementari 

            PCPPayloadWithHash mainPcpPayload = new PCPPayloadWithHash();   // costruzione del JWS contenente l'HASH. Sarà un PCPPayLoad vuoto 
                                                                            // composto coi dati necessari
            mainPcpPayload.purposeId = model["purposeId"].ToString();       // PurposeID relativo al contesto selezionato

            string ploadJson = JsonSerializer.Serialize(mainPcpPayload);




            // serializzo il PCPPayload in modo da poter aggiungere SOLO i dati
            // obbligatori e non le informazioni complementari
            string stringJws = client.composeJWT(ploadJson, hashedjwt);     // in questa fase il JWS per la richiesta del voucher viene valorizzato
                                                                            // coi dati obbligatori e con l'hash del JWT precedente inserito
                                                                            // nel campo digest del payload
            ViewData["clientAssertion"] = stringJws;

            HttpMethod method = HttpMethod.Post;
            Task<string> PDNDResponse = GetVoucher(stringJws, method);      // funzione che effettua l'httprequest per ottenere il voucher
            string voucher = PDNDResponse.Result;

            ViewData["voucherData"] = voucher;
            string endpointServizio = model["lstServizi"].ToString();

            // analizzare come gestire i vari modi in cui un servizio
            // tra quelli compresi nel contesto può essere chiamato
            // con un metodo centralizzato

            PCPEservice contesto = Configuration.GetSection("PDND_info:E-Services").Get<List<PCPEservice>>().Where(x => x.purposeId == pLoad.purposeId).Single();

            Dictionary<string, object> param = new Dictionary<string, object>();
            param.Add("@nomeServizio", model["lstServizi"].ToString());

            string strSql = "Select Method,Tipo from PDND_Servizi with(nolock) where endpoint like @nomeServizio";

            TSRecordSet ts = new TSRecordSet();
            ts = cdf.GetRSReadFromQuery_(strSql, Application.ApplicationCommon.Application.ConnectionString, param);

            string tipoRequest = string.Empty;

            if (ts != null && ts.RecordCount > 0)
            {
                method = new HttpMethod(ts["Method"].ToString().ToUpper());
                tipoRequest = ts["Tipo"].ToString();
            }

            string endpointContesto = contesto.endpoint;
            string endpointContestuale = $"{endpointContesto}{endpointServizio}";

            PCPPayload payLoad = new PCPPayload();
            payLoad.aud = audience;
            payLoad.purposeId = model["purposeId"].ToString();
            //string payloadJson = JsonSerializer.Serialize(payLoad);
            string finalJwt = client.composeJWT(payLoad, audience);
            string esito = string.Empty;


            /// ===== CODELIST ===============================================================================================================
            //method = HttpMethod.Get;
            if (method == HttpMethod.Get)
            {
                Dictionary<string, string> data = new Dictionary<string, string>();
                //data.Add("page", "1");
                //data.Add("perPage", "20");

                //come gestire parametri ??
               string[] parametriColl = model["querystring"].ToString().Split("&");
                foreach (string p in parametriColl)
                {
                    string[] pmetro = p.Split("=");
                    data.Add(pmetro[0], pmetro[1]);
                }

                Task<string> finalResponse = sendRequest(endpointContestuale, finalJwt, voucher, jwtWitData, method, parametri: data);
                string risposta = finalResponse.Result;
                ViewData["esito"] = risposta;
            }
            else if (method == HttpMethod.Post) {

                Task<string> creaAppalto = postRequest(endpointContestuale, finalJwt, voucher, jwtWitData, method, body: model["richiesta"].ToString());
                esito = creaAppalto.Result;
                ViewData["esito"] = esito;
            }
        }

        private async Task<string> GetVoucher(string stringJws, HttpMethod method)
        {
            string risposta = await client.PDNDRequest(client.url, stringJws, method);
            return risposta;
        }

        private async Task<string> sendRequest(string endpointContestuale, string finaljwt, string bearerToken, string jwtAgidBase64, HttpMethod method, Dictionary<string, string> parametri = null)
        {
            string risposta = await client.PDNDRequest(endpointContestuale, finaljwt, method, receivedVoucher: bearerToken, parametri: parametri, jwsForAgid: jwtAgidBase64, serviceRequest: true);
            return risposta;
        }

        //private async Task<string> postRequest(string endpointContestuale, string finaljwt, string bearerToken, string jwtAgidBase64, HttpMethod method, Dictionary<string, string> parametri = null)
        //{
        //    string result = await client.PDNDPostRequest(endpointContestuale, finaljwt, method, receivedVoucher: bearerToken, parametri: parametri, jwsForAgid: jwtAgidBase64, serviceRequest: true);

        //    return result;
        //}

        private async Task<string> postRequest(string endpointContestuale, string finaljwt, string bearerToken, string jwtAgidBase64, HttpMethod method, Dictionary<string, string> parametri = null, string body = null)
        {
            string result = await client.PDNDPostRequest(endpointContestuale, finaljwt, method, receivedVoucher: bearerToken, parametri: parametri, jwsForAgid: jwtAgidBase64, body: body, serviceRequest: true);

            return result;
        }
    }
}
