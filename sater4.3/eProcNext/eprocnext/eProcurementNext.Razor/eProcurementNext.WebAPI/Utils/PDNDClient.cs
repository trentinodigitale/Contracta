using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.WebAPI.Model;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.IdentityModel.Tokens;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;


namespace eProcurementNext.WebAPI.Utils
{
    public class PDNDClient
    {
        private readonly IConfiguration Configuration;
        public readonly string url;
        private readonly string aud;
        public string clientId;
        private readonly string Kid;
        private readonly string PemPrivateKey;
        private readonly string SignatureCertificate;
        private readonly string[] SignatureCertificatePublicKey;
        private HttpResponseMessage msg;
        public PCPHeader header;
        public WebAPI.Model.PCPPayLoad payload;
        public PCPPayloadWithData payloadWithData;
        private PCPEservice Eservice;
        RSACryptoServiceProvider rSACryptoServiceProvider;
        private DigestClaim digestClaim;
        private string purposeId;
        private string tokenContent = string.Empty;
        private string jwt = string.Empty;
        CommonDbFunctions cdf = new CommonDbFunctions();
        DebugTrace dt = new DebugTrace();

        public PDNDClient(IConfiguration configuration, WebAPI.Model.PCPPayloadWithData Pload) //ISession _session, 
        {

            //Session = _session;
            Configuration = configuration;
            msg = new HttpResponseMessage();
            header = new PCPHeader();
            //payload = Pload;
            Eservice = new PCPEservice();

            PemPrivateKey = Configuration.GetSection("PDND_info").GetValue<string>("keyPos");
            rSACryptoServiceProvider = new RSACryptoServiceProvider();
            digestClaim = new DigestClaim();
            //dt.Write("Percorso chiave privata: " + PemPrivateKey, "PDNDClient", "GetPemPrivateKeyByte", "PDND");
            url = Configuration.GetSection("PDND_info").GetValue<string>("url");  // endpoint per autenticazione iniziale
            aud = Configuration.GetSection("PDND_info").GetValue<string>("aud");  // riferimento per autenticazione PDND
        }


        //public string getAudForPurposeId(string purposeId)
        //{
        //    string audience = string.Empty;
        //    string strSql = $"SELECT BaseAddress from PDND_Contesti where PurposeId = '{purposeId}'";
        //    audience = cdf.ExecuteScalar(strSql, Application.ApplicationCommon.Application.ConnectionString);
        //    return audience;
        //}

        public string composeComplementaryJWT(Model.PCPPayloadWithData pLoad, Dati_PCP dati, string audience = null)
        {
            string headerJson = serializeHeader(dati);
            byte[] headerByte = System.Text.Encoding.UTF8.GetBytes(headerJson);
            string payloadJson = serializePayload(pLoad, dati, dati.aud); // serializePayload(pload); // : audience
            byte[] payLoadByte = System.Text.Encoding.UTF8.GetBytes(payloadJson);

            //string jwtHeaderBase64 = Convert.ToBase64String(headerByte);
            //string jwtPayloadBase64 = Convert.ToBase64String(payLoadByte);

            string jwtHeaderBase64 = Base64UrlEncoder.Encode(headerByte);
            string jwtPayloadBase64 = Base64UrlEncoder.Encode(payLoadByte);

            tokenContent = $"{jwtHeaderBase64}.{jwtPayloadBase64}";

            string jwtSignatureBase64 = GetPemPrivateKeyByte(tokenContent, PemPrivateKey);


            jwt = $"{tokenContent}.{jwtSignatureBase64}";

            Console.WriteLine(JsonSerializer.Serialize(jwtSignatureBase64));
            return jwt;

        }



        public void RecuperaDatiBaseVoucher() => throw new NotImplementedException();

