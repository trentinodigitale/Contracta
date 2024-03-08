
using DocumentFormat.OpenXml.Drawing.Charts;
using DocumentFormat.OpenXml.Office2010.Excel;
using eProcurementNext.Application;
using eProcurementNext.CommonDB;
//using eProcurementNext.Core.PDND;
using eProcurementNext.HTML;
using System.Data.SqlClient;
using System.Data;
using Microsoft.Extensions.FileSystemGlobbing.Internal.PathSegments;
using Microsoft.IdentityModel.Tokens;
using eProcurementNext.WebAPI.Model;
using DocumentFormat.OpenXml.Office2016.Drawing.ChartDrawing;


namespace eProcurementNext.WebAPI.Utils
{

    public class PDNDUtils
    {
        SqlCommand cmd;
        SqlConnection conn;
        SqlDataAdapter da;

        IConfiguration configuration;
        public PDNDUtils(IConfiguration _configuration)
        {
            configuration = _configuration;
            string strconn = configuration.GetConnectionString("DefaultConnection");
            conn = new SqlConnection(strconn);
            cmd = new SqlCommand();
            cmd.Connection = conn;
        }

        /// <summary>
        /// Funzione per il recupero dell'authorization Token necessario ad effettuare le operazioni sui servizi dei vari contesti
        /// </summary>
        /// <param name="idAzi"></param>
        /// <returns></returns>
        public string getToken(int idAzi)
        {
            return string.Empty;
        }

        #region "codice trasferito"
        //public async Task<string> ESPD_Request(int idDoc, string URL)
        //{
        //    string responseStream = string.Empty;
        //    HttpResponseMessage response = new HttpResponseMessage();
        //    HttpClientHandler clientHandler = new HttpClientHandler();
        //    using (HttpClient httpClient = new HttpClient(clientHandler))
        //    {
        //        httpClient.BaseAddress = new Uri(URL);
        //        httpClient.Timeout = TimeSpan.FromMinutes(2);
        //        Dictionary<string, string> dict = new Dictionary<string, string>();
        //        dict.Add("IDODC", idDoc.ToString());

        //        //string fullUrl = QueryHelpers.AddQueryString(URL, dict);

        //        var request = new HttpRequestMessage(HttpMethod.Get, URL + "?IDDOC=" + idDoc); // { Content = new FormUrlEncodedContent(dict) };

        //        request.Headers.Clear();

        //        //request.Headers.Add("x-requested-with", "XMLHttpRequest");
        //        //request.Headers.TryAddWithoutValidation("Accept", "application/json");

        //        response = httpClient.Send(request);
        //        if (response.IsSuccessStatusCode)
        //        {

        //            responseStream = await response.Content.ReadAsStringAsync();
        //        }
        //        else
        //        {
        //            responseStream = "Errore: " + response.ReasonPhrase;
        //        };
        //    }

        //    return responseStream;
        //}

        //public async Task<string> eForm_Request(int idDoc, int idPfu, string URL)
        //{
        //    string responseStream = string.Empty;
        //    HttpResponseMessage response = new HttpResponseMessage();
        //    HttpClientHandler clientHandler = new HttpClientHandler();
        //    using (HttpClient httpClient = new HttpClient(clientHandler))
        //    {
        //        httpClient.BaseAddress = new Uri(URL);
        //        httpClient.Timeout = TimeSpan.FromMinutes(2);
        //        Dictionary<string, string> dict = new Dictionary<string, string>();
        //        dict.Add("ID", idDoc.ToString());
        //        dict.Add("IDPFU", idPfu.ToString());

        //        //string fullUrl = QueryHelpers.AddQueryString(URL, dict);

        //        var request = new HttpRequestMessage(HttpMethod.Get, URL) { Content = new FormUrlEncodedContent(dict) };

        //        request.Headers.Clear();

        //        //request.Headers.Add("x-requested-with", "XMLHttpRequest");
        //        //request.Headers.TryAddWithoutValidation("Accept", "application/json");

        //        response = httpClient.Send(request);
        //        if (response.IsSuccessStatusCode)
        //        {

        //            responseStream = await response.Content.ReadAsStringAsync();
        //        }
        //        else
        //        {
        //            responseStream = "Errore: " + response.ReasonPhrase;
        //        };
        //    }

        //    return responseStream;
        //}
        #endregion

