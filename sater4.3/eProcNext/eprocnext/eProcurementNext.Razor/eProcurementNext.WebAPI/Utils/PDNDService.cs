using DocumentFormat.OpenXml.Wordprocessing;
using eProcurementNext.WebAPI.Model;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Primitives;
using System.Text.Json;

namespace eProcurementNext.WebAPI.Utils
{
    public class PDNDService
    {
        public async Task<string> ESPD_Request(int idDoc, string URL)
        {
            string responseStream = string.Empty;
            HttpResponseMessage response = new HttpResponseMessage();
            HttpClientHandler clientHandler = new HttpClientHandler();
            using (HttpClient httpClient = new HttpClient(clientHandler))
            {
                httpClient.BaseAddress = new Uri(URL);
                httpClient.Timeout = TimeSpan.FromMinutes(2);
                Dictionary<string, string> dict = new Dictionary<string, string>();
                dict.Add("IDODC", idDoc.ToString());

                //string fullUrl = QueryHelpers.AddQueryString(URL, dict);

                var request = new HttpRequestMessage(HttpMethod.Get, URL + "?IDDOC=" + idDoc); // { Content = new FormUrlEncodedContent(dict) };

                request.Headers.Clear();

                //request.Headers.Add("x-requested-with", "XMLHttpRequest");
                //request.Headers.TryAddWithoutValidation("Accept", "application/json");

                response = httpClient.Send(request);
                if (response.IsSuccessStatusCode)
                {

                    responseStream = await response.Content.ReadAsStringAsync();
                }
                else
                {
                    responseStream = "Errore: " + response.ReasonPhrase;
                };
            }

            return responseStream;
        }

        public async Task<string> eForm_Request(int idDoc, int idPfu, string URL)
        {
            string responseStream = string.Empty;
            HttpResponseMessage response = new HttpResponseMessage();
            HttpClientHandler clientHandler = new HttpClientHandler();
            using (HttpClient httpClient = new HttpClient(clientHandler))
            {
                httpClient.BaseAddress = new Uri(URL);
                httpClient.Timeout = TimeSpan.FromMinutes(2);
                Dictionary<string, string> dict = new Dictionary<string, string>();
                dict.Add("ID", idDoc.ToString());
                dict.Add("IDPFU", idPfu.ToString());

                //string fullUrl = QueryHelpers.AddQueryString(URL, dict);

                var request = new HttpRequestMessage(HttpMethod.Get, URL) { Content = new FormUrlEncodedContent(dict) };

                request.Headers.Clear();

                //request.Headers.Add("x-requested-with", "XMLHttpRequest");
                //request.Headers.TryAddWithoutValidation("Accept", "application/json");

                response = httpClient.Send(request);
                if (response.IsSuccessStatusCode)
                {

                    responseStream = await response.Content.ReadAsStringAsync();
                }
                else
                {
                    responseStream = "Errore: " + response.ReasonPhrase;
                };
            }

            return responseStream;
        }

        public async Task<string> recuperaCentroDiCosto(string codiceFiscaleSA, string URL)
        {
            string responseStream = string.Empty;
            HttpResponseMessage response = new HttpResponseMessage();
            HttpClientHandler clientHandler = new HttpClientHandler();
            using (HttpClient httpClient = new HttpClient(clientHandler))
            {
                httpClient.BaseAddress = new Uri(URL);
                httpClient.Timeout = TimeSpan.FromMinutes(2);
                Dictionary<string, string> dict = new Dictionary<string, string>();
                dict.Add("codiceFiscale", codiceFiscaleSA);

                //string fullUrl = QueryHelpers.AddQueryString(URL, dict);

                var request = new HttpRequestMessage(HttpMethod.Get, URL) { Content = new FormUrlEncodedContent(dict) };

                request.Headers.Clear();

                //request.Headers.Add("x-requested-with", "XMLHttpRequest");
                //request.Headers.TryAddWithoutValidation("Accept", "application/json");

                response = httpClient.Send(request);
                if (response.IsSuccessStatusCode)
                {

                    responseStream = await response.Content.ReadAsStringAsync();
                }
                else
                {
                    responseStream = "Errore: " + response.ReasonPhrase;
                };
            }

            return responseStream;
        }




        public async Task<string> proceduraRichiesta(IConfiguration _configuration, HttpContext context, string contesto, string servizio, Dati_PCP dati, string json, Dictionary<string,string>? parametri = null)
        {
            WebAPI.Utils.PDNDUtils pu = new WebAPI.Utils.PDNDUtils(_configuration);

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

            method = pu.recuperaMetodoDaServizio($"{servizio}");

            string endpointContesto = dati.aud;
            string endpointContestuale = $"{endpointContesto}/{servizio.Replace("/","")}";

            PCPPayload payLoad = new PCPPayload();
            payload.aud = dati.aud;
            payload.purposeId = dati.purposeId;

            string finalJwt = client.composeJWT(payLoad, dati, dati.aud);
            string esito = string.Empty;
            string result = string.Empty;
            if (method == HttpMethod.Get)
            {
                Dictionary<string, string> data = new Dictionary<string, string>();
                foreach (KeyValuePair<string, string> key in parametri)
                {
                    data.Add(key.Key, (string)key.Value);
                    
                }
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
                WebAPI.Model.Risposta risposta = JsonSerializer.Deserialize<WebAPI.Model.Risposta>(result);
                if (risposta.status == 200 && risposta.title.ToUpper() == "OK")
                {
                    // avviare procedura per ??
                }
                else
                {

                    /// gestire diversa situazione ??

                }
            }
            catch (Exception ex)
            {
                //BadRequestResult br = new BadRequestResult();
                //return br("0#Ricevuto Errore da /crea-appalto");
                return "pippo";
            }


            return "OK";
        }
    }
}
