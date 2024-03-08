using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using eProcurementNext.CommonDB;
using Microsoft.AspNetCore.WebUtilities;

namespace eProcurementNext.Core.PDND
{
    public class PDNDUtils
    {
        CommonDbFunctions cdf = new CommonDbFunctions();
        public string ConfermaAppalto(int IDDOC)
        {
            // chiama il servizio crea-appalto
            // servizio /crea-appalto
            throw new NotImplementedException();
        }

        public string ModificaAppalto()
        {
            throw new NotImplementedException();
        }

        public string CancellaAppalto() { throw new NotImplementedException(); }

        public string RecuperaAppalto() => throw new NotImplementedException();

        public string PubblicaAvviso() => throw new NotImplementedException();

        public string componiScheda(int idDoc, string codiceScheda)
        {
            string connString = Application.ApplicationCommon.Application.ConnectionString;
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            parameters.Add("@idDoc", idDoc);
            parameters.Add("@codScheda", codiceScheda);
            string strSql = $"EXEC PCP_RECUPERO_DATI  {idDoc}";
            try
            {
                TSRecordSet rs = cdf.GetRSReadFromQuery_(strSql, connString);
            }
            catch (Exception ex)
            {
                string errore = ex.Message;
            }


            return null;
        }

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
                    //var rispostaAutenticazione = JsonSerializer.Deserialize<JsonVoucherModel>(responseStream);

                    //if (rispostaAutenticazione is null)
                    //{

                    //    throw new Exception("Errore Voucher PDND: non è stato possibile deserializzare il voucher");
                    //}
                    //else
                    //{
                    //    voucher = rispostaAutenticazione.access_token;
                    //    Console.WriteLine($"voucher {voucher}");
                    //}
                }
                else
                {
                    responseStream = "Errore: " + response.ReasonPhrase;
                };
            }

            return responseStream;
        }


    }
}