        public WebAPI.Model.Dati_PCP recuperataDatiPerVoucher(int iddoc, string? contesto = "", string? servizio = "" )
        {


            Dati_PCP dati = new Dati_PCP();
            try
            {
                da = new SqlDataAdapter();
                System.Data.DataTable dt = new System.Data.DataTable();
                cmd.CommandText = "PCP_RECUPERO_DATI_ANAC_SA";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Clear();
                cmd.Parameters.AddWithValue("@idDoc", iddoc);
                if(!string.IsNullOrEmpty(contesto))
                {
                    cmd.Parameters.AddWithValue("@contesto", contesto);
                }
                if(!string.IsNullOrEmpty (servizio))
                {
                    
                    cmd.Parameters.AddWithValue("@servizio", servizio);
                }

                da.SelectCommand = cmd;
                da.Fill(dt);

                if (dt.Rows.Count > 0)
                {


                    dati.userLoa = dt.Rows[0]["userLoa"].ToString();
                    dati.cfSA = dt.Rows[0]["cfSA"].ToString();
                    dati.cfRP = dt.Rows[0]["cfRP"].ToString();
                    dati.clientId = dt.Rows[0]["clientId"].ToString();
                    dati.codiceAUSA = dt.Rows[0]["codiceAUSA"].ToString();
                    dati.codicePiattaforma = dt.Rows[0]["codicePiattaforma"].ToString();
                    dati.aud = dt.Rows[0]["endpoint"].ToString();
                    dati.idTipoUtente = dt.Rows[0]["IdTipoUtente"].ToString();
                    dati.Kid = dt.Rows[0]["Kid"].ToString();
                    dati.purposeId = dt.Rows[0]["purposeId"].ToString();
                    dati.userLoa = dt.Rows[0]["userLoa"].ToString();
                    dati.centroDiCosto = dt.Rows[0]["centroDiCosto"].ToString();
                }
            }
            catch (Exception ex)
            {

                string errore = ex.Message;
            }
            return dati;
        }

        public WebAPI.Model.PCPPayloadWithData getDatiPerVoucher(Dati_PCP dati)
        {
            WebAPI.Model.PCPPayloadWithData p = new WebAPI.Model.PCPPayloadWithData();
            p.purposeId = dati.purposeId;
            p.aud = dati.aud;
            p.SAcodiceAUSA = dati.codiceAUSA;
            //p.regCodiceComponente = dt.Rows[0]["CentroDiCosto"].ToString();  // questo dato è memorizzato anche altrove e in futuro bisognerà decidere la sua effettiva collocazione
            p.userLoa = dati.userLoa;
            p.regCodicePiattaforma = dati.codicePiattaforma;
            p.userRole = "RP"; // va sempre verificato o diamo per assodato che sia RUP? Altrimenti va fatta una query su CTL_DOC filtrando per idDoc (campo id)
            p.userCodiceFiscale = dati.cfRP;
            p.userIdpType = dati.idTipoUtente.ToString();

            return p;
        }

        public int AggiornaLotti(int iddoc, int lottoIdentifier, string cig)
        {
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idDoc", iddoc);
            cmd.Parameters.AddWithValue("@lottoId", lottoIdentifier);
            cmd.Parameters.AddWithValue("@cig", cig);
            string strSql = "UPDATE Document_Microlotti_Details set CIG = @cig where idHeader = @idDoc amd numeroLotto = @lottoId";
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSql;
            conn.Open();
            int numRecord = cmd.ExecuteNonQuery();
            conn.Close();

            return numRecord;
        }

        public int AggiornaIdAppalto(int iddoc, string idAppalto)
        {
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idDoc", iddoc);
            cmd.Parameters.AddWithValue("@idAppalto", idAppalto);
            
            string strSql = "UPDATE Document_PCP_Appalto set pcp_CodiceAppalto = @idAppalto where idHeader = @idDoc";
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSql;
            conn.Open();
            int numRecord = cmd.ExecuteNonQuery();
            conn.Close();

            return numRecord;
        }
        public string recuperaEFormXml(int idDoc)
        {
            cmd.Parameters.Clear();
            string strSql = "PCP_DATI_EFORM";
            cmd.Parameters.AddWithValue("@idDoc", idDoc);
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            conn.Open();
            string strXml = (string)cmd.ExecuteScalar();
            conn.Close();

            return strXml;
        }