        public string composeJWT(string serializedPayLoad, string hashedJwt, Dati_PCP dati)
        {
            string headerJson = serializeHeader(dati);
            byte[] headerByte = System.Text.Encoding.UTF8.GetBytes(headerJson);

            PCPPayloadWithHash payload = JsonSerializer.Deserialize<PCPPayloadWithHash>(serializedPayLoad);
            Digest dig = new Digest();
            dig.value = hashedJwt;

            payload.digest = dig;
            string payloadJson = serializePayload(payload, dati); // serializePayload(pload); // : 
            byte[] payLoadByte = System.Text.Encoding.UTF8.GetBytes(payloadJson);
            try
            {
                //string jwtHeaderBase64 = Convert.ToBase64String(headerByte);
                //string jwtPayloadBase64 = Convert.ToBase64String(payLoadByte);
                string jwtHeaderBase64 = Base64UrlEncoder.Encode(headerByte);
                string jwtPayloadBase64 = Base64UrlEncoder.Encode(payLoadByte);

                tokenContent = $"{jwtHeaderBase64}.{jwtPayloadBase64}";

                string jwtSignatureBase64 = GetPemPrivateKeyByte(tokenContent, PemPrivateKey);



                jwt = $"{tokenContent}.{jwtSignatureBase64}";  // client assertion 

            }
            catch (Exception ex)
            {
                string errore = ex.Message;
            }
            return jwt;
        }

        public string composeJWT(PCPPayload pLoad, Dati_PCP dati, string audience = null)
        {
            string headerJson = serializeHeader(dati);
            byte[] headerByte = System.Text.Encoding.UTF8.GetBytes(headerJson);
            //if (!string.IsNullOrEmpty(audience))
            //{
            pLoad.aud = dati.aud;
            //}
            string payloadJson = serializeEmptyPayLoad(pLoad, dati);
            byte[] payLoadByte = System.Text.Encoding.UTF8.GetBytes(payloadJson);

            //string jwtHeaderBase64 = Convert.ToBase64String(headerByte);
            //string jwtPayloadBase64 = Convert.ToBase64String(payLoadByte);
            string jwtHeaderBase64 = Base64UrlEncoder.Encode(headerByte);
            string jwtPayloadBase64 = Base64UrlEncoder.Encode(payLoadByte);

            tokenContent = $"{jwtHeaderBase64}.{jwtPayloadBase64}";

            string jwtSignatureBase64 = GetPemPrivateKeyByte(tokenContent, PemPrivateKey);

            jwt = $"{tokenContent}.{jwtSignatureBase64}";  // client assertion 

            return jwt;
        }

        public Dictionary<string, string> composeParams(string strJwt)
        {
            var dict = new Dictionary<string, string>();
            dict.Add("client_id", clientId);
            dict.Add("client_assertion", strJwt);
            dict.Add("client_assertion_type", "urn:ietf:params:oauth:client-assertion-type:jwt-bearer");
            dict.Add("grant_type", "client_credentials");

            return dict;
        }



        public string serializeHeader(Dati_PCP dati)
        {
            header.kid = dati.Kid; // Configuration.GetSection("PDND_info").GetValue<string>("kid");
            return JsonSerializer.Serialize(header);
        }
        public string serializePayload(Model.PCPPayloadWithData pLoad, Dati_PCP dati, string audience = null)
        {
            pLoad.iss = dati.clientId;
            pLoad.sub = dati.clientId;
            if (!string.IsNullOrEmpty(audience))
            {
                pLoad.aud = audience;
            }
            else
            {
                pLoad.aud = aud;
            }
            long iat = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            int expPeriod = Configuration.GetSection("PDND_info").GetValue<int>("expirationInSeconds");
            //long exp = DateTimeOffset.Now.AddSeconds(expPeriod).ToUnixTimeSeconds();
            long exp = DateTimeOffset.UtcNow.AddMinutes(10).ToUnixTimeSeconds();
            pLoad.iat = iat;
            pLoad.exp = exp;
            pLoad.jti = Guid.NewGuid().ToString();
            //pLoad.nbf = DateTimeOffset.Now.ToUnixTimeSeconds();
            var finaldate =
            pLoad.nbf = pLoad.iat;
            pLoad.purposeId = pLoad.purposeId;
            pLoad.regCodiceComponente = dati.centroDiCosto;
            return JsonSerializer.Serialize(pLoad);
        }