        public int testEspdTemplate(int idDoc)
        {
            string strSql = "SELECT dbo.GetIdTemplateComtest(  " + idDoc + " ) AS idTemplate ";

            cmd.CommandText = strSql;
            conn.Open();
            int idTemplate = (Int32)cmd.ExecuteScalar();
            conn.Close();

            return idTemplate;

        }

        public string recuperaESPDXml(int idDoc)
        {
            cmd.Parameters.Clear();
            string strSql = "PCP_DATI_ESPD";
            cmd.Parameters.AddWithValue("@idDoc", idDoc);
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            conn.Open();
            string strXml = (string)cmd.ExecuteScalar();
            conn.Close();

            return strXml;
        }

        public AnacForm recuperaAnacForm(int idDoc, string tipoScheda, Dati_PCP dati)
        {
            AnacForm a = new AnacForm();
            string strSql = "SELECT * FROM Document_PCP_Appalto WHERE IDhEADER = " + idDoc;
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.Text;
            System.Data.DataTable dt = new System.Data.DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);
            List<FunzioniSvolte> fsvolte = new List<FunzioniSvolte>();
            List<StazioniAppaltanti> stazioni = new List<StazioniAppaltanti>();
            List<CategorieMerceologiche> catMerceologiche = new();
            if (dt.Rows.Count > 0)
            {
                StazioniAppaltanti s = new StazioniAppaltanti();

                s.saTitolare = false;
                s.codiceCentroCosto = dt.Rows[0]["pcp_CodiceCentroDiCosto"].ToString();
                s.codiceAusa = dati.codiceAUSA;
                s.codiceFiscale = dati.cfSA.Substring(2);
                string funzioniSvolte = dt.Rows[0]["pcp_FunzioniSvolte"].ToString();

                if (!string.IsNullOrEmpty(funzioniSvolte))
                {
                    if (funzioniSvolte.Contains("###"))
                    {
                        string[] funzionalitaAr = funzioniSvolte.Split("###");
                        foreach (var item in funzionalitaAr)
                        {
                            if (!string.IsNullOrEmpty(item))
                            {
                                FunzioniSvolte f = new FunzioniSvolte();
                                f.idTipologica = "funzioniSvolte";
                                f.codice = item;
                                fsvolte.Add(f);
                            }
                        }
                    }
                    else
                    {
                        FunzioniSvolte f = new FunzioniSvolte();
                        f.idTipologica = "funzioniSvolte";
                        f.codice = funzioniSvolte;
                        fsvolte.Add(f);
                    }
                }
                s.funzioniSvolte = fsvolte;
                if (fsvolte.Count > 0)
                {
                    s.saTitolare = true;
                }
                stazioni.Add(s);

                a.stazioniAppaltanti = stazioni;
                Appalto appalto = new Appalto();
                string categorieMerc = string.Empty;
                categorieMerc = recupereCatMerceologica(idDoc);// dt.Rows[0]["pcp_Categoria"].ToString();  // chiamare altra query 
                List<CategorieMerceologiche> listCatM = new List<CategorieMerceologiche>();
                if (!string.IsNullOrEmpty(categorieMerc))
                {
                    if (categorieMerc.Contains("###"))
                    {
                        string[] catAr = categorieMerc.Split("###");
                        foreach (string cat in catAr)
                        {
                            if (!string.IsNullOrEmpty(cat))
                            {
                                CategorieMerceologiche c = new CategorieMerceologiche();
                                c.idTipologica = "categorieMerceologiche";
                                c.codice = "999"; //cat;
                                listCatM.Add(c);
                            }
                        }
                    }
                    else
                    {
                        CategorieMerceologiche c = new CategorieMerceologiche();
                        c.idTipologica = "categorieMerceologiche";
                        c.codice = categorieMerc;
                        listCatM.Add(c);
                    }
                }

                appalto.categorieMerceologiche = listCatM;

                appalto.linkDocumenti = dt.Rows[0]["pcp_LinkDocumenti"] != null ? dt.Rows[0]["pcp_LinkDocumenti"].ToString() : string.Empty;
                StrumentiSvolgimentoProcedure ss = new StrumentiSvolgimentoProcedure() { codice = "5", idTipologica = "strumentiSvolgimentoProcedure" };
                appalto.strumentiSvolgimentoProcedure = ss;


                if (dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"] != null)
                {
                    ContrattiDisposizioniParticolari cd = new ContrattiDisposizioniParticolari();
                    cd.idTipologica = "contrattiDisposizioniParticolari";
                    cd.codice = dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"].ToString();
                    appalto.contrattiDisposizioniParticolari = cd;
                }


                //ContrattiDisposizioniParticolari con = new ContrattiDisposizioniParticolari();
                //con.codice = dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"].ToString();
                //con.idTipologica = "contrattidisposizioniparticolari";
                //appalto.contrattiDisposizioniParticolari = con; // dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"].ToString();
                //appalto.categorieMerceologiche = catMerceologiche;

                //MotivoUrgenza listaMotivi = new MotivoUrgenza();

                if (dt.Rows[0]["pcp_MotivoUrgenza"] != null)
                {
                    string cMotivo = dt.Rows[0]["pcp_MotivoUrgenza"].ToString();
                    if (!string.IsNullOrEmpty(cMotivo)) {
                        MotivoUrgenza m = new MotivoUrgenza();
                        m.idTipologica = "motivoUrgenza";
                        m.codice = cMotivo;
                        appalto.motivoUrgenza = m;
                    }
                }

                //appalto.motivoUrgenza = listaMotivi;
                appalto.codiceAppalto = recuperaCodiceAppalto(idDoc);
                if (tipoScheda.ToUpper() != "AD_3" && tipoScheda.ToUpper() != "AD_5")
                {
                    a.lotti = recuperaLotti(idDoc);

                }
                else if (tipoScheda.ToUpper().Equals("AD_5"))
                {
                    // solo aggiudicazioni
                }
                else if (tipoScheda.ToUpper().Equals("AD_3"))
                {
                    // solo aghgiudicazioni e espd
                }
                a.appalto = appalto;
            }

            return a;
        }

        private string recupereCatMerceologica(int idDoc)
        {
            string strSql = "SELECT CATEGORIE_MERC FROM Document_Bando where idHeader = @iddoc";
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@iddoc", idDoc);
            cmd.CommandText = strSql;
            conn.Open();
            object categoria = cmd.ExecuteScalar();
            conn.Close();
            if (categoria != null)
            {
                return categoria.ToString();
            }
            else
            {
                return string.Empty;
            }
        }
        private string recuperaCodiceAppalto(int idDoc)
        {
            string strSql = "select CN16_CODICE_APPALTO,*from Document_E_FORM_CONTRACT_NOTICE where idHeader = @iddoc";
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@iddoc", idDoc);
            cmd.CommandText = strSql;
            conn.Open();
            object codiceAppalto = cmd.ExecuteScalar();
            conn.Close();
            if (codiceAppalto != null)
            {
                return codiceAppalto.ToString();
            }
            else
            {
                return string.Empty;
            }

        }

        private List<Lotti> recuperaLotti(int idDoc)
        {
            System.Data.DataTable dt = new System.Data.DataTable();
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idDoc", idDoc);
            string strSQL = "select TipoBandoGara, NumeroLotto,VALORE_BASE_ASTA_IVA_ESCLUSA as ValoreBase,pcp_SommeRipetizioni as sommeRipetizioni,pcp_SommeADisposizione as sommeADisposizione,pcp_SommeOpzioniRinnovi as sommeOpzioniRinnovi,pcp_UlterioriSommeNoRibasso as ulterioriSommeNoRibasso, IMPORTO_ATTUAZIONE_SICUREZZA as ImportoSicurezza,  ba.CUP as CUP, app.pcp_OggettoPrincipaleContratto, app.pcp_PrevedeRipetizioniOpzioni, app.pcp_TipologiaLavoro, app.pcp_Categoria , app.pcp_CondizioniNegoziata, app.pcp_ContrattiDisposizioniParticolari, dett.pcp_ModalitaAcquisizione, app.pcp_PrestazioniComprese, app.pcp_ServizioPubblicoLocale, app.pcp_PrevedeRipetizioniCompl, app.pcp_CodiceCUI from Document_MicroLotti_Dettagli dett left join Document_PCP_Appalto app on dett.IdHeader = app.idHeader left join Document_Bando ba on dett.IdHeader = ba.idHeader where TipoDoc = 'BANDO_GARA' and dett.idheader = @idDoc";
            cmd.CommandText = strSQL;
            da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);