        public PCPPayload composePayLoad(PCPPayloadWithData pLoadWithData, Dati_PCP dati)
        {
            PCPPayload pLoad = new PCPPayload();
            pLoad.iss = dati.clientId;
            pLoad.sub = dati.clientId;
            pLoad.aud = aud;
            long iat = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            int expPeriod = Configuration.GetSection("PDND_info").GetValue<int>("expirationInSeconds");
            //long exp = DateTimeOffset.Now.AddSeconds(expPeriod).ToUnixTimeSeconds();
            long exp = DateTimeOffset.UtcNow.AddMinutes(10).ToUnixTimeSeconds();
            pLoad.iat = iat;
            pLoad.exp = exp;
            pLoad.jti = Guid.NewGuid().ToString();
            //pLoad.nbf = DateTimeOffset.Now.ToUnixTimeSeconds();
            pLoad.nbf = pLoad.iat;
            pLoad.purposeId = pLoad.purposeId;

            return pLoad;
        }

        public string serializePayload(PCPPayloadWithHash pLoad, Dati_PCP dati)
        {
            pLoad.iss = dati.clientId;
            pLoad.sub = dati.clientId;
            pLoad.aud = aud;
            long iat = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            int expPeriod = Configuration.GetSection("PDND_info").GetValue<int>("expirationInSeconds");
            //long exp = DateTimeOffset.Now.AddSeconds(expPeriod).ToUnixTimeSeconds();
            long exp = DateTimeOffset.UtcNow.AddMinutes(10).ToUnixTimeSeconds();
            pLoad.iat = iat;
            pLoad.exp = exp;
            pLoad.jti = Guid.NewGuid().ToString();
            pLoad.purposeId = pLoad.purposeId;
            pLoad.nbf = pLoad.iat;

            return JsonSerializer.Serialize(pLoad);
        }

        public string serializeEmptyPayLoad(PCPPayload pLoad, Dati_PCP dati, string audience = null)
        {
            pLoad.iss = dati.clientId;
            pLoad.sub = dati.clientId;
            if (!string.IsNullOrEmpty(audience))
            {
                pLoad.aud = audience;
            }
            else
            {
                pLoad.aud = dati.aud;
            }
            long iat = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            int expPeriod = Configuration.GetSection("PDND_info").GetValue<int>("expirationInSeconds");
            //long exp = DateTimeOffset.Now.AddSeconds(expPeriod).ToUnixTimeSeconds();
            long exp = DateTimeOffset.UtcNow.AddMinutes(10).ToUnixTimeSeconds();
            pLoad.iat = iat;
            pLoad.exp = exp;
            pLoad.jti = Guid.NewGuid().ToString();
            pLoad.purposeId = pLoad.purposeId;
            pLoad.nbf = pLoad.iat;

            return JsonSerializer.Serialize(pLoad);
        }


        public PCPEservice GetService(string section, string purposeId)
        {
            List<PCPEservice> servizi = GetObjectsInSection("PDND_info:E-Services");
            PCPEservice servizio = servizi.Where(x => x.purposeId == purposeId).SingleOrDefault<PCPEservice>();
            return servizio;
        }