            List<Lotti> listaLotti = new List<Lotti>();

            if (dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    Lotti l = new Lotti();
                    List<string> cupList = new List<string>();
                    l.ccnl = "non applicabile";
                    if (dt.Rows[i]["CUP"] != null)
                    {

                        string cups = dt.Rows[i]["CUP"].ToString();
                        if (cups.Contains("###"))
                        {
                            string[] cupsAr = cups.Split("###");
                            foreach (string s in cupsAr)
                            {
                                cupList.Add(s);
                            }
                        }
                        else
                        {
                            cupList.Add(cups);
                        }
                    }

                    l.cupLotto = cupList;

                    string numLotto = "0000" + dt.Rows[i]["NumeroLotto"].ToString();
                    l.lotIdentifier = "LOT-" + numLotto.Substring(numLotto.Length - 4);
                   
                    if (dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"] != null)
                    {
                        ContrattiDisposizioniParticolari cd = new ContrattiDisposizioniParticolari();
                        cd.idTipologica = "contrattiDisposizioniParticolari";
                        cd.codice = dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"].ToString();
                        l.contrattiDisposizioniParticolari = cd;
                    }

                    CodIstat istat = new CodIstat();
                    istat.idTipologica = "codIstat";
                    istat.codice = "15065116";
                    l.codIstat = istat;
                    l.afferenteInvestimentiPNRR = false;
                    l.acquisizioneCup = true;
                    List<string> listCupLotto = new List<string>();
                    if (dt.Rows[i]["CUP"] != null)
                    {
                        string cupLotto = dt.Rows[i]["CUP"].ToString();
                        if (cupLotto.Contains("###"))
                        {
                            string[] cupLottoAr = cupLotto.Split("###");
                            foreach (var item in cupLottoAr)
                            {
                                if (!string.IsNullOrEmpty(item))
                                {
                                    listCupLotto.Add(item);
                                }
                            }
                        }
                        else
                        {
                            listCupLotto.Add(cupLotto);
                        }
                    }
                    if (listCupLotto.Count > 0)
                    {
                        l.cupLotto = listCupLotto;
                    }
                    if (dt.Rows[i]["pcp_ModalitaAcquisizione"] != null)
                    {
                        ModalitaAcquisizione m = new ModalitaAcquisizione();
                        m.codice = dt.Rows[i]["pcp_ModalitaAcquisizione"].ToString();
                        m.idTipologica = "modalitaAcquisizione";
                        l.modalitaAcquisizione = m;
                    }

                    string oggetto = recuperaTipoAppalto(idDoc); // dt.Rows[i]["pcp_oggettoPrincipaleContratto"].ToString();
                    List<OggettoPrincipaleContratto> lOggetto = new List<OggettoPrincipaleContratto>();
                    if (!string.IsNullOrEmpty(oggetto))
                    {
                        string codiceTipologca = string.Empty;
                        switch (oggetto)
                        {

                            case "1":
                                codiceTipologca = "F";
                                break;
                            case "2":
                                codiceTipologca = "L";
                                break;
                            case "3":
                                codiceTipologca = "S";
                                break;

                        }



                        OggettoPrincipaleContratto ogg = new OggettoPrincipaleContratto() { codice = codiceTipologca, idTipologica = "oggettoPrincipaleContratto" };

                        l.oggettoPrincipaleContratto = ogg;
                    }
                    if (dt.Rows[i]["pcp_PrestazioniComprese"] != null)
                    {
                        string prestazioniComprese = dt.Rows[i]["pcp_PrestazioniComprese"].ToString();

                        prestazioniComprese p = new prestazioniComprese();
                        p.idTipologica = "prestazioniComprese";
                        p.codice = prestazioniComprese;

                        l.prestazioniComprese = p;
                    }

                    l.servizioPubblicoLocale = true;
                    l.ripetizioniEConsegneComplementari = false;
                    l.lavoroOAcquistoPrevistoInProgrammazione = true;

                    l.ccnl = "non applicabile";
                    
                    List<TipologiaLavoro> tipoL = new List<TipologiaLavoro>();
                    l.tipologiaLavoro = tipoL;

                    l.opzioniRinnovi = true;

                    List<CategorieMerceologiche> listCatM = new List<CategorieMerceologiche>();

                    string categorieM = recuperaCategorieMerceologiche(idDoc);

                    if (!String.IsNullOrEmpty(categorieM))
                    {

                        //string cat = dt.Rows[i]["pcp_Categoria"].ToString();
                        if (!string.IsNullOrEmpty(categorieM))
                        {
                            if (categorieM.Contains("###"))
                            {
                                string[] catAr = categorieM.Split("###");
                                foreach (string t in catAr)
                                {
                                    if (!string.IsNullOrEmpty(t))
                                    {
                                        CategorieMerceologiche c = new CategorieMerceologiche();
                                        c.idTipologica = "categorieMerceologiche";
                                        c.codice = t;
                                        listCatM.Add(c);
                                    }
                                }
                            }
                            else
                            {
                                CategorieMerceologiche c = new CategorieMerceologiche();
                                c.idTipologica = "categorieMerceologiche";
                                c.codice = categorieM;
                                listCatM.Add(c);
                            }
                        }
                    }
                    l.categorieMerceologiche = listCatM;

                    string lCategoria = dt.Rows[i]["pcp_Categoria"].ToString();
                    if (!string.IsNullOrEmpty(lCategoria))
                    {
                        Categoria c = new Categoria() { codice = lCategoria, idTipologica = "categoria" };
                        l.categoria = c;
                    }

                    //if (!string.IsNullOrEmpty(categorieM))
                    //{
                    //    Categoria c = new Categoria() { codice = categorieM, idTipologica = "categoria" };
                    //    l.categoria = c;
                    //}

                    QuadroEconomicoStandard qs = new QuadroEconomicoStandard();
                    if (!string.IsNullOrEmpty(dt.Rows[i]["UlterioriSommeNoRibasso"].ToString()))
                    {
                        qs.ulterioriSommeNoRibasso = Convert.ToInt32(dt.Rows[i]["UlterioriSommeNoRibasso"].ToString());
                    }
                    else
                    {
                        qs.ulterioriSommeNoRibasso = 0;
                    }
                    qs.impForniture = 0;
                    qs.impServizi = 0;
                    qs.impLavori = 0;
                    qs.sommeOpzioniRinnovi = 0;
                    if (!string.IsNullOrEmpty(dt.Rows[i]["sommeOpzioniRinnovi"].ToString()))
                    {
                        qs.sommeOpzioniRinnovi = Convert.ToInt32(dt.Rows[i]["sommeOpzioniRinnovi"].ToString());
                    }
                    else
                    {
                        qs.sommeOpzioniRinnovi = 0;
                    }

                    if (!string.IsNullOrEmpty(dt.Rows[i]["sommeADisposizione"].ToString()))
                    {
                        qs.sommeADisposizione = Convert.ToInt32(dt.Rows[i]["sommeADisposizione"].ToString());
                    }
                    else
                    {
                        qs.sommeADisposizione = 0;
                    }


                    qs.impProgettazione = 0;
                    qs.impTotaleSicurezza = 0;
                    if (!string.IsNullOrEmpty(dt.Rows[i]["sommeRipetizioni"].ToString()))
                    {
                        qs.sommeRipetizioni = Convert.ToInt32(dt.Rows[i]["sommeRipetizioni"].ToString());
                    }
                    else
                    {
                        qs.sommeRipetizioni = 0;
                    }

                   
                    
                    int tipoBangoGara = Convert.ToInt32(dt.Rows[i]["TipoBandoGara"].ToString());
                    int valorebase = 0;
                    if (!string.IsNullOrEmpty(dt.Rows[i]["ValoreBase"].ToString()))
                    {
                        valorebase = Convert.ToInt32(dt.Rows[i]["ValoreBase"].ToString());
                    }
                    if (tipoBangoGara == 2)
                    {
                        qs.impLavori = valorebase;
                    }
                    else if (tipoBangoGara == 3)
                    {
                        qs.impServizi = valorebase;
                    }
                    if (dt.Rows[i]["ImportoSicurezza"] != null)
                    {
                        string importo = dt.Rows[i]["ImportoSicurezza"].ToString();
                        if (!string.IsNullOrEmpty(importo))
                        {
                            qs.impForniture = Convert.ToInt32(dt.Rows[i]["ImportoSicurezza"].ToString());
                        }
                    }

                    l.quadroEconomicoStandard = qs;


                    listaLotti.Add(l);
                }
            }

            return listaLotti;
        }

        public async Task<WebAPI.Model.Scheda> compilaScheda(int idDoc, string tipoScheda, string eform, string espdXml, Dati_PCP dati)
        {

            WebAPI.Model.Scheda s = new WebAPI.Model.Scheda();
            Appalto appalto = new Appalto();
            Body body = new Body();
            AnacForm aForm = new AnacForm();
            aForm = recuperaAnacForm(idDoc, tipoScheda, dati);
            body.anacForm = aForm;


            eform = eform;// recuperaEFormXml(idDoc);
            //if (!string.IsNullOrEmpty(eform))
            //{
            //    eform = Base64UrlEncoder.Encode(eform);
            //}
            //aForm.eform = eform;
            string espd = espdXml; // string.Empty;
            //if (!string.IsNullOrEmpty(espdXml))
            //{
            //    espd = Base64UrlEncoder.Encode(espdXml);
            //}
            //aForm.espd = espd;
            Codice c = new Codice();
            c.idTipologica = "codiceScheda";
            c.codice = !string.IsNullOrEmpty(tipoScheda) ? tipoScheda : "P1_16";
            s.codice = c;
            s.versione = "1.0";
            s.body = body;
            s.body.espd = espd;
            s.body.eform = eform;
            return s;
        }