        public List<PCPEservice> GetObjectsInSection(string sectionKey)
        {

            var Section = Configuration.GetSection(sectionKey);

            string result = "";
            // iterate through each child object of section
            foreach (var Object in Section.GetChildren())
            {
                Dictionary<string, string> elements = new Dictionary<string, string>();
                List<IConfigurationSection> el = Object.GetChildren().ToList();
                foreach (IConfigurationSection i in el)
                {
                    elements.Add(i.Key, i.Value);

                }
                result += JsonSerializer.Serialize(elements) + ",";
            }

            int resultLenght = result.Length;

            if (result.EndsWith(","))
            {
                result = result.Substring(0, result.Length - 1);
            }


            result = "[" + result + "]";

            List<PCPEservice> servizi = JsonSerializer.Deserialize<List<PCPEservice>>(result);

            return servizi;

        }


        public string GetPemPrivateKeyByte(string token, string pemPrivateKey)
        {
            string keyText = "";
            string signatureBase64 = string.Empty;

            try
            {
                dt.Write("Nuovo StreamReader legge la chiave privata", "GetPemPrivateKeyByte", "GetPemPrivateKeyByte", "PDND");
                using (var sr = new StreamReader(pemPrivateKey))
                {
                    keyText = sr.ReadToEnd();
                    dt.Write("Ho letto la chiave privata", "GetPemPrivateKeyByte", "GetPemPrivateKeyByte", "PDND");
                    dt.Write("RSA.Create", "GetPemPrivateKeyByte", "GetPemPrivateKeyByte", "PDND");
                    //RSA rsa = RSA.Create();
                    //dt.Write("Dopo RSA.cREATE E PRIMA DI rsa.ImportFromPem(keyText)", "GetPemPrivateKeyByte", "GetPemPrivateKeyByte", "PDND");
                    //dt.Write("Contenuto keyText: " + keyText, "GetPemPrivateKeyByte", "GetPemPrivateKeyByte", "PDND");
                    //rsa.ImportFromPem(keyText);
                    dt.Write("Ho eseguito rsa.ImportFromPem", "GetPemPrivateKeyByte", "GetPemPrivateKeyByte", "PDND");
                    RSACryptoServiceProvider rsaCryptoServiceProvider = new RSACryptoServiceProvider();
                    dt.Write("Prima di rsaCryptoServiceProvider.ImportFromPem(keyText)", "GetPemPrivateKeyByte", "GetPemPrivateKeyByte", "PDND");
                    rsaCryptoServiceProvider.ImportFromPem(keyText);
                    dt.Write("Dopo di rsaCryptoServiceProvider.ImportFromPem(keyText)", "GetPemPrivateKeyByte", "GetPemPrivateKeyByte", "PDND");
                    byte[] signatureBytes = rsaCryptoServiceProvider.SignData(Encoding.UTF8.GetBytes(token), System.Security.Cryptography.HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
                    //signatureBase64 = Convert.ToBase64String(signatureBytes);
                    signatureBase64 = Base64UrlEncoder.Encode(signatureBytes);
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Problemi con lettura della chiave privata: " + ex.Message + Environment.NewLine + pemPrivateKey);
            }

            return signatureBase64;
        }

        public string computeHash(string value)
        {

            var sb = new StringBuilder();
            var digest = "";
            using (var sha256hash = SHA256.Create())
            {
                byte[] valueBytes = sha256hash
                    .ComputeHash(Encoding.UTF8.GetBytes(value));

                for (int i = 0; i < valueBytes.Length; i++)
                    sb.Append(valueBytes[i].ToString("x2"));
                digest = sb.ToString();
            }
            return digest;
        }

        public async Task<string> PDNDRequest(string url, string jwt, HttpMethod method = null, Dictionary<string, string> parametri = null, string? receivedVoucher = null, string? jwsForAgid = null, bool serviceRequest = false)
        {
            //Risposta risposta = new Risposta();
            string baseUrl = url;
            string esito = string.Empty;
            // Creazione di un oggetto HttpClient
            using (HttpClient httpClient = new HttpClient())
            {
                // Aggiunta di intestazioni (headers) personalizzate
                //httpClient.DefaultRequestHeaders.Add("x-requested-with", "XMLHttpRequest");
                httpClient.DefaultRequestHeaders.Add("Accept", "application/json");

                httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {receivedVoucher}");
                httpClient.DefaultRequestHeaders.Add("Agid-JWT-TrackingEvidence", jwsForAgid);



                // Costruzione dell'URL completo con i parametri
                string fullUrl = QueryHelpers.AddQueryString(url, parametri);

                // Eseguire la richiesta HTTP GET

                HttpResponseMessage response = await httpClient.GetAsync(fullUrl);

                IEnumerable<string> values;
                string? retryAfter = response.Headers.TryGetValues("Retry-After", out values).ToString();
                string? remaining = response.Headers.TryGetValues("Limit", out values).ToString();

                //if (response.IsSuccessStatusCode)
                //{

                string responseStream = await response.Content.ReadAsStringAsync();
                esito = responseStream;
                //    var rispostaAutenticazione = JsonSerializer.Deserialize<JsonVoucherModel>(responseStream);
                //    //risposta = JsonSerializer.Deserialize<Risposta>(responseStream);
                //    if (risposta is null)
                //    {

                //        throw new Exception("Errore Voucher PDND: non è stato possibile deserializzare il voucher");
                //    }
                //    else
                //    {
                //        //voucher = risposta.voucher.access_token;
                //        //Console.WriteLine($"voucher {voucher}");

                //    }
                //}
                //else
                //{


                //foreach (var n in response.Headers.NonValidated)
                //{
                //    esito += n.Key + " " + n.Value + Environment.NewLine;
                //}
                //esito += "La richiesta HTTP ha restituito uno stato non riuscito: " + response.StatusCode;
           
                }

            //var webRequest = new HttpRequestMessage(method, fullUrl);
                //{
                //    Content = new StringContent(@jsonContent, Encoding.UTF8, "application/json")
                //};

                //var response = httpClient.Send(webRequest);

                //using var reader = new StreamReader(response.Content.ReadAsStream());

                //string fault = reader.ReadToEnd();

                //foreach (var n in response.Headers.NonValidated)
                //{
                //    esito += n.Key + " " + n.Value + "<br />";
                //}
            //}

            return esito;




        }

        public async Task<string> ESPD_Request(string idDoc, string URL)
        {
            string responseStream = string.Empty;
            HttpResponseMessage response = new HttpResponseMessage();
            HttpClientHandler clientHandler = new HttpClientHandler();
            using (HttpClient httpClient = new HttpClient(clientHandler))
            {
                httpClient.BaseAddress = new Uri(URL);
                Dictionary<string, string> dict = new Dictionary<string, string>();
                dict.Add("idDoc", idDoc);

                var request = new HttpRequestMessage(HttpMethod.Get, url) { Content = new FormUrlEncodedContent(dict) };

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


        public async Task<string> PDNDRequest(string url, string jwt, HttpMethod method)
        {
            HttpResponseMessage msg = new HttpResponseMessage();
            HttpClientHandler clientHandler; // = new HttpClientHandler();
            HttpClient httpClient = new HttpClient();
            httpClient.BaseAddress = new Uri(url);

            Dictionary<string, string> dict = new Dictionary<string, string>(composeParams(jwt));

            var request = new HttpRequestMessage(method, url) { Content = new FormUrlEncodedContent(dict) };

            string voucher = string.Empty;

            request.Headers.Clear();

            request.Headers.Add("x-requested-with", "XMLHttpRequest");
            request.Headers.TryAddWithoutValidation("Accept", "application/json");

            HttpClient client;

            clientHandler = new HttpClientHandler();

            Risposta risposta = new Risposta();

            using (client = new HttpClient(clientHandler))
            {
                msg = client.Send(request);

                IEnumerable<string> values;
                string? retryAfter = msg.Headers.TryGetValues("Retry-After", out values).ToString();
                string? remaining = msg.Headers.TryGetValues("Limit", out values).ToString();


                if (msg.IsSuccessStatusCode)
                {

                    string responseStream = await msg.Content.ReadAsStringAsync();
                    var rispostaAutenticazione = JsonSerializer.Deserialize<JsonVoucherModel>(responseStream);

                    if (rispostaAutenticazione is null)
                    {

                        throw new Exception("Errore Voucher PDND: non è stato possibile deserializzare il voucher");
                    }
                    else
                    {
                        voucher = rispostaAutenticazione.access_token;
                        Console.WriteLine($"voucher {voucher}");
                    }
                }
                else
                {
                    throw new Exception("Errore Voucher PDND: " + msg.ReasonPhrase);
                };
            };

            return voucher;
        }

        public async Task<string> PDNDPostRequest(string url, string jwt, HttpMethod method = null, Dictionary<string, string> parametri = null, string? receivedVoucher = null, string? jwsForAgid = null, bool serviceRequest = false, string body = null)
        {
            string strResult = string.Empty;
            string baseUrl = url;
            string voucher = string.Empty;
            // Creazione di un oggetto HttpClient
            using (HttpClient httpClient = new HttpClient())
            {
                //httpClient.BaseAddress = new Uri(baseUrl);
                // Aggiunta di intestazioni (headers) personalizzate
                httpClient.DefaultRequestHeaders.Add("x-requested-with", "XMLHttpRequest");
                httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", receivedVoucher);
                httpClient.DefaultRequestHeaders.Add("Agid-JWT-TrackingEvidence", jwsForAgid);

                string fullUrl = string.Empty;

                string jsonContent = body.Replace(Environment.NewLine, string.Empty);
                fullUrl = url;
                var content = new StringContent(jsonContent, System.Text.Encoding.UTF8, "application/json");


                //HttpResponseMessage response = await httpClient.PostAsync(fullUrl, content);

                ////HttpResponseMessage response = task.Result;

                //string responseStream = await response.Content.ReadAsStringAsync();

                //if (response.IsSuccessStatusCode)
                //{

                //    using var reader = new StreamReader(response.Content.ReadAsStream());

                //    strResult = reader.ReadToEnd();

                //}
                //else
                //{
                //    strResult = "La richiesta HTTP ha restituito uno stato non riuscito: " + response.StatusCode + Environment.NewLine;
                //    string fault = string.Empty;
                //    foreach (var n in response.Headers.NonValidated)
                //    {
                //        strResult += n.Key + " " + n.Value + "<br />";
                //    }
                //}


                var webRequest = new HttpRequestMessage(HttpMethod.Post, fullUrl)
                {
                    Content = new StringContent(@jsonContent, Encoding.UTF8, "application/json")
                };

                var response = httpClient.Send(webRequest);
                IEnumerable<string> values;
                string? retryAfter = response.Headers.TryGetValues("Retry-After", out values).ToString();
                string? remaining = response.Headers.TryGetValues("Limit", out values).ToString();

                using var reader = new StreamReader(response.Content.ReadAsStream());

                strResult = reader.ReadToEnd();

                var oggetto = JsonSerializer.Deserialize<object>(strResult);

                //foreach (var n in response.Headers.NonValidated)
                //{
                //    strResult += n.Key + " " + n.Value + "<br />";
                //}


            };

            return strResult;

        }

    }


    public class PCPEservice
    {
        public string id { get; set; }
        public string endpoint { get; set; }
        public string purposeId { get; set; }
        public string clientId { get; set; }
        public string kid { get; set; }
    }

    public class DigestClaim
    {
        public string alg { get; set; } = "SHA256";
        public string value { get; set; } = "";
    }

    public class PCPHeader
    {
        public string kid { get; set; }
        public string alg { get; set; } = "RS256";
        public string typ { get; set; } = "JWT";
    }
    public class PCPPayload
    {
        public string iss { get; set; }
        public string sub { get; set; }
        public string aud { get; set; }
        public string purposeId { get; set; }

        public string jti { get; set; }
        public long iat { get; set; } // => DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        public long exp { get; set; } // da appsettings recuperare la scadenza in secondi nel caso venisse modificata nel tempo
        public long nbf { get; set; }

    }

    public class PCPPayloadWithData : PCPPayload
    {
        //public long nbf { get; set; } // not before
        public string userLocation { get; set; } = "postazione di test";
        public string userCodiceFiscale { get; set; }
        public string userRole { get; set; } = "RP";
        public string userLoa { get; set; } = "3";
        public string userIdpType { get; set; }   /*    description: tipo di identity provider utilizzato per stabilire l'identità dell'utente.
                                                        type: string
                                                        example: "SPID"
                                                        enum:
                                                        - "SPID"
                                                        - "CIE"
                                                        - "CNS"
                                                        - "EIDAS"
                                                        - "CUSTOM" # sistema interno al gestore della piattaforma certificata */
        public string SAcodiceAUSA { get; set; }        /*# blocco SA, Stazione Appaltante. Dati identificativi della stazione appaltante alla quale afferisce l'utente connesso        
                                                        SACodiceFiscale:
                                                        description: codice Fiscale della stazione appaltante. Può essere nullo in caso di soggetti non dotati di personalità giuridica
                                                        type: string
                                                        example: "11111111115"
                                                        SAcodiceAUSA:  
                                                        description: codice ausa della stazione appaltante alla quale appartiene l'utente
                                                        type: string
                                                        example: "0000000000" 
                                                         */
        public string regCodicePiattaforma { get; set; }
        public string regCodiceComponente { get; set; }
        public string businessFlowID { get; set; } = new Guid().ToString(); // sarà uguale a "00000000-0000-0000-0000-000000000000"
        /* businessFlowID:
           description: coincide con idAppalto. Assume valore "00000000-0000-0000-0000-000000000000" 
           nella prima transazione (che è necessariamente comunicaAppalto.crea-appalto) In tutte le operazioni 
           successive riconduce la transazione all’appalto
           type: string
           example: "8cc2d6ca-690d-4031-b75d-b0139b7ace39"
        */
        public string traceID { get; set; } = Guid.NewGuid().ToString();
        public string spanID { get; set; } = Guid.NewGuid().ToString();     /* description: identificativo univoco assegnato dalla piattaforma (?) all'operazione iniziale richiesta dall'utente 
                                                                               type: string
                                                                               example: "8cc2d6ca-690d-4031-b75d-b0139b7ace39"
                                                                            */

    }

    public class ComplementaryPayload
    {
        public PCPHeader header { get; set; }
        public PCPPayload payload { get; set; }
    }

    public class PCPPayloadWithHash : PCPPayload
    {
        public Digest digest { get; set; }

    }

    public class Digest
    {
        public string alg { get; set; } = "SHA256";
        public string value { get; set; }
    }

    public class JsonVoucherModel
    {
        public string access_token { get; set; }
        public int expires_in { get; set; }
        public string token_type { get; set; }

    }

    public class Tipologiche
    {
        public string idTipologica { get; set; }
        public string descrizione { get; set; }
    }

    public class Risposta
    {
        public int totRows { get; set; }
        public int totPages { get; set; }
        public int currentPage { get; set; }
        public int elementPage { get; set; }
        public List<Tipologiche> result { get; set; }
        public object instance { get; set; }
        public int status { get; set; }
        public string title { get; set; }
        public string detail { get; set; }
        public string type { get; set; }
        public JsonVoucherModel voucher { get; set; }
    }

    public class contesti
    {
        public string idContesto { get; set; }
        public string NomeContesto { get; set; }
    }

    public class JsonResponseModel
    {
        public int ResponseCode { get; set; }
        public string ResponseMessage { get; set; }
    }

}