        public async Task<string> GetVoucher(PDNDClient client, string stringJws, HttpMethod method)
        {
            string risposta = await client.PDNDRequest(client.url, stringJws, method);
            return risposta;
        }


        public string recuperaTipoAppalto(int iddoc)
        {
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idDoc", iddoc);
            string strSql = "SELECT TipoAppaltoGara from view_bando_gara_INTEROP_PCP where idheader = @idDoc";
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSql;
            conn.Open();
            object tipo = (string)cmd.ExecuteScalar();
            conn.Close();
            string result = string.Empty;
            if (tipo != null)
            {
                result = tipo.ToString();
            }

            return result;
        }
        public string recuperaCategorieMerceologiche(int idoc)
        {
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idDoc", idoc);
            string strSql = "SELECT CATEGORIE_MERC FROM Document_Bando where idHeader = @idDoc";
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSql;
            conn.Open();
            object CAT = (string)cmd.ExecuteScalar();
            conn.Close();
            string result = string.Empty;
            if (CAT != null)
            {
                result = CAT.ToString();
            }

            return result;
        }

        public int inserisciLogIntegrazione(int iddoc, string endpointcontestuale,string statorichiesta, string datoRichiesto, string msgErrore, string jsonSent, string jsonReceived, DateTime dataIn, DateTime dataExecuted, DateTime dataFinalizza, int idPfu, int idAzi, string inOut)
        {
            int rec = 0;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idRichiesta", iddoc);
            cmd.Parameters.AddWithValue("@integrazione","PCP");
            cmd.Parameters.AddWithValue("@operazioneRichiesta", endpointcontestuale);
            cmd.Parameters.AddWithValue("@statoRichiesta",statorichiesta);
            cmd.Parameters.AddWithValue("@datoRichiesto",datoRichiesto);
            cmd.Parameters.AddWithValue("@msgError",msgErrore);
            cmd.Parameters.AddWithValue("@jsonSent",jsonSent);
            cmd.Parameters.AddWithValue("@jsonReceived", jsonReceived);
            cmd.Parameters.AddWithValue("@dataIn", dataIn);
            cmd.Parameters.AddWithValue("@dataExecuted",dataExecuted);
            cmd.Parameters.AddWithValue("@dataFinalizza",dataFinalizza);
            cmd.Parameters.AddWithValue("@idPfu",idPfu);
            cmd.Parameters.AddWithValue("@idAzi",idAzi);
            cmd.Parameters.AddWithValue("@inOut",inOut);
            
            string strSql = "insert into Services_Integration_Request(idRichiesta, integrazione,operazioneRichiesta,statoRichiesta,datoRichiesto,msgError,numretry,inputWS,outputWS,isOld,dateIn, DataExecuted,DataFinalizza,idPfu,idAzi,InOut)  VALUES(";
            strSql += "@idRichiesta, @integrazione,@operazioneRichiesta,@statoRichiesta,@datoRichiesto,@msgError,0,@jsonSent,@jsonReceived,0,@dataIn,@dataExecuted,@dataFinalizza,@idPfu,@idAzi,@inOut)";

            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSql;

            try
            {
                conn.Open();
                rec = cmd.ExecuteNonQuery();
                conn.Close();
            }
            catch (Exception ex)
            {
                string errore = ex.Message;
            }

            return rec;
        }

        public void aggiornaCig(int idDoc, string idAppalto)
        {
            // l'idAppalto va memorizzato nel campo pcp_CodiceAppalto della tabella Document_PCP_Appalto

            string strSQL = $"INSERT INTO  Document_PCP_Appalto(pcp_CodiceAppalto) values('{idAppalto}' WHERE idHeader = {idDoc}"; 
            cmd.Parameters.Clear();
            cmd.CommandType = CommandType.Text; 
            cmd.CommandText = strSQL;
            conn.Open();
            cmd.ExecuteNonQuery();
            cmd.Clone();
        }


        //protected string getTipologiaLavoro(int idDoc)
        //{
        //    cmd.Parameters.Clear();
        //    cmd.Parameters.AddWithValue("@idDoc", idDoc);
        //    string strSql = "select TipoAppaltoGara from view_bando_gara_INTEROP_PCP where idheader = @idDoc";
        //    cmd.CommandType = CommandType.Text;
        //    cmd.CommandText = strSql;
        //    conn.Open();
        //    object tAppalto = (string)cmd.ExecuteScalar();
        //    conn.Close();
        //    if (tAppalto != null)
        //    {

        //    }

        //    return "pippo";
        //}

        public HttpMethod recuperaMetodoDaServizio(string servizio)
        {
            HttpMethod method;
            cmd.Parameters.Clear();
            string strSql = "SELECT Method, Tipo from PDND_Servizi with(nolock) where endpoint like '" + servizio + "'";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.Text;
            System.Data.DataTable dt = new System.Data.DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);
            if (dt.Rows.Count > 0)
            {
                method = new HttpMethod(dt.Rows[0]["Method"].ToString().ToUpper());
                // tipoRequest
                return method;
            }
            else
            {
                return null;
            }
        }

        public async Task<string> sendRequest(PDNDClient client, string endpointContestuale, string finaljwt, string bearerToken, string jwtAgidBase64, HttpMethod method, Dictionary<string, string> parametri = null)
        {
            string risposta = await client.PDNDRequest(endpointContestuale, finaljwt, method, receivedVoucher: bearerToken, parametri: parametri, jwsForAgid: jwtAgidBase64, serviceRequest: true);
            return risposta;
        }


        //private async Task<string> postRequest(string endpointContestuale, string finaljwt, string bearerToken, string jwtAgidBase64, HttpMethod method, Dictionary<string, string> parametri = null)
        //{
        //    string result = await client.PDNDPostRequest(endpointContestuale, finaljwt, method, receivedVoucher: bearerToken, parametri: parametri, jwsForAgid: jwtAgidBase64, serviceRequest: true);

        //    return result;
        //}

        public async Task<string> postRequest(PDNDClient client, string endpointContestuale, string finaljwt, string bearerToken, string jwtAgidBase64, HttpMethod method, Dictionary<string, string> parametri = null, string body = null)
        {
            string result = await client.PDNDPostRequest(endpointContestuale, finaljwt, method, receivedVoucher: bearerToken, parametri: parametri, jwsForAgid: jwtAgidBase64, body: body, serviceRequest: true);

            return result;
        }

        public void avviaEsitoOperazione(int idpfu, int iddoc)
        {
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@integrazione", "INTEROPERABILITA");
            cmd.Parameters.AddWithValue("@operazioneRichiesta","esitoOperazione");
            cmd.Parameters.AddWithValue("@idPfu", idpfu);
            cmd.Parameters.AddWithValue("@idDocRichiedente", iddoc);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandText = "INSERT_SERVICE_REQUEST";
            try
            {
                conn.Open();
                cmd.ExecuteNonQuery();
                conn.Close();
            }
            catch(Exception ex)
            {
                string errore = ex.Message;

            // TODO: va gestita l'eccezione
            }


            // eseguire EXEC INSERT_SERVICE_REQUEST 'INTEROPERABILITA' 'esitoOperazione' ippfu idDoc



        }
    }
}
