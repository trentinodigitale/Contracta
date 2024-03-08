using Microsoft.IdentityModel.Tokens;
using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.Crypto.Parameters;
using Org.BouncyCastle.OpenSsl;
using Org.BouncyCastle.Security;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Runtime.InteropServices.ComTypes;
//using System.Runtime.Serialization;
using System.Security.Cryptography;
using System.Security.Permissions;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web.UI.WebControls;
using static INIPEC.Library.AggiudicazioneAD2_25Type;
using static INIPEC.Library.PDNDUtils;

namespace INIPEC.Library
{
    public class Voucher
    {
        public PDNDClient client { set; get; }
        public string jwtWithData { set; get; }
        public string voucher { set; get; }

        public Voucher(PDNDClient c, string jwt, string barer)
        {
            this.client = c;
            this.jwtWithData = jwt;
            this.voucher = barer;
        }
    }

    public class PDNDUtils
    {
        SqlCommand cmd;
        SqlConnection conn;
        SqlDataAdapter da;

        public PDNDUtils()
        {
            string strconn = ConfigurationManager.AppSettings["db.conn"];
            conn = new SqlConnection(strconn);
            cmd = new SqlCommand
            {
                Connection = conn
            };
        }

        public Voucher GetBarerToken(Dati_PCP dati, int idDoc = 0)
        {
            var pu = new PDNDUtils();
            var payload = pu.getDatiPerVoucher(dati);
            var client = new PDNDClient(payload, dati)
            {
                clientId = dati.clientId
            };
            var jwtWithData = client.composeComplementaryJWT(payload, dati);
            var hashedjwt = client.computeHash(jwtWithData);

            var mainPcpPayLoad = new PCPPayloadWithHash
            {
                purposeId = payload.purposeId
            };

            var ploadJson = JsonSerializer.Serialize(mainPcpPayLoad);
            var stringJws = client.composeJWT(ploadJson, hashedjwt, dati, idDoc);

            var method = HttpMethod.Post;
            string voucher = pu.GetVoucher(client, stringJws, method, idDoc);

            return new Voucher(client, jwtWithData, voucher);
        }

        public Dati_Base recuperaContestoEServizio(int idDoc)
        {
            Dati_Base d = new Dati_Base();
            string strSql = "Select * from DATI_BASE_TEST_PCP WITH(NOLOCK) WHERE ID = @idDoc";
            da = new SqlDataAdapter();
            DataTable dt = new DataTable();
            cmd.Parameters.Clear();
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.Text;
            cmd.Parameters.AddWithValue("@idDoc", idDoc);

            da.SelectCommand = cmd;
            da.Fill(dt);
            d.codicefiscale = dt.Rows[0]["codicefiscale"].ToString();
            if (!string.IsNullOrEmpty(dt.Rows[0]["PCP_LOA"].ToString()))
            {
                d.PCP_LOA = Convert.ToInt32(dt.Rows[0]["PCP_LOA"].ToString());
            }
            d.PCP_CONTESTO = dt.Rows[0]["PCP_CONTESTO"].ToString();
            d.PCP_SERVIZIO = dt.Rows[0]["PCP_SERVIZIO"].ToString();
            d.PCP_PARAMETRI = dt.Rows[0]["PCP_PARAMETRI"].ToString();
            d.PCP_JSON = dt.Rows[0]["PCP_JSON"].ToString();
            return d;

        }

        public Dati_PCP recuperaDatiPerVoucher(int iddoc, string contesto = "", string servizio = "")
        {

            Dati_PCP dati = new Dati_PCP();

            try
            {
                InsertTrace("PCP", "Inizio chiamata al metodo recuperaDatiPerVoucher()", iddoc);

                da = new SqlDataAdapter();
                DataTable dt = new System.Data.DataTable();
                cmd.CommandText = "PCP_RECUPERO_DATI_ANAC_SA";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Clear();
                cmd.Parameters.AddWithValue("@idDoc", iddoc);
                if (!string.IsNullOrEmpty(contesto))
                {
                    cmd.Parameters.AddWithValue("@contesto", contesto);
                }

                if (!string.IsNullOrEmpty(servizio))
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
                    dati.regCodiceComponente = dt.Rows[0]["PCP_regCodiceComponente"].ToString();
                    dati.audAuth = dt.Rows[0]["audAuth"].ToString();
                    dati.urlAuth = dt.Rows[0]["urlAuth"].ToString();
                    dati.PemPrivateKey = dt.Rows[0]["PemPrivateKey"].ToString();
                }
                else
                {
                    throw new ApplicationException("Nessun dato recuperato da PCP_RECUPERO_DATI_ANAC_SA");
                }
            }
            catch (ApplicationException e)
            {
                throw;
            }
            catch (Exception e)
            {
                //Eccezione di runtime non gestita
                throw new Exception($"Eccezione di rutime in recuperaDatiPerVoucher() : {e.Message}", e);
            }
            finally
            {
                InsertTrace("PCP", "Fine chiamata al metodo recuperaDatiPerVoucher()", iddoc);
            }

            return dati;
        }

        public PCPPayloadWithData getDatiPerVoucher(Dati_PCP dati)
        {
            PCPPayloadWithData p = new PCPPayloadWithData();
            p.purposeId = dati.purposeId;
            p.aud = dati.aud;
            p.SAcodiceAUSA = dati.codiceAUSA;
            p.regCodiceComponente = dati.regCodiceComponente;
            p.userLoa = dati.userLoa;
            p.regCodicePiattaforma = dati.codicePiattaforma;
            p.userRole = "RP"; //TODO: dato cablato! va sempre verificato o diamo per assodato che sia RUP? Altrimenti va fatta una query su CTL_DOC filtrando per idDoc (campo id)
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

        public int nuovoIdAppaltoCN16(int iddoc)
        {
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idDoc", iddoc);

            string strSql = "update Document_E_FORM_CONTRACT_NOTICE set CN16_CODICE_APPALTO = lower(NEWID()) where idHeader = @idDoc";
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSql;
            conn.Open();
            int numRecord = cmd.ExecuteNonQuery();
            conn.Close();

            return numRecord;
        }

        public string recuperaEFormXml(int idDoc, string operation = "CN16")
        {
            cmd.Parameters.Clear();
            string strSql = "PCP_DATI_EFORM";
            cmd.Parameters.AddWithValue("@idDoc", idDoc);
            cmd.Parameters.AddWithValue("@Tipo_E_FORM", operation);
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

        public TipoScheda recuperaTipoSchedaGara(int iddoc)
        {
            string strSql = "SELECT pcp_TipoScheda as TipoScheda FROM Document_PCP_Appalto with(nolock) where idHeader = @iddoc";
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@iddoc", iddoc);

            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.Text;

            conn.Open();
            
            object tipoScheda = cmd.ExecuteScalar();
            conn.Close();
        

            return enumTipoScheda(tipoScheda.ToString());
        }

        public void aggiornaRecordSchedaAppalto(int iddoc, int idpfu, string tipoScheda, string statoScheda, int idRowScheda = 0)
        {
            conn.Open();

            try
            {
                using (SqlCommand command = new SqlCommand("PCP_SCHEDE_UPDATE_REQUEST", conn))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    command.Parameters.AddWithValue("@idRic", iddoc);
                    command.Parameters.AddWithValue("@idPfu", idpfu);
                    command.Parameters.AddWithValue("@tipoScheda", tipoScheda);
                    command.Parameters.AddWithValue("@IdDoc_Scheda", iddoc);
                    command.Parameters.AddWithValue("@statoScheda", statoScheda);
                    command.Parameters.AddWithValue("@idRowScheda", idRowScheda);
                    
                    command.ExecuteNonQuery();
                }
            }
            finally
            {
                conn.Close();
            }
        }

        public int creaRecordSchedaAppalto(int iddoc, int idpfu, string tipoScheda)
        {
            int idRowScheda = -1;

            conn.Open();

            try
            {
                using (SqlCommand command = new SqlCommand("PCP_SCHEDE_INSERT_REQUEST", conn))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    // Parametri di input
                    command.Parameters.AddWithValue("@idRic", iddoc);
                    command.Parameters.AddWithValue("@idPfu", idpfu);
                    command.Parameters.AddWithValue("@tipoScheda", tipoScheda);
                    command.Parameters.AddWithValue("@operazioneRichiesta", "");
                    command.Parameters.AddWithValue("@IdDoc_Scheda", iddoc);
                    command.Parameters.AddWithValue("@noServiceRequest", 1);

                    // Parametro di output
                    SqlParameter idRowParam = command.Parameters.Add("@idRowScheda", SqlDbType.Int);
                    idRowParam.Direction = ParameterDirection.Output;

                    command.ExecuteNonQuery();

                    // Retrieve the output parameter value
                    if (idRowParam.Value != DBNull.Value)
                    {
                        idRowScheda = Convert.ToInt32(idRowParam.Value);
                    }
                    else
                    {
                        throw new ApplicationException("Fallita creazione record scheda dalla PCP_SCHEDE_INSERT_REQUEST");
                    }
                }
            }
            finally
            {
                conn.Close();
            }

            return idRowScheda;
        }

        public TipoScheda enumTipoScheda(string tipoScheda)
        {
            switch (tipoScheda)
            {
                case ("AD3"):
                case ("AD_3"):
                    return TipoScheda.AD_3;
                case ("P116"):
                case ("P1_16"):
                    return TipoScheda.P1_16;
                case ("AD4"):
                case ("AD_4"):
                    return TipoScheda.AD_4;
                case ("AD5"):
                case ("AD_5"):
                    return TipoScheda.AD_5;
                case ("S2"):
                case ("S_2"):
                    return TipoScheda.S2;
                case ("S1"):
                case ("S_1"):
                    return TipoScheda.S1;
                case ("P216"):
                case ("P2_16"):
                    return TipoScheda.P2_16;
                case ("P61"):
                case ("P6_1"):
                    return TipoScheda.P6_1;
                case ("P62"):
                case ("P6_2"):
                    return TipoScheda.P6_2;
                case ("P72"):
                case ("P7_2"):
                    return TipoScheda.P7_2;
                case ("AD225"):
                case ("AD_225"):
                case ("AD2_25"):
                case ("AD_2_25"):
                    return TipoScheda.AD2_25;
                case ("A129"):
                case ("A1_29"):
                    return TipoScheda.A1_29;
                case ("S3"):
                case ("S_3"):
                    return TipoScheda.S3;
                case ("SC1"):
                case ("SC_1"):
                    return TipoScheda.SC1;
                case ("P7_1_2"):
                    return TipoScheda.P7_1_2;
                case ("P7_1_3"):
                    return TipoScheda.P7_1_3;
                case ("A229"):
                case ("A2_29"):
                    return TipoScheda.A2_29;
                case ("P1_19"):
                    return TipoScheda.P1_19;
                case ("P2_19"):
                    return TipoScheda.P2_19;
                case ("A7_1_2"):
                    return TipoScheda.A7_1_2;
                default:
                    return TipoScheda.P1_16;
            }
        }

        public void RecuperaEFormXml64EspdXml64(int idDoc, ref string eformXml64, ref string espdXml64)
        {
            TipoScheda tipoScheda = recuperaTipoSchedaGara(idDoc);


            switch (tipoScheda)
            {
                case TipoScheda.AD_3:
                case TipoScheda.AD_5:
                case TipoScheda.P7_2:
                case TipoScheda.P2_16:
                    string espdAD_3 = recuperaESPDXml(idDoc);
                    //è stato definito che per le schede AD3, AD4, AD5 e P7.2 (oltre che per P6.1 e P6.2) l’ESPD request NON è obbligatorio
                    espdXml64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(!string.IsNullOrEmpty(espdAD_3) ? espdAD_3 : ""));
                    break;

                case TipoScheda.P1_16:
                case TipoScheda.P1_19:
                    string espdP1_16 = recuperaESPDXml(idDoc);
                    string eform = recuperaEFormXml(idDoc);

                    if (string.IsNullOrEmpty(eform))
                    {
                        //esito = "0#XML eForm vuoto";
                        throw new ApplicationException("XML eForm vuoto");
                    }

                    if (String.IsNullOrEmpty(espdP1_16))
                    {
                        //esito = "0#XML ESPD vuoto";
                        throw new ApplicationException("XML ESPD vuoto");

                    }

                    eformXml64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(eform));
                    espdXml64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(espdP1_16));
                    break;
                case TipoScheda.AD2_25:
                    string espdAD2_25 = recuperaESPDXml(idDoc);
                    if (String.IsNullOrEmpty(espdAD2_25))
                    {
                        //esito = "0#XML ESPD vuoto";
                        throw new ApplicationException("XML ESPD vuoto");
                    }

                    espdXml64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(espdAD2_25));
                    break;
                case TipoScheda.P7_1_3:
                    eformXml64 = string.Empty;
                    espdXml64 = string.Empty;
                    break;
                default:
                    break;
            }
        }

        public TipoScheda recuperaTipoScheda(int idRow)
        {
            string strSql = "SELECT tipoScheda FROM document_pcp_appalto_schede with(nolock) WHERE idrow = @idRow";
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idRow", idRow);
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.Text;
            conn.Open();
            object tipoScheda = cmd.ExecuteScalar();
            conn.Close();

            return enumTipoScheda(tipoScheda.ToString());
        }


        public AnacForm recuperaAnacFormP1_16(int idDoc, Dati_PCP dati)
        {
            AnacForm a = new AnacForm();
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql = "GET_DATI_SCHEDA_PCP_HEADER";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);
            List<FunzioniSvolte> fsvolte = new List<FunzioniSvolte>();
            List<StazioniAppaltanti> stazioni = new List<StazioniAppaltanti>();
            List<CategorieMerceologiche> catMerceologiche = new List<CategorieMerceologiche>();
            if (dt.Rows.Count > 0)
            {
                StazioniAppaltanti s = new StazioniAppaltanti();

                s.saTitolare = false;
                s.codiceCentroCosto = dt.Rows[0]["pcp_CodiceCentroDiCosto"].ToString();
                s.codiceAusa = dati.codiceAUSA;
                //TODO: dati.cdRP
                s.codiceFiscale = dati.cfSA.ToUpper().StartsWith("IT") ? dati.cfSA.Substring(2) : dati.cfSA;
                string funzioniSvolte = dt.Rows[0]["pcp_FunzioniSvolte"].ToString();

                if (!string.IsNullOrEmpty(funzioniSvolte))
                {
                    if (funzioniSvolte.Contains("###"))
                    {
                        string[] funzionalitaAr = funzioniSvolte.Split(new string[] { "###" }, StringSplitOptions.None);
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
                categorieMerc = recupereCatMerceologica(idDoc);
                List<CategorieMerceologiche> listCatM = new List<CategorieMerceologiche>();
                if (!string.IsNullOrEmpty(categorieMerc))
                {
                    if (categorieMerc.Contains("###"))
                    {
                        string[] catAr = categorieMerc.Split(new string[] { "###" }, StringSplitOptions.None);
                        foreach (string cat in catAr)
                        {
                            if (!string.IsNullOrEmpty(cat))
                            {
                                CategorieMerceologiche c = new CategorieMerceologiche();
                                c.idTipologica = "categorieMerceologiche";
                                c.codice = "999"; //cat; //TODO???? non implementato!!!
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


                if (dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"] != null && dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"].ToString() != "")
                {
                    ContrattiDisposizioniParticolari cd = new ContrattiDisposizioniParticolari();
                    cd.idTipologica = "contrattiDisposizioniParticolari";
                    cd.codice = dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"].ToString();
                    appalto.contrattiDisposizioniParticolari = cd;
                }


                //if (dt.Rows[0]["pcp_MotivoUrgenza"] != null)
                if (!string.IsNullOrEmpty(dt.Rows[0]["pcp_MotivoUrgenza"].ToString()))
                {
                    string cMotivo = dt.Rows[0]["pcp_MotivoUrgenza"].ToString();
                    if (!string.IsNullOrEmpty(cMotivo))
                    {
                        MotivoUrgenza m = new MotivoUrgenza();
                        m.idTipologica = "motivoUrgenza";
                        m.codice = cMotivo;
                        appalto.motivoUrgenza = m;
                    }
                }


                appalto.codiceAppalto = recuperaCodiceAppalto(idDoc);
                a.lotti = recuperaLotti(idDoc);
                a.appalto = appalto;
            }

            return a;
        }

        public AnacFormP2_16 recuperaAnacFormP2_16(int idDoc, Dati_PCP dati)
        {
            AnacFormP2_16 a = new AnacFormP2_16();
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql = "GET_DATI_SCHEDA_PCP_HEADER";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);

            List<FunzioniSvolte> fsvolte = new List<FunzioniSvolte>();
            List<StazioniAppaltanti> stazioni = new List<StazioniAppaltanti>();
            List<CategorieMerceologiche> catMerceologiche = new List<CategorieMerceologiche>();
            if (dt.Rows.Count > 0)
            {
                StazioniAppaltanti s = new StazioniAppaltanti();
                s.saTitolare = false;
                s.codiceCentroCosto = dt.Rows[0]["pcp_CodiceCentroDiCosto"].ToString();
                s.codiceAusa = dati.codiceAUSA;
                s.codiceFiscale = dati.cfSA.ToUpper().StartsWith("IT") ? dati.cfSA.Substring(2) : dati.cfSA;
                string funzioniSvolte = dt.Rows[0]["pcp_FunzioniSvolte"].ToString();
                if (!string.IsNullOrEmpty(funzioniSvolte))
                {
                    if (funzioniSvolte.Contains("###"))
                    {
                        string[] funzionalitaAr = funzioniSvolte.Split(new string[] { "###" }, StringSplitOptions.None);
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

                AppaltoP2_16 appalto = new AppaltoP2_16();

                string categorieMerc = string.Empty;
                categorieMerc = recupereCatMerceologica(idDoc);
                List<CategorieMerceologiche> listCatM = new List<CategorieMerceologiche>();
                if (!string.IsNullOrEmpty(categorieMerc))
                {
                    if (categorieMerc.Contains("###"))
                    {
                        string[] catAr = categorieMerc.Split(new string[] { "###" }, StringSplitOptions.None);
                        foreach (string cat in catAr)
                        {
                            if (!string.IsNullOrEmpty(cat))
                            {
                                CategorieMerceologiche c = new CategorieMerceologiche();
                                c.idTipologica = "categorieMerceologiche";
                                c.codice = "999"; //cat; //TODO???? non implementato!!!
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
                StrumentiSvolgimentoProcedure ss = new StrumentiSvolgimentoProcedure() { codice = dt.Rows[0]["strumentiSvolgimentoProcedure"].ToString(), idTipologica = "strumentiSvolgimentoProcedure" };
                appalto.strumentiSvolgimentoProcedure = ss;

                // pcp_ContrattiDisposizioniParticolari ??

                if (!string.IsNullOrEmpty(dt.Rows[0]["pcp_MotivoUrgenza"].ToString()))
                {
                    string cMotivo = dt.Rows[0]["pcp_MotivoUrgenza"].ToString();
                    if (!string.IsNullOrEmpty(cMotivo))
                    {
                        MotivoUrgenza m = new MotivoUrgenza();
                        m.idTipologica = "motivoUrgenza";
                        m.codice = cMotivo;
                        appalto.motivoUrgenza = m;
                    }
                }

                appalto.codiceAppalto = recuperaCodiceAppalto(idDoc);

                DatiBaseProceduraP2_16 dbaseProc = new DatiBaseProceduraP2_16();
                //dbaseProc.proceduraAccelerata = UtilsConvert.ToBool(dt.Rows[0]["proceduraAccelerata"].ToString());
                TipoProcedura t = new TipoProcedura();
                t.codice = dt.Rows[0]["tipoProcedura"] != null ? dt.Rows[0]["tipoProcedura"].ToString() : string.Empty; ; // TODO: SISTEMARE E RENDERE DINAMICO
                t.idTipologica = "tipoProcedura";
                dbaseProc.tipoProcedura = t;
                appalto.datiBaseProcedura = dbaseProc;

                DatiBase dba = new DatiBase();
                dba.oggetto = dt.Rows[0]["Oggetto"].ToString();
				
                //dba.importo = Convert.ToDouble(dt.Rows[0]["Importo"].ToString());
                
				dba.importo = UtilsConvert.ToDecimal( dt.Rows[0]["Importo"].ToString() );


				appalto.datiBase = dba;

                a.appalto = appalto;
                a.lotti = recuperaLottiP2_16(idDoc, appalto);
            }

            return a;
        }

        private List<LottiP2_16> recuperaLottiP2_16(int idDoc, AppaltoP2_16 appalto)
        {
            List<LottiP2_16> listaLotti = new List<LottiP2_16>();

            DataTable dt = new DataTable();

            AnacForm a = new AnacForm();
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql = "GET_DATI_SCHEDA_PCP_HEADER";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt1 = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt1);


            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            strSql = "GET_DATI_SCHEDA_PCP_DETAIL";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);

            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idDoc", idDoc);
            strSql = "Select DataScadenzaOfferta, Concessione, TipoBandoGara from document_bando with(nolock) where idHeader = @idDoc";
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSql;
            SqlDataAdapter da2 = new SqlDataAdapter();
            da2.SelectCommand = cmd;
            DataTable dt3 = new DataTable();
            da2.Fill(dt3);

            //cmd.Parameters.Clear();
            //cmd.Parameters.AddWithValue("idDoc", idDoc);
            //cmd.CommandType = CommandType.StoredProcedure;
            //cmd.CommandText = "GET_DATI_PCP_BASE_PROCEDURA";
            //conn.Open();
            //var result = cmd.ExecuteScalar();
            //if(result != null)
            //{
            //    dataTermineInvio 
            //}

            if (dt.Rows.Count > 0)
            {
                appalto.datiBaseProcedura.proceduraAccelerata = UtilsConvert.ToBool(dt.Rows[0]["proceduraAccelerata"].ToString());

                //MotivazioneCIG motivazione = new MotivazioneCIG();
                //motivazione.idTipologica = "motivazioneCIG";
                //motivazione.codice = dt.Rows[0]["MOTIVAZIONE_CIG"] != null ? dt.Rows[0]["MOTIVAZIONE_CIG"].ToString() : string.Empty;

                //appalto.motivazioneCig = motivazione;



                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    LottiP2_16 l = new LottiP2_16();

                    string numLotto = "0000" + dt.Rows[i]["NumeroLotto"].ToString();
                    l.lotIdentifier = "LOT-" + numLotto.Substring(numLotto.Length - 4);






                    List<CategorieMerceologiche> listCatM = new List<CategorieMerceologiche>();





                    string categorieM = recuperaCategorieMerceologiche(idDoc);

                    if (!String.IsNullOrEmpty(categorieM))
                    {

                        //string cat = dt.Rows[i]["pcp_Categoria"].ToString();
                        if (!string.IsNullOrEmpty(categorieM))
                        {
                            if (categorieM.Contains("###"))
                            {
                                string[] catAr = categorieM.Split(new string[] { "###" }, StringSplitOptions.None);
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



                    if (dt.Rows[i]["pcp_ContrattiDisposizioniParticolari"] != null && dt.Rows[i]["pcp_ContrattiDisposizioniParticolari"].ToString() != "")
                    {
                        ContrattiDisposizioniParticolari cd = new ContrattiDisposizioniParticolari();
                        cd.idTipologica = "contrattiDisposizioniParticolari";
                        cd.codice = dt.Rows[i]["pcp_ContrattiDisposizioniParticolari"].ToString();
                        l.contrattiDisposizioniParticolari = cd;
                    }

                    CodIstat istat = new CodIstat();
                    istat.idTipologica = "codIstat";
                    istat.codice = dt.Rows[i]["codIstat"].ToString();
                    l.codIstat = istat;

                    l.afferenteInvestimentiPNRR = dt.Rows[i]["afferenteInvestimentiPNRR"] != null && (!string.IsNullOrEmpty(dt.Rows[i]["afferenteInvestimentiPNRR"].ToString())) ? UtilsConvert.ToBool(dt.Rows[i]["afferenteInvestimentiPNRR"].ToString()) : false;

                    l.acquisizioneCup = UtilsConvert.ToBool(dt.Rows[i]["acquisizioneCup"].ToString());

                    List<string> cupLottoList = new List<string>();

                    if (dt.Rows[i]["CUP"] != null && !string.IsNullOrEmpty(dt.Rows[i]["CUP"].ToString()))
                    {
                        cupLottoList.Add(dt.Rows[i]["CUP"].ToString());
                    }

                    l.cupLotto = cupLottoList;


                    if (dt.Rows[i]["pcp_PrestazioniComprese"] != null)
                    {
                        string prestazioniComprese = dt.Rows[i]["pcp_PrestazioniComprese"].ToString();

                        prestazioniComprese p = new prestazioniComprese();
                        p.idTipologica = "prestazioniComprese";
                        p.codice = prestazioniComprese;

                        l.prestazioniComprese = p;
                    }


                    l.servizioPubblicoLocale = UtilsConvert.ToBool(dt.Rows[i]["pcp_ServizioPubblicoLocale"].ToString());
                    l.ripetizioniEConsegneComplementari = UtilsConvert.ToBool(dt.Rows[i]["ripetizioniEConsegneComplementari"].ToString());
                    l.lavoroOAcquistoPrevistoInProgrammazione = UtilsConvert.ToBool(dt.Rows[i]["pcp_lavoroOAcquistoPrevistoInProgrammazione"].ToString());



                    if (!string.IsNullOrEmpty(dt.Rows[i]["pcp_codiceCUI"].ToString()))
                    {
                        l.cui = dt.Rows[i]["pcp_codiceCUI"].ToString();
                    }
                    else
                    {
                        l.cui = null;
                    }


                    l.saNonSoggettaObblighi24Dicembre2015 = dt.Rows[i]["saNonSoggettaObblighi24Dicembre2015"] != null && !string.IsNullOrEmpty(dt.Rows[i]["saNonSoggettaObblighi24Dicembre2015"].ToString()) ? Convert.ToBoolean(dt.Rows[i]["saNonSoggettaObblighi24Dicembre2015"].ToString()) : false;
                    l.iniziativeNonSoddisfacenti = dt.Rows[i]["pcp_iniziativeNonSoddisfacenti"] != null && !string.IsNullOrEmpty(dt.Rows[i]["pcp_iniziativeNonSoddisfacenti"].ToString()) ? Convert.ToBoolean(dt.Rows[i]["pcp_iniziativeNonSoddisfacenti"].ToString()) : false;

                    l.ccnl = dt.Rows[i]["ccnl"].ToString();

                    List<TipologiaLavoro> tipoL = new List<TipologiaLavoro>();

                    if (dt.Rows[i]["pcp_TipologiaLavoro"] != null && (!string.IsNullOrEmpty(dt.Rows[i]["pcp_TipologiaLavoro"].ToString())))
                    {

                        string TipologieLavori = dt.Rows[i]["pcp_TipologiaLavoro"].ToString();

                        if (TipologieLavori.Contains("###"))
                        {
                            string[] TipLav = TipologieLavori.Split(new string[] { "###" }, StringSplitOptions.None);
                            foreach (string t in TipLav)
                            {
                                if (!string.IsNullOrEmpty(t))
                                {
                                    TipologiaLavoro tl = new TipologiaLavoro();

                                    tl.idTipologica = "tipologiaLavoro";
                                    tl.codice = t;

                                    tipoL.Add(tl);
                                }
                            }
                        }
                        else
                        {
                            TipologiaLavoro tl = new TipologiaLavoro();

                            tl.idTipologica = "tipologiaLavoro";
                            tl.codice = dt.Rows[i]["pcp_TipologiaLavoro"].ToString();

                            tipoL.Add(tl);
                        }


                    }

                    l.tipologiaLavoro = tipoL;

					IpotesiCollegamento ipotesiCollegamento = new IpotesiCollegamento();
					List<string> cigCollegato = new List<string>();
					cigCollegato.Add(dt.Rows[i]["pcp_cigCollegato"].ToString());
					ipotesiCollegamento.cigCollegato = cigCollegato;

                    ipotesiCollegamento.motivoCollegamento = new MotivoCollegamento() { idTipologica = "motivoCollegamento", codice = dt.Rows[i]["MOTIVO_COLLEGAMENTO"].ToString() };
                    l.ipotesiCollegamento = ipotesiCollegamento;


                    l.opzioniRinnovi = UtilsConvert.ToBool(dt.Rows[i]["opzioniRinnovi"].ToString());


                    string lCategoria = dt.Rows[i]["pcp_Categoria"].ToString();
                    if (!string.IsNullOrEmpty(lCategoria))
                    {
                        Categoria c = new Categoria() { codice = lCategoria, idTipologica = "categoria" };
                        l.categoria = c;
                    }


                    if (dt.Rows[i]["pcp_ModalitaAcquisizione"] != null && !string.IsNullOrEmpty(dt.Rows[i]["pcp_ModalitaAcquisizione"].ToString()))
                    {
                        ModalitaAcquisizione m = new ModalitaAcquisizione();
                        m.codice = dt.Rows[i]["pcp_ModalitaAcquisizione"].ToString();
                        m.idTipologica = "modalitaAcquisizione";
                        l.modalitaAcquisizione = m;
                    }



                    //QuadroEconomicoStandard qs = new QuadroEconomicoStandard();
                    QuadroEconomicoStandard quadroEconomicoStandard = new QuadroEconomicoStandard();

                    quadroEconomicoStandard.impLavori = UtilsConvert.ToDecimal(dt.Rows[i]["impLavori"]);
                    quadroEconomicoStandard.impServizi = UtilsConvert.ToDecimal(dt.Rows[i]["impServizi"]);
                    quadroEconomicoStandard.impForniture = UtilsConvert.ToDecimal(dt.Rows[i]["impForniture"]);



                    if (!string.IsNullOrEmpty(dt.Rows[i]["impTotaleSicurezza"].ToString()))
                    {
                        quadroEconomicoStandard.impTotaleSicurezza = UtilsConvert.ToDecimal(dt.Rows[i]["impTotaleSicurezza"].ToString());
                    }
                    else
                    {
                        quadroEconomicoStandard.impTotaleSicurezza = 0;
                    }

                    if (!string.IsNullOrEmpty(dt.Rows[i]["ulterioriSommeNoRibasso"].ToString()))
                    {
                        quadroEconomicoStandard.ulterioriSommeNoRibasso = UtilsConvert.ToDecimal(dt.Rows[i]["ulterioriSommeNoRibasso"].ToString());
                    }
                    else
                    {
                        quadroEconomicoStandard.ulterioriSommeNoRibasso = 0;
                    }

                    if (!string.IsNullOrEmpty(dt.Rows[i]["impProgettazione"].ToString()))
                    {
                        quadroEconomicoStandard.impProgettazione = UtilsConvert.ToDecimal(dt.Rows[i]["impProgettazione"].ToString());
                    }
                    else
                    {
                        quadroEconomicoStandard.impProgettazione = 0;
                    }

                    if (!string.IsNullOrEmpty(dt.Rows[i]["sommeOpzioniRinnovi"].ToString()))
                    {
                        quadroEconomicoStandard.sommeOpzioniRinnovi = UtilsConvert.ToDecimal(dt.Rows[i]["sommeOpzioniRinnovi"].ToString());
                    }
                    else
                    {
                        quadroEconomicoStandard.sommeOpzioniRinnovi = 0;
                    }

                    if (!string.IsNullOrEmpty(dt.Rows[i]["sommeRipetizioni"].ToString()))
                    {
                        quadroEconomicoStandard.sommeRipetizioni = UtilsConvert.ToDecimal(dt.Rows[i]["sommeRipetizioni"].ToString());
                    }
                    else
                    {
                        quadroEconomicoStandard.sommeRipetizioni = 0;
                    }

                    if (!string.IsNullOrEmpty(dt.Rows[i]["sommeADisposizione"].ToString()))
                    {
                        quadroEconomicoStandard.sommeADisposizione = UtilsConvert.ToDecimal(dt.Rows[i]["sommeADisposizione"].ToString());
                    }
                    else
                    {
                        quadroEconomicoStandard.sommeADisposizione = 0;
                    }


                    l.quadroEconomicoStandard = quadroEconomicoStandard;




                    //se non passato non lo aggiungo al json
                    if (!string.IsNullOrEmpty(dt.Rows[i]["StrumentiElettroniciSpecifici"].ToString()))
                    {
                        l.strumentiElettroniciSpecifici = UtilsConvert.ToBool(dt.Rows[i]["StrumentiElettroniciSpecifici"]);
                    }
                    else
                        l.strumentiElettroniciSpecifici = null;

                    decimal valorebase = 0;
                    valorebase = UtilsConvert.ToDecimal(dt.Rows[i]["ValoreBase"].ToString());
                    
                    DatiBaseP2_16 datiBase = new DatiBaseP2_16();
                    OggettoPrincipaleContratto ogg = new OggettoPrincipaleContratto();
                    ogg.idTipologica = "oggettoContratto";
                    ogg.codice = dt.Rows[i]["oggettoContratto"].ToString();
                    
                    datiBase.oggetto = dt1.Rows[0]["Oggetto"] != null ? dt1.Rows[0]["Oggetto"].ToString() : string.Empty;
                    datiBase.oggettoContratto = ogg;
                    datiBase.importo = valorebase;

                    l.datiBase = datiBase;

                    DatiBaseDocumenti dbaseDoc = new DatiBaseDocumenti();
                    dbaseDoc.url = dt1.Rows[0]["cn16_CallForTendersDocumentReference_ExternalRef"] != null ? dt1.Rows[0]["cn16_CallForTendersDocumentReference_ExternalRef"].ToString() : string.Empty;

                    l.datiBaseDocumenti = dbaseDoc;

                    DatiBaseCPVP2_16 datiBaseCPVP2 = new DatiBaseCPVP2_16();

                    TipoClassificazione tipoClassificazione = new TipoClassificazione();
                    tipoClassificazione.idTipologica = "tipoClassificazione";
                    tipoClassificazione.codice = "cpv";

                    datiBaseCPVP2.tipoClassificazione = tipoClassificazione;

                    l.datiBaseCPV = datiBaseCPVP2;

					//dalla versione 01.00.01 aggiungiamo sempre il campo datiBaseTerminiInvio che è diventato obbligatorio
					//se gara aperta valorizziamo oraScadenzaPresentazioneOfferte altrimenti scadenzaPresentazioneInvito
					//il ragionamento è fatto nella SP GET_DATI_SCHEDA_PCP_HEADER
					DatiBaseTerminiInvio2 datiBaseTerminiInvio = new DatiBaseTerminiInvio2();

                    if ( !string.IsNullOrEmpty(dt1.Rows[0]["scadenzaPresentazioneInvito"].ToString()) ) 
					{
                        datiBaseTerminiInvio.scadenzaPresentazioneInvito = Convert.ToDateTime(dt1.Rows[0]["oraScadenzaPresentazioneOfferte"].ToString());
					}
                    else
					{
						if (!string.IsNullOrEmpty(dt1.Rows[0]["oraScadenzaPresentazioneOfferte"].ToString()))
						{
                            datiBaseTerminiInvio.oraScadenzaPresentazioneOfferte = Convert.ToDateTime(dt1.Rows[0]["oraScadenzaPresentazioneOfferte"].ToString());
					    }
					}
					//};

					l.datiBaseTerminiInvio = datiBaseTerminiInvio;

					listaLotti.Add(l);
                }
            }

            return mergeLottiP2_16(listaLotti);
        }

        public AnacFormP7_1_2 recuperaAnacFormP7_1_2(int idDoc, Dati_PCP dati)
        {
            AnacFormP7_1_2 a = new AnacFormP7_1_2();
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql = "GET_DATI_SCHEDA_PCP_HEADER";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);

            //GET_DATI_SCHEDA_PCP_DETAIL
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql_2 = "GET_DATI_SCHEDA_PCP_DETAIL";
            cmd.CommandText = strSql_2;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt2 = new DataTable();
            SqlDataAdapter da2 = new SqlDataAdapter();
            da2.SelectCommand = cmd;
            da2.Fill(dt2);


            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idDoc", idDoc);
            strSql = "Select DataScadenzaOfferta, Concessione, TipoBandoGara from document_bando with(nolock) where idHeader = @idDoc";
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSql;
            SqlDataAdapter da1 = new SqlDataAdapter();
            da1.SelectCommand = cmd;
            DataTable dt3 = new DataTable();
            da1.Fill(dt3);

            int tipoGara = Convert.ToInt32(dt3.Rows[0]["TipoBandoGara"].ToString());

            List<FunzioniSvolte> fsvolte = new List<FunzioniSvolte>();
            List<StazioniAppaltanti> stazioni = new List<StazioniAppaltanti>();
            List<CategorieMerceologiche> catMerceologiche = new List<CategorieMerceologiche>();

            if (dt.Rows.Count > 0)
            {
                StazioniAppaltanti s = new StazioniAppaltanti();

                s.saTitolare = false;
                s.codiceCentroCosto = dt.Rows[0]["pcp_CodiceCentroDiCosto"].ToString();
                s.codiceAusa = dati.codiceAUSA;
                s.codiceFiscale = dati.cfSA.ToUpper().StartsWith("IT") ? dati.cfSA.Substring(2) : dati.cfSA;
                string funzioniSvolte = dt.Rows[0]["pcp_FunzioniSvolte"].ToString();

                if (!string.IsNullOrEmpty(funzioniSvolte))
                {
                    if (funzioniSvolte.Contains("###"))
                    {
                        string[] funzionalitaAr = funzioniSvolte.Split(new string[] { "###" }, StringSplitOptions.None);
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

                AppaltoP7_1_2 appalto = new AppaltoP7_1_2();

                DatiBaseP7_1_2 datiBase = new DatiBaseP7_1_2();
                datiBase.oggetto = dt.Rows[0]["Oggetto"].ToString();
                OggettoContratto oggettoContratto = new OggettoContratto();
                oggettoContratto.idTipologica = "oggettoContratto";
                oggettoContratto.codice = dt2.Rows[0]["oggettoContratto"].ToString();

                datiBase.oggettoContratto = oggettoContratto;
                datiBase.importo = UtilsConvert.ToDecimal(dt.Rows[0]["importo"].ToString());

                appalto.datiBase = datiBase;

                StrumentiSvolgimentoProcedure ss = new StrumentiSvolgimentoProcedure() { codice = "5", idTipologica = "strumentiSvolgimentoProcedure" };
                appalto.strumentiSvolgimentoProcedure = ss;

                string categorieMerc = string.Empty;
                categorieMerc = recupereCatMerceologica(idDoc);
                List<CategorieMerceologiche> listCatM = new List<CategorieMerceologiche>();
                if (!string.IsNullOrEmpty(categorieMerc))
                {
                    if (categorieMerc.Contains("###"))
                    {
                        string[] catAr = categorieMerc.Split(new string[] { "###" }, StringSplitOptions.None);
                        foreach (string cat in catAr)
                        {
                            if (!string.IsNullOrEmpty(cat))
                            {
                                CategorieMerceologiche c = new CategorieMerceologiche();
                                c.idTipologica = "categorieMerceologiche";
                                c.codice = "999"; //cat; //TODO???? non implementato!!!
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

                appalto.codiceAppalto = recuperaCodiceAppalto(idDoc);

                //DatiBase datiBase = new DatiBase();
                //datiBase.oggetto = dt.Rows[0]["Oggetto"] != null ? dt.Rows[0]["Oggetto"].ToString() : string.Empty; // TODO: verificare con Maria Chiara
                ////appalto.datiBase = datiBase;

                DatiBaseProcedura dbaseProc = new DatiBaseProcedura();
                TipoProcedura t = new TipoProcedura();
                t.codice = dt.Rows[0]["tipoProcedura"] != null ? dt.Rows[0]["tipoProcedura"].ToString() : string.Empty; ; // TODO: SISTEMARE E RENDERE DINAMICO
                t.idTipologica = "tipoProcedura";
                dbaseProc.tipoProcedura = t;
                //dbaseProc.tipoProcedura.codice = "Procedura di Gara";
                //dbaseProc.tipoProcedura.idTipologica = dt.Rows[0]["tipoProcedura"] != null ? dt.Rows[0]["tipoProcedura"].ToString() : string.Empty;
                appalto.datiBaseProcedura = dbaseProc;
                if (!string.IsNullOrEmpty(dt.Rows[0]["pcp_MotivoUrgenza"].ToString()))
                {
                    MotivoUrgenza m = new MotivoUrgenza();
                    m.idTipologica = "motivoUrgenza";
                    m.codice = dt2.Rows[0]["pcp_MotivoUrgenza"] != null ? dt2.Rows[0]["pcp_MotivoUrgenza"].ToString() : string.Empty;
                    appalto.motivoUrgenza = m;
                }
                else
                {
                    appalto.motivoUrgenza = null;
                }

                TipoProcedura motivazioneCig = new TipoProcedura();
                motivazioneCig.idTipologica = "motivazioneCIG";
                motivazioneCig.codice = dt2.Rows[0]["MOTIVAZIONE_CIG"] != null ? dt2.Rows[0]["MOTIVAZIONE_CIG"].ToString() : string.Empty; ;

                appalto.motivazioneCIG = motivazioneCig;

                a.lotti = recuperaLottiP7_1_2(idDoc);
                a.appalto = appalto;




                //#region QuadroEconomicoStandard AD2_25
                //QuadroEconomicoStandard qs = new QuadroEconomicoStandard();
                //if (!string.IsNullOrEmpty(dt2.Rows[0]["UlterioriSommeNoRibasso"].ToString()))
                //{
                //    qs.ulterioriSommeNoRibasso = UtilsConvert.ToDecimal(dt2.Rows[0]["UlterioriSommeNoRibasso"].ToString());
                //}
                //else
                //{
                //    qs.ulterioriSommeNoRibasso = 0;
                //}
                //qs.impForniture = 0;
                //qs.impServizi = 0;
                //qs.impLavori = 0;
                //qs.sommeOpzioniRinnovi = 0;
                //if (!string.IsNullOrEmpty(dt2.Rows[0]["sommeOpzioniRinnovi"].ToString()))
                //{
                //    qs.sommeOpzioniRinnovi = UtilsConvert.ToDecimal(dt2.Rows[0]["sommeOpzioniRinnovi"].ToString());
                //}
                //else
                //{
                //    qs.sommeOpzioniRinnovi = 0;
                //}

                //if (!string.IsNullOrEmpty(dt2.Rows[0]["sommeADisposizione"].ToString()))
                //{
                //    qs.sommeADisposizione = UtilsConvert.ToDecimal(dt2.Rows[0]["sommeADisposizione"].ToString());
                //}
                //else
                //{
                //    qs.sommeADisposizione = 0;
                //}


                //qs.impProgettazione = 0;
                //qs.impTotaleSicurezza = 0;
                //if (!string.IsNullOrEmpty(dt2.Rows[0]["sommeRipetizioni"].ToString()))
                //{
                //    qs.sommeRipetizioni = UtilsConvert.ToDecimal(dt2.Rows[0]["sommeRipetizioni"].ToString());
                //}
                //else
                //{
                //    qs.sommeRipetizioni = 0;
                //}



                //int tipoBandoGara = Convert.ToInt32(dt2.Rows[0]["TipoBandoGara"].ToString());
                //decimal valorebase = 0;
                //if (!string.IsNullOrEmpty(dt2.Rows[0]["ValoreBase"].ToString()))
                //{
                //    valorebase = UtilsConvert.ToDecimal(dt2.Rows[0]["ValoreBase"].ToString());
                //}
                //if (tipoBandoGara == 2)
                //{
                //    qs.impLavori = valorebase;
                //}
                //else if (tipoBandoGara == 3)
                //{
                //    qs.impServizi = valorebase;
                //}
                //if (dt2.Rows[0]["ImportoSicurezza"] != null)
                //{
                //    string importo = dt2.Rows[0]["ImportoSicurezza"].ToString();
                //    if (!string.IsNullOrEmpty(importo))
                //    {
                //        qs.impForniture = UtilsConvert.ToDecimal(dt2.Rows[0]["ImportoSicurezza"].ToString());
                //    }
                //}
                //#endregion

                //DatiBaseAD2_25 datiBase1 = new DatiBaseAD2_25();
                //datiBase1.oggetto = dt.Rows[0]["Oggetto"] != null ? dt.Rows[0]["Oggetto"].ToString() : string.Empty; //TODO: Body da tab Testata?
                //Categoria cat5 = new Categoria();
                //cat5.idTipologica = "oggettoContratto";
                //cat5.codice = oggettoContratto;
                //datiBase1.oggettoContratto = cat5;
                //lotto.datiBase = datiBase1;

                ////DatiBaseAggiudicazioneAppalto datiBaseAggiudicazioneAppalto = new DatiBaseAggiudicazioneAppalto();
                ////datiBaseAggiudicazioneAppalto.dataAggiudicazione = dataAggiudicazione;
                ////lotto.datiBaseAggiudicazioneAppalto = datiBaseAggiudicazioneAppalto;

                //a.lotti = lotti;
                a.appalto = appalto;
            }

            return a;
        }

        public AnacFormP7_1_3 recuperaAnacFormP7_1_3(int idDoc, Dati_PCP dati)
        {
            AnacFormP7_1_3 p7_1_3 = new AnacFormP7_1_3();
            AnacFormP7_1_2 p7_1_2 = recuperaAnacFormP7_1_2(idDoc, dati);

            p7_1_3.appalto = p7_1_2.appalto;
            p7_1_3.stazioniAppaltanti = p7_1_2.stazioniAppaltanti;

            DataTable dt = new DataTable();

            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql = "GET_DATI_SCHEDA_PCP_DETAIL";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);

            List<LottiP7_1_3> lotti = new List<LottiP7_1_3>();

            foreach (DataRow dr in dt.Rows)
            {
                string numLotto = "0000" + dr["NumeroLotto"].ToString();
                var lotIdentifier = "LOT-" + numLotto.Substring(numLotto.Length - 4);

                var lottoP7_1_2 = p7_1_2.lotti.Find(x => x.lotIdentifier == lotIdentifier);


                if (lottoP7_1_2 != null)
                {
                    LottiP7_1_3 lottoP7_1_3 = new LottiP7_1_3()
                    {
                        lotIdentifier = lottoP7_1_2.lotIdentifier,
                        categorieMerceologiche = lottoP7_1_2.categorieMerceologiche,
                        saNonSoggettaObblighi24Dicembre2015 = lottoP7_1_2.saNonSoggettaObblighi24Dicembre2015,
                        iniziativeNonSoddisfacenti = lottoP7_1_2.iniziativeNonSoddisfacenti,
                        condizioniNegoziata = lottoP7_1_2.condizioniNegoziata,
                        contrattiDisposizioniParticolari = lottoP7_1_2.contrattiDisposizioniParticolari,
                        codIstat = lottoP7_1_2.codIstat,
                        servizioPubblicoLocale = lottoP7_1_2.servizioPubblicoLocale,
                        lavoroOAcquistoPrevistoInProgrammazione = lottoP7_1_2.lavoroOAcquistoPrevistoInProgrammazione,
                        cui = lottoP7_1_2.cui,
                        ripetizioniEConsegneComplementari = lottoP7_1_2.ripetizioniEConsegneComplementari,
                        ipotesiCollegamento = lottoP7_1_2.ipotesiCollegamento,
                        opzioniRinnovi = lottoP7_1_2.opzioniRinnovi,
                        afferenteInvestimentiPNRR = lottoP7_1_2.afferenteInvestimentiPNRR,
                        acquisizioneCup = lottoP7_1_2.acquisizioneCup,
                        cupLotto = lottoP7_1_2.cupLotto,
                        ccnl = lottoP7_1_2.ccnl,
                        modalitaAcquisizione = lottoP7_1_2.modalitaAcquisizione,
                        categoria = lottoP7_1_2.categoria,
                        prestazioniComprese = lottoP7_1_2.prestazioniComprese,
                        finanziamenti = lottoP7_1_2.finanziamenti,
                        tipoRealizzazione = lottoP7_1_2.tipoRealizzazione,
                        datiBase = lottoP7_1_2.datiBase,
                        quadroEconomicoStandard = lottoP7_1_2.quadroEconomicoStandard,
                        
                        //commentato perchè mai esistito era stato introdotto errato
                        //datiBaseTermineInvio = lottoP7_1_2.datiBaseTermineInvio,
                        datiBaseTerminiInvio = lottoP7_1_2.datiBaseTerminiInvio,

						datiBaseDocumenti = lottoP7_1_2.datiBaseDocumenti,

					};

                    if (!string.IsNullOrEmpty(dr["StrumentiElettroniciSpecifici"].ToString()))
                    {
                        lottoP7_1_3.strumentiElettroniciSpecifici = Convert.ToBoolean(dr["StrumentiElettroniciSpecifici"].ToString());
                    }


					

					lotti.Add(lottoP7_1_3);
                }
            }

            p7_1_3.lotti = lotti;

            return p7_1_3;
        }

        public AnacFormAD2_25 recuperaAnacFormAD2_25(int idDoc, Dati_PCP dati)
        {
            AnacFormAD2_25 a = new AnacFormAD2_25();

            //GET_DATI_SCHEDA_PCP_HEADER
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql = "GET_DATI_SCHEDA_PCP_HEADER";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);

            //GET_DATI_SCHEDA_PCP_DETAIL
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql_2 = "GET_DATI_SCHEDA_PCP_DETAIL";
            cmd.CommandText = strSql_2;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt2 = new DataTable();
            SqlDataAdapter da2 = new SqlDataAdapter();
            da2.SelectCommand = cmd;
            da2.Fill(dt2);

            //GET_DATI_SCHEDA_PCP_PARTECIPANTI
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql_3 = "GET_DATI_SCHEDA_PCP_PARTECIPANTI";
            cmd.CommandText = strSql_3;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt3 = new DataTable();
            SqlDataAdapter da3 = new SqlDataAdapter();
            da3.SelectCommand = cmd;
            da3.Fill(dt3);

            List<FunzioniSvolte> fsvolte = new List<FunzioniSvolte>();
            List<StazioniAppaltanti> stazioni = new List<StazioniAppaltanti>();
            List<CategorieMerceologiche> catMerceologiche = new List<CategorieMerceologiche>();

            if (dt.Rows.Count > 0)
            {
                StazioniAppaltanti s = new StazioniAppaltanti();

                s.saTitolare = false;
                s.codiceCentroCosto = dt.Rows[0]["pcp_CodiceCentroDiCosto"].ToString();
                s.codiceAusa = dati.codiceAUSA;
                s.codiceFiscale = dati.cfSA.ToUpper().StartsWith("IT") ? dati.cfSA.Substring(2) : dati.cfSA;
                string funzioniSvolte = dt.Rows[0]["pcp_FunzioniSvolte"].ToString();

                if (!string.IsNullOrEmpty(funzioniSvolte))
                {
                    if (funzioniSvolte.Contains("###"))
                    {
                        string[] funzionalitaAr = funzioniSvolte.Split(new string[] { "###" }, StringSplitOptions.None);
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

                AppaltoAD2_25 appalto = new AppaltoAD2_25();

                appalto.linkDocumenti = dt.Rows[0]["pcp_LinkDocumenti"] != null ? dt.Rows[0]["pcp_LinkDocumenti"].ToString() : string.Empty;


                appalto.relazioneUnicaSulleProcedure = dt.Rows[0]["pcp_relazioneUnicaSulleProcedure"] != null && (!string.IsNullOrEmpty(dt.Rows[0]["pcp_relazioneUnicaSulleProcedure"].ToString())) ? Convert.ToBoolean(dt.Rows[0]["pcp_relazioneUnicaSulleProcedure"].ToString()) : false;
                appalto.opereUrbanizzazioneScomputo = dt.Rows[0]["W9APOUSCOMP"] != null && (!string.IsNullOrEmpty(dt.Rows[0]["W9APOUSCOMP"].ToString())) ? Convert.ToBoolean(dt.Rows[0]["W9APOUSCOMP"].ToString()) : false;

                appalto.codiceAppalto = recuperaCodiceAppalto(idDoc);

                DatiBase datiBase = new DatiBase();
                datiBase.oggetto = dt.Rows[0]["Oggetto"] != null ? dt.Rows[0]["Oggetto"].ToString() : string.Empty; // TODO: verificare con Maria Chiara
                appalto.datiBase = datiBase;
                DatiBaseProcedura dbaseProc = new DatiBaseProcedura();
                TipoProcedura t = new TipoProcedura();
                t.codice = dt.Rows[0]["tipoProcedura"] != null ? dt.Rows[0]["tipoProcedura"].ToString() : string.Empty; ; // TODO: SISTEMARE E RENDERE DINAMICO
                t.idTipologica = "tipoProcedura";
                dbaseProc.tipoProcedura = t;
                //dbaseProc.tipoProcedura.codice = "Procedura di Gara";
                //dbaseProc.tipoProcedura.idTipologica = dt.Rows[0]["tipoProcedura"] != null ? dt.Rows[0]["tipoProcedura"].ToString() : string.Empty;
                appalto.datiBaseProcedura = dbaseProc;
                MotivoUrgenza m = new MotivoUrgenza();
                m.idTipologica = "motivoUrgenza";
                m.codice = dt.Rows[0]["pcp_MotivoUrgenza"] != null ? dt.Rows[0]["pcp_MotivoUrgenza"].ToString() : string.Empty;
                appalto.motivoUrgenza = m;


				List<AggiudicazioneAD2_25Type> aggiudicazioni = new List<AggiudicazioneAD2_25Type>();

				for (int j = 0; j < dt2.Rows.Count; j++)
				{

                    AggiudicazioneAD2_25Type aggiudicazioneAD2_25Type = new AggiudicazioneAD2_25Type();
               
                    aggiudicazioneAD2_25Type.lotIdentifier = dt2.Rows[j]["lotIdentifier"].ToString();

                    List<string> cupLottoList = new List<string>();

                    if (dt2.Rows[j]["CUP"] != null && !string.IsNullOrEmpty(dt2.Rows[j]["CUP"].ToString()))
                    {
                        cupLottoList.Add(dt2.Rows[j]["CUP"].ToString());
                    }

                    aggiudicazioneAD2_25Type.cupLotto = cupLottoList;


                    aggiudicazioneAD2_25Type.ccnl = dt2.Rows[j]["ccnl"].ToString();
                    Categoria cat2 = new Categoria();
                    cat2.idTipologica = "categoria";
                    cat2.codice = dt2.Rows[j]["pcp_Categoria"].ToString();
                    aggiudicazioneAD2_25Type.categoria = cat2;
                    CodIstat istat = new CodIstat();
                    istat.idTipologica = "codIstat";
                    istat.codice = dt2.Rows[j]["codIstat"].ToString();
                    aggiudicazioneAD2_25Type.codIstat = istat;
                    aggiudicazioneAD2_25Type.afferenteInvestimentiPNRR = false;
                    aggiudicazioneAD2_25Type.ccnl = "non applicabile";

                   

                    #region QuadroEconomicoStandard AD2_25
                    QuadroEconomicoStandard qs = new QuadroEconomicoStandard();
                    if (!string.IsNullOrEmpty(dt2.Rows[j]["UlterioriSommeNoRibasso"].ToString()))
                    {
                        qs.ulterioriSommeNoRibasso = UtilsConvert.ToDecimal(dt2.Rows[j]["UlterioriSommeNoRibasso"].ToString());
                    }
                    else
                    {
                        qs.ulterioriSommeNoRibasso = 0;
                    }

                    //qs.impForniture = 0;
                    //qs.impServizi = 0;
                    //qs.impLavori = 0;

                    qs.sommeOpzioniRinnovi = 0;
                    if (!string.IsNullOrEmpty(dt2.Rows[j]["sommeOpzioniRinnovi"].ToString()))
                    {
                        qs.sommeOpzioniRinnovi = UtilsConvert.ToDecimal(dt2.Rows[j]["sommeOpzioniRinnovi"].ToString());
                    }
                    else
                    {
                        qs.sommeOpzioniRinnovi = 0;
                    }

                    if (!string.IsNullOrEmpty(dt2.Rows[j]["sommeADisposizione"].ToString()))
                    {
                        qs.sommeADisposizione = UtilsConvert.ToDecimal(dt2.Rows[j]["sommeADisposizione"].ToString());
                    }
                    else
                    {
                        qs.sommeADisposizione = 0;
                    }


                    //qs.impProgettazione = 0;

                    if (!string.IsNullOrEmpty(dt2.Rows[j]["impProgettazione"].ToString()))
                    {
                        qs.impProgettazione = UtilsConvert.ToDecimal(dt2.Rows[j]["impProgettazione"].ToString());
                    }
                    else
                    {
                        qs.impProgettazione = 0;
                    }


                    //qs.impTotaleSicurezza = 0;

                    if (!string.IsNullOrEmpty(dt2.Rows[j]["impTotaleSicurezza"].ToString()))
                    {
                        qs.impTotaleSicurezza = UtilsConvert.ToDecimal(dt2.Rows[j]["impTotaleSicurezza"].ToString());
                    }
                    else
                    {
                        qs.impTotaleSicurezza = 0;
                    }

                    if (!string.IsNullOrEmpty(dt2.Rows[j]["sommeRipetizioni"].ToString()))
                    {
                        qs.sommeRipetizioni = UtilsConvert.ToDecimal(dt2.Rows[j]["sommeRipetizioni"].ToString());
                    }
                    else
                    {
                        qs.sommeRipetizioni = 0;
                    }

                    qs.impLavori = UtilsConvert.ToDecimal(dt2.Rows[j]["impLavori"].ToString());
                    qs.impServizi = UtilsConvert.ToDecimal(dt2.Rows[j]["impServizi"].ToString());
                    qs.impForniture = UtilsConvert.ToDecimal(dt2.Rows[j]["impForniture"].ToString());

                    /*
                    int tipoBandoGara = Convert.ToInt32(dt2.Rows[0]["TipoBandoGara"].ToString());
                    decimal valorebase = 0;
                    if (!string.IsNullOrEmpty(dt2.Rows[0]["ValoreBase"].ToString()))
                    {
                        valorebase = UtilsConvert.ToDecimal(dt2.Rows[0]["ValoreBase"].ToString());
                    }
                    if (tipoBandoGara == 2)
                    {
                        qs.impLavori = valorebase;
                    }
                    else if (tipoBandoGara == 3)
                    {
                        qs.impServizi = valorebase;
                    }
                    if (dt2.Rows[0]["ImportoSicurezza"] != null)
                    {
                        string importo = dt2.Rows[0]["ImportoSicurezza"].ToString();
                        if (!string.IsNullOrEmpty(importo))
                        {
                            qs.impForniture = UtilsConvert.ToDecimal(dt2.Rows[0]["ImportoSicurezza"].ToString());
                        }
                    }
                    */

                    #endregion

                    aggiudicazioneAD2_25Type.quadroEconomicoStandard = qs;
                    List<PartecipanteAD2_25> partecipantiAD2_25 = new List<PartecipanteAD2_25>();
                    string dataAggiudicazione = "";
                    string oggettoContratto = "";
                    for (int i = 0; i < dt3.Rows.Count; i++)
                    {

						if (dt2.Rows[j]["NumeroLotto"].ToString() == dt3.Rows[i]["NumeroLotto"].ToString())
						{
							PartecipanteAD2_25 partecipanteAD2_25 = new PartecipanteAD2_25();
                            partecipanteAD2_25.codiceFiscale = dt3.Rows[i]["codiceFiscale"].ToString();
                            partecipanteAD2_25.denominazione = dt3.Rows[i]["Denominazione"].ToString();
                            Categoria cat3 = new Categoria();
                            cat3.idTipologica = "ruoloOE";
                            cat3.codice = dt3.Rows[i]["ruoloOE"].ToString();
                            partecipanteAD2_25.ruoloOE = cat3;
                            Categoria cat4 = new Categoria();
                            cat4.idTipologica = "tipoOE";
                            cat4.codice = dt3.Rows[i]["tipoOE"].ToString();
                            partecipanteAD2_25.tipoOE = cat4;
                            partecipanteAD2_25.idPartecipante = dt3.Rows[i]["idPartecipante"].ToString();
                            partecipanteAD2_25.paeseOperatoreEconomico = dt3.Rows[i]["paeseOperatoreEconomico"].ToString();
                            partecipanteAD2_25.avvalimento = dt3.Rows[i]["paeseOperatoreEconomico"].ToString() == "1";
                            partecipanteAD2_25.importo = UtilsConvert.ToDecimal(dt3.Rows[i]["importo"].ToString());
                            dataAggiudicazione = dt3.Rows[i]["dataAggiudicazione"].ToString();
                            oggettoContratto = dt3.Rows[i]["oggettoContratto"].ToString();
                            partecipantiAD2_25.Add(partecipanteAD2_25);
						}

					}

                    aggiudicazioneAD2_25Type.partecipanti = partecipantiAD2_25;

                    DatiBaseAD2_25 datiBase1 = new DatiBaseAD2_25();
                    datiBase1.oggetto = dt.Rows[0]["Oggetto"] != null ? dt.Rows[0]["Oggetto"].ToString() : string.Empty; //TODO: Body da tab Testata?
                    Categoria cat5 = new Categoria();
                    cat5.idTipologica = "oggettoContratto";
                    cat5.codice = oggettoContratto;
                    datiBase1.oggettoContratto = cat5;
                    aggiudicazioneAD2_25Type.datiBase = datiBase1;

                    DatiBaseAggiudicazioneAppalto datiBaseAggiudicazioneAppalto = new DatiBaseAggiudicazioneAppalto();
                    datiBaseAggiudicazioneAppalto.dataAggiudicazione = dataAggiudicazione;
                    aggiudicazioneAD2_25Type.datiBaseAggiudicazioneAppalto = datiBaseAggiudicazioneAppalto;


					//se valorizzato (nuova versione dalla '2024_01_31') aggiungo datiBaseDocumenti.url
					if (!string.IsNullOrEmpty(dt.Rows[0]["datiBaseDocumenti_url"].ToString()))
					{
						DatiBaseDocumenti dbaseDoc = new DatiBaseDocumenti();
						dbaseDoc.url = dt.Rows[0]["datiBaseDocumenti_url"].ToString();

						aggiudicazioneAD2_25Type.datiBaseDocumenti = dbaseDoc;
					}

					aggiudicazioni.Add(aggiudicazioneAD2_25Type);

				}

				a.aggiudicazioni = aggiudicazioni;
				a.appalto = appalto;

            }

            return a;
        }
        public AnacFormAD3 recuperaAnacFormAD3(int idDoc, Dati_PCP dati)
        {

            AnacFormAD3 a = new AnacFormAD3();

            //GET_DATI_SCHEDA_PCP_HEADER
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql = "GET_DATI_SCHEDA_PCP_HEADER";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);

            //GET_DATI_SCHEDA_PCP_DETAIL
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql_2 = "GET_DATI_SCHEDA_PCP_DETAIL";
            cmd.CommandText = strSql_2;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt2 = new DataTable();
            SqlDataAdapter da2 = new SqlDataAdapter();
            da2.SelectCommand = cmd;
            da2.Fill(dt2);

            //GET_DATI_SCHEDA_PCP_PARTECIPANTI
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql_3 = "GET_DATI_SCHEDA_PCP_PARTECIPANTI";
            cmd.CommandText = strSql_3;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt3 = new DataTable();
            SqlDataAdapter da3 = new SqlDataAdapter();
            da3.SelectCommand = cmd;
            da3.Fill(dt3);



            List<FunzioniSvolte> fsvolte = new List<FunzioniSvolte>();
            List<StazioniAppaltanti> stazioni = new List<StazioniAppaltanti>();
            List<CategorieMerceologiche> catMerceologiche = new List<CategorieMerceologiche>();
            if (dt.Rows.Count > 0)
            {
                StazioniAppaltanti s = new StazioniAppaltanti();

                s.saTitolare = false;
                s.codiceCentroCosto = dt.Rows[0]["pcp_CodiceCentroDiCosto"].ToString();
                s.codiceAusa = dati.codiceAUSA;
                s.codiceFiscale = dati.cfSA.ToUpper().StartsWith("IT") ? dati.cfSA.Substring(2) : dati.cfSA;
                string funzioniSvolte = dt.Rows[0]["pcp_FunzioniSvolte"].ToString();

                if (!string.IsNullOrEmpty(funzioniSvolte))
                {
                    if (funzioniSvolte.Contains("###"))
                    {
                        string[] funzionalitaAr = funzioniSvolte.Split(new string[] { "###" }, StringSplitOptions.None);
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
                AppaltoAD3 appalto = new AppaltoAD3();
                string categorieMerc = string.Empty;
                categorieMerc = recupereCatMerceologica(idDoc);
                List<CategorieMerceologiche> listCatM = new List<CategorieMerceologiche>();
                if (!string.IsNullOrEmpty(categorieMerc))
                {
                    if (categorieMerc.Contains("###"))
                    {
                        string[] catAr = categorieMerc.Split(new string[] { "###" }, StringSplitOptions.None);
                        foreach (string cat in catAr)
                        {
                            if (!string.IsNullOrEmpty(cat))
                            {
                                CategorieMerceologiche c = new CategorieMerceologiche();
                                c.idTipologica = "categorieMerceologiche";
                                c.codice = "999"; //cat; //TODO???? non implementato!!!
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


                if (dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"] != null && dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"].ToString() != "")
                {
                    ContrattiDisposizioniParticolari cd = new ContrattiDisposizioniParticolari();
                    cd.idTipologica = "contrattiDisposizioniParticolari";
                    cd.codice = dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"].ToString();
                    appalto.contrattiDisposizioniParticolari = cd;
                }

                //if (dt.Rows[0]["pcp_MotivoUrgenza"] != null)
                if (!string.IsNullOrEmpty(dt.Rows[0]["pcp_MotivoUrgenza"].ToString()))
                {
                    string cMotivo = dt.Rows[0]["pcp_MotivoUrgenza"].ToString();
                    if (!string.IsNullOrEmpty(cMotivo))
                    {
                        MotivoUrgenza m = new MotivoUrgenza();
                        m.idTipologica = "motivoUrgenza";
                        m.codice = cMotivo;
                        appalto.motivoUrgenza = m;
                    }
                }

                appalto.codiceAppalto = recuperaCodiceAppalto(idDoc);

                DatiBase datiBase = new DatiBase();
                datiBase.oggetto = dt.Rows[0]["Oggetto"].ToString();

                appalto.datiBase = datiBase;

				List<AggiudicazioneAD3Type> aggiudicazioni = new List<AggiudicazioneAD3Type>();

				for (int j = 0; j < dt2.Rows.Count; j++)
				{

					AggiudicazioneAD3Type aggiudicazioneAD3Type = new AggiudicazioneAD3Type();
                    aggiudicazioneAD3Type.lotIdentifier = dt2.Rows[j]["lotIdentifier"].ToString();
                    List<string> cupLottoList = new List<string>();

                    if (dt2.Rows[j]["CUP"] != null && !string.IsNullOrEmpty(dt2.Rows[j]["CUP"].ToString()))
                    {
                        cupLottoList.Add(dt2.Rows[j]["CUP"].ToString());
                    }

                    aggiudicazioneAD3Type.cupLotto = cupLottoList;
                    aggiudicazioneAD3Type.ccnl = dt2.Rows[j]["ccnl"].ToString();
                    Categoria cat2 = new Categoria();
                    cat2.idTipologica = "categoria";
                    cat2.codice = dt2.Rows[j]["pcp_Categoria"].ToString();
                    aggiudicazioneAD3Type.categoria = cat2;
                    CodIstat istat = new CodIstat();
                    istat.idTipologica = "codIstat";
                    istat.codice = dt2.Rows[j]["codIstat"].ToString();
                    aggiudicazioneAD3Type.codIstat = istat;

                    #region QuadroEconomicoStandard AD3
                    QuadroEconomicoStandard qs = new QuadroEconomicoStandard();
                    if (!string.IsNullOrEmpty(dt2.Rows[j]["UlterioriSommeNoRibasso"].ToString()))
                    {
                        qs.ulterioriSommeNoRibasso = UtilsConvert.ToDecimal(dt2.Rows[j]["UlterioriSommeNoRibasso"].ToString());
                    }
                    else
                    {
                        qs.ulterioriSommeNoRibasso = 0;
                    }
                    qs.impForniture = 0;
                    qs.impServizi = 0;
                    qs.impLavori = 0;
                    qs.sommeOpzioniRinnovi = 0;
                    if (!string.IsNullOrEmpty(dt2.Rows[j]["sommeOpzioniRinnovi"].ToString()))
                    {
                        qs.sommeOpzioniRinnovi = UtilsConvert.ToDecimal(dt2.Rows[j]["sommeOpzioniRinnovi"].ToString());
                    }
                    else
                    {
                        qs.sommeOpzioniRinnovi = 0;
                    }

                    if (!string.IsNullOrEmpty(dt2.Rows[j]["sommeADisposizione"].ToString()))
                    {
                        qs.sommeADisposizione = UtilsConvert.ToDecimal(dt2.Rows[j]["sommeADisposizione"].ToString());
                    }
                    else
                    {
                        qs.sommeADisposizione = 0;
                    }


                    //qs.impProgettazione = 0;
                    if (!string.IsNullOrEmpty(dt2.Rows[j]["impProgettazione"].ToString()))
                    {
                        qs.impProgettazione = UtilsConvert.ToDecimal(dt2.Rows[j]["impProgettazione"].ToString());
                    }
                    else
                    {
                        qs.impProgettazione = 0;
                    }


                    qs.impTotaleSicurezza = 0;
                    if (!string.IsNullOrEmpty(dt2.Rows[j]["sommeRipetizioni"].ToString()))
                    {
                        qs.sommeRipetizioni = UtilsConvert.ToDecimal(dt2.Rows[j]["sommeRipetizioni"].ToString());
                    }
                    else
                    {
                        qs.sommeRipetizioni = 0;
                    }

                    qs.impLavori = UtilsConvert.ToDecimal(dt2.Rows[j]["impLavori"].ToString());
                    qs.impServizi = UtilsConvert.ToDecimal(dt2.Rows[j]["impServizi"].ToString());
                    qs.impForniture = UtilsConvert.ToDecimal(dt2.Rows[j]["impForniture"].ToString());

                    #endregion
                    aggiudicazioneAD3Type.quadroEconomicoStandard = qs;
                    List<PartecipanteAD3> partecipanteAD3s = new List<PartecipanteAD3>();
                    string dataAggiudicazione = "";
                    string oggettoContratto = "";
                    for (int i = 0; i < dt3.Rows.Count; i++)
                    {
						if (dt2.Rows[j]["NumeroLotto"].ToString() == dt3.Rows[i]["NumeroLotto"].ToString())
						{
							PartecipanteAD3 partecipanteAD3 = new PartecipanteAD3();
                            partecipanteAD3.codiceFiscale = dt3.Rows[i]["codiceFiscale"].ToString();
                            partecipanteAD3.denominazione = dt3.Rows[i]["Denominazione"].ToString();
                            Categoria cat3 = new Categoria();
                            cat3.idTipologica = "ruoloOE";
                            cat3.codice = dt3.Rows[i]["ruoloOE"].ToString();
                            partecipanteAD3.ruoloOE = cat3;
                            Categoria cat4 = new Categoria();
                            cat4.idTipologica = "tipoOE";
                            cat4.codice = dt3.Rows[i]["tipoOE"].ToString();
                            partecipanteAD3.tipoOE = cat4;
                            partecipanteAD3.idPartecipante = dt3.Rows[i]["idPartecipante"].ToString();
                            partecipanteAD3.paeseOperatoreEconomico = dt3.Rows[i]["paeseOperatoreEconomico"].ToString();
                            partecipanteAD3.avvalimento = dt3.Rows[i]["paeseOperatoreEconomico"].ToString() == "1";
                            partecipanteAD3.importo = UtilsConvert.ToDecimal(dt3.Rows[i]["importo"].ToString());
                            dataAggiudicazione = dt3.Rows[i]["dataAggiudicazione"].ToString();
                            oggettoContratto = dt3.Rows[i]["oggettoContratto"].ToString();
                            partecipanteAD3s.Add(partecipanteAD3);
						}
					}
                    aggiudicazioneAD3Type.partecipanti = partecipanteAD3s;

                    DatiBaseAD3 datiBase1 = new DatiBaseAD3();
                    datiBase1.oggetto = dt.Rows[0]["Oggetto"].ToString();
                    Categoria cat5 = new Categoria();
                    cat5.idTipologica = "oggettoContratto";
                    cat5.codice = oggettoContratto;
                    datiBase1.oggettoContratto = cat5;
                    aggiudicazioneAD3Type.datiBase = datiBase1;
                    DatiBaseAggiudicazioneAppaltoAD3 datiBaseAggiudicazioneAppaltoAD3 = new DatiBaseAggiudicazioneAppaltoAD3();
                    datiBaseAggiudicazioneAppaltoAD3.dataAggiudicazione = dataAggiudicazione;
                    aggiudicazioneAD3Type.datiBaseAggiudicazioneAppalto = datiBaseAggiudicazioneAppaltoAD3;

					//se valorizzato (nuova versione dalla '2024_01_31') aggiungo datiBaseDocumenti.url
					if (!string.IsNullOrEmpty(dt.Rows[0]["datiBaseDocumenti_url"].ToString()))
					{
						DatiBaseDocumenti dbaseDoc = new DatiBaseDocumenti();
						dbaseDoc.url = dt.Rows[0]["datiBaseDocumenti_url"].ToString();

						aggiudicazioneAD3Type.datiBaseDocumenti = dbaseDoc;
					}


					aggiudicazioni.Add(aggiudicazioneAD3Type);

                    

				}

				a.aggiudicazioni = aggiudicazioni;

				a.appalto = appalto;
            }

            return a;
        }

        public AnacFormP1_19 recuperaAnacFormP1_19(int idDoc, Dati_PCP dati)
        {
            AnacFormP1_19 a = new AnacFormP1_19();

            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql = "GET_DATI_SCHEDA_PCP_HEADER";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);

            //GET_DATI_SCHEDA_PCP_DETAIL
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql_2 = "GET_DATI_SCHEDA_PCP_DETAIL";
            cmd.CommandText = strSql_2;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt2 = new DataTable();
            SqlDataAdapter da2 = new SqlDataAdapter();
            da2.SelectCommand = cmd;
            da2.Fill(dt2);

            //GET_DATI_SCHEDA_PCP_PARTECIPANTI
            //cmd.Parameters.Clear();
            //cmd.Parameters.AddWithValue("@idGara", idDoc);
            //string strSql_3 = "GET_DATI_SCHEDA_PCP_PARTECIPANTI";
            //cmd.CommandText = strSql_3;
            //cmd.CommandType = CommandType.StoredProcedure;
            //DataTable dt3 = new DataTable();
            //SqlDataAdapter da3 = new SqlDataAdapter();
            //da3.SelectCommand = cmd;
            //da3.Fill(dt3);

            List<FunzioniSvolte> fsvolte = new List<FunzioniSvolte>();
            List<StazioniAppaltanti> stazioni = new List<StazioniAppaltanti>();
            List<CategorieMerceologiche> catMerceologiche = new List<CategorieMerceologiche>();
            if (dt.Rows.Count > 0)
            {
                StazioniAppaltanti s = new StazioniAppaltanti();

                s.saTitolare = false;
                s.codiceCentroCosto = dt.Rows[0]["pcp_CodiceCentroDiCosto"].ToString();
                s.codiceAusa = dati.codiceAUSA;
                s.codiceFiscale = dati.cfSA.ToUpper().StartsWith("IT") ? dati.cfSA.Substring(2) : dati.cfSA;
                string funzioniSvolte = dt.Rows[0]["pcp_FunzioniSvolte"].ToString();

                if (!string.IsNullOrEmpty(funzioniSvolte))
                {
                    if (funzioniSvolte.Contains("###"))
                    {
                        string[] funzionalitaAr = funzioniSvolte.Split(new string[] { "###" }, StringSplitOptions.None);
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

                AppaltoP1_19 appalto = new AppaltoP1_19();

                string categorieMerc = string.Empty;
                categorieMerc = recupereCatMerceologica(idDoc);
                List<CategorieMerceologiche> listCatM = new List<CategorieMerceologiche>();
                if (!string.IsNullOrEmpty(categorieMerc))
                {
                    if (categorieMerc.Contains("###"))
                    {
                        string[] catAr = categorieMerc.Split(new string[] { "###" }, StringSplitOptions.None);
                        foreach (string cat in catAr)
                        {
                            if (!string.IsNullOrEmpty(cat))
                            {
                                CategorieMerceologiche c = new CategorieMerceologiche();
                                c.idTipologica = "categorieMerceologiche";
                                c.codice = "999"; //cat; //TODO???? non implementato!!!
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


                StrumentiSvolgimentoProcedure ss = new StrumentiSvolgimentoProcedure() { codice = "5", idTipologica = "strumentiSvolgimentoProcedure" };
                appalto.strumentiSvolgimentoProcedure = ss;
                appalto.codiceAppalto = recuperaCodiceAppalto(idDoc);
                a.appalto = appalto;

                List<LottiP1_19> lotti = new List<LottiP1_19>();
                List<Finanziamenti> listaFinanziamenti = new List<Finanziamenti>();

                for (int i = 0; i < dt2.Rows.Count; i++)
                {
                    LottiP1_19 l = new LottiP1_19();
                    l.finanziamenti = listaFinanziamenti;
                    string numLotto = "0000" + dt2.Rows[i]["NumeroLotto"].ToString();
                    l.lotIdentifier = "LOT-" + numLotto.Substring(numLotto.Length - 4);

                    List<CategorieMerceologiche> listCatML = new List<CategorieMerceologiche>();
                    string categorieM = recuperaCategorieMerceologiche(idDoc);

                    if (!String.IsNullOrEmpty(categorieM))
                    {

                        //string cat = dt.Rows[i]["pcp_Categoria"].ToString();
                        if (!string.IsNullOrEmpty(categorieM))
                        {
                            if (categorieM.Contains("###"))
                            {
                                string[] catAr = categorieM.Split(new string[] { "###" }, StringSplitOptions.None);
                                foreach (string t in catAr)
                                {
                                    if (!string.IsNullOrEmpty(t))
                                    {
                                        CategorieMerceologiche c = new CategorieMerceologiche();
                                        c.idTipologica = "categorieMerceologiche";
                                        c.codice = t;
                                        listCatML.Add(c);
                                    }
                                }
                            }
                            else
                            {
                                CategorieMerceologiche c = new CategorieMerceologiche();
                                c.idTipologica = "categorieMerceologiche";
                                c.codice = categorieM;
                                listCatML.Add(c);
                            }
                        }
                    }
                    l.categorieMerceologiche = listCatML;


                   // l.condizioniNegoziata = new List<CondizioniNegoziata>();


                    //string condNeg = dt2.Rows[i]["pcp_CondizioniNegoziata"].ToString();

                    //if (!string.IsNullOrEmpty(condNeg))
                    //{
                    //    if (condNeg.Contains("###"))
                    //    {
                    //        string[] condNegAr = condNeg.Split(new string[] { "###" }, StringSplitOptions.None);
                    //        foreach (var item in condNegAr)
                    //        {
                    //            if (!string.IsNullOrEmpty(item))
                    //            {
                    //                CondizioniNegoziata c = new CondizioniNegoziata();
                    //                c.idTipologica = "condizioniNegoziata";
                    //                c.codice = item;
                    //                l.condizioniNegoziata.Add(c);
                    //            }
                    //        }
                    //    }
                    //    else
                    //    {
                    //        CondizioniNegoziata c = new CondizioniNegoziata();
                    //        c.idTipologica = "condizioniNegoziata";
                    //        c.codice = condNeg;
                    //        l.condizioniNegoziata.Add(c);
                    //    }
                    //}
                    //else
                    //{
                    //    l.condizioniNegoziata = null;
                    //}

                    if (dt2.Rows[i]["pcp_ContrattiDisposizioniParticolari"] != null && dt2.Rows[i]["pcp_ContrattiDisposizioniParticolari"].ToString() != "")
                    {
                        ContrattiDisposizioniParticolari cd = new ContrattiDisposizioniParticolari();
                        cd.idTipologica = "contrattiDisposizioniParticolari";
                        cd.codice = dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"].ToString();
                        l.contrattiDisposizioniParticolari = cd;
                    }

                    CodIstat istat = new CodIstat();
                    istat.idTipologica = "codIstat";
                    istat.codice = dt2.Rows[i]["codIstat"].ToString();

                    l.codIstat = istat;

                    l.afferenteInvestimentiPNRR = UtilsConvert.ToBool(dt2.Rows[i]["afferenteInvestimentiPNRR"].ToString());

                    l.acquisizioneCup = UtilsConvert.ToBool(dt2.Rows[i]["acquisizioneCup"].ToString());

                    List<string> listCupLotto = new List<string>();

                    if (dt2.Rows[i]["CUP"] != null && !string.IsNullOrEmpty(dt2.Rows[i]["CUP"].ToString()))
                    {
                        string cupLotto = dt2.Rows[i]["CUP"].ToString();
                        if (cupLotto.Contains("###"))
                        {
                            string[] cupLottoAr = cupLotto.Split(new string[] { "###" }, StringSplitOptions.None);
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

                    

                    Finanziamenti Fin = new Finanziamenti();

                    var Tipof = new TipoFinanziamento()
                    {
                        idTipologica = "tipoFinanziamento",
                        codice = dt.Rows[0]["TIPO_FINANZIAMENTO"].ToString()
                    };

                    Fin.importo = !dt2.Rows[i]["pcp_ImportoFinanziamento"].ToString().IsNullOrEmpty() ? UtilsConvert.ToDecimal(dt2.Rows[i]["pcp_ImportoFinanziamento"].ToString()) : 0;
                    Fin.tipoFinanziamento = Tipof;    
                    
                    listaFinanziamenti.Add(Fin);

                    

                    l.servizioPubblicoLocale = UtilsConvert.ToBool(dt2.Rows[i]["pcp_ServizioPubblicoLocale"].ToString());
                    l.saNonSoggettaObblighi24Dicembre2015 = UtilsConvert.ToBool(dt2.Rows[i]["saNonSoggettaObblighi24Dicembre2015"].ToString());
                    l.iniziativeNonSoddisfacenti = UtilsConvert.ToBool(dt2.Rows[i]["pcp_iniziativeNonSoddisfacenti"].ToString());
                    
                    l.lavoroOAcquistoPrevistoInProgrammazione = UtilsConvert.ToBool(dt2.Rows[i]["pcp_lavoroOAcquistoPrevistoInProgrammazione"].ToString());

                    if (!string.IsNullOrEmpty(dt2.Rows[i]["pcp_codiceCUI"].ToString()))
                    {
                        l.cui = dt2.Rows[i]["pcp_codiceCUI"].ToString();
                    }
                    else
                    {
                        l.cui = null;
                    }

                    if (dt2.Rows[i]["pcp_ModalitaAcquisizione"] != null && !string.IsNullOrEmpty(dt2.Rows[i]["pcp_ModalitaAcquisizione"].ToString()))
                    {
                        ModalitaAcquisizione m = new ModalitaAcquisizione();
                        m.codice = dt2.Rows[i]["pcp_ModalitaAcquisizione"].ToString();
                        m.idTipologica = "modalitaAcquisizione";
                        l.modalitaAcquisizione = m;
                    }
                    

                    l.opzioniRinnovi = dt2.Rows[i]["opzioniRinnovi"] != null && (!string.IsNullOrEmpty(dt2.Rows[i]["opzioniRinnovi"].ToString())) ? UtilsConvert.ToBool(dt2.Rows[i]["opzioniRinnovi"].ToString()) : true;

                    IpotesiCollegamento ipotesiCollegamento = new IpotesiCollegamento();
                    List<string> cigCollegato = new List<string>();
                    cigCollegato.Add(dt2.Rows[i]["pcp_cigCollegato"].ToString());
                    ipotesiCollegamento.cigCollegato = cigCollegato;

                    ipotesiCollegamento.motivoCollegamento = new MotivoCollegamento() { idTipologica = "motivoCollegamento", codice = dt.Rows[0]["MOTIVO_COLLEGAMENTO"].ToString() };
                    l.ipotesiCollegamento = ipotesiCollegamento;

                    Categoria cat2 = new Categoria();
                    cat2.idTipologica = "categoria";
                    cat2.codice = dt2.Rows[i]["pcp_Categoria"].ToString();

                    l.categoria = cat2;

                    lotti.Add(l);
                }

                a.lotti = lotti;

            }



            return a;
        }
        public AnacFormAD3 recuperaAnacFormAD5(int idDoc, Dati_PCP dati)
        {

            AnacFormAD3 a = new AnacFormAD3();

            //GET_DATI_SCHEDA_PCP_HEADER
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql = "GET_DATI_SCHEDA_PCP_HEADER";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);

            //GET_DATI_SCHEDA_PCP_DETAIL
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql_2 = "GET_DATI_SCHEDA_PCP_DETAIL";
            cmd.CommandText = strSql_2;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt2 = new DataTable();
            SqlDataAdapter da2 = new SqlDataAdapter();
            da2.SelectCommand = cmd;
            da2.Fill(dt2);

            //GET_DATI_SCHEDA_PCP_PARTECIPANTI
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql_3 = "GET_DATI_SCHEDA_PCP_PARTECIPANTI";
            cmd.CommandText = strSql_3;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt3 = new DataTable();
            SqlDataAdapter da3 = new SqlDataAdapter();
            da3.SelectCommand = cmd;
            da3.Fill(dt3);



            List<FunzioniSvolte> fsvolte = new List<FunzioniSvolte>();
            List<StazioniAppaltanti> stazioni = new List<StazioniAppaltanti>();
            List<CategorieMerceologiche> catMerceologiche = new List<CategorieMerceologiche>();
            if (dt.Rows.Count > 0)
            {
                StazioniAppaltanti s = new StazioniAppaltanti();

                s.saTitolare = false;
                s.codiceCentroCosto = dt.Rows[0]["pcp_CodiceCentroDiCosto"].ToString();
                s.codiceAusa = dati.codiceAUSA;
                s.codiceFiscale = dati.cfSA.ToUpper().StartsWith("IT") ? dati.cfSA.Substring(2) : dati.cfSA;
                string funzioniSvolte = dt.Rows[0]["pcp_FunzioniSvolte"].ToString();

                if (!string.IsNullOrEmpty(funzioniSvolte))
                {
                    if (funzioniSvolte.Contains("###"))
                    {
                        string[] funzionalitaAr = funzioniSvolte.Split(new string[] { "###" }, StringSplitOptions.None);
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
                AppaltoAD3 appalto = new AppaltoAD3();
                string categorieMerc = string.Empty;
                categorieMerc = recupereCatMerceologica(idDoc);
                List<CategorieMerceologiche> listCatM = new List<CategorieMerceologiche>();
                if (!string.IsNullOrEmpty(categorieMerc))
                {
                    if (categorieMerc.Contains("###"))
                    {
                        string[] catAr = categorieMerc.Split(new string[] { "###" }, StringSplitOptions.None);
                        foreach (string cat in catAr)
                        {
                            if (!string.IsNullOrEmpty(cat))
                            {
                                CategorieMerceologiche c = new CategorieMerceologiche();
                                c.idTipologica = "categorieMerceologiche";
                                c.codice = "999"; //cat; //TODO???? non implementato!!!
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


                if (dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"] != null && dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"].ToString() != "")
                {
                    ContrattiDisposizioniParticolari cd = new ContrattiDisposizioniParticolari();
                    cd.idTipologica = "contrattiDisposizioniParticolari";
                    cd.codice = dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"].ToString();
                    appalto.contrattiDisposizioniParticolari = cd;
                }

                //if (dt.Rows[0]["pcp_MotivoUrgenza"] != null)
                if (!string.IsNullOrEmpty(dt.Rows[0]["pcp_MotivoUrgenza"].ToString()))
                {
                    string cMotivo = dt.Rows[0]["pcp_MotivoUrgenza"].ToString();
                    if (!string.IsNullOrEmpty(cMotivo))
                    {
                        MotivoUrgenza m = new MotivoUrgenza();
                        m.idTipologica = "motivoUrgenza";
                        m.codice = cMotivo;
                        appalto.motivoUrgenza = m;
                    }
                }

                appalto.codiceAppalto = recuperaCodiceAppalto(idDoc);

                DatiBase datiBase = new DatiBase();
                datiBase.oggetto = dt.Rows[0]["Oggetto"].ToString();

                appalto.datiBase = datiBase;

				List<AggiudicazioneAD3Type> aggiudicazioni = new List<AggiudicazioneAD3Type>();

				//Itero sui lotti
				for (int j = 0; j < dt2.Rows.Count; j++)
				{

					
                    AggiudicazioneAD3Type aggiudicazioneAD3Type = new AggiudicazioneAD3Type();
                    aggiudicazioneAD3Type.lotIdentifier = dt2.Rows[j]["lotIdentifier"].ToString();

                    if (!string.IsNullOrEmpty(dt2.Rows[j]["CUP"].ToString()))
                    {
                        aggiudicazioneAD3Type.cup = dt2.Rows[j]["CUP"].ToString();
                    }

                    aggiudicazioneAD3Type.ccnl = dt2.Rows[j]["ccnl"].ToString();
                    Categoria cat2 = new Categoria();
                    cat2.idTipologica = "categoria";
                    cat2.codice = dt2.Rows[j]["pcp_Categoria"].ToString();
                    aggiudicazioneAD3Type.categoria = cat2;
                    CodIstat istat = new CodIstat();
                    istat.idTipologica = "codIstat";
                    istat.codice = dt2.Rows[j]["codIstat"].ToString();
                    aggiudicazioneAD3Type.codIstat = istat;

                    //AD5 non c'è quadro economico standard
                    string oggettoDelContratto = "";
                    string oggettoContratto = "";
                    List<PartecipanteAD3> partecipanteAD3s = new List<PartecipanteAD3>();
                    for (int i = 0; i < dt3.Rows.Count; i++)
                    {
                        if ( dt2.Rows[j]["NumeroLotto"].ToString() == dt3.Rows[i]["NumeroLotto"].ToString() )
						{
							PartecipanteAD3 partecipanteAD3 = new PartecipanteAD3();
                            partecipanteAD3.codiceFiscale = dt3.Rows[i]["codiceFiscale"].ToString();
                            partecipanteAD3.denominazione = dt3.Rows[i]["Denominazione"].ToString();
                            partecipanteAD3.idPartecipante = dt3.Rows[i]["idPartecipante"].ToString();

                            /*
							Categoria cat3 = new Categoria();
							cat3.idTipologica = "ruoloOE";
							cat3.codice = dt3.Rows[i]["ruoloOE"].ToString();
							partecipanteAD3.ruoloOE = cat3;
							Categoria cat4 = new Categoria();
							cat4.idTipologica = "tipoOE";
							cat4.codice = dt3.Rows[i]["tipoOE"].ToString();
							partecipanteAD3.tipoOE = cat4;

							partecipanteAD3.paeseOperatoreEconomico = dt3.Rows[i]["paeseOperatoreEconomico"].ToString();
							partecipanteAD3.avvalimento = UtilsConvert.ToBool(dt3.Rows[i]["avvalimento"].ToString() );  
							*/

							partecipanteAD3.importo = UtilsConvert.ToDecimal(dt3.Rows[i]["importo"].ToString());
                            oggettoDelContratto = dt3.Rows[i]["Oggetto"].ToString();
                            oggettoContratto = dt3.Rows[i]["oggettoContratto"].ToString();
                            partecipanteAD3s.Add(partecipanteAD3);

							aggiudicazioneAD3Type.partecipanti = partecipanteAD3s;

						}
					}
                    
                    

                    DatiBaseAD3 datiBase1 = new DatiBaseAD3();
                    datiBase1.oggetto = oggettoDelContratto;
                    Categoria cat5 = new Categoria();
                    cat5.idTipologica = "oggettoContratto";
                    cat5.codice = oggettoContratto;
                    datiBase1.oggettoContratto = cat5;
                    aggiudicazioneAD3Type.datiBase = datiBase1;


					//se valorizzato (nuova versione dalla '2024_01_31') aggiungo datiBaseDocumenti.url
            		if (!string.IsNullOrEmpty(dt.Rows[0]["datiBaseDocumenti_url"].ToString()))
					{
						DatiBaseDocumenti dbaseDoc = new DatiBaseDocumenti();
                        dbaseDoc.url = dt.Rows[0]["datiBaseDocumenti_url"].ToString();

						aggiudicazioneAD3Type.datiBaseDocumenti = dbaseDoc;
					}

					aggiudicazioni.Add(aggiudicazioneAD3Type);
                

                    
				}

				a.aggiudicazioni = aggiudicazioni;

				a.appalto = appalto;
            }

            return a;
        }

        public AnacFormS1 recuperaAnacFormS1(int idDoc, Dati_PCP dati)
        {
            var anacForm = new AnacFormS1();

            //eseguire le stored sql e recuperare tutti i dati che servono per poi popolare gli oggetti DTO dell's1. cioè l'anacforms1
            //devi popolare la collezione di elencoSoggettiRichiedenti

            //Otteniamo la lista di TUTTI i lotti della gara
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            cmd.Parameters.AddWithValue("@operation", "LOTTI");
            const string strSql = "ANAC_FORM_S2";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);

            //Otteniamo l'elenco completo dei partecipanti della gara ( comprese RTI ) in prodotto cartesiano sui lotti a cui hanno partecipato
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            cmd.Parameters.AddWithValue("@operation", "PARTECIPANTI");
            const string strSql2 = "ANAC_FORM_S2";
            cmd.CommandText = strSql2;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt2 = new DataTable();
            SqlDataAdapter da2 = new SqlDataAdapter();
            da2.SelectCommand = cmd;
            da2.Fill(dt2);

            var elencoSoggetti = new List<SoggettoS1>();


            //ITERO SUI CIG E PER OGNUO AGGIUNGO I PARTECIAPNTI
            if (dt.Rows.Count > 0)
            {
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    var s1 = new SoggettoS1();

                    s1.soggettiInteressati = new List<SoggettoInteressato>();

                    s1.cig = (string)dt.Rows[i]["CIG"];

                    //CICLO SUI PARTECIPANTI PER COMPORRE LA LISTA 
                    for (var k = 0; k < dt2.Rows.Count; k++)
                    {
                        //ISTANZIO NUOVO PARTECIPANTE
                        var par = new SoggettoInteressato();

                        par.codiceFiscale = (string)dt2.Rows[k]["codiceFiscale"];
                        par.denominazione = (string)dt2.Rows[k]["denominazione"];
                        par.idPartecipante = (string)dt2.Rows[k]["idPartecipante"];

                        var catRuolo = new Categoria();
                        catRuolo.idTipologica = "ruoloOE";
                        catRuolo.codice = (string)dt2.Rows[k]["ruoloOE_codice"];
                        par.ruoloOE = catRuolo;

                        var catTipo = new Categoria();
                        catTipo.idTipologica = "tipoOE";
                        catTipo.codice = (string)dt2.Rows[k]["tipoOE_codice"];
                        par.tipoOE = catTipo;

                        s1.soggettiInteressati.Add(par);

                    }

                    elencoSoggetti.Add(s1);
                }
            }
            else
            {
                throw new ApplicationException("Recupero dati scheda S2 non possibile per lotti assenti");
            }

            anacForm.elencoSoggettiRichiedenti = elencoSoggetti;

            return anacForm;
        }

        public AnacFormS2 recuperaAnacFormS2(int idDoc, Dati_PCP dati)
        {
            AnacFormS2 anacForm = new AnacFormS2();

            //Otteniamo la lista di TUTTI i lotti della gara
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            cmd.Parameters.AddWithValue("@operation", "LOTTI");
            const string strSql = "ANAC_FORM_S2";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);

            //Otteniamo l'elenco completo dei partecipanti della gara ( comprese RTI ) in prodotto cartesiano sui lotti a cui hanno partecipato
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            cmd.Parameters.AddWithValue("@operation", "PARTECIPANTI");
            const string strSql2 = "ANAC_FORM_S2";
            cmd.CommandText = strSql2;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt2 = new DataTable();
            SqlDataAdapter da2 = new SqlDataAdapter();
            da2.SelectCommand = cmd;
            da2.Fill(dt2);

            //Otteniamo la lista degli invitati. in caso di procedura ad invito. 
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            cmd.Parameters.AddWithValue("@operation", "INVITATI");
            const string strSql3 = "ANAC_FORM_S2";
            cmd.CommandText = strSql3;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt3 = new DataTable();
            SqlDataAdapter da3 = new SqlDataAdapter();
            da3.SelectCommand = cmd;
            da3.Fill(dt3);

            var elencoSoggetti = new List<SoggettoS2>();

            //var partecipanti = new List<PartecipanteS2>();

            var partecipantiAll = new Dictionary<string, List<PartecipanteS2>>(); //Chiave cig, oggetto il partecipante
            var invitatiAll = new Dictionary<string, InvitatoNonPartecipanteS2>(); //Chiave CF dell'azi, oggetto l'invitato

            var partecipantiCig = new List<PartecipanteS2>();

            /* Salvo nella prima collection tutti i lotti della gara. questi ultimi saranno inviati a prescindere dai partecipanti
                o dagli invitati. vedi ad. es il caso deserta. a seguire si itererà su questi per cercare nei dictionary di partecipanti ed invitati
                andando in chiave sul numero lotto per i partecipanti ed in "NOT IN" per gli invitati rispetto alla collection dei partecipanti( per CF ) */
            if (dt.Rows.Count > 0)
            {
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    var s2 = new SoggettoS2();

                    s2.cig = (string)dt.Rows[i]["CIG"];

                    s2.dataInvito = (string)dt.Rows[i]["dataInvito"];
                    s2.dataScadenzaPresentazioneOfferta = (string)dt.Rows[i]["dataScadenzaPresentazioneOfferta"];

                    elencoSoggetti.Add(s2);
                }
            }
            else
            {
                throw new ApplicationException("Recupero dati scheda S2 non possibile per lotti assenti");
            }

            var prevCig = "";

            //Itero sui partecipanti ( opzionali ) e lavoro a rottura di chiave sul CIG per inserire nella stessa lista i partecipanti di quel cig
            for (var k = 0; k < dt2.Rows.Count; k++)
            {
                var cig = (string)dt2.Rows[k]["CIG"];

                var par = new PartecipanteS2();
                par.avvalimento = (int)dt2.Rows[k]["avvalimento"] == 1;

                par.codiceFiscale = (string)dt2.Rows[k]["codiceFiscale"];
                par.denominazione = (string)dt2.Rows[k]["denominazione"];
                par.idPartecipante = (string)dt2.Rows[k]["idPartecipante"];
                par.paeseOperatoreEconomico = (string)dt2.Rows[k]["paeseOperatoreEconomico"];

                var catRuolo = new Categoria();
                catRuolo.idTipologica = "ruoloOE";
                catRuolo.codice = (string)dt2.Rows[k]["ruoloOE_codice"];
                par.ruoloOE = catRuolo;

                var catTipo = new Categoria();
                catTipo.idTipologica = "tipoOE";
                catTipo.codice = (string)dt2.Rows[k]["tipoOE_codice"];
                par.tipoOE = catTipo;

                if (cig == prevCig || k == 0)
                {
                    //Se mi trovo nello stesso CIG continuo ad aggiungere alla lista ( o se sono sulla prima iterazione )
                    partecipantiCig.Add(par);
                }
                else
                {
                    //Se il cig cambia ripulisco la lista precedente e ne inizializzo una nuova previa aggiunta della precedente nel dictionary
                    var partecipantiCigTemp = new List<PartecipanteS2>();
                    foreach (var item in partecipantiCig)
                    {
                        partecipantiCigTemp.Add(item);
                    }
                    partecipantiAll.Add(prevCig, partecipantiCigTemp);

                    partecipantiCig.Clear();
                    partecipantiCig.Add(par);
                }

                prevCig = cig;

            }

            if (partecipantiCig.Count > 0)
            {
                //Carico nel dictionary l'ultima lista/cig
                partecipantiAll.Add(prevCig, partecipantiCig);
            }

            //Itero sugli invitati ( opzionali )
            for (var j = 0; j < dt3.Rows.Count; j++)
            {
                var invitato = new InvitatoNonPartecipanteS2();

                invitato.codiceFiscale = (string)dt3.Rows[j]["codiceFiscale"];
                invitato.denominazione = (string)dt3.Rows[j]["denominazione"];

                var catRuolo = new Categoria();
                catRuolo.idTipologica = "ruoloOE";
                catRuolo.codice = (string)dt3.Rows[j]["ruoloOE_codice"];
                invitato.ruoloOE = catRuolo;

                var catTipo = new Categoria();
                catTipo.idTipologica = "tipoOE";
                catTipo.codice = (string)dt3.Rows[j]["tipoOE_codice"];
                invitato.tipoOE = catTipo;

                //Ho trovato refusi sul db con cf doppi quindi introduciamo un controllo
                if (!invitatiAll.ContainsKey(invitato.codiceFiscale))
                    invitatiAll.Add(invitato.codiceFiscale, invitato);
            }

            foreach (var soggetto in elencoSoggetti)
            {
                //Se per il lotto sul quale sto iterando sono presenti partecipanti/offerenti aggiungo la relativa collection
                if (partecipantiAll.ContainsKey(soggetto.cig))
                {
                    soggetto.partecipanti = partecipantiAll[soggetto.cig];
                }
                else
                {
                    soggetto.partecipanti = null; //lotto deserto
                }

                //Se mi trovo su una gara ad invito ( quindi se ho degli invitati ) verifico se per il cig sul quale sto iterando
                //  se ci sono OE che non hanno partecipato, ma che appunto sono stati invitati
                if (invitatiAll.Count > 0)
                {
                    var invitatiCopy = new Dictionary<string, InvitatoNonPartecipanteS2>(invitatiAll);

                    //Se per questo lotto non ci sono partecipanti allora tutti gli invitati sono NON partecipanti
                    if (soggetto.partecipanti is null)
                    {
                        soggetto.invitatiCheNonHannoPresentatoOfferta = invitatiAll.Values.ToList();
                    }
                    else
                    {
                        //Se ci sono dei partecipanti iteriamo su questi ultimi andando a rimuoverli da una copia della collection degli invitati
                        //  così facendo gli elementi restanti saranno i NON invitati
                        foreach (var par in soggetto.partecipanti)
                        {
                            //Se il codice fiscale del partecipante era tra gli invitati allora lo togliamo in quanto "partecipante"
                            if (invitatiAll.ContainsKey(par.codiceFiscale))
                            {
                                invitatiCopy.Remove(par.codiceFiscale);
                            }
                        }

                        soggetto.invitatiCheNonHannoPresentatoOfferta = invitatiCopy.Values.ToList();

                    }
                }

            }

            anacForm.elencoSoggetti = elencoSoggetti;

            List<SoggettoS2> listOfSoggettiToRemove = new List<SoggettoS2>();

            foreach (var item in anacForm.elencoSoggetti)
            {
                if (item.partecipanti == null || item.partecipanti.Count == 0)
                {
                    listOfSoggettiToRemove.Add(item);
                }
            }

            foreach (var item in listOfSoggettiToRemove)
            {
                anacForm.elencoSoggetti.Remove(item);
            }


            return anacForm;
        }

        public AnacFormA1_29 recuperaAnacFormA1_29(int idDoc, Dati_PCP dati, int IdDoc_Scheda)
        {
            AnacFormA1_29 a = new AnacFormA1_29();

            //GET_DATI_SCHEDA_PCP_HEADER
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql = "GET_DATI_SCHEDA_PCP_HEADER";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);

            //il recupero dei dati va fatto passando alle stored l'id del contratto, NON l'id della gara
            //in quanto la scheda si costruisce dal contratto
            //difatti per una gara possiamo avere n contratti, quindi n scheda a1_29


            //GET_DATI_SCHEDA_PCP_FROM_CONTRATTO
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@IdContratto", IdDoc_Scheda);
            cmd.Parameters.AddWithValue("@Contesto", "LOTTI");
            string strSql_2 = "GET_DATI_SCHEDA_PCP_FROM_CONTRATTO";
            cmd.CommandText = strSql_2;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt2 = new DataTable();
            SqlDataAdapter da2 = new SqlDataAdapter();
            da2.SelectCommand = cmd;
            da2.Fill(dt2);

            //GET_DATI_SCHEDA_PCP_OFFERTE_PRESENTATE
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@IdContratto", IdDoc_Scheda);
            cmd.Parameters.AddWithValue("@Contesto", "PARTECIPANTI");
            string strSql_3 = "GET_DATI_SCHEDA_PCP_FROM_CONTRATTO";
            cmd.CommandText = strSql_3;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt3 = new DataTable();
            SqlDataAdapter da3 = new SqlDataAdapter();
            da3.SelectCommand = cmd;
            da3.Fill(dt3);


            #region anacForm.appalto
            var appalto = new AppaltoA1_29();

            var motivoUrgenza = new MotivoUrgenza();
            motivoUrgenza.idTipologica = "motivoUrgenza";
            motivoUrgenza.codice = UtilsConvert.ToString(dt.Rows[0]["pcp_MotivoUrgenza"]);
            appalto.motivoUrgenza = motivoUrgenza;

            string linkDocumenti;
            linkDocumenti = UtilsConvert.ToString(dt.Rows[0]["pcp_LinkDocumenti"]);
            appalto.linkDocumenti = linkDocumenti;

            //TODO: Enrico da capire il contenuto
            if (dt.Columns.Contains("modalitaRiaggiudicazioneAffidamento"))
            {
                var modalitaRiaggiudicazioneAffidamento = new ModalitaRiaggiudicazioneAffidamento();
                modalitaRiaggiudicazioneAffidamento.idTipologica = "modalitaRiaggiudicazioneAffidamento";
                modalitaRiaggiudicazioneAffidamento.codice = UtilsConvert.ToString(dt.Rows[0]["modalitaRiaggiudicazioneAffidamento"]);
                if (!string.IsNullOrEmpty(modalitaRiaggiudicazioneAffidamento.codice))//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    appalto.modalitaRiaggiudicazioneAffidamento = modalitaRiaggiudicazioneAffidamento;
                }
            }

            bool relazioneUnicaSulleProcedure;
            relazioneUnicaSulleProcedure = UtilsConvert.ToBool(dt.Rows[0]["pcp_relazioneUnicaSulleProcedure"]);
            appalto.relazioneUnicaSulleProcedure = relazioneUnicaSulleProcedure;

            bool opereUrbanizzazioneScomputo;
            opereUrbanizzazioneScomputo = UtilsConvert.ToBool(dt.Rows[0]["pcp_opereUrbanizzazioneScomputo"]);
            appalto.opereUrbanizzazioneScomputo = opereUrbanizzazioneScomputo;

            a.appalto = appalto;
            #endregion

            #region anacForm.aggiudicazioni
            var aggiudicazioni = new List<AggiudicazioneA1_29>();
            for (int i = 0; i < dt2.Rows.Count; i++)
            {
                var aggiudicazione = new AggiudicazioneA1_29();

                aggiudicazione.cig = UtilsConvert.ToString(dt2.Rows[i]["cig"]);

                if (dt2.Columns.Contains("valoreSogliaAnomalia") && dt2.Rows[i]["valoreSogliaAnomalia"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    aggiudicazione.valoreSogliaAnomalia = UtilsConvert.ToDecimal(dt2.Rows[i]["valoreSogliaAnomalia"]);
                }

                QuadroEconomicoStandard quadroEconomicoStandard = new QuadroEconomicoStandard();
                quadroEconomicoStandard.impLavori = UtilsConvert.ToDecimal(dt2.Rows[i]["impLavori"]);
                quadroEconomicoStandard.impServizi = UtilsConvert.ToDecimal(dt2.Rows[i]["impServizi"]);
                quadroEconomicoStandard.impForniture = UtilsConvert.ToDecimal(dt2.Rows[i]["impForniture"]);
                quadroEconomicoStandard.impTotaleSicurezza = UtilsConvert.ToDecimal(dt2.Rows[i]["impTotaleSicurezza"]);
                quadroEconomicoStandard.ulterioriSommeNoRibasso = UtilsConvert.ToDecimal(dt2.Rows[i]["ulterioriSommeNoRibasso"]);
                quadroEconomicoStandard.impProgettazione = UtilsConvert.ToDecimal(dt2.Rows[i]["impProgettazione"]);
                quadroEconomicoStandard.sommeOpzioniRinnovi = UtilsConvert.ToDecimal(dt2.Rows[i]["sommeOpzioniRinnovi"]);
                quadroEconomicoStandard.sommeRipetizioni = UtilsConvert.ToDecimal(dt2.Rows[i]["sommeRipetizioni"]);
                quadroEconomicoStandard.sommeADisposizione = UtilsConvert.ToDecimal(dt2.Rows[i]["sommeADisposizione"]);
                if (//non è obbligatorio, lo inserisco nel json se ho almeno 1 valore != null
                    dt2.Rows[i]["impLavori"] != null ||
                    dt2.Rows[i]["impServizi"] != null ||
                    dt2.Rows[i]["impForniture"] != null ||
                    dt2.Rows[i]["impTotaleSicurezza"] != null ||
                    dt2.Rows[i]["ulterioriSommeNoRibasso"] != null ||
                    dt2.Rows[i]["impProgettazione"] != null ||
                    dt2.Rows[i]["sommeOpzioniRinnovi"] != null ||
                    dt2.Rows[i]["sommeRipetizioni"] != null ||
                    dt2.Rows[i]["sommeADisposizione"] != null
                    )
                {
                    aggiudicazione.quadroEconomicoStandard = quadroEconomicoStandard;
                }
                List<OffertePresentate> listOfOffertePresentate = new List<OffertePresentate>();
                //Le offerte presentate sono recuperate con la Stored GET_DATI_SCHEDA_PCP_OFFERTE_PRESENTATE
                //quindi successivamente faccio un ciclo sulla dt3
                aggiudicazione.offertePresentate = listOfOffertePresentate;

                aggiudicazione.numeroOfferteAmmesse = UtilsConvert.ToDecimal(dt2.Rows[i]["numeroOfferteAmmesse"]);

                EsitoProceduraAnnullata esitoProceduraAnnullata = new EsitoProceduraAnnullata();
                esitoProceduraAnnullata.idTipologica = "esitoProceduraAnnullata";

                if (dt2.Columns.Contains("esitoProceduraAnnullata") && dt2.Rows[i]["esitoProceduraAnnullata"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    esitoProceduraAnnullata.codice = UtilsConvert.ToString(dt2.Rows[i]["esitoProceduraAnnullata"]);
                    aggiudicazione.esitoProceduraAnnullata = esitoProceduraAnnullata;
                }

                aggiudicazioni.Add(aggiudicazione);
            }

            for (int i = 0; i < dt3.Rows.Count; i++)
            {
                OffertePresentate offertePresentate = new OffertePresentate();
                offertePresentate.idPartecipante = UtilsConvert.ToString(dt3.Rows[i]["idPartecipante"]);
                offertePresentate.importo = UtilsConvert.ToDecimal(dt3.Rows[i]["importo"]);

                if (dt3.Columns.Contains("aggiudicatario") && dt3.Rows[i]["aggiudicatario"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json 
                {
                    offertePresentate.aggiudicatario = UtilsConvert.ToBool(dt3.Rows[i]["aggiudicatario"]);
                }
                offertePresentate.ccnl = UtilsConvert.ToString(dt3.Rows[i]["ccnl"]);
                if (dt3.Columns.Contains("posizioneGraduatoria") && dt3.Rows[i]["posizioneGraduatoria"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    offertePresentate.posizioneGraduatoria = Convert.ToInt32(dt3.Rows[i]["posizioneGraduatoria"].ToString());
                }
                if (dt3.Columns.Contains("offertaEconomica") && dt3.Rows[i]["offertaEconomica"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    offertePresentate.offertaEconomica = UtilsConvert.ToDecimal(dt3.Rows[i]["offertaEconomica"]);
                }
                if (dt3.Columns.Contains("offertaQualitativa") && dt3.Rows[i]["offertaQualitativa"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    offertePresentate.offertaQualitativa = UtilsConvert.ToDecimal(dt3.Rows[i]["offertaQualitativa"]);
                }

                if (dt3.Columns.Contains("offertaInAumento") && dt3.Rows[i]["offertaInAumento"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    offertePresentate.offertaInAumento = UtilsConvert.ToDecimal(dt3.Rows[i]["offertaInAumento"]);
                }

                if (dt3.Columns.Contains("offertaMaggioreSogliaAnomalia") && dt3.Rows[i]["offertaMaggioreSogliaAnomalia"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    offertePresentate.offertaMaggioreSogliaAnomalia = UtilsConvert.ToBool(dt3.Rows[i]["offertaMaggioreSogliaAnomalia"]);
                }

                if (dt3.Columns.Contains("impresaEsclusaAutomaticamente") && dt3.Rows[i]["impresaEsclusaAutomaticamente"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    offertePresentate.impresaEsclusaAutomaticamente = UtilsConvert.ToBool(dt3.Rows[i]["impresaEsclusaAutomaticamente"]);
                }

                if (dt3.Columns.Contains("offertaAnomala") && dt3.Rows[i]["offertaAnomala"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    offertePresentate.offertaAnomala = UtilsConvert.ToBool(dt3.Rows[i]["offertaAnomala"]);
                }

                //ciclo sulle aggiudicazioni, se trovo l'offertaPresentata corrispondente al cig la aggiungo alla lista
                foreach (var item in aggiudicazioni)
                {
                    if (UtilsConvert.ToString(dt3.Rows[i]["cig"]) == item.cig)
                    {
                        item.offertePresentate.Add(offertePresentate);
                    }
                }
            }

            //TODO: chiedere se necessario eliminare le aggiudicazioni con offertePresentate.Count == 0? (come viene fatto per l'S2)


            a.aggiudicazioni = aggiudicazioni;
            #endregion


            return a;
        }

        public AnacFormA2_29 recuperaAnacFormA2_29(int idDoc, Dati_PCP dati, int IdDoc_Scheda)
        {
            AnacFormA2_29 a = new AnacFormA2_29();

            //GET_DATI_SCHEDA_PCP_HEADER
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql = "GET_DATI_SCHEDA_PCP_HEADER";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);

            //il recupero dei dati va fatto passando alle stored l'id del contratto, NON l'id della gara
            //in quanto la scheda si costruisce dal contratto
            //difatti per una gara possiamo avere n contratti, quindi n scheda a2_29


            //GET_DATI_SCHEDA_PCP_FROM_CONTRATTO
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@IdContratto", IdDoc_Scheda);
            cmd.Parameters.AddWithValue("@Contesto", "LOTTI");
            string strSql_2 = "GET_DATI_SCHEDA_PCP_FROM_CONTRATTO";
            cmd.CommandText = strSql_2;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt2 = new DataTable();
            SqlDataAdapter da2 = new SqlDataAdapter();
            da2.SelectCommand = cmd;
            da2.Fill(dt2);

            //GET_DATI_SCHEDA_PCP_OFFERTE_PRESENTATE
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@IdContratto", IdDoc_Scheda);
            cmd.Parameters.AddWithValue("@Contesto", "PARTECIPANTI");
            string strSql_3 = "GET_DATI_SCHEDA_PCP_FROM_CONTRATTO";
            cmd.CommandText = strSql_3;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt3 = new DataTable();
            SqlDataAdapter da3 = new SqlDataAdapter();
            da3.SelectCommand = cmd;
            da3.Fill(dt3);


            #region anacForm.appalto
            var appalto = new AppaltoA2_29();

            var motivoUrgenza = new MotivoUrgenza();
            motivoUrgenza.idTipologica = "motivoUrgenza";
            motivoUrgenza.codice = UtilsConvert.ToString(dt.Rows[0]["pcp_MotivoUrgenza"]);
            appalto.motivoUrgenza = motivoUrgenza;

            if (dt.Columns.Contains("pcp_LinkDocumenti"))
            {
                string linkDocumenti;
                linkDocumenti = UtilsConvert.ToString(dt.Rows[0]["pcp_LinkDocumenti"]);
                appalto.linkDocumenti = linkDocumenti;
            }

            //TODO: Enrico da capire il contenuto
            if (dt.Columns.Contains("modalitaRiaggiudicazioneAffidamento"))
            {
                var modalitaRiaggiudicazioneAffidamento = new ModalitaRiaggiudicazioneAffidamento();
                modalitaRiaggiudicazioneAffidamento.idTipologica = "modalitaRiaggiudicazioneAffidamento";
                modalitaRiaggiudicazioneAffidamento.codice = UtilsConvert.ToString(dt.Rows[0]["modalitaRiaggiudicazioneAffidamento"]);
                if (!string.IsNullOrEmpty(modalitaRiaggiudicazioneAffidamento.codice))//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    appalto.modalitaRiaggiudicazioneAffidamento = modalitaRiaggiudicazioneAffidamento;
                }
            }

            bool relazioneUnicaSulleProcedure;
            relazioneUnicaSulleProcedure = UtilsConvert.ToBool(dt.Rows[0]["pcp_relazioneUnicaSulleProcedure"]);
            appalto.relazioneUnicaSulleProcedure = relazioneUnicaSulleProcedure;

            bool opereUrbanizzazioneScomputo;
            opereUrbanizzazioneScomputo = UtilsConvert.ToBool(dt.Rows[0]["pcp_opereUrbanizzazioneScomputo"]);
            appalto.opereUrbanizzazioneScomputo = opereUrbanizzazioneScomputo;

            DatiBaseProceduraA2_29 datiBaseProcedura = new DatiBaseProceduraA2_29();
            TipoProcedura tipoProcedura = new TipoProcedura();
            tipoProcedura.idTipologica = "tipoProcedura";
            tipoProcedura.codice = UtilsConvert.ToString(dt.Rows[0]["tipoProcedura"]);
            datiBaseProcedura.tipoProcedura = tipoProcedura;
            if (dt.Columns.Contains("giustificazioniAggiudicazioneDiretta"))
            {
                List<GiustificazioniAggiudicazioneDiretta> listGiustificazioniAggiudicazioneDiretta = new List<GiustificazioniAggiudicazioneDiretta>();
                GiustificazioniAggiudicazioneDiretta giustificazioniAggiudicazioneDiretta = new GiustificazioniAggiudicazioneDiretta();
                giustificazioniAggiudicazioneDiretta.idTipologica = "giustificazioniAggiudicazioneDiretta";
                giustificazioniAggiudicazioneDiretta.codice = UtilsConvert.ToString(dt.Rows[0]["giustificazioniAggiudicazioneDiretta"]);
                listGiustificazioniAggiudicazioneDiretta.Add(giustificazioniAggiudicazioneDiretta);
                datiBaseProcedura.giustificazioniAggiudicazioneDiretta = listGiustificazioniAggiudicazioneDiretta;
            }
            appalto.datiBaseProcedura = datiBaseProcedura;

            DatiBaseStrumentiProcedura datiBaseStrumentiProcedura = new DatiBaseStrumentiProcedura();
            AccordoQuadro accordoQuadro = new AccordoQuadro();
            accordoQuadro.idTipologica = "accordoQuadro";
            if (dt.Columns.Contains("accordoQuadro"))
            {
                accordoQuadro.codice = UtilsConvert.ToString(dt.Rows[0]["accordoQuadro"]);
                datiBaseStrumentiProcedura.accordoQuadro = accordoQuadro;
            }
            SistemaDinamicoAcquisizione sistemaDinamicoAcquisizione = new SistemaDinamicoAcquisizione();
            sistemaDinamicoAcquisizione.idTipologica = "sistemaDinamicoAcquisizione";
            if (dt.Columns.Contains("sistemaDinamicoAcquisizione"))
            {
                sistemaDinamicoAcquisizione.codice = UtilsConvert.ToString(dt.Rows[0]["sistemaDinamicoAcquisizione"]);
                datiBaseStrumentiProcedura.sistemaDinamicoAcquisizione = sistemaDinamicoAcquisizione;
            }
            if (dt.Columns.Contains("astaElettronica"))
            {
                datiBaseStrumentiProcedura.astaElettronica = UtilsConvert.ToBool(dt.Rows[0]["astaElettronica"]);
            }
            if(dt.Columns.Contains("accordoQuadro") || dt.Columns.Contains("sistemaDinamicoAcquisizione") || dt.Columns.Contains("astaElettronica"))//non è obbligatorio se non ho un valore da db non lo inserisco nel json
            {
                appalto.datiBaseStrumentiProcedura = datiBaseStrumentiProcedura;
            }

            if (dt.Columns.Contains("subappalto"))//non è obbligatorio se non ho un valore da db non lo inserisco nel json
            {
                DatiBaseSubappalti datiBaseSubappalti = new DatiBaseSubappalti();
                Subappalto subappalto = new Subappalto();
                subappalto.idTipologica = "subappalto";
                subappalto.codice = UtilsConvert.ToString(dt.Rows[0]["subappalto"]);
                datiBaseSubappalti.subappalto = subappalto;
                appalto.datiBaseSubappalti = datiBaseSubappalti;
            }

            a.appalto = appalto;
            #endregion

            #region anacForm.aggiudicazioni
            var aggiudicazioni = new List<AggiudicazioneA2_29>();
            for (int i = 0; i < dt2.Rows.Count; i++)
            {
                var aggiudicazione = new AggiudicazioneA2_29();

                aggiudicazione.cig = UtilsConvert.ToString(dt2.Rows[i]["cig"]);

                if (dt2.Columns.Contains("valoreSogliaAnomalia") && dt2.Rows[i]["valoreSogliaAnomalia"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    aggiudicazione.valoreSogliaAnomalia = UtilsConvert.ToDecimal(dt2.Rows[i]["valoreSogliaAnomalia"]);
                }

                QuadroEconomicoStandard quadroEconomicoStandard = new QuadroEconomicoStandard();
                quadroEconomicoStandard.impLavori = UtilsConvert.ToDecimal(dt2.Rows[i]["impLavori"]);
                quadroEconomicoStandard.impServizi = UtilsConvert.ToDecimal(dt2.Rows[i]["impServizi"]);
                quadroEconomicoStandard.impForniture = UtilsConvert.ToDecimal(dt2.Rows[i]["impForniture"]);
                quadroEconomicoStandard.impTotaleSicurezza = UtilsConvert.ToDecimal(dt2.Rows[i]["impTotaleSicurezza"]);
                quadroEconomicoStandard.ulterioriSommeNoRibasso = UtilsConvert.ToDecimal(dt2.Rows[i]["ulterioriSommeNoRibasso"]);
                quadroEconomicoStandard.impProgettazione = UtilsConvert.ToDecimal(dt2.Rows[i]["impProgettazione"]);
                quadroEconomicoStandard.sommeOpzioniRinnovi = UtilsConvert.ToDecimal(dt2.Rows[i]["sommeOpzioniRinnovi"]);
                quadroEconomicoStandard.sommeRipetizioni = UtilsConvert.ToDecimal(dt2.Rows[i]["sommeRipetizioni"]);
                quadroEconomicoStandard.sommeADisposizione = UtilsConvert.ToDecimal(dt2.Rows[i]["sommeADisposizione"]);
                if (//non è obbligatorio, lo inserisco nel json se ho almeno 1 valore != null
                    dt2.Rows[i]["impLavori"] != null ||
                    dt2.Rows[i]["impServizi"] != null ||
                    dt2.Rows[i]["impForniture"] != null ||
                    dt2.Rows[i]["impTotaleSicurezza"] != null ||
                    dt2.Rows[i]["ulterioriSommeNoRibasso"] != null ||
                    dt2.Rows[i]["impProgettazione"] != null ||
                    dt2.Rows[i]["sommeOpzioniRinnovi"] != null ||
                    dt2.Rows[i]["sommeRipetizioni"] != null ||
                    dt2.Rows[i]["sommeADisposizione"] != null
                    )
                {
                    aggiudicazione.quadroEconomicoStandard = quadroEconomicoStandard;
                }
                List<OffertePresentate> listOfOffertePresentate = new List<OffertePresentate>();
                //Le offerte presentate sono recuperate con la Stored GET_DATI_SCHEDA_PCP_OFFERTE_PRESENTATE
                //quindi successivamente faccio un ciclo sulla dt3
                aggiudicazione.offertePresentate = listOfOffertePresentate;

                aggiudicazione.numeroOfferteAmmesse = UtilsConvert.ToDecimal(dt2.Rows[i]["numeroOfferteAmmesse"]);

                if (dt2.Columns.Contains("esitoProcedura"))//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    DatiBaseRisultatoProcedura datiBaseRisultatoProcedura = new DatiBaseRisultatoProcedura();
                    EsitoProcedura esitoProcedura = new EsitoProcedura();
                    esitoProcedura.idTipologica = "esitoProcedura";
                    esitoProcedura.codice = UtilsConvert.ToString(dt2.Rows[i]["esitoProcedura"]);
                    datiBaseRisultatoProcedura.esitoProcedura = esitoProcedura;
                    aggiudicazione.datiBaseRisultatoProcedura = datiBaseRisultatoProcedura;
                }

                if (dt2.Columns.Contains("dataAggiudicazione"))//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    DatiBaseAggiudicazioneAppalto datiBaseAggiudicazioneAppalto = new DatiBaseAggiudicazioneAppalto();
                    datiBaseAggiudicazioneAppalto.dataAggiudicazione = UtilsConvert.ToString(dt2.Rows[i]["dataAggiudicazione"]);
                    aggiudicazione.datiBaseAggiudicazioneAppalto = datiBaseAggiudicazioneAppalto;
                }

                if (dt2.Columns.Contains("accessibilita") || dt2.Columns.Contains("giustificazione"))//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    DatiBaseAccessibilita datiBaseAccessibilita = new DatiBaseAccessibilita();
                    Accessibilita accessibilita = new Accessibilita();
                    accessibilita.idTipologica = "accessibilita";
                    accessibilita.codice = UtilsConvert.ToString(dt2.Rows[i]["accessibilita"]);
                    datiBaseAccessibilita.accessibilita = accessibilita;
                    datiBaseAccessibilita.giustificazione = UtilsConvert.ToString(dt2.Rows[i]["giustificazione"]);
                    aggiudicazione.datiBaseAccessibilita = datiBaseAccessibilita;
                }

                if (dt2.Columns.Contains("offertaMassimoRibasso"))//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    DatiBaseSottomissioniRicevute datiBaseSottomissioniRicevute = new DatiBaseSottomissioniRicevute();
                    datiBaseSottomissioniRicevute.offertaMassimoRibasso = UtilsConvert.ToDecimal(dt2.Rows[i]["offertaMassimoRibasso"]);
                    aggiudicazione.datiBaseSottomissioniRicevute = datiBaseSottomissioniRicevute;
                }


                aggiudicazioni.Add(aggiudicazione);
            }

            for (int i = 0; i < dt3.Rows.Count; i++)
            {
                OffertePresentate offertePresentate = new OffertePresentate();
                offertePresentate.idPartecipante = UtilsConvert.ToString(dt3.Rows[i]["idPartecipante"]);
                offertePresentate.importo = UtilsConvert.ToDecimal(dt3.Rows[i]["importo"]);
                offertePresentate.aggiudicatario = UtilsConvert.ToBool(dt3.Rows[i]["aggiudicatario"]);
                offertePresentate.ccnl = UtilsConvert.ToString(dt3.Rows[i]["ccnl"]);
                
                if (dt3.Columns.Contains("posizioneGraduatoria") && dt3.Rows[i]["posizioneGraduatoria"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    offertePresentate.posizioneGraduatoria = Convert.ToInt32(dt3.Rows[i]["posizioneGraduatoria"].ToString());
                }
                if (dt3.Columns.Contains("offertaEconomica") && dt3.Rows[i]["offertaEconomica"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    offertePresentate.offertaEconomica = UtilsConvert.ToDecimal(dt3.Rows[i]["offertaEconomica"]);
                }
                if (dt3.Columns.Contains("offertaQualitativa") && dt3.Rows[i]["offertaQualitativa"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    offertePresentate.offertaQualitativa = UtilsConvert.ToDecimal(dt3.Rows[i]["offertaQualitativa"]);
                }

                if (dt3.Columns.Contains("offertaInAumento") && dt3.Rows[i]["offertaInAumento"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    offertePresentate.offertaInAumento = UtilsConvert.ToDecimal(dt3.Rows[i]["offertaInAumento"]);
                }

                if (dt3.Columns.Contains("offertaMaggioreSogliaAnomalia") && dt3.Rows[i]["offertaMaggioreSogliaAnomalia"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    offertePresentate.offertaMaggioreSogliaAnomalia = UtilsConvert.ToBool(dt3.Rows[i]["offertaMaggioreSogliaAnomalia"]);
                }

                if (dt3.Columns.Contains("impresaEsclusaAutomaticamente") && dt3.Rows[i]["impresaEsclusaAutomaticamente"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    offertePresentate.impresaEsclusaAutomaticamente = UtilsConvert.ToBool(dt3.Rows[i]["impresaEsclusaAutomaticamente"]);
                }

                if (dt3.Columns.Contains("offertaAnomala") && dt3.Rows[i]["offertaAnomala"] != null)//non è obbligatorio se non ho un valore da db non lo inserisco nel json
                {
                    offertePresentate.offertaAnomala = UtilsConvert.ToBool(dt3.Rows[i]["offertaAnomala"]);
                }

                //ciclo sulle aggiudicazioni, se trovo l'offertaPresentata corrispondente al cig la aggiungo alla lista
                foreach (var item in aggiudicazioni)
                {
                    if (UtilsConvert.ToString(dt3.Rows[i]["cig"]) == item.cig)
                    {
                        item.offertePresentate.Add(offertePresentate);
                    }
                }
            }

            a.aggiudicazioni = aggiudicazioni;
            #endregion


            return a;
        }


        public AnacFormSC1 recuperaAnacFormSC1(int idDoc, Dati_PCP dati, int IdDoc_Scheda)
        {
            AnacFormSC1 a = new AnacFormSC1();
            ////GET_DATI_SCHEDA_PCP_HEADER
            //cmd.Parameters.Clear();
            //cmd.Parameters.AddWithValue("@idGara", idDoc);
            //string strSql = "GET_DATI_SCHEDA_PCP_HEADER";
            //cmd.CommandText = strSql;
            //cmd.CommandType = CommandType.StoredProcedure;
            //DataTable dt = new DataTable();
            //SqlDataAdapter da = new SqlDataAdapter();
            //da.SelectCommand = cmd;
            //da.Fill(dt);

            //GET_DATI_SCHEDA_PCP_FROM_CONTRATTO
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@IdContratto", IdDoc_Scheda);
            cmd.Parameters.AddWithValue("@Contesto", "DATI_CONTRATTO");
            string strSql_2 = "GET_DATI_SCHEDA_PCP_FROM_CONTRATTO";
            cmd.CommandText = strSql_2;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt2 = new DataTable();
            SqlDataAdapter da2 = new SqlDataAdapter();
            da2.SelectCommand = cmd;
            da2.Fill(dt2);

            DatiContratto datiContratto = new DatiContratto();
            List<string> codiciAusa = new List<string>();
            codiciAusa.Add(dati.codiceAUSA);
            datiContratto.codiceAusa = codiciAusa;
            datiContratto.idPartecipante = UtilsConvert.ToString(dt2.Rows[0]["idPartecipante"]);
            List<string> listOfCIG = new List<string>();
            for (int i = 0; i < dt2.Rows.Count; i++)
            {
                var item = UtilsConvert.ToString(dt2.Rows[i]["CIG"]);
                listOfCIG.Add(item);

            }
            datiContratto.cig = listOfCIG;
            if (dt2.Columns.Contains("dataStipula") && dt2.Rows[0]["dataStipula"] != null && !(dt2.Rows[0]["dataStipula"] is System.DBNull))
            {
                datiContratto.dataStipula = UtilsConvert.ToString(dt2.Rows[0]["dataStipula"]);
            }
            if (dt2.Columns.Contains("dataEsecutivita") && dt2.Rows[0]["dataEsecutivita"] != null && !(dt2.Rows[0]["dataEsecutivita"] is System.DBNull))
            {
                datiContratto.dataEsecutivita = UtilsConvert.ToString(dt2.Rows[0]["dataEsecutivita"]);
            }

            datiContratto.dataDecorrenza = UtilsConvert.ToString(dt2.Rows[0]["dataDecorrenza"]);
            datiContratto.dataScadenza = UtilsConvert.ToString(dt2.Rows[0]["dataScadenza"]);


            datiContratto.importoCauzione = UtilsConvert.ToDecimal(dt2.Rows[0]["ImportoCauzione"]);

            a.datiContratto = datiContratto;

            return a;
        }

        public AnacFormS3 recuperaAnacFormS3(int idDoc, Dati_PCP dati, int IdDoc_Scheda)
        {

            AnacFormS3 a = new AnacFormS3();

            //GET_DATI_SCHEDA_PCP_HEADER
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql = "GET_DATI_SCHEDA_PCP_HEADER";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);

            //GET_DATI_SCHEDA_PCP_FROM_CONTRATTO
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@IdContratto", IdDoc_Scheda);
            cmd.Parameters.AddWithValue("@Contesto", "ELENCO_INCARICHI");
            string strSql_2 = "GET_DATI_SCHEDA_PCP_FROM_CONTRATTO";
            cmd.CommandText = strSql_2;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt2 = new DataTable();
            SqlDataAdapter da2 = new SqlDataAdapter();
            da2.SelectCommand = cmd;
            da2.Fill(dt2);

            List<ElencoIncarichi> listOfelencoIncarichi = new List<ElencoIncarichi>();
            for (int i = 0; i < dt2.Rows.Count; i++)
            {
                ElencoIncarichi elencoIncarichi = new ElencoIncarichi();
                elencoIncarichi.cig = UtilsConvert.ToString(dt2.Rows[i]["cig"]);


                List<Incarico> listOfTipoIncarico = new List<Incarico>();
                Incarico incarico = new Incarico();//TODO: per il momento ipotizzo 1 solo incarico per cig
                TipoIncarico tipoIncarico = new TipoIncarico();
                tipoIncarico.idTipologica = "tipoIncarico";
                tipoIncarico.codice = UtilsConvert.ToString(dt2.Rows[i]["tipoIncarico"]);//dovrà essere sempre 8, prendo comunque il valore dalla stored
                incarico.tipoIncarico = tipoIncarico;
                DatiPersonaFisica datiPersonaFisica = new DatiPersonaFisica();
                if (dt2.Rows[i]["codiceFiscale"] != null && !(dt2.Rows[i]["codiceFiscale"] is System.DBNull))
                {
                    datiPersonaFisica.codiceFiscale = UtilsConvert.ToString(dt2.Rows[i]["codiceFiscale"]);
                }
                if (dt2.Rows[i]["cognome"] != null && !(dt2.Rows[i]["cognome"] is System.DBNull))
                {
                    datiPersonaFisica.cognome = UtilsConvert.ToString(dt2.Rows[i]["cognome"]);
                }
                if (dt2.Rows[i]["nome"] != null && !(dt2.Rows[i]["nome"] is System.DBNull))
                {
                    datiPersonaFisica.nome = UtilsConvert.ToString(dt2.Rows[i]["nome"]);
                }
                if (dt2.Rows[i]["telefono"] != null && !(dt2.Rows[i]["telefono"] is System.DBNull))
                {
                    datiPersonaFisica.telefono = UtilsConvert.ToString(dt2.Rows[i]["telefono"]);
                }
                if (dt2.Rows[i]["fax"] != null && !(dt2.Rows[i]["fax"] is System.DBNull))
                {
                    datiPersonaFisica.fax = UtilsConvert.ToString(dt2.Rows[i]["fax"]);
                }
                if (dt2.Rows[i]["email"] != null && !(dt2.Rows[i]["email"] is System.DBNull))
                {
                    datiPersonaFisica.email = UtilsConvert.ToString(dt2.Rows[i]["email"]);
                }
                if (dt2.Rows[i]["indirizzo"] != null && !(dt2.Rows[i]["indirizzo"] is System.DBNull))
                {
                    datiPersonaFisica.indirizzo = UtilsConvert.ToString(dt2.Rows[i]["indirizzo"]);
                }
                if (dt2.Rows[i]["cap"] != null && !(dt2.Rows[i]["cap"] is System.DBNull))
                {
                    datiPersonaFisica.cap = UtilsConvert.ToString(dt2.Rows[i]["cap"]);
                }
                CodIstat codIstat = new CodIstat();
                codIstat.idTipologica = "codIstat";
                codIstat.codice = UtilsConvert.ToString(dt2.Rows[i]["codIstat"]);
                if (dt2.Rows[i]["codIstat"] != null && !(dt2.Rows[i]["codIstat"] is System.DBNull))
                {
                    datiPersonaFisica.codIstat = codIstat;
                }

                datiPersonaFisica.incaricatoEstero = UtilsConvert.ToBool(dt2.Rows[i]["incaricatoEstero"]);//dovrà essere sempre false, prendo comunque il valore dalla stored
                incarico.datiPersonaFisica = datiPersonaFisica;

                List<DatiPersonaGiuridica> listOfDatiPersonaGiuridica = new List<DatiPersonaGiuridica>();
                //DatiPersonaGiuridica datiPersonaGiuridica = new DatiPersonaGiuridica(); //ipotizzo 1 solo DatiPersonaGiuridica per incarico
                //datiPersonaGiuridica.codiceFiscale = UtilsConvert.ToString(dt2.Rows[i]["codiceFiscale"]); //TODO: attenzione!!! impostato stesso codice fiscale della DatiPersonaFisica 
                //datiPersonaGiuridica.denominazione = UtilsConvert.ToString(dt2.Rows[i]["denominazione"]);
                //Categoria ruoloOE = new Categoria();
                //ruoloOE.idTipologica = "ruoloOE";
                //ruoloOE.codice = UtilsConvert.ToString(dt2.Rows[i]["ruoloOE"]);
                //datiPersonaGiuridica.ruoloOE = ruoloOE;
                //Categoria tipoOE = new Categoria();
                //ruoloOE.idTipologica = "tipoOE";
                //ruoloOE.codice = UtilsConvert.ToString(dt2.Rows[i]["tipoOE"]);
                //datiPersonaGiuridica.tipoOE = tipoOE;
                //datiPersonaGiuridica.idGruppo = Convert.ToInt32(dt2.Rows[i]["idGruppo"].ToString());

                //listOfDatiPersonaGiuridica.Add(datiPersonaGiuridica);
                incarico.datiPersonaGiuridica = listOfDatiPersonaGiuridica;

                listOfTipoIncarico.Add(incarico);

                elencoIncarichi.incarichi = listOfTipoIncarico;
                //elencoIncarichi.prestazioni = ?;//TODO: completare con la lista delle prestazioni


                listOfelencoIncarichi.Add(elencoIncarichi);
            }

            a.elencoIncarichi = listOfelencoIncarichi;

            return a;
        }

        public AnacFormP7_2 recuperaAnacFormP7_2(int idDoc, Dati_PCP dati)
        {

            AnacFormP7_2 a = new AnacFormP7_2();

            //GET_DATI_SCHEDA_PCP_HEADER
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql = "GET_DATI_SCHEDA_PCP_HEADER";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);

            //GET_DATI_SCHEDA_PCP_DETAIL
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql_2 = "GET_DATI_SCHEDA_PCP_DETAIL";
            cmd.CommandText = strSql_2;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt2 = new DataTable();
            SqlDataAdapter da2 = new SqlDataAdapter();
            da2.SelectCommand = cmd;
            da2.Fill(dt2);


            //document_bando
            //cmd.Parameters.Clear();
            //cmd.Parameters.AddWithValue("@idGara", idDoc);
            //string strSql_4 = "select ImportoBaseAsta from document_bando where idHeader = @idGara;";
            //cmd.CommandText = strSql_4;
            //cmd.CommandType = CommandType.Text;
            //DataTable dt4 = new DataTable();
            //SqlDataAdapter da4 = new SqlDataAdapter();
            //conn.Open();
            //da4.SelectCommand = cmd;
            //da4.Fill(dt4);
            //conn.Close();

            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idDoc", idDoc);
            string strSql_3 = "select Concessione from document_bando where idHeader = @idDoc ";
            cmd.CommandText = strSql_3;
            cmd.CommandType = CommandType.Text;
            conn.Open();
            string concessione = string.Empty;
            var result = cmd.ExecuteScalar();
            if (result != null)
            {
                concessione = result.ToString();
            }
            conn.Close();






            AppaltoP7_2 appalto = new AppaltoP7_2();
            List<StazioniAppaltanti> stazioni = new List<StazioniAppaltanti>();
            List<LottiP7_2> lotti = new List<LottiP7_2>();

            if (dt.Rows.Count > 0)
            {

                //StazioniAppaltanti
                List<FunzioniSvolte> fsvolte = new List<FunzioniSvolte>();
                StazioniAppaltanti s = new StazioniAppaltanti();

                s.saTitolare = false;
                s.codiceCentroCosto = dt.Rows[0]["pcp_CodiceCentroDiCosto"].ToString();
                s.codiceAusa = dati.codiceAUSA;
                s.codiceFiscale = dati.cfSA.ToUpper().StartsWith("IT") ? dati.cfSA.Substring(2) : dati.cfSA;
                string funzioniSvolte = dt.Rows[0]["pcp_FunzioniSvolte"].ToString();

                if (!string.IsNullOrEmpty(funzioniSvolte))
                {
                    if (funzioniSvolte.Contains("###"))
                    {
                        string[] funzionalitaAr = funzioniSvolte.Split(new string[] { "###" }, StringSplitOptions.None);
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
                //StazioniAppaltanti


                //APPALTO
                appalto.codiceAppalto = recuperaCodiceAppalto(idDoc);

                string categorieMerc = string.Empty;
                categorieMerc = recupereCatMerceologica(idDoc);
                List<CategorieMerceologiche> listCatM = new List<CategorieMerceologiche>();
                if (!string.IsNullOrEmpty(categorieMerc))
                {
                    if (categorieMerc.Contains("###"))
                    {
                        string[] catAr = categorieMerc.Split(new string[] { "###" }, StringSplitOptions.None);
                        foreach (string cat in catAr)
                        {
                            if (!string.IsNullOrEmpty(cat))
                            {
                                CategorieMerceologiche c = new CategorieMerceologiche();
                                c.idTipologica = "categorieMerceologiche";
                                c.codice = cat; //cat; //TODO???? non implementato!!!
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

                appalto.motivazioneCIG = new MotivazioneCIG() { codice = dt.Rows[0]["MOTIVAZIONE_CIG"].ToString(), idTipologica = "motivazioneCIG" };

                if (!string.IsNullOrEmpty(dt.Rows[0]["pcp_MotivoUrgenza"].ToString()))
                {
                    MotivoUrgenza m = new MotivoUrgenza();
                    m.idTipologica = "motivoUrgenza";
                    m.codice = dt.Rows[0]["pcp_MotivoUrgenza"] != null ? dt.Rows[0]["pcp_MotivoUrgenza"].ToString() : string.Empty;
                    appalto.motivoUrgenza = m;
                }
                else
                {
                    //lo setto a null sarò tolto alla fine e non aggiunto al json
                    //dalla funzione anacformutils.getJsonWithOptAttrib
                    appalto.motivoUrgenza = null;
                }

                DatiBase datiBase = new DatiBase();
                datiBase.oggetto = dt.Rows[0]["Oggetto"] != null ? dt.Rows[0]["Oggetto"].ToString() : string.Empty;
				//datiBase.importo = Convert.ToDouble(dt4.Rows[0]["ImportoBaseAsta"].ToString());
				//datiBase.importo = Convert.ToDouble(dt.Rows[0]["importo"].ToString());
				datiBase.importo = UtilsConvert.ToDecimal(dt.Rows[0]["importo"].ToString());
				appalto.datiBase = datiBase;

                DatiBaseProcedura dbaseProc = new DatiBaseProcedura();
                TipoProcedura t = new TipoProcedura();
                t.codice = dt.Rows[0]["tipoProcedura"] != null ? dt.Rows[0]["tipoProcedura"].ToString() : string.Empty; ;
                t.idTipologica = "tipoProcedura";
                dbaseProc.tipoProcedura = t;
                appalto.datiBaseProcedura = dbaseProc;

                appalto.linkDocumenti = dt.Rows[0]["pcp_LinkDocumenti"] != null ? dt.Rows[0]["pcp_LinkDocumenti"].ToString() : string.Empty;
                //APPALTO


                //LOTTI
                for (int i = 0; i < dt2.Rows.Count; i++)
                {
                    LottiP7_2 lotto = new LottiP7_2();

                    lotto.lotIdentifier = dt2.Rows[i]["lotIdentifier"].ToString();

                    lotto.categorieMerceologiche = listCatM;

                    lotto.saNonSoggettaObblighi24Dicembre2015 = UtilsConvert.ToBool(dt2.Rows[i]["saNonSoggettaObblighi24Dicembre2015"].ToString());

                    lotto.iniziativeNonSoddisfacenti = UtilsConvert.ToBool(dt2.Rows[i]["pcp_iniziativeNonSoddisfacenti"].ToString());

                    lotto.condizioniNegoziata = new List<CondizioniNegoziata>();


                    string condNeg = dt2.Rows[i]["pcp_CondizioniNegoziata"].ToString();

                    if (!string.IsNullOrEmpty(condNeg))
                    {
                        if (condNeg.Contains("###"))
                        {
                            string[] condNegAr = condNeg.Split(new string[] { "###" }, StringSplitOptions.None);
                            foreach (var item in condNegAr)
                            {
                                if (!string.IsNullOrEmpty(item))
                                {
                                    CondizioniNegoziata c = new CondizioniNegoziata();
                                    c.idTipologica = "condizioniNegoziata";
                                    c.codice = item;
                                    lotto.condizioniNegoziata.Add(c);
                                }
                            }
                        }
                        else
                        {
                            CondizioniNegoziata c = new CondizioniNegoziata();
                            c.idTipologica = "condizioniNegoziata";
                            c.codice = condNeg;
                            lotto.condizioniNegoziata.Add(c);
                        }
                    }

                    if (!string.IsNullOrEmpty(dt2.Rows[i]["pcp_ContrattiDisposizioniParticolari"].ToString()))
                    {
                        ContrattiDisposizioniParticolari cdp = new ContrattiDisposizioniParticolari();
                        cdp.idTipologica = "contrattiDisposizioniParticolari";
                        cdp.codice = dt2.Rows[i]["pcp_ContrattiDisposizioniParticolari"].ToString();
                        lotto.contrattiDisposizioniParticolari = cdp;
                    }




                    CodIstat codIstat = new CodIstat();
                    codIstat.idTipologica = "codIstat";
                    codIstat.codice = dt2.Rows[i]["codIstat"].ToString();

                    lotto.codIstat = codIstat;

                    lotto.servizioPubblicoLocale = UtilsConvert.ToBool(dt2.Rows[i]["pcp_ServizioPubblicoLocale"].ToString());

                    lotto.lavoroOAcquistoPrevistoInProgrammazione = UtilsConvert.ToBool(dt2.Rows[i]["pcp_lavoroOAcquistoPrevistoInProgrammazione"].ToString());


                    if (!string.IsNullOrEmpty(dt2.Rows[i]["pcp_codiceCUI"].ToString()))
                    {
                        lotto.cui = dt2.Rows[i]["pcp_codiceCUI"].ToString();
                    }
                    else
                    {
                        lotto.cui = null;
                    }
                    //lotto.ripetizioniEConsegneComplementari //lascia vuoto

                    lotto.ripetizioniEConsegneComplementari = dt2.Rows[i]["ripetizioniEConsegneComplementari"] != null && (!string.IsNullOrEmpty(dt2.Rows[i]["ripetizioniEConsegneComplementari"].ToString())) ? UtilsConvert.ToBool(dt2.Rows[i]["ripetizioniEConsegneComplementari"].ToString()) : true;


                    IpotesiCollegamento ipotesiCollegamento = new IpotesiCollegamento();
                    List<string> cigCollegato = new List<string>();
                    cigCollegato.Add(dt2.Rows[i]["pcp_cigCollegato"].ToString());
                    ipotesiCollegamento.cigCollegato = cigCollegato;

                    ipotesiCollegamento.motivoCollegamento = new MotivoCollegamento() { idTipologica = "motivoCollegamento", codice = dt2.Rows[i]["MOTIVO_COLLEGAMENTO"].ToString() };
                    lotto.ipotesiCollegamento = ipotesiCollegamento;


                    //lotto.opzioniRinnovi = false; //lascia vuoto
                    lotto.opzioniRinnovi = dt2.Rows[i]["opzioniRinnovi"] != null && (!string.IsNullOrEmpty(dt2.Rows[i]["opzioniRinnovi"].ToString())) ? UtilsConvert.ToBool(dt2.Rows[i]["opzioniRinnovi"].ToString()) : true;

                    lotto.afferenteInvestimentiPNRR = UtilsConvert.ToBool(dt2.Rows[i]["afferenteInvestimentiPNRR"].ToString());

                    lotto.acquisizioneCup = UtilsConvert.ToBool(dt2.Rows[i]["acquisizioneCup"].ToString());


                    List<string> cupList = new List<string>();

                    //if (dt2.Rows[i]["CUP"] != null )
                    if (dt2.Rows[i]["CUP"] != null && !string.IsNullOrEmpty(dt2.Rows[i]["CUP"].ToString()))
                    {

                        string cups = dt2.Rows[i]["CUP"].ToString();
                        if (cups.Contains("###"))
                        {
                            string[] cupsAr = cups.Split(new string[] { "###" }, StringSplitOptions.None);
                            foreach (string cup in cupsAr)
                            {
                                cupList.Add(cup);
                            }
                        }
                        else
                        {
                            cupList.Add(cups);
                        }
                    }

                    lotto.cupLotto = cupList;

                    lotto.ccnl = dt2.Rows[0]["ccnl"].ToString();

                    /*
                    if (dt2.Rows[i]["pcp_ModalitaAcquisizione"] != null)
                    {
                        ModalitaAcquisizione ma = new ModalitaAcquisizione();
                        ma.codice = dt2.Rows[i]["pcp_ModalitaAcquisizione"].ToString();
                        ma.idTipologica = "modalitaAcquisizione";
                        lotto.modalitaAcquisizione = ma;
                    }
                    */

                    Categoria categoria = new Categoria();
                    categoria.idTipologica = "categoria";
                    categoria.codice = dt2.Rows[0]["pcp_Categoria"].ToString();

                    lotto.categoria = categoria;

                    if (dt2.Rows[i]["pcp_PrestazioniComprese"] != null)
                    {
                        string prestazioniComprese = dt2.Rows[i]["pcp_PrestazioniComprese"].ToString();

                        prestazioniComprese p = new prestazioniComprese();
                        p.idTipologica = "prestazioniComprese";
                        p.codice = prestazioniComprese;

                        lotto.prestazioniComprese = p;
                    }

                    List<Finanziamento> listaFin = new List<Finanziamento>();

                    var Tipof = new TipoFinanziamento()
                    {
                        idTipologica = "tipoFinanziamento",
                        codice = dt2.Rows[i]["TIPO_FINANZIAMENTO"].ToString()
                    };
                    var fin = new Finanziamento()
                    {
                        importo = !dt2.Rows[i]["pcp_ImportoFinanziamento"].ToString().IsNullOrEmpty() ? Convert.ToDouble(dt2.Rows[i]["pcp_ImportoFinanziamento"].ToString()) : 0,
                        tipoFinanziamento = Tipof
                    };
                    listaFin.Add(fin);
                    lotto.finanziamenti = listaFin;


                    lotto.tipoRealizzazione = new TipoRealizzazione() { codice = "1", idTipologica = "tipoRealizzazione" };
                    if (concessione == "si")
                    {
                        lotto.tipoRealizzazione.codice = "2";
                    }


                    var oggettoContratto = new OggettoContratto()
                    {
                        codice = dt2.Rows[i]["oggettoContratto"].ToString(),
                        idTipologica = "oggettoContratto"
                    };

                    lotto.datiBase = new DatiBaseP7_2()
                    {
                        oggettoContratto = oggettoContratto,
                        oggetto = dt.Rows[0]["Oggetto"].ToString(),
						//importo = Convert.ToDouble(dt4.Rows[0]["ImportoBaseAsta"])
						//importo = Convert.ToDouble(dt2.Rows[i]["ValoreBase"])
						importo = UtilsConvert.ToDecimal(dt2.Rows[i]["ValoreBase"].ToString())

				};

                    QuadroEconomicoStandard qes = new QuadroEconomicoStandard();
                    if (!string.IsNullOrEmpty(dt2.Rows[i]["UlterioriSommeNoRibasso"].ToString()))
                    {
                        qes.ulterioriSommeNoRibasso = UtilsConvert.ToDecimal(dt2.Rows[i]["UlterioriSommeNoRibasso"].ToString());
                    }
                    else
                    {
                        qes.ulterioriSommeNoRibasso = 0;
                    }

                    qes.impForniture = 0;
                    qes.impServizi = 0;
                    qes.impLavori = 0;
                    qes.sommeOpzioniRinnovi = 0;

                    if (!string.IsNullOrEmpty(dt2.Rows[i]["sommeOpzioniRinnovi"].ToString()))
                    {
                        qes.sommeOpzioniRinnovi = UtilsConvert.ToDecimal(dt2.Rows[i]["sommeOpzioniRinnovi"].ToString());
                    }
                    else
                    {
                        qes.sommeOpzioniRinnovi = 0;
                    }

                    if (!string.IsNullOrEmpty(dt2.Rows[i]["sommeADisposizione"].ToString()))
                    {
                        qes.sommeADisposizione = UtilsConvert.ToDecimal(dt2.Rows[i]["sommeADisposizione"].ToString());
                    }
                    else
                    {
                        qes.sommeADisposizione = 0;
                    }


                    //qes.impProgettazione = 0;
                    if (!string.IsNullOrEmpty(dt2.Rows[i]["impProgettazione"].ToString()))
                    {
                        qes.impProgettazione = UtilsConvert.ToDecimal(dt2.Rows[i]["impProgettazione"].ToString());
                    }
                    else
                    {
                        qes.impProgettazione = 0;
                    }

                    if (!string.IsNullOrEmpty(dt2.Rows[i]["impTotaleSicurezza"].ToString()))
                    {
                        qes.impTotaleSicurezza = UtilsConvert.ToDecimal(dt2.Rows[i]["impTotaleSicurezza"].ToString());
                    }
                    else
                    {
                        qes.impTotaleSicurezza = 0;
                    }

                    if (!string.IsNullOrEmpty(dt2.Rows[i]["sommeRipetizioni"].ToString()))
                    {
                        qes.sommeRipetizioni = UtilsConvert.ToDecimal(dt2.Rows[i]["sommeRipetizioni"].ToString());
                    }
                    else
                    {
                        qes.sommeRipetizioni = 0;
                    }

                    qes.impLavori = UtilsConvert.ToDecimal(dt2.Rows[i]["impLavori"]);
                    qes.impServizi = UtilsConvert.ToDecimal(dt2.Rows[i]["impServizi"]);
                    qes.impForniture = UtilsConvert.ToDecimal(dt2.Rows[i]["impForniture"]);


                    /*
					int tipoBandoGara = Convert.ToInt32(dt2.Rows[i]["TipoBandoGara"].ToString());
					decimal valorebase = 0;
					if (!string.IsNullOrEmpty(dt2.Rows[i]["ValoreBase"].ToString()))
					{
						valorebase = UtilsConvert.ToDecimal(dt2.Rows[i]["ValoreBase"].ToString());
					}
					if (tipoBandoGara == 2)
					{
						qes.impLavori = valorebase;
					}
					else if (tipoBandoGara == 3)
					{
						qes.impServizi = valorebase;
					}

					if (dt2.Rows[i]["ImportoSicurezza"] != null)
					{
						string importo = dt2.Rows[i]["ImportoSicurezza"].ToString();
						if (!string.IsNullOrEmpty(importo))
						{
							qes.impForniture = UtilsConvert.ToDecimal(dt2.Rows[i]["ImportoSicurezza"].ToString());
						}
					}
					*/

                    lotto.quadroEconomicoStandard = qes;

                    lotto.datiBaseTerminiInvio = new DatiBaseTerminiInvio()
                    {
                        oraScadenzaPresentazioneOfferte = Convert.ToDateTime(dt.Rows[0]["oraScadenzaPresentazioneOfferte"].ToString()),
                    };


					//se valorizzato (nuova versione dalla '01.00.01') aggiungo datiBaseDocumenti.url
					if (!string.IsNullOrEmpty(dt.Rows[0]["datiBaseDocumenti_url"].ToString()))
					{
						DatiBaseDocumenti dbaseDoc = new DatiBaseDocumenti();
						dbaseDoc.url = dt.Rows[0]["datiBaseDocumenti_url"].ToString();

						lotto.datiBaseDocumenti = dbaseDoc;
					}


					List<TipologiaLavoro> tipoL = new List<TipologiaLavoro>();
                    lotto.tipologiaLavoro = tipoL;

                    lotti.Add(lotto);
                }
            }

            a.appalto = appalto;
            a.stazioniAppaltanti = stazioni;
            a.lotti = lotti;

            return a;
        }

        public AnacFormNAG recuperaAnacFormNAG(int idDoc, Dati_PCP dati, int idDoc_scheda, string CIG, string contesto)
        {

            //ATTUALMENTE LE SCHEDE NAG VENGONO RICHIESTE LOTTO PER LOTTO
            AnacFormNAG a = new AnacFormNAG();
            List<LottoNAG> lotti = new List<LottoNAG>();


            //CERCO UN RECORD PER FARE IL CONTROLLO PER LA PROCEDURA DI SELEZIONE
            string strSql1 = "select TOP 1 Id from ctl_doc with(nolock) where TipoDoc = 'PDA_MICROLOTTI' and LinkedDoc =  @idGara";
            cmd.Parameters.Clear();  
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            cmd.CommandText = strSql1;
            cmd.CommandType = CommandType.Text;
            conn.Open();
            var PDA = cmd.ExecuteScalar();
            conn.Close();



            var lotto = new LottoNAG();

            lotto.cig = CIG;

            EsitoProceduraAnnullataEnum esitoProceduraAnnullata = new EsitoProceduraAnnullataEnum();
            esitoProceduraAnnullata.idTipologica = "esitoProceduraAnnullata";

            if (PDA == null)
            {
                esitoProceduraAnnullata.codice = "6";
            }
            else
            {
                esitoProceduraAnnullata.codice = "7";
            }

            lotto.esitoProceduraAnnullata = esitoProceduraAnnullata;


            DatiBaseRisultatoProceduraNAG datiBaseRisultatoProcedura = new DatiBaseRisultatoProceduraNAG();
            datiBaseRisultatoProcedura.giustificazione = new Giustificazione()
            {
                idTipologica = "giustificazione"
            };

            switch (contesto)
            {
                case "TERMINE_VAL_AMM":
                case "DECADENZA":
                case "DESERTA":
                    datiBaseRisultatoProcedura.giustificazione.codice = "no-rece"; //DESERTA
                    break;
                case "TERMINE_VAL_TEC":
                case "TERMINE_VAL_TEC_LOTTO":
                case "TERMINE_VAL_ECO":
                    datiBaseRisultatoProcedura.giustificazione.codice = "all-rej"; //Non Giudicabile/Non Aggiudicabile
                    break;
                case "REVOCA_BANDO":
                case "REVOCA_LOTTO":
                    datiBaseRisultatoProcedura.giustificazione.codice = "chan-need"; //Revocato
                    break;
            }

            lotto.datiBaseRisultatoProcedura = datiBaseRisultatoProcedura;

            lotti.Add(lotto);

            a.lotti = lotti;

            return a;
        }

        private string recupereCatMerceologica(int idDoc)
        {
            string strSql = "SELECT CATEGORIE_MERC FROM Document_Bando with(nolock) where idHeader = @iddoc";
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@iddoc", idDoc);
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.Text;
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
            string strSql = "select CN16_CODICE_APPALTO from Document_E_FORM_CONTRACT_NOTICE with(nolock) where idHeader = @iddoc";
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@iddoc", idDoc);
            cmd.CommandType = CommandType.Text;
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

        //public class LottiP2_16
        //{
        //    public string lotIdentifier { get; set; }
        //    public List<CategorieMerceologiche> categorieMerceologiche { get; set; }
        //    public ContrattiDisposizioniParticolari contrattiDisposizioniParticolari { get; set; }
        //    public CodIstat codIstat { get; set; }
        //    public bool afferenteInvestimentiPNRR { get; set; }
        //    public prestazioniComprese prestazioniComprese { get; set; }
        //    public bool servizioPubblicoLocale { get; set; }
        //    public bool ripetizioniEConsegneComplementari { get; set; }
        //    public bool lavoroOAcquistoPrevistoInProgrammazione { get; set; }
        //    public string ccnl { get; set; }
        //    public bool opzioniRinnovi { get; set; }
        //    public IpotesiCollegamento ipotesiCollegamento { get; set; }
        //    public Categoria categoria { get; set; }
        //    public ModalitaAcquisizione modalitaAcquisizione { get; set; }
        //    public QuadroEconomicoStandard quadroEconomicoStandard { get; set; }
        //    public DatiBaseP2_16 datiBase { get; set; }
        //    public DatiBaseAggiuntiviP2_16 datiBaseAggiuntivi { get; set; }
        //    public List<CondizioniNegoziata> condizioniNegoziata { get; set; }
        //    public List<string> cupLotto { get; set; }
        //    public bool acquisizioneCup { get; set; }
        //    public bool saNonSoggettaObblighi24Dicembre2015 { get; set; }
        //    public bool iniziativeNonSoddisfacenti { get; set; }
        //    public bool strumentiElettroniciSpecifici { get; set; }
        //    public TipologiaLavoro tipologiaLavoro { get; set; }
        //    public DatiBaseContratto datiBaseContratto { get; set; }
        //    public DatiBaseAggiudicazione datiBaseAggiudicazione { get; set; }
        //    public DatiBaseCPVP2_16 datiBaseCPV { get; set; }
        //    public DatiBaseDocumenti datiBaseDocumenti { get; set; }
        //    public string cui { get; set; }

        //}

        private List<LottiP7_1_2> recuperaLottiP7_1_2(int idDoc)
        {
            
            //string dataTermineInvito = string.Empty;
            
            DataTable dt = new DataTable();


            SqlDataAdapter da1 = new SqlDataAdapter();

            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql = "GET_DATI_SCHEDA_PCP_DETAIL";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            da1 = new SqlDataAdapter();
            da1.SelectCommand = cmd;
            da1.Fill(dt);


            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idDoc", idDoc);
            strSql = "Select DataScadenzaOfferta, Concessione, TipoBandoGara from document_bando with(nolock) where idHeader = @idDoc";
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSql;
            SqlDataAdapter da2 = new SqlDataAdapter();
            da2.SelectCommand = cmd;
            DataTable dt3 = new DataTable();
            da2.Fill(dt3);




            //GET_DATI_SCHEDA_PCP_HEADER
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            strSql = "GET_DATI_SCHEDA_PCP_HEADER";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt2 = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt2);


            //cmd.Parameters.Clear();
            //cmd.Parameters.AddWithValue("idDoc", idDoc);
            //cmd.CommandType = CommandType.StoredProcedure;
            //cmd.CommandText = "GET_DATI_PCP_BASE_PROCEDURA";
            //conn.Open();
            //var result = cmd.ExecuteScalar();
            //conn.Close();

            //if (result != null)
            //{
            //    dataTermineInvito += result.ToString();
            //}

            //cmd.Parameters.Clear();
            //cmd.Parameters.AddWithValue("@idDoc", idDoc);
            //strSql = "Select Body from document_bando with(nolock) where idHeader = @idDoc";
            //cmd.CommandType = CommandType.Text;
            //cmd.CommandText = strSql;
            //conn.Open();
            int tipoGara = Convert.ToInt32(dt3.Rows[0]["TipoBandoGara"].ToString());
            //var Column = cmd.ExecuteScalar();
            //if (Column != null)
            //{
            //    tipoGara = Convert.ToInt32(firstColumn.ToString());
            //}
            //conn.Close();

            List<LottiP7_1_2> listaLotti = new List<LottiP7_1_2>();

            if (dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    LottiP7_1_2 l = new LottiP7_1_2();

                    string numLotto = "0000" + dt.Rows[i]["NumeroLotto"].ToString();
                    l.lotIdentifier = "LOT-" + numLotto.Substring(numLotto.Length - 4);

                    l.saNonSoggettaObblighi24Dicembre2015 = dt.Rows[i]["saNonSoggettaObblighi24Dicembre2015"] != null && !string.IsNullOrEmpty(dt.Rows[i]["saNonSoggettaObblighi24Dicembre2015"].ToString()) ? Convert.ToBoolean(dt.Rows[i]["saNonSoggettaObblighi24Dicembre2015"].ToString()) : false;
                    l.iniziativeNonSoddisfacenti = dt.Rows[i]["iniziativeNonSoddisfacenti"] != null && !string.IsNullOrEmpty(dt.Rows[i]["iniziativeNonSoddisfacenti"].ToString()) ? Convert.ToBoolean(dt.Rows[i]["iniziativeNonSoddisfacenti"].ToString()) : false;
                    CondizioniNegoziata condizioniNegoziata = new CondizioniNegoziata();
                    string condNeg = dt.Rows[i]["pcp_CondizioniNegoziata"].ToString();


                    List<CondizioniNegoziata> lCondNeg = new List<CondizioniNegoziata>();

                    if (!string.IsNullOrEmpty(condNeg))
                    {
                        if (condNeg.Contains("###"))
                        {
                            string[] condNegAr = condNeg.Split(new string[] { "###" }, StringSplitOptions.None);
                            foreach (var item in condNegAr)
                            {
                                if (!string.IsNullOrEmpty(item))
                                {
                                    CondizioniNegoziata c = new CondizioniNegoziata();
                                    c.idTipologica = "condizioniNegoziata";
                                    c.codice = item;
                                    lCondNeg.Add(c);
                                }
                            }
                        }
                        else
                        {
                            CondizioniNegoziata c = new CondizioniNegoziata();
                            c.idTipologica = "condizioniNegoziata";
                            c.codice = condNeg;
                            lCondNeg.Add(c);
                        }
                    }

                    l.condizioniNegoziata = lCondNeg;

                    if (dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"] != null && !string.IsNullOrEmpty(dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"].ToString()))
                    {
                        ContrattiDisposizioniParticolari cd = new ContrattiDisposizioniParticolari();
                        cd.idTipologica = "contrattiDisposizioniParticolari";
                        cd.codice = dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"].ToString();
                        l.contrattiDisposizioniParticolari = cd;
                    }

                    CodIstat istat = new CodIstat();
                    istat.idTipologica = "codIstat";
                    istat.codice = dt.Rows[0]["codIstat"].ToString();
                    l.codIstat = istat;


                    l.servizioPubblicoLocale = dt.Rows[i]["pcp_ServizioPubblicoLocale"] != null && (!string.IsNullOrEmpty(dt.Rows[i]["pcp_ServizioPubblicoLocale"].ToString())) ? Convert.ToBoolean(dt.Rows[i]["pcp_ServizioPubblicoLocale"].ToString()) : false;
                    l.lavoroOAcquistoPrevistoInProgrammazione = dt.Rows[i]["pcp_lavoroOAcquistoPrevistoInProgrammazione"] != null && (!string.IsNullOrEmpty(dt.Rows[i]["pcp_lavoroOAcquistoPrevistoInProgrammazione"].ToString())) ? Convert.ToBoolean(dt.Rows[i]["pcp_lavoroOAcquistoPrevistoInProgrammazione"].ToString()) : false;

                    if (!string.IsNullOrEmpty(dt.Rows[i]["pcp_CodiceCUI"].ToString()))
                    {
                        l.cui = dt.Rows[i]["pcp_CodiceCUI"].ToString();
                    }
                    else
                    {
                        l.cui = null;
                    }

                    MotivoCollegamento motivoCollegamento = new MotivoCollegamento();
                    motivoCollegamento.idTipologica = "motivoCollegamento";
                    motivoCollegamento.codice = dt.Rows[i]["MOTIVO_COLLEGAMENTO"].ToString();
                    IpotesiCollegamentoP7_1_2 ipotesiCollegamento = new IpotesiCollegamentoP7_1_2();
                    ipotesiCollegamento.motivoCollegamento = motivoCollegamento;
                    l.ipotesiCollegamento = ipotesiCollegamento;

                    //l.opzioniRinnovi = TODO: in attesa di chiarimenti con Maria Chiara
                    l.opzioniRinnovi = dt.Rows[i]["opzioniRinnovi"] != null && (!string.IsNullOrEmpty(dt.Rows[i]["opzioniRinnovi"].ToString())) ? UtilsConvert.ToBool(dt.Rows[i]["opzioniRinnovi"].ToString()) : true;

                    l.afferenteInvestimentiPNRR = dt.Rows[i]["afferenteInvestimentiPNRR"] != null && (!string.IsNullOrEmpty(dt.Rows[i]["afferenteInvestimentiPNRR"].ToString())) ? UtilsConvert.ToBool(dt.Rows[i]["afferenteInvestimentiPNRR"].ToString()) : false;

                    //bool acquizioneCup = dt.Rows[i]["acquisizioneCup"] != null && (!string.IsNullOrEmpty(dt.Rows[i]["acquisizioneCup"].ToString())) ? true : false;
                    //l.acquisizioneCup = acquizioneCup;


                    l.acquisizioneCup = UtilsConvert.ToBool(dt.Rows[i]["acquisizioneCup"].ToString());

                    List<string> cupList = new List<string>();

                    if (dt.Rows[i]["CUP"] != null && !string.IsNullOrEmpty(dt.Rows[i]["CUP"].ToString()))
                    {

                        string cups = dt.Rows[i]["CUP"].ToString();
                        if (cups.Contains("###"))
                        {
                            string[] cupsAr = cups.Split(new string[] { "###" }, StringSplitOptions.None);
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

                    if (dt.Rows[i]["pcp_ModalitaAcquisizione"] != null && !string.IsNullOrEmpty(dt.Rows[i]["pcp_ModalitaAcquisizione"].ToString()))
                    {
                        ModalitaAcquisizione m = new ModalitaAcquisizione();
                        m.codice = dt.Rows[i]["pcp_ModalitaAcquisizione"].ToString();
                        m.idTipologica = "modalitaAcquisizione";
                        l.modalitaAcquisizione = m;
                    }

                    //OggettoPrincipaleContratto ogg = new OggettoPrincipaleContratto() { codice = dt.Rows[i]["oggettoPrincipaleContratto"].ToString(), idTipologica = "oggettoPrincipaleContratto" };

                    //l.oggettoPrincipaleContratto = ogg;

                    //if (dt.Rows[i]["pcp_PrestazioniComprese"] != null)
                    //{
                    //    string prestazioniComprese = dt.Rows[i]["pcp_PrestazioniComprese"].ToString();

                    //    prestazioniComprese p = new prestazioniComprese();
                    //    p.idTipologica = "prestazioniComprese";
                    //    p.codice = prestazioniComprese;

                    //    l.prestazioniComprese = p;
                    //}

                    //l.servizioPubblicoLocale = true;
                    //l.ripetizioniEConsegneComplementari = false;

                    l.ripetizioniEConsegneComplementari = dt.Rows[i]["ripetizioniEConsegneComplementari"] != null && (!string.IsNullOrEmpty(dt.Rows[i]["ripetizioniEConsegneComplementari"].ToString())) ? UtilsConvert.ToBool(dt.Rows[i]["ripetizioniEConsegneComplementari"].ToString()) : true;


                    //l.lavoroOAcquistoPrevistoInProgrammazione = true;

                    //l.ccnl = "non applicabile";
                    l.ccnl = dt.Rows[i]["ccnl"].ToString();

                    //List<TipologiaLavoro> tipoL = new List<TipologiaLavoro>();
                    //l.tipologiaLavoro = tipoL;


                    //string cat = dt.Rows[i]["pcp_Categoria"].ToString();



                    List<CategorieMerceologiche> listCatM = new List<CategorieMerceologiche>();

                    string categorieM = recuperaCategorieMerceologiche(idDoc);

                    if (!String.IsNullOrEmpty(categorieM))
                    {


                        if (!string.IsNullOrEmpty(categorieM))
                        {
                            if (categorieM.Contains("###"))
                            {
                                string[] catAr = categorieM.Split(new string[] { "###" }, StringSplitOptions.None);
                                foreach (string str in catAr)
                                {
                                    if (!string.IsNullOrEmpty(str))
                                    {
                                        CategorieMerceologiche c = new CategorieMerceologiche();
                                        c.idTipologica = "categorieMerceologiche";
                                        c.codice = str;
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

                    ModalitaAcquisizione modalitaAcquisizione = new ModalitaAcquisizione();
                    if (dt.Rows[i]["pcp_ModalitaAcquisizione"] != null && (!string.IsNullOrEmpty(dt.Rows[i]["pcp_ModalitaAcquisizione"].ToString())))
                    {
                        modalitaAcquisizione.codice = dt.Rows[i]["pcp_ModalitaAcquisizione"].ToString();
                        modalitaAcquisizione.idTipologica = "modalitaAcquisizione";
                        l.modalitaAcquisizione = modalitaAcquisizione;
                    }

                    if (dt.Rows[i]["pcp_PrestazioniComprese"] != null && (!string.IsNullOrEmpty(dt.Rows[i]["pcp_PrestazioniComprese"].ToString())))
                    {
                        prestazioniComprese p = new prestazioniComprese();
                        string prestazioniComprese = dt.Rows[i]["pcp_PrestazioniComprese"].ToString();
                        p.codice = prestazioniComprese;
                        p.idTipologica = "prestazioniComprese";
                        l.prestazioniComprese = p;
                    }

                    TipoFinanziamento t = new TipoFinanziamento();
                    if (dt.Rows[i]["TIPO_FINANZIAMENTO"] != null && (!string.IsNullOrEmpty(dt.Rows[i]["TIPO_FINANZIAMENTO"].ToString())))
                    {
                        t.idTipologica = "tipoFinanziamento";
                        t.codice = dt.Rows[i]["TIPO_FINANZIAMENTO"].ToString();
                    }

                    List<Finanziamenti> lFin = new List<Finanziamenti>();
                    Finanziamenti finanziamento = new Finanziamenti();
                    finanziamento.tipoFinanziamento = t;
                    lFin.Add(finanziamento);


                    if (dt.Rows[i]["pcp_ImportoFinanziamento"] != null && (!string.IsNullOrEmpty(dt.Rows[i]["pcp_ImportoFinanziamento"].ToString())))
                    {
                        finanziamento.importo = UtilsConvert.ToDecimal(dt.Rows[i]["pcp_ImportoFinanziamento"].ToString());

                    }
                    else
                    {
                        finanziamento.importo = 0;
                    }

                    l.finanziamenti = lFin; // finanziamento;

                    TipoRealizzazione tr = new TipoRealizzazione();
                    tr.idTipologica = "tipoRealizzazione";
                    tr.codice = dt3.Rows[0]["Concessione"].ToString() == "no" ? "1" : "2";

                    l.tipoRealizzazione = tr;

                    DatiBaseP7_1_2 datiBase = new DatiBaseP7_1_2();
                    
                    OggettoContratto ogg = new OggettoContratto();
                    ogg.idTipologica = "oggettoContratto";
                    ogg.codice = dt.Rows[i]["oggettoContratto"].ToString();

                    decimal valorebase = 0;
                    datiBase.oggetto = dt2.Rows[0]["Oggetto"] != null ? dt2.Rows[0]["Oggetto"].ToString() : string.Empty;
                    datiBase.oggettoContratto = ogg;

                    if (!string.IsNullOrEmpty(dt.Rows[i]["ValoreBase"].ToString()))
                    {
                        valorebase = UtilsConvert.ToDecimal(dt.Rows[i]["ValoreBase"].ToString());  //TODO: cosa fare se null
                    }

                    datiBase.importo = valorebase;
                    l.datiBase = datiBase;

                    QuadroEconomicoStandard qs = new QuadroEconomicoStandard();
                    if (!string.IsNullOrEmpty(dt.Rows[i]["UlterioriSommeNoRibasso"].ToString()))
                    {
                        qs.ulterioriSommeNoRibasso = UtilsConvert.ToDecimal(dt.Rows[i]["UlterioriSommeNoRibasso"].ToString());
                    }
                    else
                    {
                        qs.ulterioriSommeNoRibasso = 0;
                    }


                    qs.sommeOpzioniRinnovi = 0;

                    if (!string.IsNullOrEmpty(dt.Rows[i]["sommeOpzioniRinnovi"].ToString()))
                    {
                        qs.sommeOpzioniRinnovi = UtilsConvert.ToDecimal(dt.Rows[i]["sommeOpzioniRinnovi"].ToString());
                    }
                    else
                    {
                        qs.sommeOpzioniRinnovi = 0;
                    }

                    if (!string.IsNullOrEmpty(dt.Rows[i]["sommeADisposizione"].ToString()))
                    {
                        qs.sommeADisposizione = UtilsConvert.ToDecimal(dt.Rows[i]["sommeADisposizione"].ToString());
                    }
                    else
                    {
                        qs.sommeADisposizione = 0;
                    }


                    qs.impForniture = UtilsConvert.ToDecimal(dt.Rows[i]["impForniture"].ToString());
                    qs.impServizi = UtilsConvert.ToDecimal(dt.Rows[i]["impServizi"].ToString());
                    
                    if (!string.IsNullOrEmpty(dt.Rows[i]["impLavori"].ToString()))
                    {
                        qs.impLavori = UtilsConvert.ToDecimal(dt.Rows[i]["impLavori"].ToString());
                    }
                    else
                    {
                        qs.impLavori = 0;
                    }


                    if (!string.IsNullOrEmpty(dt.Rows[i]["impProgettazione"].ToString()))
                    {
                        qs.impProgettazione = UtilsConvert.ToDecimal(dt.Rows[i]["impProgettazione"].ToString());
                    }
                    else
                    {
                        qs.impProgettazione = 0;
                    }

                    if (!string.IsNullOrEmpty(dt.Rows[i]["impTotaleSicurezza"].ToString()))
                    {
                        qs.impTotaleSicurezza = UtilsConvert.ToDecimal(dt.Rows[i]["impTotaleSicurezza"].ToString());
                    }
                    else
                    {
                        qs.impTotaleSicurezza = 0;
                    }


                    if (!string.IsNullOrEmpty(dt.Rows[i]["sommeRipetizioni"].ToString()))
                    {
                        qs.sommeRipetizioni = UtilsConvert.ToDecimal(dt.Rows[i]["sommeRipetizioni"].ToString());
                    }
                    else
                    {
                        qs.sommeRipetizioni = 0;
                    }


                    /*
                    int tipoBandoGara = Convert.ToInt32(dt.Rows[i]["TipoBandoGara"].ToString());
                    //decimal valorebase = 0;
                    //if (!string.IsNullOrEmpty(dt.Rows[i]["ValoreBase"].ToString()))
                    //{
                    //    valorebase = UtilsConvert.ToDecimal(dt.Rows[i]["ValoreBase"].ToString());
                    //}
                    if (tipoBandoGara == 2)
                    {
                        qs.impLavori = valorebase;
                    }
                    else if (tipoBandoGara == 3)
                    {
                        qs.impServizi = valorebase;
                    }
                    if (dt.Rows[i]["ImportoSicurezza"] != null)
                    {
                        string importo = dt.Rows[i]["ImportoSicurezza"].ToString();
                        if (!string.IsNullOrEmpty(importo))
                        {
                            qs.impForniture = UtilsConvert.ToDecimal(dt.Rows[i]["ImportoSicurezza"].ToString());
                        }
                    }
                    */

                    l.quadroEconomicoStandard = qs;

					
					//tolto perche sembra un campo mai esistito; è sempre esistito il campo datiBaseTerminiInvio che era opzionale
					//	l.datiBaseTermineInvio = dataTermineInvito ;
					


					//NOTA BENE: per la nuova versione dalla 01.00.01 in avanti aggiungiamo sempre il campo datiBaseTerminiInvio che è diventato obbligatorio
					//per la P7_1_2 e P7_1_3
					l.datiBaseTerminiInvio = new DatiBaseTerminiInvio2()
					{
					    scadenzaPresentazioneInvito = Convert.ToDateTime ( dt2.Rows[0]["oraScadenzaPresentazioneOfferte"].ToString()),
					};


					//se valorizzato (nuova versione dalla '2024_01_31') aggiungo datiBaseDocumenti.url
					if (!string.IsNullOrEmpty(dt2.Rows[0]["datiBaseDocumenti_url"].ToString()))
					{
						DatiBaseDocumenti dbaseDoc = new DatiBaseDocumenti();
						dbaseDoc.url = dt2.Rows[0]["datiBaseDocumenti_url"].ToString();

						l.datiBaseDocumenti = dbaseDoc;
					}



					listaLotti.Add(l);
                }
            }

            return mergeLottiP7_1_2(listaLotti);

        }

        private List<Lotti> recuperaLotti(int idDoc)
        {
            DataTable dt = new DataTable();

            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idGara", idDoc);
            string strSql = "GET_DATI_SCHEDA_PCP_DETAIL";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.StoredProcedure;
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

					l.ccnl =  dt.Rows[i]["ccnl"].ToString();

                    if (dt.Rows[i]["CUP"] != null && !string.IsNullOrEmpty(dt.Rows[i]["CUP"].ToString()))
                    {

                        string cups = dt.Rows[i]["CUP"].ToString();
                        if (cups.Contains("###"))
                        {
                            string[] cupsAr = cups.Split(new string[] { "###" }, StringSplitOptions.None);
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

                    if (dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"] != null && dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"].ToString() != "")
                    {
                        ContrattiDisposizioniParticolari cd = new ContrattiDisposizioniParticolari();
                        cd.idTipologica = "contrattiDisposizioniParticolari";
                        cd.codice = dt.Rows[0]["pcp_ContrattiDisposizioniParticolari"].ToString();
                        l.contrattiDisposizioniParticolari = cd;
                    }

                    CodIstat istat = new CodIstat();
                    istat.idTipologica = "codIstat";
                    istat.codice = dt.Rows[0]["codIstat"].ToString();
                    l.codIstat = istat;
                    l.afferenteInvestimentiPNRR = false;

                    l.acquisizioneCup = UtilsConvert.ToBool(dt.Rows[i]["acquisizioneCup"].ToString());

                    List<string> listCupLotto = new List<string>();

                    if (dt.Rows[i]["CUP"] != null && !string.IsNullOrEmpty(dt.Rows[i]["CUP"].ToString()))
                    {
                        string cupLotto = dt.Rows[i]["CUP"].ToString();
                        if (cupLotto.Contains("###"))
                        {
                            string[] cupLottoAr = cupLotto.Split(new string[] { "###" }, StringSplitOptions.None);
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

                    ModalitaAcquisizione m = new ModalitaAcquisizione();
                    if (dt.Rows[i]["pcp_ModalitaAcquisizione"] != null && (!string.IsNullOrEmpty(dt.Rows[i]["pcp_ModalitaAcquisizione"].ToString())))
                    {
                        m.codice = dt.Rows[i]["pcp_ModalitaAcquisizione"].ToString();
                        m.idTipologica = "modalitaAcquisizione";
                        l.modalitaAcquisizione = m;
                    }

                    if (dt.Rows[i]["pcp_PrestazioniComprese"] != null)
                    {
                        string prestazioniComprese = dt.Rows[i]["pcp_PrestazioniComprese"].ToString();

                        prestazioniComprese p = new prestazioniComprese();
                        p.idTipologica = "prestazioniComprese";
                        p.codice = prestazioniComprese;

                        l.prestazioniComprese = p;
                    }

                    l.servizioPubblicoLocale = UtilsConvert.ToBool(dt.Rows[i]["pcp_ServizioPubblicoLocale"].ToString());
					
                    l.ripetizioniEConsegneComplementari = dt.Rows[i]["ripetizioniEConsegneComplementari"] != null && (!string.IsNullOrEmpty(dt.Rows[i]["ripetizioniEConsegneComplementari"].ToString())) ? UtilsConvert.ToBool(dt.Rows[i]["ripetizioniEConsegneComplementari"].ToString()) : true;

					l.lavoroOAcquistoPrevistoInProgrammazione = UtilsConvert.ToBool(dt.Rows[i]["pcp_lavoroOAcquistoPrevistoInProgrammazione"].ToString());

                    List<TipologiaLavoro> tipoL = new List<TipologiaLavoro>();

                    if (dt.Rows[i]["pcp_TipologiaLavoro"] != null && (!string.IsNullOrEmpty(dt.Rows[i]["pcp_TipologiaLavoro"].ToString())))
                    {

                        string TipologieLavori = dt.Rows[i]["pcp_TipologiaLavoro"].ToString();

                        if (TipologieLavori.Contains("###"))
                        {
                            string[] TipLav = TipologieLavori.Split(new string[] { "###" }, StringSplitOptions.None);
                            foreach (string t in TipLav)
                            {
                                if (!string.IsNullOrEmpty(t))
                                {
                                    TipologiaLavoro tl = new TipologiaLavoro();

                                    tl.idTipologica = "tipologiaLavoro";
                                    tl.codice = t;

                                    tipoL.Add(tl);
                                }
                            }
                        }
                        else
                        {
                            TipologiaLavoro tl = new TipologiaLavoro();

                            tl.idTipologica = "tipologiaLavoro";
                            tl.codice = dt.Rows[i]["pcp_TipologiaLavoro"].ToString();

                            tipoL.Add(tl);
                        }


                    }

                    l.tipologiaLavoro = tipoL;


                    IpotesiCollegamento ipotesiCollegamento = new IpotesiCollegamento();
                    List<string> cigCollegato = new List<string>();
                    cigCollegato.Add(dt.Rows[i]["pcp_cigCollegato"].ToString());
                    ipotesiCollegamento.cigCollegato = cigCollegato;

                    ipotesiCollegamento.motivoCollegamento = new MotivoCollegamento() { idTipologica = "motivoCollegamento", codice = dt.Rows[i]["MOTIVO_COLLEGAMENTO"].ToString() };
                    l.ipotesiCollegamento = ipotesiCollegamento;




                    //l.opzioniRinnovi = true;
                    l.opzioniRinnovi = dt.Rows[i]["opzioniRinnovi"] != null && (!string.IsNullOrEmpty(dt.Rows[i]["opzioniRinnovi"].ToString())) ? UtilsConvert.ToBool(dt.Rows[i]["opzioniRinnovi"].ToString()) : true;

                    List<CategorieMerceologiche> listCatM = new List<CategorieMerceologiche>();

                    string categorieM = recuperaCategorieMerceologiche(idDoc);

                    if (!String.IsNullOrEmpty(categorieM))
                    {

                        //string cat = dt.Rows[i]["pcp_Categoria"].ToString();
                        if (!string.IsNullOrEmpty(categorieM))
                        {
                            if (categorieM.Contains("###"))
                            {
                                string[] catAr = categorieM.Split(new string[] { "###" }, StringSplitOptions.None);
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
                        qs.ulterioriSommeNoRibasso = UtilsConvert.ToDecimal(dt.Rows[i]["UlterioriSommeNoRibasso"].ToString());
                    }
                    else
                    {
                        qs.ulterioriSommeNoRibasso = 0;
                    }


                    qs.sommeOpzioniRinnovi = 0;
                    if (!string.IsNullOrEmpty(dt.Rows[i]["sommeOpzioniRinnovi"].ToString()))
                    {
                        qs.sommeOpzioniRinnovi = UtilsConvert.ToDecimal(dt.Rows[i]["sommeOpzioniRinnovi"].ToString());
                    }
                    else
                    {
                        qs.sommeOpzioniRinnovi = 0;
                    }

                    if (!string.IsNullOrEmpty(dt.Rows[i]["sommeADisposizione"].ToString()))
                    {
                        qs.sommeADisposizione = UtilsConvert.ToDecimal(dt.Rows[i]["sommeADisposizione"].ToString());
                    }
                    else
                    {
                        qs.sommeADisposizione = 0;
                    }


                    qs.impProgettazione = 0;

                    if (!string.IsNullOrEmpty(dt.Rows[i]["impProgettazione"].ToString()))
                    {
                        qs.impProgettazione = UtilsConvert.ToDecimal(dt.Rows[i]["impProgettazione"].ToString());
                    }


                    qs.impTotaleSicurezza = 0;

                    if (!string.IsNullOrEmpty(dt.Rows[i]["impTotaleSicurezza"].ToString()))
                    {
                        qs.impTotaleSicurezza = UtilsConvert.ToDecimal(dt.Rows[i]["impTotaleSicurezza"].ToString());
                    }

                    if (!string.IsNullOrEmpty(dt.Rows[i]["sommeRipetizioni"].ToString()))
                    {
                        qs.sommeRipetizioni = UtilsConvert.ToDecimal(dt.Rows[i]["sommeRipetizioni"].ToString());
                    }
                    else
                    {
                        qs.sommeRipetizioni = 0;
                    }

                    //qs.impForniture = 0;
                    //qs.impServizi = 0;
                    //qs.impLavori = 0;

                    qs.impLavori = UtilsConvert.ToDecimal(dt.Rows[i]["impLavori"].ToString());

                    qs.impServizi = UtilsConvert.ToDecimal(dt.Rows[i]["impServizi"].ToString());

                    qs.impForniture = UtilsConvert.ToDecimal(dt.Rows[i]["impForniture"].ToString());

                    /*
                    int tipoBandoGara = Convert.ToInt32(dt.Rows[i]["TipoBandoGara"].ToString());
                    decimal valorebase = 0;
                    if (!string.IsNullOrEmpty(dt.Rows[i]["ValoreBase"].ToString()))
                    {
                        valorebase = UtilsConvert.ToDecimal(dt.Rows[i]["ValoreBase"].ToString());
                    }
                    if (tipoBandoGara == 2)
                    {
                        qs.impLavori = valorebase;
                    }
                    else if (tipoBandoGara == 3)
                    {
                        qs.impServizi = valorebase;
                    }
                    if (dt.Rows[i]["ImportoSicurezza"] != null)
                    {
                        string importo = dt.Rows[i]["ImportoSicurezza"].ToString();
                        if (!string.IsNullOrEmpty(importo))
                        {
                            qs.impForniture = UtilsConvert.ToDecimal(dt.Rows[i]["ImportoSicurezza"].ToString());
                        }
                    }
                    */

                    l.quadroEconomicoStandard = qs;

                    //se non passato non lo aggiungo al json
                    if (!string.IsNullOrEmpty(dt.Rows[i]["StrumentiElettroniciSpecifici"].ToString()))
                    {
                        l.strumentiElettroniciSpecifici = UtilsConvert.ToBool(dt.Rows[i]["StrumentiElettroniciSpecifici"]);
                    }
                    else
                        l.strumentiElettroniciSpecifici = null;



                    listaLotti.Add(l);
                }
            }

            return mergeLotti(listaLotti);
        }

        public List<LottiP2_16> mergeLottiP2_16(List<LottiP2_16> listOfLotti)
        {
            List<LottiP2_16> listToReturn = new List<LottiP2_16>();

            foreach (var lotto in listOfLotti)
            {
                if (listToReturn.FindAll(x =>
                {
                    return x.lotIdentifier == lotto.lotIdentifier;
                }).Count == 0)
                {
                    listToReturn.Add(lotto);
                }
                else
                {
                    var lottoAlreadyAdded = listToReturn.Find(x =>
                    {
                        return x.lotIdentifier == lotto.lotIdentifier;
                    });
                    lottoAlreadyAdded.quadroEconomicoStandard.impForniture += lotto.quadroEconomicoStandard.impForniture;
                    lottoAlreadyAdded.quadroEconomicoStandard.impLavori += lotto.quadroEconomicoStandard.impLavori;
                    lottoAlreadyAdded.quadroEconomicoStandard.impProgettazione += lotto.quadroEconomicoStandard.impProgettazione;
                    lottoAlreadyAdded.quadroEconomicoStandard.impServizi += lotto.quadroEconomicoStandard.impServizi;
                    lottoAlreadyAdded.quadroEconomicoStandard.impTotaleSicurezza += lotto.quadroEconomicoStandard.impTotaleSicurezza;
                    lottoAlreadyAdded.quadroEconomicoStandard.sommeADisposizione += lotto.quadroEconomicoStandard.sommeADisposizione;
                    lottoAlreadyAdded.quadroEconomicoStandard.sommeOpzioniRinnovi += lotto.quadroEconomicoStandard.sommeOpzioniRinnovi;
                    lottoAlreadyAdded.quadroEconomicoStandard.sommeRipetizioni += lotto.quadroEconomicoStandard.sommeRipetizioni;
                    lottoAlreadyAdded.quadroEconomicoStandard.ulterioriSommeNoRibasso += lotto.quadroEconomicoStandard.ulterioriSommeNoRibasso;

                    if (string.IsNullOrEmpty(lottoAlreadyAdded.modalitaAcquisizione.codice))
                    {
                        lottoAlreadyAdded.modalitaAcquisizione.codice = lotto.modalitaAcquisizione.codice;
                    }
                }
            }

            return listToReturn;
        }

        public List<LottiP7_1_2> mergeLottiP7_1_2(List<LottiP7_1_2> listOfLotti)
        {
            List<LottiP7_1_2> listToReturn = new List<LottiP7_1_2>();

            foreach (var lotto in listOfLotti)
            {
                if (listToReturn.FindAll(x =>
                {
                    return x.lotIdentifier == lotto.lotIdentifier;
                }).Count == 0)
                {
                    listToReturn.Add(lotto);
                }
                else
                {
                    var lottoAlreadyAdded = listToReturn.Find(x =>
                    {
                        return x.lotIdentifier == lotto.lotIdentifier;
                    });
                    lottoAlreadyAdded.quadroEconomicoStandard.impForniture += lotto.quadroEconomicoStandard.impForniture;
                    lottoAlreadyAdded.quadroEconomicoStandard.impLavori += lotto.quadroEconomicoStandard.impLavori;
                    lottoAlreadyAdded.quadroEconomicoStandard.impProgettazione += lotto.quadroEconomicoStandard.impProgettazione;
                    lottoAlreadyAdded.quadroEconomicoStandard.impServizi += lotto.quadroEconomicoStandard.impServizi;
                    lottoAlreadyAdded.quadroEconomicoStandard.impTotaleSicurezza += lotto.quadroEconomicoStandard.impTotaleSicurezza;
                    lottoAlreadyAdded.quadroEconomicoStandard.sommeADisposizione += lotto.quadroEconomicoStandard.sommeADisposizione;
                    lottoAlreadyAdded.quadroEconomicoStandard.sommeOpzioniRinnovi += lotto.quadroEconomicoStandard.sommeOpzioniRinnovi;
                    lottoAlreadyAdded.quadroEconomicoStandard.sommeRipetizioni += lotto.quadroEconomicoStandard.sommeRipetizioni;
                    lottoAlreadyAdded.quadroEconomicoStandard.ulterioriSommeNoRibasso += lotto.quadroEconomicoStandard.ulterioriSommeNoRibasso;

                    if (string.IsNullOrEmpty(lottoAlreadyAdded.modalitaAcquisizione.codice))
                    {
                        lottoAlreadyAdded.modalitaAcquisizione.codice = lotto.modalitaAcquisizione.codice;
                    }
                }
            }

            return listToReturn;
        }
        public List<Lotti> mergeLotti(List<Lotti> listOfLotti)
        {
            //Si occupa di fare il merge dei lotti con lo stesso lotIdentifier
            List<Lotti> listToReturn = new List<Lotti>();

            foreach (var lotto in listOfLotti)
            {
                if (listToReturn.FindAll(x =>
                {
                    return x.lotIdentifier == lotto.lotIdentifier;
                }).Count == 0)
                {
                    listToReturn.Add(lotto);
                }
                else
                {
                    var lottoAlreadyAdded = listToReturn.Find(x =>
                    {
                        return x.lotIdentifier == lotto.lotIdentifier;
                    });
                    lottoAlreadyAdded.quadroEconomicoStandard.impForniture += lotto.quadroEconomicoStandard.impForniture;
                    lottoAlreadyAdded.quadroEconomicoStandard.impLavori += lotto.quadroEconomicoStandard.impLavori;
                    lottoAlreadyAdded.quadroEconomicoStandard.impProgettazione += lotto.quadroEconomicoStandard.impProgettazione;
                    lottoAlreadyAdded.quadroEconomicoStandard.impServizi += lotto.quadroEconomicoStandard.impServizi;
                    lottoAlreadyAdded.quadroEconomicoStandard.impTotaleSicurezza += lotto.quadroEconomicoStandard.impTotaleSicurezza;
                    lottoAlreadyAdded.quadroEconomicoStandard.sommeADisposizione += lotto.quadroEconomicoStandard.sommeADisposizione;
                    lottoAlreadyAdded.quadroEconomicoStandard.sommeOpzioniRinnovi += lotto.quadroEconomicoStandard.sommeOpzioniRinnovi;
                    lottoAlreadyAdded.quadroEconomicoStandard.sommeRipetizioni += lotto.quadroEconomicoStandard.sommeRipetizioni;
                    lottoAlreadyAdded.quadroEconomicoStandard.ulterioriSommeNoRibasso += lotto.quadroEconomicoStandard.ulterioriSommeNoRibasso;

                    if (string.IsNullOrEmpty(lottoAlreadyAdded.modalitaAcquisizione.codice))
                    {
                        lottoAlreadyAdded.modalitaAcquisizione.codice = lotto.modalitaAcquisizione.codice;
                    }
                }
            }

            return listToReturn;
        }

        public string getPayloadS2(int idGara, string idAppalto = null)
        {
            //var jsonSerializerOptions = new JsonSerializerOptions
            //{
            //    DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull
            //};
            //var jsonSerializerOptions = new JsonSerializerOptions
            //{
            //    Converters = { new NullExcludeConverter<BaseModelGeneric<SchedaGeneric<BodyS2>>>() }
            //};
            //string json = System.Text.Json.JsonSerializer.Serialize(baseModelS2, jsonSerializerOptions);
            //string json = System.Text.Json.JsonSerializer.Serialize(baseModelS2);
            //string json = System.Text.Json.JsonSerializer.Serialize(baseModelS2, Formatting.Indented,
            //    new JsonSerializerSettings { NullValueHandling = NullValueHandling.Ignore });

            PDNDUtils pu = new PDNDUtils();
            object s = pu.compilaScheda(idGara, "", "", null, TipoScheda.S2);

            var baseModelS2 = new BaseModelGeneric<SchedaGeneric<BodyS2>>();
            baseModelS2.scheda = (SchedaGeneric<BodyS2>)s;
            baseModelS2.idAppalto = idAppalto;

            string json = AnacFormUtils.getJsonWithOptAttrib(baseModelS2);

            return json;
        }

        public string getPayloadS1(int idGara, string idAppalto = null)
        {

            PDNDUtils pu = new PDNDUtils();
            object s = pu.compilaScheda(idGara, "", "", null, TipoScheda.S1);

            var baseModelS1 = new BaseModelGeneric<SchedaGeneric<BodyS1>>();
            baseModelS1.scheda = (SchedaGeneric<BodyS1>)s;
            baseModelS1.idAppalto = idAppalto;

            string json = AnacFormUtils.getJsonWithOptAttrib(baseModelS1);

            return json;
        }

        public bool garaIsMultiLotto(int idGara)
        {
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idDoc", idGara);
            string strSql = "select isnull(Divisione_lotti,0) as Divisione_lotti from Document_Bando with(nolock) where idHeader = @idDoc";
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSql;
            conn.Open();
            object Divisione_lotti = (string)cmd.ExecuteScalar();
            conn.Close();
            string result = string.Empty;
            if (Divisione_lotti != null)
            {
                result = Divisione_lotti.ToString();
            }


            return result != "0";
        }

        public string recuperaLottiContratto(int idContratto)
        {
            string strToReturn = "";
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@IdContratto", idContratto);
            cmd.Parameters.AddWithValue("@Contesto", "LOTTI");
            string strSql_2 = "GET_DATI_SCHEDA_PCP_FROM_CONTRATTO";
            cmd.CommandText = strSql_2;
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable dt2 = new DataTable();
            SqlDataAdapter da2 = new SqlDataAdapter();
            da2.SelectCommand = cmd;
            da2.Fill(dt2);

            for (int i = 0; i < dt2.Rows.Count; i++)
            {
                strToReturn += dt2.Rows[i]["numeroLotto"] + ",";
            }

            return strToReturn;

        }
        public int recuperaPDAFromGara(int idGara)
        {
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idDoc", idGara);
            string strSql = "select ID from Ctl_doc with(nolock) where LinkedDoc = @idDoc and tipodoc = 'PDA_MICROLOTTI' and Deleted = 0";
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSql;
            conn.Open();
            object Id = cmd.ExecuteScalar();
            conn.Close();
            int result = 0;
            if (Id != null || !(Id is System.DBNull))
            {
                result = Convert.ToInt32(Id);
            }


            return result;


        }

        /// <summary>
        /// Metodo utile ad ottenere il payload json della scheda A1_29. aggiudicazione
        /// </summary>
        /// <param name="idGara">l'iddoc della procedura di gara</param>
        /// <param name="idAppalto">il guid della procedura di gara, è l'identificativo per PCP</param>
        /// <param name="IdDoc_Scheda">è l'iddoc del documento che innesca il giro. può essere sia il contratto ( CONTRATTO_GARA / SCRITTURA_PRIVATA ) sia l'id della convenzione ( CONVENZIONE ) </param>
        /// <returns>Scheda json dell'a1_29</returns>
        /// <exception cref="ApplicationException"></exception>
        public string getPayloadA1_29(int idGara, string idAppalto, int IdDoc_Scheda)
        {

            PDNDUtils pu = new PDNDUtils();
            //generazione Can29

            string respCan29 = null;
            bool isMultiLotto = pu.garaIsMultiLotto(idGara);

            INIPEC.Controllers.CAN29Controller cAN29Controller = new INIPEC.Controllers.CAN29Controller();
            int idPDA = pu.recuperaPDAFromGara(idGara);

            if (isMultiLotto)
            {
                string listaLotti = pu.recuperaLottiContratto(idContratto: IdDoc_Scheda);
                respCan29 = cAN29Controller.GenerateXml(idPDA.ToString(), operation: "", lotto: listaLotti, idContrattoConv: IdDoc_Scheda).Content.ReadAsStringAsync().Result;
            }
            else
            {
                respCan29 = cAN29Controller.GenerateXml(idPDA.ToString(), operation: "monolotto", idContrattoConv: IdDoc_Scheda).Content.ReadAsStringAsync().Result;
            }

            if (respCan29 == null || !respCan29.StartsWith("1#"))
            {
                if (respCan29.StartsWith("0#"))
                {
                    throw new ApplicationException(respCan29.Substring(2));
                }
                throw new ApplicationException("Errore generazione XML eForm CAN29 necessario per la scheda A1_29");
            }


            //Can29 generato
            string eform = pu.recuperaEFormXml(idGara, "CAN29");
            string eformXml64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(eform));
            object s = pu.compilaScheda(idGara, eformXml64, "", null, TipoScheda.A1_29, IdDoc_Scheda);

            var baseModelA1_29 = new BaseModelGeneric<SchedaGeneric<BodyA1_29>>();
            baseModelA1_29.scheda = (SchedaGeneric<BodyA1_29>)s;
            baseModelA1_29.idAppalto = idAppalto;

            string json = AnacFormUtils.getJsonWithOptAttrib(baseModelA1_29);

            return json;
        }

        public string getPayloadA2_29(int idGara, string idAppalto, int IdDoc_Scheda)
        {
            
            PDNDUtils pu = new PDNDUtils();
            object s = pu.compilaScheda(idGara, "", "", null, TipoScheda.A2_29, IdDoc_Scheda);

            var baseModelA2_29 = new BaseModelGeneric<SchedaGeneric<BodyA2_29>>();
            baseModelA2_29.scheda = (SchedaGeneric<BodyA2_29>)s;
            baseModelA2_29.idAppalto = idAppalto;

            string json = AnacFormUtils.getJsonWithOptAttrib(baseModelA2_29);

            return json;
        }

        public string getPayloadS3(int idGara, string idAppalto, int IdDoc_Scheda)
        {

            PDNDUtils pu = new PDNDUtils();
            object s = pu.compilaScheda(idGara, "", "", null, TipoScheda.S3, IdDoc_Scheda);

            var baseModelS3 = new BaseModelGeneric<SchedaGeneric<BodyS3>>();
            baseModelS3.scheda = (SchedaGeneric<BodyS3>)s;
            baseModelS3.idAppalto = idAppalto;

            string json = AnacFormUtils.getJsonWithOptAttrib(baseModelS3);

            return json;
        }

        public string getPayloadSC1(int idGara, string idAppalto, int IdDoc_Scheda)
        {
            PDNDUtils pu = new PDNDUtils();
            Dati_PCP dati = pu.recuperaDatiPerVoucher(idGara);
            object s = pu.compilaScheda(idGara, "", "", dati, TipoScheda.SC1, IdDoc_Scheda);
            var baseModelSC1 = new BaseModelGeneric<SchedaGeneric<BodySC1>>();
            baseModelSC1.scheda = (SchedaGeneric<BodySC1>)s;
            baseModelSC1.idAppalto = idAppalto;

            string json = AnacFormUtils.getJsonWithOptAttrib(baseModelSC1);

            return json;
        }

        public string getPayloadNAG(int idGara, int IdDoc_Scheda, string CIG, string DatiElaborazione)
        {
            PDNDUtils pu = new PDNDUtils();
            Dati_PCP dati = pu.recuperaDatiPerVoucher(idGara);
            SchedaGeneric<BodyNAG> s = (SchedaGeneric<BodyNAG>)pu.compilaScheda(idGara, "", "", dati, TipoScheda.NAG, IdDoc_Scheda, CIG, DatiElaborazione);

            SchedaNAG schedaNAG = new SchedaNAG();
            schedaNAG.scheda = s;
            schedaNAG.idAppalto = recuperaIdAppalto(idGara);


            string json = AnacFormUtils.getJsonWithOptAttrib(schedaNAG);

            return json;
        }

        public class SchedaNAG
        {
            public string idAppalto { get; set; }
            public SchedaGeneric<BodyNAG> scheda { get; set; }
        }



        public object compilaScheda(int idDoc, string eformXml64, string espdXml64, Dati_PCP dati, TipoScheda tipoScheda, int IdDoc_Scheda = 0, string CIG = "", string DatiEaborazione = "")
        {

            switch (tipoScheda)
            {
                case TipoScheda.P1_16:
                    Scheda s = new Scheda();
                    Appalto appalto = new Appalto();
                    Body body = new Body();
                    AnacForm aForm = new AnacForm();
                    aForm = recuperaAnacFormP1_16(idDoc, dati);
                    body.anacForm = aForm;

                    Codice c = new Codice();
                    c.idTipologica = "codiceScheda";
                    c.codice = "P1_16";
                    s.codice = c;
                    s.versione = "1.0";
                    s.body = body;
                    s.body.espd = espdXml64;
                    s.body.eform = eformXml64;
                    return s;
                case TipoScheda.P1_19:
                    SchedaP1_19 schedaP1_19 = new SchedaP1_19();
                    AppaltoP1_19 appaltoP1_19 = new AppaltoP1_19();
                    BodyP1_19 bodyP1_19 = new BodyP1_19();
                    AnacFormP1_19 anacFormP1_19 = new AnacFormP1_19();
                    anacFormP1_19 = recuperaAnacFormP1_19(idDoc, dati);
                    bodyP1_19.anacForm = anacFormP1_19;

                    Codice cP1_19 = new Codice();
                    cP1_19.idTipologica = "codiceScheda";
                    cP1_19.codice = "P1_19";
                    schedaP1_19.codice = cP1_19;
                    schedaP1_19.versione = "1.0";
                    schedaP1_19.body = bodyP1_19;
                    schedaP1_19.body.eform = eformXml64;
                    schedaP1_19.body.espd = espdXml64;
                    return schedaP1_19;
                case TipoScheda.P2_16:
                    SchedaP2_16 schedaP2_16 = new SchedaP2_16();
                    AppaltoP2_16 appaltoP2_16 = new AppaltoP2_16();
                    BodyP2_16 bodyP2_16 = new BodyP2_16();
                    AnacFormP2_16 aFormP2_16 = new AnacFormP2_16();
                    aFormP2_16 = recuperaAnacFormP2_16(idDoc, dati);
                    bodyP2_16.anacForm = aFormP2_16;

                    Codice cP2_16 = new Codice();
                    cP2_16.idTipologica = "codiceScheda";
                    cP2_16.codice = "P2_16";
                    schedaP2_16.codice = cP2_16;
                    schedaP2_16.versione = "1.0";
                    schedaP2_16.body = bodyP2_16;
                    schedaP2_16.body.espd = espdXml64;
                    return schedaP2_16;
                case TipoScheda.AD2_25:
                    SchedaAd2_25 schedaAD2_25 = new SchedaAd2_25();
                    AppaltoAD2_25 appaltoAD2_25 = new AppaltoAD2_25();
                    BodyAD2_25 bodyAD2_25 = new BodyAD2_25();
                    AnacFormAD2_25 anacFormAD2_25 = new AnacFormAD2_25();
                    anacFormAD2_25 = recuperaAnacFormAD2_25(idDoc, dati);
                    bodyAD2_25.anacForm = anacFormAD2_25;
                    Codice cAD2_25 = new Codice();
                    cAD2_25.idTipologica = "codiceScheda";
                    cAD2_25.codice = "AD2_25";
                    schedaAD2_25.codice = cAD2_25;
                    schedaAD2_25.versione = "1.0";
                    schedaAD2_25.body = bodyAD2_25;
                    schedaAD2_25.body.espd = espdXml64;
                    return schedaAD2_25;
                case TipoScheda.AD_3:
                    SchedaAD3 sAD3 = new SchedaAD3();
                    AppaltoAD3 appaltoAD_3 = new AppaltoAD3();
                    BodyAD3 bodyAD_3 = new BodyAD3();
                    AnacFormAD3 aFormAD_3 = new AnacFormAD3();
                    aFormAD_3 = recuperaAnacFormAD3(idDoc, dati);

                    Codice cAD_3 = new Codice();
                    cAD_3.idTipologica = "codiceScheda";
                    cAD_3.codice = "AD3";
                    sAD3.codice = cAD_3;
                    sAD3.versione = "1.0";
                    sAD3.body = bodyAD_3;
                    sAD3.body.espd = !string.IsNullOrEmpty(espdXml64) ? espdXml64 : ""; ;
                    sAD3.body.anacForm = aFormAD_3;
                    return sAD3;
                case TipoScheda.AD_5:
                    SchedaAD3 sAD5 = new SchedaAD3();
                    AppaltoAD3 appaltoAD_5 = new AppaltoAD3();
                    BodyAD3 bodyAD_5 = new BodyAD3();
                    AnacFormAD3 aFormAD_5 = new AnacFormAD3();
                    aFormAD_5 = recuperaAnacFormAD5(idDoc, dati);

                    Codice cAD_5 = new Codice();
                    cAD_5.idTipologica = "codiceScheda";
                    cAD_5.codice = "AD5";
                    sAD5.codice = cAD_5;
                    sAD5.versione = "1.0";
                    sAD5.body = bodyAD_5;
                    sAD5.body.espd = !string.IsNullOrEmpty(espdXml64) ? espdXml64 : "";
                    sAD5.body.anacForm = aFormAD_5;
                    return sAD5;
                case TipoScheda.S2:
                    SchedaGeneric<BodyS2> schedaS2 = new SchedaGeneric<BodyS2>();
                    BodyS2 bodyS2 = new BodyS2();
                    AnacFormS2 aFormS2 = new AnacFormS2();

                    aFormS2 = recuperaAnacFormS2(idDoc, dati);

                    Codice cS2 = new Codice();
                    cS2.idTipologica = "codiceScheda";
                    cS2.codice = "S2";

                    schedaS2.codice = cS2;
                    schedaS2.versione = "1.0";

                    schedaS2.body = bodyS2;
                    schedaS2.body.anacForm = aFormS2;

                    return schedaS2;
                case TipoScheda.S1:
                    SchedaGeneric<BodyS1> schedaS1 = new SchedaGeneric<BodyS1>();
                    var bodyS1 = new BodyS1();

                    AnacFormS1 aFormS1 = recuperaAnacFormS1(idDoc, dati);

                    var cS1 = new Codice();
                    cS1.idTipologica = "codiceScheda";
                    cS1.codice = "S1";

                    schedaS1.codice = cS1;
                    schedaS1.versione = "1.0";

                    schedaS1.body = bodyS1;
                    schedaS1.body.anacForm = aFormS1;

                    return schedaS1;
                case TipoScheda.P7_2:
                    SchedaP7_2 sP7_2 = new SchedaP7_2();

                    sP7_2.codice = new Codice()
                    {
                        codice = "P7_2",
                        idTipologica = "codiceScheda"
                    };

                    sP7_2.versione = "1.0";

                    sP7_2.body = new BodyP7_2()
                    {
                        anacForm = recuperaAnacFormP7_2(idDoc, dati),
                        espd = espdXml64
                    };

                    return sP7_2;
                case TipoScheda.A1_29:
                    SchedaGeneric<BodyA1_29> schedaA1_29 = new SchedaGeneric<BodyA1_29>();
                    var bodyA1_29 = new BodyA1_29();

                    AnacFormA1_29 aFormA1_29 = recuperaAnacFormA1_29(idDoc, dati, IdDoc_Scheda);

                    var cA1_29 = new Codice();
                    cA1_29.idTipologica = "codiceScheda";
                    cA1_29.codice = "A1_29";

                    schedaA1_29.codice = cA1_29;
                    schedaA1_29.versione = "1.0";

                    schedaA1_29.body = bodyA1_29;
                    schedaA1_29.body.anacForm = aFormA1_29;

                    schedaA1_29.body.eform = eformXml64;


                    return schedaA1_29;

                case TipoScheda.A2_29:
                    SchedaGeneric<BodyA2_29> schedaA2_29 = new SchedaGeneric<BodyA2_29>();
                    var bodyA2_29 = new BodyA2_29();

                    AnacFormA2_29 aFormA2_29 = recuperaAnacFormA2_29(idDoc, dati, IdDoc_Scheda);

                    var cA2_29 = new Codice();
                    cA2_29.idTipologica = "codiceScheda";
                    cA2_29.codice = "A2_29";

                    schedaA2_29.codice = cA2_29;
                    schedaA2_29.versione = "1.0";

                    schedaA2_29.body = bodyA2_29;
                    schedaA2_29.body.anacForm = aFormA2_29;

                    return schedaA2_29;

                case TipoScheda.S3:
                    SchedaGeneric<BodyS3> schedaS3 = new SchedaGeneric<BodyS3>();
                    var bodyS3 = new BodyS3();

                    AnacFormS3 aFormS3 = recuperaAnacFormS3(idDoc, dati, IdDoc_Scheda);

                    var cS3 = new Codice();
                    cS3.idTipologica = "codiceScheda";
                    cS3.codice = "S3";

                    schedaS3.codice = cS3;
                    schedaS3.versione = "1.0";

                    schedaS3.body = bodyS3;
                    schedaS3.body.anacForm = aFormS3;


                    return schedaS3;

                case TipoScheda.SC1:
                    SchedaGeneric<BodySC1> schedaSC1 = new SchedaGeneric<BodySC1>();
                    var bodySC1 = new BodySC1();

                    AnacFormSC1 aFormSC1 = recuperaAnacFormSC1(idDoc, dati, IdDoc_Scheda);
                    var cSC1 = new Codice();
                    cSC1.idTipologica = "codiceScheda";
                    cSC1.codice = "SC1";

                    schedaSC1.codice = cSC1;
                    schedaSC1.versione = "1.0";

                    schedaSC1.body = bodySC1;
                    schedaSC1.body.anacForm = aFormSC1;


                    return schedaSC1;
                case TipoScheda.P7_1_2:
                    SchedaP7_1_2 schedaP7_1_2 = new SchedaP7_1_2();
                    AppaltoP7_1_2 appaltoP7_1_2 = new AppaltoP7_1_2();
                    BodyP7_1_2 bodyP7_1_2 = new BodyP7_1_2();
                    AnacFormP7_1_2 aFormP7_1_2 = new AnacFormP7_1_2();
                    aFormP7_1_2 = recuperaAnacFormP7_1_2(idDoc, dati);

                    bodyP7_1_2.anacForm = aFormP7_1_2;



                    Codice cP7_1_2 = new Codice();
                    cP7_1_2.idTipologica = "codiceScheda";
                    cP7_1_2.codice = "P7_1_2";

                    schedaP7_1_2.codice = cP7_1_2;
                    schedaP7_1_2.versione = "1.0";

                    schedaP7_1_2.body = bodyP7_1_2;
                    //schedaP7_1_2.body.anacForm = aFormP7_1_2;

                    return schedaP7_1_2;
                case TipoScheda.P7_1_3:
                    SchedaP7_1_3 schedaP7_1_3 = new SchedaP7_1_3();

                    schedaP7_1_3.codice = new Codice()
                    {
                        codice = "P7_1_3",
                        idTipologica = "codiceScheda"
                    };

                    schedaP7_1_3.versione = "1.0";

                    schedaP7_1_3.body = new BodyP7_1_3()
                    {
                        anacForm = recuperaAnacFormP7_1_3(idDoc, dati)
                    };

                    return schedaP7_1_3;
                case TipoScheda.NAG:
                    SchedaGeneric<BodyNAG> schedaNAG = new SchedaGeneric<BodyNAG>();
                    var bodyNAG = new BodyNAG();

                    AnacFormNAG aFormNAG = recuperaAnacFormNAG(idDoc, dati, IdDoc_Scheda, CIG, DatiEaborazione);

                    var codNAG = new Codice();
                    codNAG.idTipologica = "codiceScheda";
                    codNAG.codice = "NAG";

                    schedaNAG.codice = codNAG;
                    schedaNAG.versione = "1.0";

                    schedaNAG.body = bodyNAG;
                    schedaNAG.body.anacForm = aFormNAG;

                    return schedaNAG;
                default:
                    break; //TODO: Lanciare un application exception per tipo scheda non gestito ?
            }
            throw new NotImplementedException();
        }


        public string GetVoucher(PDNDClient client, string stringJws, HttpMethod method, int idDoc = 0)
        {
            PDNDUtils pu = new PDNDUtils();

            pu.InsertTrace("PCP", $"Inizio chiamata a PDNDRequest() - clientId : {client.clientId} - INPUT : {stringJws}", idDoc);

            string risposta = client.PDNDRequest(client.url, stringJws, method, idDoc);

            pu.InsertTrace("PCP", $"Fine chiamata a PDNDRequest() - OUTPUT : {risposta}", idDoc);

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
            string strSql = "SELECT CATEGORIE_MERC FROM Document_Bando with(nolock) where idHeader = @idDoc";
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

        public string traduciTipoScheda(TipoScheda? ts)
        {
            if (ts == null)
            {
                return "";
            }
            else
            {
                switch (ts)
                {
                    case TipoScheda.P1_16:
                        return "P1_16";
                    case TipoScheda.AD_3:
                        return "AD3";
                    case TipoScheda.AD_4:
                        return "AD4";
                    case TipoScheda.AD_5:
                        return "AD5";
                    case TipoScheda.S1:
                        return "S1";
                    case TipoScheda.S2:
                        return "S2";
                    case TipoScheda.P2_16:
                        return "P2_16";
                    case TipoScheda.P2_19:
                        return "P2_19";
                    case TipoScheda.P6_2:
                        return "P6_2";
                    case TipoScheda.P7_2:
                        return "P7_2";
                    case TipoScheda.AD2_25:
                        return "AD2_25";
                    case TipoScheda.A2_29:
                        return "A2_29";
                    case TipoScheda.S3:
                        return "S3";
                    case TipoScheda.SC1:
                        return "SC1";
                    case TipoScheda.A1_29:
                        return "A1_29";
                    case TipoScheda.P7_1_2:
                        return "P7_1_2";
                    case TipoScheda.P7_1_3:
                        return "P7_1_3";
                    case TipoScheda.P1_19:
                        return "P1_19";
                    case TipoScheda.A7_1_2:
                        return "A7_1_2";
                    default:
                        return "P1_16";
                }
            }
        }

        public void inserisciLogIntegrazione(int idRichiesta, string operazioneRichiesta, string statorichiesta, TipoScheda? tipoScheda, string datoRichiesto, string msgErrore, string jsonSent, string jsonReceived, DateTime dataIn, DateTime dataExecuted, DateTime dataFinalizza, int idPfu, int idAzi, string inOut)
        {
            try
            {
                cmd.Parameters.Clear();
                cmd.Parameters.AddWithValue("@idRichiesta", idRichiesta);
                cmd.Parameters.AddWithValue("@integrazione", "PCP");
                cmd.Parameters.AddWithValue("@operazioneRichiesta", operazioneRichiesta);
                cmd.Parameters.AddWithValue("@statoRichiesta", statorichiesta);

                //Inseriamo tipoScheda nell'esito operazione solo se lo passa il chiamante. Era sbagliato il modo di recuperarlo. Fatto sempre allo stesso modo
                //  se il chiamante passa null in tipoScheda vuol dire che si preoccuperà lui di valorizzare correttamente "datoRichiesto"
                if (tipoScheda != null)
                    cmd.Parameters.AddWithValue("@datoRichiesto", traduciTipoScheda(tipoScheda) + "@@@" + datoRichiesto);
                else
                    cmd.Parameters.AddWithValue("@datoRichiesto", datoRichiesto);

                cmd.Parameters.AddWithValue("@msgError", msgErrore);
                cmd.Parameters.AddWithValue("@jsonSent", jsonSent);
                cmd.Parameters.AddWithValue("@jsonReceived", jsonReceived);
                cmd.Parameters.AddWithValue("@dataIn", dataIn);
                cmd.Parameters.AddWithValue("@dataExecuted", dataExecuted);
                cmd.Parameters.AddWithValue("@dataFinalizza", dataFinalizza);
                cmd.Parameters.AddWithValue("@idPfu", idPfu);
                cmd.Parameters.AddWithValue("@idAzi", idAzi);
                cmd.Parameters.AddWithValue("@inOut", inOut);

                string strSql = @"INSERT INTO Services_Integration_Request(idRichiesta, integrazione,operazioneRichiesta,statoRichiesta,datoRichiesto,msgError,numretry,inputWS,outputWS,isOld,dateIn, DataExecuted,DataFinalizza,idPfu,idAzi,InOut)  
                                    VALUES(@idRichiesta, @integrazione,@operazioneRichiesta,@statoRichiesta,@datoRichiesto,@msgError,0,@jsonSent,@jsonReceived,0,@dataIn,@dataExecuted,@dataFinalizza,@idPfu,@idAzi,@inOut)";

                cmd.CommandType = CommandType.Text;
                cmd.CommandText = strSql;

                conn.Open();
                cmd.ExecuteNonQuery();
            }
            finally
            {
                conn.Close();
            }

        }

        public void InsertTrace(string contesto, string descrizione, int idDoc = 0)
        {
            try
            {
                cmd.Parameters.Clear();
                cmd.Parameters.AddWithValue("@contesto", contesto);
                cmd.Parameters.AddWithValue("@descrizione", descrizione);
                cmd.Parameters.AddWithValue("@idDoc", idDoc);

                string strSql = @"INSERT INTO CTL_TRACE ( contesto, data, descrizione, idDoc ) VALUES ( @contesto, getDate(), @descrizione, @idDoc )";

                cmd.CommandType = CommandType.Text;
                cmd.CommandText = strSql;

                conn.Open();
                cmd.ExecuteNonQuery();

                cmd.Parameters.Clear();
            }
            finally
            {
                conn.Close();
            }
        }

        public void InsertTrace(string contesto, string descrizione, string idPfu)
        {
            try
            {
                cmd.Parameters.Clear();
                cmd.Parameters.AddWithValue("@contesto", contesto);
                cmd.Parameters.AddWithValue("@descrizione", descrizione);
                cmd.Parameters.AddWithValue("@idPfu", idPfu);

                string strSql = @"INSERT INTO CTL_TRACE ( contesto, data, descrizione, idpfu ) VALUES ( @contesto, getDate(), @descrizione, @idPfu )";

                cmd.CommandType = CommandType.Text;
                cmd.CommandText = strSql;

                conn.Open();
                cmd.ExecuteNonQuery();

                cmd.Parameters.Clear();
            }
            finally
            {
                conn.Close();
            }
        }

        public void salvaIdAvviso(int idDoc, string idAvviso)
        {
            //TODO: inserire gli Sql Parameter su tutte le query di tutte le classi. non bisogna mai effettuare queste concatenazioni come facevamo in ASP
            string strSQL = "update Document_PCP_Appalto set pcp_CodiceAvviso = '" + idAvviso + "' where idHeader= " + idDoc;
            cmd.Parameters.Clear();
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSQL;
            conn.Open();
            cmd.ExecuteNonQuery();
            cmd.Clone();
            conn.Close();
        }

        public void salvaIdScheda(int idDoc, string idScheda)
        {
            string strSQL = "update Document_PCP_Appalto set pcp_CodiceScheda = '" + idScheda + "' where idHeader= " + idDoc;
            cmd.Parameters.Clear();
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSQL;
            conn.Open();
            cmd.ExecuteNonQuery();
            cmd.Clone();
            conn.Close();
        }

        public void aggiornaScheda(int idRow, string statoScheda, string idScheda = "")
        {
            string strSql = "update document_pcp_appalto_schede set statoScheda = @statoScheda " + (string.IsNullOrEmpty(idScheda) ? "" : ",idScheda = @idScheda") + " where idRow = @idRow";

            using (SqlConnection connection = new SqlConnection(ConfigurationManager.AppSettings["db.conn"]))
            {
                connection.Open();
                using (SqlCommand cmd1 = new SqlCommand(strSql, connection))
                {
                    if (!string.IsNullOrEmpty(idScheda))
                        cmd1.Parameters.AddWithValue("@idScheda", idScheda);

                    cmd1.Parameters.AddWithValue("@statoScheda", statoScheda);
                    cmd1.Parameters.AddWithValue("@idRow", idRow);
                    cmd1.ExecuteNonQuery();
                }
                connection.Close();
            }
        }

        public void avviaSentinellaRichiestaScheda(int idRic, int idPfu, string tipoScheda, string operazioneRichiesta, int IdDoc_Scheda)
        {
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idRic", idRic);
            cmd.Parameters.AddWithValue("@idPfu", idPfu);
            cmd.Parameters.AddWithValue("@tipoScheda", tipoScheda);
            cmd.Parameters.AddWithValue("@operazioneRichiesta", operazioneRichiesta);
            cmd.Parameters.AddWithValue("@IdDoc_Scheda", IdDoc_Scheda);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandText = "PCP_SCHEDE_INSERT_REQUEST";
            conn.Open();

            try
            {
                cmd.ExecuteNonQuery();
            }
            finally
            {
                conn.Close();
            }
        }

        public DatiScheda getDatiScheda(int idrow)
        {
            var datiScheda = new DatiScheda();
            var strconn = ConfigurationManager.AppSettings["db.conn"];
            var conn = new SqlConnection(strconn);
            var cmd = new SqlCommand
            {
                Connection = conn
            };

            try
            {
                const string strSql = @"select a.idHeader as idgara, a.statoScheda, isnull(a.idScheda,'') as idScheda, isnull(b.pcp_CodiceAppalto,'') as idAppalto, a.tipoScheda, a.IdDoc_Scheda, ISNULL( docScheda.TipoDoc,'') as TipoDoc_IdDoc_Scheda, ISNULL(a.CIG, '') as CIG, ISNULL(a.DatiElaborazione,'') as DatiElaborazione
	                                        from document_pcp_appalto_schede a with(nolock)
			                                        inner join document_pcp_appalto b with(nolock) on b.idHeader = a.idHeader
                                                    left join ctl_doc docScheda with(nolock) on docScheda.id = a.IdDoc_Scheda
	                                        where a.idRow = @iddoc";

                cmd.CommandText = strSql;
                cmd.Parameters.AddWithValue("@iddoc", idrow);
                conn.Open();

                using (var rs = cmd.ExecuteReader())
                {
                    if (rs.Read())
                    {
                        datiScheda.idgara = (int)rs["idgara"];
                        datiScheda.statoScheda = (string)rs["statoScheda"];
                        datiScheda.idScheda = (string)rs["idScheda"];   //Guid ottenuto dal crea-scheda
                        datiScheda.idAppalto = (string)rs["idAppalto"]; //Guid ottenuto al conferma dell'appalto
                        datiScheda.tipoScheda = (string)rs["tipoScheda"];
                        datiScheda.IdDoc_Scheda = (rs["IdDoc_Scheda"] != null && !(rs["IdDoc_Scheda"] is System.DBNull)) ? (int)rs["IdDoc_Scheda"] : 0;
                        datiScheda.TipoDoc_IdDoc_Scheda = (rs["TipoDoc_IdDoc_Scheda"] != null && !(rs["TipoDoc_IdDoc_Scheda"] is System.DBNull)) ? (string)rs["TipoDoc_IdDoc_Scheda"] : "";
                        datiScheda.CIG = (string)rs["CIG"];
                        datiScheda.DatiElaborazione = (string)rs["DatiElaborazione"];
                    }
                    else
                    {
                        throw new ApplicationException("Dati scheda non trovati");
                    }
                }
            }
            finally
            {
                conn.Close();
            }

            return datiScheda;
        }

        public List<TipoScheda> recuperaListaSchedePreS3()
        {
            List<TipoScheda> ls = new List<TipoScheda>();
            ls.Add(TipoScheda.P1_16);
            ls.Add(TipoScheda.P2_16);
            ls.Add(TipoScheda.AD_3);
            ls.Add(TipoScheda.AD_5);
            ls.Add(TipoScheda.AD2_25);
            ls.Add(TipoScheda.P7_2);
            return ls;
        }

        public void aggiornaCigP1_16(int idDoc, string CIGtoInsert, int NumeroLotto)
        {
            //TODO: il tipodoc non deve essere cablato. bisogna prendere quello presente sulla CTL_DOC. Potrebbe essere sia BANDO_GARA che BANDO_SEMPLIFICATO. + aggiungere sql parameters
            string strSQL = "update Document_MicroLotti_Dettagli set CIG = '" + CIGtoInsert + "' where idHeader = " + idDoc + " and NumeroLotto = " + NumeroLotto + " and TipoDoc = 'BANDO_GARA'";
            cmd.Parameters.Clear();
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSQL;
            conn.Open();
            cmd.ExecuteNonQuery();
            cmd.Clone();
            conn.Close();
        }

        public int GetNumRetrySIC(int idRowSIC)
        {
            //TODO: fare parametro sql
            string strSQL = "select isnull(numRetry,0) as numRetry from Services_Integration_Request with(nolock) where idRow = " + idRowSIC;
            cmd.Parameters.Clear();
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSQL;
            conn.Open();
            object tipo = (int)cmd.ExecuteScalar();
            conn.Close();
            string result = string.Empty;
            if (tipo != null)
            {
                result = tipo.ToString();
            }

            return Convert.ToInt32(result);
        }

        public void UpdateServiceIntegration(int idRowSIC, string statoRichiesta, int numRetry = -1, string msgError = "")
        {
            cmd.Parameters.Clear();

            string strSQL = @"UPDATE Services_Integration_Request 
                                set StatoRichiesta = @statoRichiesta,
                                    DataExecuted = @dataExecuted ";

            if (numRetry != -1)
            {
                strSQL += ", numRetry = @numRetry ";
                cmd.Parameters.AddWithValue("@numRetry", numRetry);
            }

            if (!string.IsNullOrEmpty(msgError))
            {
                strSQL += ", msgError = @msgError ";
                cmd.Parameters.AddWithValue("@msgError", msgError);
            }

            strSQL += " where IdRow = @idRowSIC";

            cmd.Parameters.AddWithValue("@dataExecuted", DateTime.Now);
            cmd.Parameters.AddWithValue("@statoRichiesta", statoRichiesta);
            cmd.Parameters.AddWithValue("@idRowSIC", idRowSIC);

            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSQL;

            conn.Open();
            cmd.ExecuteNonQuery();
            conn.Close();
        }

        public void ScheduleProcess(int idRowSIC, DateTime dataProssimaEsecuzione, string DPR_DOC_ID = "", string DPR_ID = "", string idpfu = "-20")
        {
            if (string.IsNullOrEmpty(DPR_DOC_ID))
            {
                DPR_DOC_ID = "PCP_ESITO_OPERAZIONE";
            }
            if (string.IsNullOrEmpty(DPR_ID))
            {
                DPR_ID = "RETRY";
            }

            string strSQL = $"INSERT INTO CTL_Schedule_Process ( IdDoc, idUser, DPR_DOC_ID, dpr_id, DataRequestExec ) values ( {idRowSIC} , {idpfu} , '{DPR_DOC_ID}', '{DPR_ID}', @dataToBeExecuted )";

            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@dataToBeExecuted", dataProssimaEsecuzione);
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSQL;
            conn.Open();
            cmd.ExecuteNonQuery();
            cmd.Clone();
            conn.Close();
        }

        public void aggiornaCigMonolotto(int idDoc, string CIGtoInsert)
        {
            string strSQL = "update Document_Bando set CIG = '" + CIGtoInsert + "' where idHeader = " + idDoc;
            cmd.Parameters.Clear();
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSQL;
            conn.Open();
            cmd.ExecuteNonQuery();
            cmd.Clone();
            conn.Close();
        }

        public HttpMethod recuperaMetodoDaServizio(string servizio)
        {
            HttpMethod method;
            cmd.Parameters.Clear();
            string strSql = "SELECT Method from PDND_Servizi with(nolock) where endpoint = @servizio";
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.Text;
            cmd.Parameters.AddWithValue("@servizio", servizio);

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
                throw new ApplicationException($"{servizio} non trovato nella PDND_Servizi");
            }
        }

        public string sendRequest(PDNDClient client, string endpointContestuale, string finaljwt, string bearerToken, string jwtAgidBase64, HttpMethod method, Dictionary<string, string> parametri = null, int idDoc = 0)
        {
            return client.PDNDRequest(endpointContestuale, finaljwt, method, receivedVoucher: bearerToken, parametri: parametri, jwsForAgid: jwtAgidBase64, serviceRequest: true, iddoc: idDoc);
        }

        public string postRequest(PDNDClient client, string endpointContestuale, string finaljwt, string bearerToken, string jwtAgidBase64, HttpMethod method, Dictionary<string, string> parametri = null, string body = null, int idDoc = 0)
        {
            return client.PDNDPostRequest(endpointContestuale, finaljwt, method, receivedVoucher: bearerToken, parametri: parametri, jwsForAgid: jwtAgidBase64, body: body, serviceRequest: true, idDoc: idDoc);
        }

        public void avviaEsitoOperazione(int idpfu, int iddoc, string operation = null)
        {

            string operazioneRichiesta = "";

            switch (operation)
            {
                case ("pubblica-avviso"):
                    operazioneRichiesta = "esitoOperazionePostPubblicaAvviso";
                    break;
                case ("conferma-scheda"):
                    operazioneRichiesta = "esitoOperazioneConfermaScheda";
                    break;
                case ("rettifica-avviso"):
                    operazioneRichiesta = "esitoOperazionePostRettificaAvviso";
                    break;
                case ("conferma-appalto"):
                default:
                    operazioneRichiesta = "esitoOperazione";
                    break;
            }

            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@integrazione", "INTEROPERABILITA");
            cmd.Parameters.AddWithValue("@operazioneRichiesta", operazioneRichiesta);
            cmd.Parameters.AddWithValue("@idPfu", idpfu);
            cmd.Parameters.AddWithValue("@idDocRichiedente", iddoc);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandText = "INSERT_SERVICE_REQUEST";
            conn.Open();

            try
            {
                cmd.ExecuteNonQuery();
            }
            finally
            {
                conn.Close();
            }

        }

        public string recuperaIdAppalto(int idDoc)
        {
            string strSql = "select pcp_CodiceAppalto from Document_PCP_Appalto with(nolock) where idheader = @iddoc";
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@iddoc", idDoc);
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.Text;
            conn.Open();
            string idAppalto = cmd.ExecuteScalar().ToString();
            conn.Close();

            return idAppalto;
        }

        public string recuperaIdAvviso(int idDoc)
        {
            string strSql = "select pcp_CodiceAvviso from Document_PCP_Appalto with(nolock) where idheader = @iddoc";
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@iddoc", idDoc);
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.Text;
            conn.Open();
            string idAvviso = cmd.ExecuteScalar().ToString();
            conn.Close();

            return idAvviso;
        }

        public int recuperaIdDoc(int idRow)
        {
            string strSql = "select isnull(idRichiesta,0) as idRichiesta from Services_Integration_Request with(nolock) where idRow = @idRow";
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@idRow", idRow);
            cmd.CommandText = strSql;
            cmd.CommandType = CommandType.Text;
            conn.Open();
            int idDoc = Convert.ToInt32(cmd.ExecuteScalar());
            conn.Close();

            return idDoc;
        }


		public int GetNextPage_For_RecuperaCIg(int idDoc, int PerPage)
		{
			string strSql = "select count(*) as NumLotti from Document_microlotti_Dettagli with(nolock) where idheader = @iddoc and Tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO') and voce = 0 ";
			cmd.Parameters.Clear();
			cmd.Parameters.AddWithValue("@iddoc", idDoc);
			cmd.CommandText = strSql;
			cmd.CommandType = CommandType.Text;
			conn.Open();
			
            int numLotti = Convert.ToInt32(cmd.ExecuteScalar());

			//determino quanti cig ancora devo valorizzare
			string strSql1 = "select count(*) as NumCigAssenti from Document_microlotti_Dettagli with(nolock) where idheader = @iddoc and Tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO') and voce=0 and cig = ''  ";
			cmd.CommandText = strSql1;

			int numCigAssenti = Convert.ToInt32(cmd.ExecuteScalar());

			conn.Close();

            int NextPage = 1;

            if ( numCigAssenti > 0 && numCigAssenti < numLotti )
			{
				NextPage = Convert.ToInt32( ( numLotti - numCigAssenti) / PerPage ) + 1 ;
			}


            //se non ci dono cig da recuperare ho finito
            if ( numCigAssenti == 0 )
			{
                NextPage = 0;
            }

			return NextPage;

		}

		public int SvuotaCigGara(int iddoc)
		{
			cmd.Parameters.Clear();
			cmd.Parameters.AddWithValue("@idDoc", iddoc);

			string strSql = "UPDATE Document_microlotti_Dettagli set CIG = '' where idHeader = @idDoc and Tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO') AND VOCE=0";

			cmd.CommandType = CommandType.Text;
			cmd.CommandText = strSql;
			conn.Open();

			int numRecord = cmd.ExecuteNonQuery();

			string strSql1 = "UPDATE document_bando set cig='' where idheader = @iddoc";
			cmd.CommandText = strSql1;

			numRecord = cmd.ExecuteNonQuery();


			conn.Close();

			return numRecord;
		}


	}

    public class PDNDClient
    {
        public readonly string url;
        private readonly string aud;
        public string clientId;
        private readonly string Kid;
        private readonly string PemPrivateKey;
        private readonly string SignatureCertificate;
        private readonly string[] SignatureCertificatePublicKey;
        private HttpResponseMessage msg;
        public PCPHeader header;
        public PCPPayload payload;
        public PCPPayloadWithData payloadWithData;
        private PCPEservice Eservice;
        RSACryptoServiceProvider rSACryptoServiceProvider;
        private DigestClaim digestClaim;
        private string purposeId;
        private string tokenContent = string.Empty;
        private string jwt = string.Empty;

        public PDNDClient(PCPPayloadWithData Pload, Dati_PCP dati) //ISession _session, 
        {

            //Session = _session;
            msg = new HttpResponseMessage();
            header = new PCPHeader();
            //payload = Pload;
            Eservice = new PCPEservice();

            PemPrivateKey = dati.PemPrivateKey;
            rSACryptoServiceProvider = new RSACryptoServiceProvider();
            digestClaim = new DigestClaim();
            url = dati.urlAuth; // endpoint per autenticazione iniziale
            aud = dati.audAuth; // riferimento per autenticazione PDND
        }


        //public string getAudForPurposeId(string purposeId)
        //{
        //    string audience = string.Empty;
        //    string strSql = $"SELECT BaseAddress from PDND_Contesti where PurposeId = '{purposeId}'";
        //    audience = cdf.ExecuteScalar(strSql, Application.ApplicationCommon.Application.ConnectionString);
        //    return audience;
        //}

        public string composeComplementaryJWT(PCPPayloadWithData pLoad, Dati_PCP dati, string audience = null)
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

            string jwtSignatureBase64 = GetPemPrivateKeyByteFWK(tokenContent, PemPrivateKey);


            jwt = $"{tokenContent}.{jwtSignatureBase64}";

            Console.WriteLine(JsonSerializer.Serialize(jwtSignatureBase64));
            return jwt;

        }



        public void RecuperaDatiBaseVoucher() => throw new NotImplementedException();

        public string composeJWT(string serializedPayLoad, string hashedJwt, Dati_PCP dati, int iddoc = 0)
        {
            string strCause = "";

            try
            {
                new PDNDUtils().InsertTrace("PCP", "Chiamata a composeJWT", iddoc);

                strCause = "composeJWT - serializeHeader";
                string headerJson = serializeHeader(dati);
                byte[] headerByte = System.Text.Encoding.UTF8.GetBytes(headerJson);

                strCause = "composeJWT - Deserialize serializedPayLoad";
                PCPPayloadWithHash payload = JsonSerializer.Deserialize<PCPPayloadWithHash>(serializedPayLoad);

                strCause = "composeJWT - composizione Digest";
                
                Digest dig = new Digest();
                dig.value = hashedJwt;
                payload.digest = dig;

                strCause = "composeJWT - conversione in base 64 dell'header";
                string jwtHeaderBase64 = Base64UrlEncoder.Encode(headerByte);

                strCause = "composeJWT - serializePayload";
                string payloadJson = serializePayload(payload, dati);
                byte[] payLoadByte = System.Text.Encoding.UTF8.GetBytes(payloadJson);

                strCause = "composeJWT - conversione in base 64 del payload";
                string jwtPayloadBase64 = Base64UrlEncoder.Encode(payLoadByte);

                strCause = "composeJWT - concatenazione header e payload";
                tokenContent = $"{jwtHeaderBase64}.{jwtPayloadBase64}";

                strCause = "composeJWT - firma del content";
                string jwtSignatureBase64 = GetPemPrivateKeyByteFWK(tokenContent, PemPrivateKey);

                strCause = "composeJWT - concatenazione token content e signature";
                jwt = $"{tokenContent}.{jwtSignatureBase64}"; // client assertion 
            }
            catch (Exception ex)
            {
                throw new ApplicationException($"Errore metodo composeJWT() - payload : {serializedPayLoad} - strCause : {strCause} - errMsg : {ex.Message}",ex);
            }

            return jwt;
        }

        /*public string composeJWT(PCPPayload pLoad, Dati_PCP dati, string audience = null)
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

            string jwtSignatureBase64 = GetPemPrivateKeyByteFWK(tokenContent, PemPrivateKey);

            jwt = $"{tokenContent}.{jwtSignatureBase64}"; // client assertion 

            return jwt;
        }*/

        public Dictionary<string, string> composeParams(string strJwt)
        {
            //https://docs.pagopa.it/interoperabilita-1/manuale-operativo/utilizzare-i-voucher
            var dict = new Dictionary<string, string>();
            dict.Add("client_id", clientId);
            dict.Add("client_assertion", strJwt);
            /*
             * client_assertion_type è una costante ed è : il formato della client assertion, come indicato in RFC (sempre urn:ietf:params:oauth:client-assertion-type:jwt-bearer);
             * grant_type è una costante ed è : la tipologia di flusso utilizzato, come indicato in RFC (sempre client_credentials).
             */
            dict.Add("client_assertion_type", "urn:ietf:params:oauth:client-assertion-type:jwt-bearer");
            dict.Add("grant_type", "client_credentials");

            return dict;
        }



        public string serializeHeader(Dati_PCP dati)
        {
            header.kid = dati.Kid; // Configuration.GetSection("PDND_info").GetValue<string>("kid");
            return JsonSerializer.Serialize(header);
        }

        public string serializePayload(PCPPayloadWithData pLoad, Dati_PCP dati, string audience = null)
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
            int expPeriod = Convert.ToInt32(ConfigurationManager.AppSettings["PCP.expirationInSeconds"]);
            //long exp = DateTimeOffset.Now.AddSeconds(expPeriod).ToUnixTimeSeconds();
            long exp = DateTimeOffset.UtcNow.AddMinutes(10).ToUnixTimeSeconds();
            pLoad.iat = iat;
            pLoad.exp = exp;
            pLoad.jti = Guid.NewGuid().ToString();
            //pLoad.nbf = DateTimeOffset.Now.ToUnixTimeSeconds();
            var finaldate =
                pLoad.nbf = pLoad.iat;
            pLoad.purposeId = pLoad.purposeId;

            //TODO: regCodiceComponente cablato!! cambiare in dati.regCodiceComponente 
            pLoad.regCodiceComponente = "c5352203-9b6f-5f7b-a54b-77166b30cf47";
            return JsonSerializer.Serialize(pLoad);
        }

        /*public PCPPayload composePayLoad(PCPPayloadWithData pLoadWithData, Dati_PCP dati)
        {
            PCPPayload pLoad = new PCPPayload();
            pLoad.iss = dati.clientId;
            pLoad.sub = dati.clientId;
            pLoad.aud = aud;
            long iat = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            int expPeriod = Convert.ToInt32(ConfigurationManager.AppSettings["PCP.expirationInSeconds"]);
            //long exp = DateTimeOffset.Now.AddSeconds(expPeriod).ToUnixTimeSeconds();
            long exp = DateTimeOffset.UtcNow.AddMinutes(10).ToUnixTimeSeconds();
            pLoad.iat = iat;
            pLoad.exp = exp;
            pLoad.jti = Guid.NewGuid().ToString();
            //pLoad.nbf = DateTimeOffset.Now.ToUnixTimeSeconds();
            pLoad.nbf = pLoad.iat;
            pLoad.purposeId = pLoad.purposeId;

            return pLoad;
        }*/

        public string serializePayload(PCPPayloadWithHash pLoad, Dati_PCP dati)
        {
            pLoad.iss = dati.clientId;
            pLoad.sub = dati.clientId;
            pLoad.aud = aud;

            int expPeriod = Convert.ToInt32(ConfigurationManager.AppSettings["PCP.expirationInSeconds"]);

            /*
             * exp: l'expiration, il timestamp riportante data e ora di scadenza del token, espresso in UNIX epoch (valore numerico, non stringa).
             */
            long exp = DateTimeOffset.UtcNow.AddMinutes(10).ToUnixTimeSeconds();
            
            pLoad.exp = exp;
            pLoad.jti = Guid.NewGuid().ToString();
            pLoad.purposeId = pLoad.purposeId;

            /*
             * iat: l'issued at, il timestamp riportante data e ora in cui viene creato il token, espresso in UNIX epoch (valore numerico, non stringa);
             */
            long iat = DateTimeOffset.UtcNow.ToUnixTimeSeconds();

            pLoad.iat = iat;
            pLoad.nbf = pLoad.iat;

            return JsonSerializer.Serialize(pLoad);
        }

        /*public string serializeEmptyPayLoad(PCPPayload pLoad, Dati_PCP dati, string audience = null)
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
            int expPeriod = Convert.ToInt32(ConfigurationManager.AppSettings["PCP.expirationInSeconds"]);
            //long exp = DateTimeOffset.Now.AddSeconds(expPeriod).ToUnixTimeSeconds();
            long exp = DateTimeOffset.UtcNow.AddMinutes(10).ToUnixTimeSeconds();
            pLoad.iat = iat;
            pLoad.exp = exp;
            pLoad.jti = Guid.NewGuid().ToString();
            pLoad.purposeId = pLoad.purposeId;
            pLoad.nbf = pLoad.iat;

            return JsonSerializer.Serialize(pLoad);
        }*/

        public static RSAParameters ConvertFromPemToRSAParameters(string pemString)
        {
            using (TextReader privateKeyTextReader = new StringReader(pemString))
            {
                object keyObject = new PemReader(privateKeyTextReader).ReadObject();
                AsymmetricKeyParameter privateKeyParam;

                if (keyObject is AsymmetricCipherKeyPair keyPair)
                {
                    // PKCS#8 format
                    privateKeyParam = keyPair.Private;
                }
                else if (keyObject is RsaPrivateCrtKeyParameters)
                {
                    // PKCS#1 format
                    privateKeyParam = (RsaPrivateCrtKeyParameters)keyObject;
                }
                else
                {
                    throw new ArgumentException("Il file PEM non contiene una chiave RSA valida.");
                }

                return DotNetUtilities.ToRSAParameters((RsaPrivateCrtKeyParameters)privateKeyParam);
            }
        }

        public string GetPemPrivateKeyByteFWK(string token, string pemPrivateKey)
        {

            string signatureBase64 = string.Empty;

            try
            {
                RSACryptoServiceProvider rsaCryptoServiceProvider = new RSACryptoServiceProvider();
                RSAParameters rsaParams = ConvertFromPemToRSAParameters(pemPrivateKey);
                rsaCryptoServiceProvider.ImportParameters(rsaParams);
                byte[] signatureBytes = rsaCryptoServiceProvider.SignData(Encoding.UTF8.GetBytes(token),
                    System.Security.Cryptography.HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
                //signatureBase64 = Convert.ToBase64String(signatureBytes);
                signatureBase64 = Base64UrlEncoder.Encode(signatureBytes);

            }
            catch (Exception ex)
            {
                throw new Exception("Problemi con lettura della chiave privata: " + ex.Message + Environment.NewLine +
                                    pemPrivateKey);
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

        public string PDNDRequest(string fullUrl, string jwt, HttpMethod method = null,
            Dictionary<string, string> parametri = null, string receivedVoucher = null, string jwsForAgid = null,
            bool serviceRequest = false, int iddoc = 0)
        {

            string strResult = string.Empty;
            string strCause = "";
            PDNDUtils pu = new PDNDUtils();

            try
            {
                pu.InsertTrace("PCP", $"Inizio invocazione di {fullUrl}", iddoc);

                // Creazione di un oggetto HttpClient
                using (HttpClient httpClient = new HttpClient())
                {
                    // Aggiunta di intestazioni (headers) personalizzate
                    strCause = "Aggiunta degli headers";
                    httpClient.DefaultRequestHeaders.Add("Accept", "application/json");
                    httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {receivedVoucher}");
                    httpClient.DefaultRequestHeaders.Add("Agid-JWT-TrackingEvidence", jwsForAgid);

                    strCause = "Concatenazione dei parametri in GET";
                    // Costruzione dell'URL completo con i parametri
                    if (parametri.Count != 0)
                    {
                        fullUrl += "?";
                    }

                    for (int i = 0; i < parametri.Count; i++)
                    {
                        var item = parametri.ElementAt(i);

                        fullUrl += (i != 0 ? "&" : "") + item.Key + "=" + item.Value;
                    }

                    //richiesta HTTP GET
                    strCause = "Invocazione del GetAsync";
                    HttpResponseMessage response = httpClient.GetAsync(fullUrl).Result;

                    if (response is null)
                        throw new ApplicationException($"Errore in PDNDRequest() - Risposta null dal servizio {fullUrl}");

                    //PS : al momento sembra che questi 3 headers ( limit, remaining e reset ) siano stati usati in documentazione ma non nella realtà
                    strCause = "Recupero dati di response header";
                    //The number of allowed requests in the current period
                    string limit = getResponseHeaderValue(response, "X-RateLimit-Limit");
                    //The number of remaining requests in the current period
                    string remaining = getResponseHeaderValue(response, "X-RateLimit-Remaining");
                    //The number of seconds left in the current period
                    string reset = getResponseHeaderValue(response, "X-RateLimit-Reset");

                    strCause = "Recupero content dalla response";
                    strResult = response.Content.ReadAsStringAsync().Result;

                    //Se l'anac ha risposto con uno status http 200 OPPURE abbiamo come risultato un json valido ( quindi il chiamante di questo metodo leggerà l'esito dalla risposta )
                    if (response.IsSuccessStatusCode || IsValidJson(strResult))
                    {
                        if (string.IsNullOrEmpty(strResult))
                        {
                            throw new ApplicationException($"Errore in PDNDRequest() - Risposta vuota dal servizio {fullUrl}");
                        }

                        if (!response.IsSuccessStatusCode)
                        {
                            string msgError = $"Errore da {fullUrl} - StatusCode : {(int)response.StatusCode}/{response.StatusCode} - Content : {strResult}";
                            new PDNDUtils().InsertTrace("PCP", msgError, iddoc);
                        }

                        return strResult;
                    }
                    else
                    {
                        string msgError = $"Errore da {fullUrl} - StatusCode : {(int)response.StatusCode}/{response.StatusCode} - Content : {strResult}"; //- retryAfter : {retryAfter} - Limit : {remaining}");

                        new PDNDUtils().InsertTrace("PCP", msgError, iddoc);
                        //new PDNDUtils().InsertTrace("PCP", $"Errore {fullUrl} per INPUT : {jsonContent}"); --> non traccio anche l'input altrimenti salveremmo troppi dati. le request sono pesanti

                        throw new ApplicationException(msgError);
                    }

                }

            }
            catch (ApplicationException e)
            {
                throw;
            }
            catch (Exception e)
            {
                throw new Exception($"Eccezione di runtime dal metodo PDNDRequest() - {strCause} : {e.Message}", e);
            }
            finally
            {
                pu.InsertTrace("PCP", $"Fine invocazione di {fullUrl}", iddoc);
            }

        }

        /// <summary>
        /// Metodo utilizzato SOLO ed esclusivamente per staccare un voucher
        /// </summary>
        /// <param name="url"></param>
        /// <param name="jwt"></param>
        /// <param name="method"></param>
        /// <param name="iddoc"></param>
        /// <returns></returns>
        /// <exception cref="Exception"></exception>
        public string PDNDRequest(string url, string jwt, HttpMethod method, int iddoc = 0)
        {
            string strCause = "";

            try
            {
                HttpResponseMessage msg = new HttpResponseMessage();
                HttpClientHandler clientHandler;

                strCause = "Creazione parametri digest";
                Dictionary<string, string> dict = new Dictionary<string, string>(composeParams(jwt));

                //Passiamo nel Content il DIGEST contenente la client assertion
                var request = new HttpRequestMessage(method, url) { Content = new FormUrlEncodedContent(dict) };

                string voucher = string.Empty;

                request.Headers.Clear();

                strCause = "Settaggio request headers";
             
                request.Headers.Add("x-requested-with", "XMLHttpRequest"); //Header obbligator per il voucher
                request.Headers.TryAddWithoutValidation("Accept", "application/json");

                clientHandler = new HttpClientHandler();

                Risposta risposta = new Risposta();

                strCause = "Creazione HttpClient";
                using (HttpClient client = new HttpClient(clientHandler))
                {
                    strCause = "Chiamata alla SendAsync";
                    msg = client.SendAsync(request).Result;

                    if (msg is null)
                        throw new ApplicationException($"Errore in PDNDRequest() - Risposta null dal servizio {url}");

                    //string retryAfter = getResponseHeaderValue(msg, "Retry-After"); //msg.Headers.TryGetValues("Retry-After", out values).ToString();
                    //string remaining = getResponseHeaderValue(msg, "Limit");//msg.Headers.TryGetValues("Limit", out values).ToString();

                    strCause = "Test IsSuccessStatusCode";
                    //Se l'anac ha risposto con uno status http 200
                    if (msg.IsSuccessStatusCode)
                    {
                        strCause = "Lettura response content";
                        string responseStream = msg.Content.ReadAsStringAsync().Result;

                        if ( string.IsNullOrEmpty(responseStream) )
                        {
                            throw new ApplicationException($"Errore in PDNDRequest() - Risposta vuota dal servizio {url}");
                        }

                        strCause = "Deserialize del response content";
                        JsonVoucherModel rispostaAutenticazione;

                        try
                        {
                            rispostaAutenticazione = JsonSerializer.Deserialize<JsonVoucherModel>(responseStream);
                        }
                        catch (Exception e)
                        {
                            throw new ApplicationException($"Errore Voucher PDND: non è stato possibile deserializzare il voucher {responseStream} - {e.Message}", e);
                        }
                        
                        if (rispostaAutenticazione is null)
                        {
                            throw new ApplicationException($"Errore Voucher PDND: non è stato possibile deserializzare il voucher {responseStream}");
                        }
                        else
                        {

                            /*
                             * Se tutto è impostato correttamente, PDND Interoperabilità risponderà con un voucher valido all'interno del body della risposta
                             *      alla proprietà access_token. Sempre nella risposta, sarà contenuta anche la durata di validità del token in secondi
                             *      (es. "expires_in": 600 indica un token con validità 10 minuti, 10 * 60 secondi = 600).
                                    Il token andrà inserito nell'header di tutte le chiamate successive verso le API gateway di PDND Interoperabilità come header Authorization: Bearer.
                             */

                            voucher = rispostaAutenticazione.access_token;
                            
                        }
                    }
                    else
                    {
                        string respOut = msg.Content.ReadAsStringAsync().Result;
                        string msgError = $"Errore Generazione Voucher PDND: StatusCode : {(int)msg.StatusCode}/{msg.StatusCode} - Content : {respOut}";

                        new PDNDUtils().InsertTrace("PCP", msgError, iddoc);

                        throw new ApplicationException(msgError); //- retryAfter : {retryAfter} - Limit : {remaining}");
                    }
                }

                return voucher;
            }
            catch (ApplicationException e)
            {
                throw;
            }
            catch (Exception e)
            {
                throw new Exception($"Eccezione di runtime dal metodo PDNDRequest() - {strCause} : {e.Message}", e);
            }
        }

        public string getResponseHeaderValue(HttpResponseMessage response, string headerKey, string defaultValue = "")
        {
            string outVal = defaultValue;

            IEnumerable<string> values;
            if (response.Headers.TryGetValues(headerKey, out values))
                outVal = values.FirstOrDefault();

            return outVal;
        }

        public bool IsValidJson(string jsonString)
        {
            try
            {
                _ = JsonSerializer.Deserialize<JsonElement>(jsonString);
                return true;
            }
            catch (JsonException)
            {
                return false;
            }
        }

        public string PDNDPostRequest(string fullUrl, string jwt, HttpMethod method = null,
            Dictionary<string, string> parametri = null, string receivedVoucher = null, string jwsForAgid = null,
            bool serviceRequest = false, string body = null, int idDoc = 0)
        {
            string strResult = string.Empty;
            string strCause = "";
            PDNDUtils pu = new PDNDUtils();

            try
            {
                pu.InsertTrace("PCP", $"Inizio invocazione di {fullUrl}", idDoc);

                // Creazione di un oggetto HttpClient
                using (HttpClient httpClient = new HttpClient())
                {
                    strCause = "aggiunta degli headers di request";
                    httpClient.DefaultRequestHeaders.Add("x-requested-with", "XMLHttpRequest");
                    httpClient.DefaultRequestHeaders.Accept.Add(
                        new MediaTypeWithQualityHeaderValue("application/json"));

                    //Settaggio dell'header di barer per l'autorizzation token 
                    httpClient.DefaultRequestHeaders.Authorization =
                        new AuthenticationHeaderValue("Bearer", receivedVoucher);

                    //passaggio negli headers del JWT per indicare la finalità
                    httpClient.DefaultRequestHeaders.Add("Agid-JWT-TrackingEvidence", jwsForAgid);

                    strCause = "replace del newline con stringa vuota";
                    string jsonContent = body.Replace(Environment.NewLine, string.Empty);

                    var webRequest = new HttpRequestMessage(HttpMethod.Post, fullUrl)
                    {
                        //Composizione del content json che andremo ad inviare come body
                        Content = new StringContent(@jsonContent, Encoding.UTF8, "application/json")
                    };

                    strCause = "Invocazione del SendAsync";
                    var response = httpClient.SendAsync(webRequest).Result;

                    if (response is null)
                        throw new ApplicationException(
                            $"Errore in PDNDPostRequest() - Risposta null dal servizio {fullUrl}");

                    strCause = "Recupero dati di response header";

                    //PS : al momento sembra che questi 3 headers ( limit, remaining e reset ) siano stati usati in documentazione ma non nella realtà

                    //The number of allowed requests in the current period
                    string limit = getResponseHeaderValue(response, "X-RateLimit-Limit");

                    //The number of remaining requests in the current period
                    string remaining = getResponseHeaderValue(response, "X-RateLimit-Remaining");

                    //The number of seconds left in the current period
                    string reset = getResponseHeaderValue(response, "X-RateLimit-Reset");

                    strCause = "Recupero content dalla response";
                    using (var reader = new StreamReader(response.Content.ReadAsStreamAsync().Result))
                    {
                        strResult = reader.ReadToEnd();
                    }

                    //Se l'anac ha risposto con uno status http 200 OPPURE abbiamo come risultato un json valido ( quindi il chiamante di questo metodo leggerà l'esito dalla risposta )
                    if (response.IsSuccessStatusCode || IsValidJson(strResult))
                    {
                        if (string.IsNullOrEmpty(strResult))
                        {
                            throw new ApplicationException(
                                $"Errore in PDNDPostRequest() - Risposta vuota dal servizio {fullUrl}");
                        }

                        if (!response.IsSuccessStatusCode)
                        {
                            string msgError = $"Errore da {fullUrl} - StatusCode : {(int)response.StatusCode}/{response.StatusCode} - Content : {strResult}";
                            new PDNDUtils().InsertTrace("PCP", msgError, idDoc);
                        }

                        return strResult;
                    }
                    else
                    {
                        string msgError =
                            $"Errore da {fullUrl} - StatusCode : {(int)response.StatusCode}/{response.StatusCode} - Content : {strResult}"; //- retryAfter : {retryAfter} - Limit : {remaining}");

                        new PDNDUtils().InsertTrace("PCP", msgError, idDoc);
                        //new PDNDUtils().InsertTrace("PCP", $"Errore {fullUrl} per INPUT : {jsonContent}"); --> non traccio anche l'input altrimenti salveremmo troppi dati. le request sono pesanti

                        throw new ApplicationException(msgError);
                    }
                }
            }
            catch (ApplicationException e)
            {
                throw;
            }
            catch (Exception e)
            {
                throw new Exception($"Eccezione di runtime dal metodo PDNDPostRequest() - {strCause} : {e.Message}", e);
            }
            finally
            {
                pu.InsertTrace("PCP", $"Fine invocazione di {fullUrl}", idDoc);
            }
   
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

    public class TipoClassificazione
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
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

    public class Dati_Base
    {
        public string codicefiscale { get; set; }
        public string HR2 { get; set; }
        public string PCP_CONTESTO { get; set; }
        public string PCP_ID_TIPO_UTENTE { get; set; }
        public int PCP_LOA { get; set; }
        public string PCP_PARAMETRI { get; set; }
        public string PCP_SERVIZIO { get; set; }
        public string User { get; set; }
        public string UserRUP { get; set; }
        public string PCP_JSON { get; set; }
    }

    public class Dati_PCP
    {
        public string cfSA { get; set; }
        public string cfRP { get; set; }
        public int idAzi { get; set; }
        public string purposeId { get; set; }
        public string Kid { get; set; }
        public string aud { get; set; }
        public string codiceAUSA { get; set; }
        public string codicePiattaforma { get; set; }
        public string userLoa { get; set; }
        public string idTipoUtente { get; set; }
        public string clientId { get; set; }
        public string regCodiceComponente { get; set; }
        public string PemPrivateKey { get; set; }
        public string audAuth { get; set; }
        public string urlAuth { get; set; }
    }


    public class AnacForm
    {
        public List<StazioniAppaltanti> stazioniAppaltanti { get; set; }
        public Appalto appalto { get; set; }
        public List<Lotti> lotti { get; set; }

    }
    public class DtoConfermaScheda
    {
        public string idScheda { get; set; }
        public string idAppalto { get; set; }
    }
    public class DatiScheda
    {
        public int idgara { get; set; }
        public string statoScheda { get; set; }
        public string idScheda { get; set; }
        public string idAppalto { get; set; }
        public string tipoScheda { get; set; }
        public int IdDoc_Scheda { get; set; }
        public string TipoDoc_IdDoc_Scheda { get; set; }

        //Campi utili scheda NAG
        public string CIG { get; set; }
        public string DatiElaborazione { get; set; }
    }

    /* Inizio DTO per la scheda S2 */
    public class BaseModelGeneric<TScheda>
    {
        public string idAppalto { get; set; } = null; //di base non esce finchè non viene valorizzato
        public TScheda scheda { get; set; }
    }
    public class SchedaGeneric<TBody>
    {
        public Codice codice { get; set; }
        public string versione { get; set; }
        public TBody body { get; set; }
    }

    public class BaseModelGenericModifica<TScheda> : BaseModelGeneric<TScheda>
    {
        public string idAppalto { get; set; }

    }

    public class BodyS2
    {
        public AnacFormS2 anacForm { get; set; }
    }
    public class AnacFormS2
    {
        public List<SoggettoS2> elencoSoggetti { get; set; }
    }

    public class SoggettoS2
    {
        public string cig { get; set; } //obblig.
                                        //[JsonProperty(DefaultValueHandling = DefaultValueHandling.Ignore)]
                                        //[JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
                                        //[DataMember(Name = "invitatiCheNonHannoPresentatoOfferta", EmitDefaultValue = false)]
        public List<InvitatoNonPartecipanteS2> invitatiCheNonHannoPresentatoOfferta { get; set; } = null; //opz.
                                                                                                          //[JsonProperty(DefaultValueHandling = DefaultValueHandling.Ignore)]
                                                                                                          //[JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public List<PartecipanteS2> partecipanti { get; set; } = null; //opz.
        public string dataInvito { get; set; } //data pubblicazione
        public string dataScadenzaPresentazioneOfferta { get; set; }
    }

    public class PartecipanteS2
    {
        public string codiceFiscale { get; set; }
        public string denominazione { get; set; }
        public Categoria ruoloOE { get; set; }
        public Categoria tipoOE { get; set; }
        public string idPartecipante { get; set; }
        public string paeseOperatoreEconomico { get; set; }
        public bool avvalimento { get; set; }
    }
    public class InvitatoNonPartecipanteS2
    {
        public string codiceFiscale { get; set; }
        public string denominazione { get; set; }
        public Categoria ruoloOE { get; set; }
        public Categoria tipoOE { get; set; }
    }
    /* Fine DTO per la scheda S2 */

    /* INIZIO DTO PER SCHEDA S3*/

    public class BodyS3
    {
        public AnacFormS3 anacForm { get; set; }
    }

    public class AnacFormS3
    {
        public List<ElencoIncarichi> elencoIncarichi { get; set; }
    }

    public class ElencoIncarichi
    {
        public string cig { get; set; }
        public List<Prestazione> prestazioni { get; set; }
        public List<Incarico> incarichi { get; set; }
    }

    /* INIZIO DTO per la scheda SC1 */

    public class BodySC1
    {
        public AnacFormSC1 anacForm { get; set; }
    }

    public class AnacFormSC1
    {
        public DatiContratto datiContratto { get; set; }
    }

    public class BodyNAG
    {
        public AnacFormNAG anacForm { get; set; }
    }

    public class AnacFormNAG
    {
        public List<LottoNAG> lotti { get; set; }
    }

    public class LottoNAG
    {
        public string cig { get; set; }
        public DatiBaseRisultatoProceduraNAG datiBaseRisultatoProcedura { get; set; }
        public EsitoProceduraAnnullataEnum esitoProceduraAnnullata { get; set; }
    }

    public class DatiBaseRisultatoProceduraNAG
    {
        public Giustificazione giustificazione { get; set; }
    }

    public class Giustificazione
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class EsitoProceduraAnnullataEnum
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class DatiContratto
    {
        public List<string> codiceAusa { get; set; }
        public string idPartecipante { get; set; }
        public List<string> cig { get; set; }
        public string dataStipula { get; set; }
        public string dataEsecutivita { get; set; }
        public string dataDecorrenza { get; set; }
        public string dataScadenza { get; set; }
        public decimal importoCauzione { get; set; }
    }

    /* FINE DTO per scheda SC1 */

    public class Prestazione
    {
        public string progettazioneInternaEsterna { get; set; }
        public TipoSoggetto tipoSoggetto { get; set; }
        public DatiPersonaFisica datiPersonaFisica { get; set; }
        public List<DatiPersonaGiuridica> datiPersonaGiuridica { get; set; }
        public TipoProgettazione tipoProgettazione { get; set; }
        public string cig { get; set; }
        public string dataAffidamentoIncarico { get; set; }
        public string dataConsegna { get; set; }
    }

    public class Incarico
    {
        public TipoIncarico tipoIncarico { get; set; }
        public DatiPersonaFisica datiPersonaFisica { get; set; }
        public List<DatiPersonaGiuridica> datiPersonaGiuridica { get; set; }
    }

    public class TipoSoggetto
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class TipoProgettazione
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class TipoIncarico
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class DatiPersonaFisica
    {
        public string codiceFiscale { get; set; }
        public string cognome { get; set; }
        public string nome { get; set; }
        public string telefono { get; set; }
        public string fax { get; set; }
        public string email { get; set; }
        public string indirizzo { get; set; }
        public string cap { get; set; }
        public CodIstat codIstat { get; set; }
        public bool incaricatoEstero { get; set; }
    }

    public class DatiPersonaGiuridica
    {
        public string codiceFiscale { get; set; }
        public string denominazione { get; set; }
        public Categoria ruoloOE { get; set; }
        public Categoria tipoOE { get; set; }
        public int idGruppo { get; set; }
    }

    /* Fine DTO per la scheda S3 */


    /* INIZIO DTO PER SCHEDA A1_29*/

    public class BodyA1_29
    {
        public AnacFormA1_29 anacForm { get; set; }

        public string eform { get; set; }
    }

    public class AnacFormA1_29
    {
        public AppaltoA1_29 appalto { get; set; }

        public List<AggiudicazioneA1_29> aggiudicazioni { get; set; }
    }

    public class AppaltoA1_29
    {
        public MotivoUrgenza motivoUrgenza { get; set; }
        public string linkDocumenti { get; set; }
        public bool relazioneUnicaSulleProcedure { get; set; }
        public bool opereUrbanizzazioneScomputo { get; set; }
        public ModalitaRiaggiudicazioneAffidamento modalitaRiaggiudicazioneAffidamento { get; set; }
    }

    public class ModalitaRiaggiudicazioneAffidamento
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class AggiudicazioneA1_29
    {
        public string cig { get; set; }
        public decimal valoreSogliaAnomalia { get; set; }
        public QuadroEconomicoStandard quadroEconomicoStandard { get; set; }
        public List<OffertePresentate> offertePresentate { get; set; }
        public decimal numeroOfferteAmmesse { get; set; }
        public EsitoProceduraAnnullata esitoProceduraAnnullata { get; set; }
    }

    public class EsitoProceduraAnnullata
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class OffertePresentate
    {
        public string idPartecipante { get; set; }
        public decimal importo { get; set; }
        public bool aggiudicatario { get; set; }
        public string ccnl { get; set; }
        public int posizioneGraduatoria { get; set; }
        public decimal offertaEconomica { get; set; }
        public decimal offertaQualitativa { get; set; }
        public decimal offertaInAumento { get; set; }
        public bool offertaMaggioreSogliaAnomalia { get; set; }
        public bool impresaEsclusaAutomaticamente { get; set; }
        public bool offertaAnomala { get; set; }
    }

    /* Fine DTO per la scheda A1_29 */

    /* INIZIO DTO PER SCHEDA A2_29*/

    public class BodyA2_29
    {
        public AnacFormA2_29 anacForm { get; set; }
    }

    public class AnacFormA2_29
    {
        public AppaltoA2_29 appalto { get; set; }

        public List<AggiudicazioneA2_29> aggiudicazioni { get; set; }
    }

    public class AppaltoA2_29
    {
        public MotivoUrgenza motivoUrgenza { get; set; }
        public string linkDocumenti { get; set; }
        public ModalitaRiaggiudicazioneAffidamento modalitaRiaggiudicazioneAffidamento { get; set; }
        public bool relazioneUnicaSulleProcedure { get; set; }
        public bool opereUrbanizzazioneScomputo { get; set; }
        public DatiBaseProceduraA2_29 datiBaseProcedura { get; set; }
        public DatiBaseStrumentiProcedura datiBaseStrumentiProcedura { get; set; }
        public DatiBaseSubappalti datiBaseSubappalti { get; set; }

    }

    public class DatiBaseSubappalti
    {
        public Subappalto subappalto { get; set; }
    }

    public class AggiudicazioneA2_29
    {
        public string cig { get; set; }
        public decimal valoreSogliaAnomalia { get; set; }
        public QuadroEconomicoStandard quadroEconomicoStandard { get; set; }
        public List<OffertePresentate> offertePresentate { get; set; }
        public decimal numeroOfferteAmmesse { get; set; }

        public DatiBaseRisultatoProcedura datiBaseRisultatoProcedura { get; set; }
        public DatiBaseAggiudicazioneAppalto datiBaseAggiudicazioneAppalto { get; set; }
        public DatiBaseAccessibilita datiBaseAccessibilita { get; set; }
        public DatiBaseSottomissioniRicevute datiBaseSottomissioniRicevute { get; set; }
    }

    public class DatiBaseSottomissioniRicevute
    {
        public decimal offertaMassimoRibasso { get; set; }
    }

    public class DatiBaseAccessibilita 
    {
        public Accessibilita accessibilita { get; set; }
        public string giustificazione { get; set; }
        public Multilingua giustificazioneMl { get; set; }
    }

    public class Multilingua 
    { 
        public string de    { get; set; }
        public string en    { get; set; }
    }

    public class DatiBaseRisultatoProcedura 
    { 
        public EsitoProcedura esitoProcedura { get; set; }
    }

    public class Accessibilita
{
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class EsitoProcedura
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    /* Fine DTO per la scheda A2_29 */


    /* INIZIO DTO PER SCHEDA S1 */
    public class BodyS1
    {
        public AnacFormS1 anacForm { get; set; }
    }
    public class AnacFormS1
    {
        public List<SoggettoS1> elencoSoggettiRichiedenti { get; set; }
    }
    public class SoggettoS1
    {
        public string cig { get; set; } //obblig.
        public List<SoggettoInteressato> soggettiInteressati { get; set; } = null;
    }
    public class SoggettoInteressato
    {
        public string codiceFiscale { get; set; }
        public string denominazione { get; set; }
        public Categoria ruoloOE { get; set; }
        public Categoria tipoOE { get; set; }
        public string idPartecipante { get; set; }
    }
    /* FINE DTO PER SCHEDA S1 */


    /* Inizio DTO per la scheda P1_19 */

    public class BaseModelP1_19
    {
        public SchedaP1_19 scheda { get; set; }
    }

    public class SchedaP1_19
    {
        public Codice codice { get; set; }
        public string versione { get; set; }
        public BodyP1_19 body { get; set; }
        public string espd { get; set; }
        public string eform { get; set; }
    }

    public class BodyP1_19
    {
        public AnacFormP1_19 anacForm { get; set; }
        public string espd { get; set; }
        public string eform { get; set; }
    }

    public class AnacFormP1_19
    {
        public List<StazioniAppaltanti> stazioniAppaltanti { get; set; }
        public AppaltoP1_19 appalto { get; set; }
        public List<LottiP1_19> lotti { get; set; }

    }

    public class AppaltoP1_19
    {
        public string codiceAppalto { get; set; }
        public List<CategorieMerceologiche> categorieMerceologiche { get; set; }
        public MotivazioneCIG motivazioneCIG { get; set; }
        public StrumentiSvolgimentoProcedure strumentiSvolgimentoProcedure { get; set; }
    }
    public class LottiP1_19
    {

        public string lotIdentifier { get; set; }
        public List<CategorieMerceologiche> categorieMerceologiche { get; set; }
        //public List<CondizioniNegoziata> condizioniNegoziata { get; set; }
        public ContrattiDisposizioniParticolari contrattiDisposizioniParticolari { get; set; }
        public CodIstat codIstat { get; set; }
        public bool afferenteInvestimentiPNRR { get; set; } = false;
        public bool acquisizioneCup { get; set; } = false;
        public List<string> cupLotto { get; set; }
        public List<Finanziamenti> finanziamenti { get; set; }
        public bool servizioPubblicoLocale { get; set; } = false;
        public bool saNonSoggettaObblighi24Dicembre2015 { get; set; } = false;
        public bool iniziativeNonSoddisfacenti { get; set; } = false;
        public bool lavoroOAcquistoPrevistoInProgrammazione { get; set; } = false;
        public string cui { get; set; }
        public string ccnl { get; set; } = "non applicabile";
        public TipologiaLavoro tipologiaLavoro { get; set; }
        public ModalitaAcquisizione modalitaAcquisizione { get; set; }
        public bool opzioniRinnovi { get; set; } = false;
        public IpotesiCollegamento ipotesiCollegamento { get; set; }
        public Categoria categoria { get; set; }
    }

    /* Fine DTO per la scheda P1_19 */


    /* Inizio DTO per la scheda P2_16 */

    public class BaseModelP2_16
    {
        public SchedaP2_16 scheda { get; set; }
    }

    public class SchedaP2_16
    {
        public Codice codice { get; set; }
        public string versione { get; set; }
        public BodyP2_16 body { get; set; }
    }

    public class BodyP2_16
    {
        public AnacFormP2_16 anacForm { get; set; }
        public string espd { get; set; }
    }

    public class AnacFormP2_16
    {
        public List<StazioniAppaltanti> stazioniAppaltanti { get; set; }
        public AppaltoP2_16 appalto { get; set; }
        public List<LottiP2_16> lotti { get; set; }
    }

    public class AppaltoP2_16
    {

        public string codiceAppalto { get; set; }
        public List<CategorieMerceologiche> categorieMerceologiche { get; set; }
        // public MotivazioneCIG motivazioneCig { get; set; }
        public StrumentiSvolgimentoProcedure strumentiSvolgimentoProcedure { get; set; }
        public MotivoUrgenza motivoUrgenza { get; set; }

        public string linkDocumenti { get; set; }

        public DatiBase datiBase { get; set; }
        public DatiBaseProceduraP2_16 datiBaseProcedura { get; set; }
        public DatiBaseStrumentiProceduraP2_16 datiBaseStrumentiProcedura { get; set; }
        //public bool relazioneUnicaSulleProcedure { get; set; }
        //public bool opereUrbanizzazioneScomputo { get; set; }
    }

    public class DatiBaseStrumentiProceduraP2_16
    {
        public TipologicaBase accordoQuadro { get; set; }
        public TipologicaBase sistemaDinamicoAcquisizione { get; set; }
        public bool astaElettronica { get; set; }
    }

    public class TipologicaBase
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class LottiP2_16
    {
        public string lotIdentifier { get; set; }
        public List<CategorieMerceologiche> categorieMerceologiche { get; set; }
        public ContrattiDisposizioniParticolari contrattiDisposizioniParticolari { get; set; }
        public CodIstat codIstat { get; set; }
        public bool afferenteInvestimentiPNRR { get; set; }
        public prestazioniComprese prestazioniComprese { get; set; }
        public bool servizioPubblicoLocale { get; set; }
        public bool ripetizioniEConsegneComplementari { get; set; }
        public bool lavoroOAcquistoPrevistoInProgrammazione { get; set; }
        public string ccnl { get; set; }
        public bool opzioniRinnovi { get; set; }
        public IpotesiCollegamento ipotesiCollegamento { get; set; }
        public Categoria categoria { get; set; }
        public ModalitaAcquisizione modalitaAcquisizione { get; set; }
        public QuadroEconomicoStandard quadroEconomicoStandard { get; set; }
        public DatiBaseP2_16 datiBase { get; set; }
        public DatiBaseAggiuntiviP2_16 datiBaseAggiuntivi { get; set; }
        //public List<CondizioniNegoziata> condizioniNegoziata { get; set; }
        public List<string> cupLotto { get; set; }
        public bool acquisizioneCup { get; set; }
        public bool saNonSoggettaObblighi24Dicembre2015 { get; set; }
        public bool iniziativeNonSoddisfacenti { get; set; }
        public bool? strumentiElettroniciSpecifici { get; set; }
        public List<TipologiaLavoro> tipologiaLavoro { get; set; }
        public DatiBaseContratto datiBaseContratto { get; set; }
        public DatiBaseAggiudicazione datiBaseAggiudicazione { get; set; }
        public DatiBaseCPVP2_16 datiBaseCPV { get; set; }
        public DatiBaseDocumenti datiBaseDocumenti { get; set; }
        //public string datiBaseDocumenti { get; set; }
        public string cui { get; set; }

		public DatiBaseTerminiInvio2 datiBaseTerminiInvio { get; set; }

	}

    public class IpotesiCollegamentoP2_16
    {
        public MotivoCollegamento motivoCollegamento { get; set; }
    }

    //public class MotivoCollegamento
    //{
    //    public string idTipologica { get; set; }
    //    public string codice { get; set; }
    //}
    public class DatiBaseAggiuntiviP2_16
    {
        List<TipologicaBase> affidamentiRiservati { get; set; }
    }
    public class DatiBaseP2_16
    {
        public string oggetto { get; set; }
        public decimal importo { get; set; }
        public OggettoPrincipaleContratto oggettoContratto { get; set; }
    }

    /* Fine DTO per la scheda P2_16 */





    /* Inizio DTO per la scheda P7_1_2 */

    public class BodyP7_1_2
    {
        public AnacFormP7_1_2 anacForm { get; set; }
    }

    public class AnacFormP7_1_2
    {
        public List<StazioniAppaltanti> stazioniAppaltanti { get; set; }
        public AppaltoP7_1_2 appalto { get; set; }
        public List<LottiP7_1_2> lotti { get; set; }
    }

    public class AppaltoP7_1_2
    {
        public string codiceAppalto { get; set; }

        public TipoProcedura motivazioneCIG { get; set; }  // non ho creato una classe apposta per la motivazione CIG essendo una tipologica come altre
        public MotivoUrgenza motivoUrgenza { get; set; }
        public string linkDocumenti { get; set; }
        public StrumentiSvolgimentoProcedure strumentiSvolgimentoProcedure { get; set; }
        public DatiBaseP7_1_2 datiBase { get; set; }
        public DatiBaseProcedura datiBaseProcedura { get; set; }
        public List<CategorieMerceologiche> categorieMerceologiche { get; set; }
    }

    public class LottiP7_1_2
    {
        public string lotIdentifier { get; set; }
        public List<CategorieMerceologiche> categorieMerceologiche { get; set; }
        public bool saNonSoggettaObblighi24Dicembre2015 { get; set; } = false;
        public bool iniziativeNonSoddisfacenti { get; set; } = false;
        public List<CondizioniNegoziata> condizioniNegoziata { get; set; }
        public ContrattiDisposizioniParticolari contrattiDisposizioniParticolari { get; set; }
        public CodIstat codIstat { get; set; }
        public bool servizioPubblicoLocale { get; set; } = false;
        public bool lavoroOAcquistoPrevistoInProgrammazione { get; set; } = false;
        public string cui { get; set; }

        public bool ripetizioniEConsegneComplementari { get; set; } = false;

        public IpotesiCollegamentoP7_1_2 ipotesiCollegamento { get; set; }
        public bool opzioniRinnovi { get; set; } = false;
        public bool afferenteInvestimentiPNRR { get; set; } = false;
        public bool acquisizioneCup { get; set; } = false;
        public List<string> cupLotto { get; set; }
        public string ccnl { get; set; }
        public ModalitaAcquisizione modalitaAcquisizione { get; set; }
        //public TipologiaLavoro tipologiaLavoro { get; set; }
        public Categoria categoria { get; set; }
        public prestazioniComprese prestazioniComprese { get; set; }
        public List<Finanziamenti> finanziamenti { get; set; }
        public TipoRealizzazione tipoRealizzazione { get; set; }
        public DatiBaseP7_1_2 datiBase { get; set; }
        public QuadroEconomicoStandard quadroEconomicoStandard { get; set; }
		//public DatiBaseTermineInvio datiBaseTermineInvio { get; set; }

		
		public string datiBaseTermineInvio { get; set; }

		
		public DatiBaseTerminiInvio2 datiBaseTerminiInvio { get; set; }

		public DatiBaseDocumenti datiBaseDocumenti { get; set; }

	}


    public class DatiBaseP7_1_2
    {
        public OggettoContratto oggettoContratto { get; set; }
        public string oggetto { get; set; }
        public decimal importo { get; set; }
    }
    public class Finanziamenti
    {
        public TipoFinanziamento tipoFinanziamento { get; set; }
        public decimal importo { get; set; }
    }

    public class TipoFinanziamento
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class IpotesiCollegamentoP7_1_2
    {
        public MotivoCollegamento motivoCollegamento { get; set; }
    }

    /* FINE DTO per la scheda P7_1_2 */

    /* Inizio DTO per la scheda AD2_25 */

    public class BodyAD2_25
    {
        public AnacFormAD2_25 anacForm { get; set; }
        public string espd { get; set; }
    }

    public class AnacFormAD2_25
    {
        public List<StazioniAppaltanti> stazioniAppaltanti { get; set; }
        public AppaltoAD2_25 appalto { get; set; }
        public List<AggiudicazioneAD2_25Type> aggiudicazioni { get; set; }
    }

    public class AppaltoAD2_25
    {
        public string codiceAppalto { get; set; }
        public MotivoUrgenza motivoUrgenza { get; set; }
        public string linkDocumenti { get; set; }
        public bool relazioneUnicaSulleProcedure { get; set; }
        public bool opereUrbanizzazioneScomputo { get; set; }
        public DatiBase datiBase { get; set; }
        public DatiBaseProcedura datiBaseProcedura { get; set; }
    }

    public class AggiudicazioneAD2_25Type
    {
        public string lotIdentifier { get; set; }
        public bool afferenteInvestimentiPNRR { get; set; }
        public bool acquisizioneCup { get; set; }
        public List<string> cupLotto { get; set; }
        public string ccnl { get; set; }
        public Categoria categoria { get; set; }
        public CodIstat codIstat { get; set; }
        public QuadroEconomicoStandard quadroEconomicoStandard { get; set; }
        //public QuadroEconomicoConcessioni quadroEconomicoConcessioni { get; set; }
        public List<PartecipanteAD2_25> partecipanti { get; set; }
        public DatiBaseAD2_25 datiBase { get; set; }
        public string oggetto { get; set; }
        public DatiBaseAggiudicazioneAppalto datiBaseAggiudicazioneAppalto { get; set; }

		public DatiBaseDocumenti datiBaseDocumenti { get; set; }

		public class PartecipanteAD2_25
        {
            public string codiceFiscale { get; set; }
            public string denominazione { get; set; }
            public Categoria ruoloOE { get; set; }
            public Categoria tipoOE { get; set; }
            public string idPartecipante { get; set; }
            public string paeseOperatoreEconomico { get; set; }
            public bool avvalimento { get; set; }
            public decimal importo { get; set; }
            //public TipologiaAvvalimento tipologiaAvvalimento { get; set; }

        }
        public class DatiBaseAD2_25
        {
            public Categoria oggettoContratto { get; set; }
            public string oggetto { get; set; }
        }
    }

    /* Fine DTO per la scheda AD2_25 */
    public class AnacFormAD3
    {
        public List<StazioniAppaltanti> stazioniAppaltanti { get; set; }
        public AppaltoAD3 appalto { get; set; }
        public List<AggiudicazioneAD3Type> aggiudicazioni { get; set; }
    }


    public class AppaltoAD3 : Appalto
    {
        public DatiBase datiBase { get; set; }
    }


    public class AggiudicazioneAD3Type : Lotti
    {
        public List<PartecipanteAD3> partecipanti { get; set; }

        public DatiBaseAD3 datiBase { get; set; }
        public DatiBaseAggiudicazioneAppaltoAD3 datiBaseAggiudicazioneAppalto { get; set; }

		public DatiBaseDocumenti datiBaseDocumenti { get; set; }
	}



    public class DatiBaseAggiudicazioneAppaltoAD3
    {
        public string dataAggiudicazione { get; set; }
    }

    public class DatiBaseAggiudicazioneAppalto
    {
        public string dataAggiudicazione { get; set; }
    }

    public class PartecipanteAD3
    {
        public string codiceFiscale { get; set; }
        public string denominazione { get; set; }
        public Categoria ruoloOE { get; set; }
        public Categoria tipoOE { get; set; }
        public string idPartecipante { get; set; }
        public string paeseOperatoreEconomico { get; set; }
        public bool avvalimento { get; set; }
        public decimal importo { get; set; }

    }





    public class Appalto
    {
        public string codiceAppalto { get; set; }
        public List<CategorieMerceologiche> categorieMerceologiche { get; set; }
        public StrumentiSvolgimentoProcedure strumentiSvolgimentoProcedure { get; set; }
        public ContrattiDisposizioniParticolari contrattiDisposizioniParticolari { get; set; }
        public MotivoUrgenza motivoUrgenza { get; set; }
        public string linkDocumenti { get; set; }
        //public DatiBase datiBase { get; set; }
        //public DatiBaseProcedura datiBaseProcedura { get; set; }
        //public DatiBaseStrumentiProcedura datiBaseStrumentiProcedura { get; set; }
        //public List<Lotti> lotti { get; set; }
    }

    public class ContrattiDisposizioniParticolari
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }
    public class StrumentiSvolgimentoProcedure
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class Body
    {
        public AnacForm anacForm { get; set; }
        public string eform { get; set; }
        public string espd { get; set; }
    }

    public class BodyAD3
    {
        public AnacFormAD3 anacForm { get; set; }
        public string espd { get; set; }
    }



    public class Categoria
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class CategorieMerceologiche
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class Codice
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class CodIstat
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class CondizioniNegoziatum
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    //public class ContrattiDisposizioniParticolari
    //{
    //    public string idTipologica { get; set; }
    //    public string codice { get; set; }
    //}

    public class TipologiaLavoro
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class DatiBase
    {
        public string oggetto { get; set; }
        public decimal? importo { get; set; }
        //public string oggettoContratto { get; set; }
    }



    public class DatiBaseAD3
    {
        public string oggetto { get; set; }
        public Categoria oggettoContratto { get; set; }
    }

    public class DatiBaseAccessibilità
    {
        public string accessibilit { get; set; }
        public string giustificazione { get; set; }
    }

    public class DatiBaseAggiudicazione
    {
        public string criteriAggiudicazione { get; set; }
    }

    public class DatiBaseAggiuntivi
    {
        public string affidamentiRiservati { get; set; }
    }

    public class DatiBaseContratto
    {
        public string codNUTS { get; set; }
    }

    public class DatiBaseCPV
    {
        public string tipoClassificazione { get; set; }
        public string cpvPrevalemte { get; set; }
        public List<string> cpvSecondarie { get; set; }
    }

    public class DatiBaseCPVP2_16
    {
        public TipoClassificazione tipoClassificazione { get; set; }
        //public CPVPervalente cpvPrevalente { get; set; }
    }

    public class CPVPervalente
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class DatiBaseDocumenti
    {
        public string url { get; set; }
        //public List<string> lingue { get; set; }
    }

    public class DatiBaseImporto
    {
        public bool contrattiSuccessivi { get; set; }
    }

    public class DatiBaseProcedura
    {
        public TipoProcedura tipoProcedura { get; set; }
        //public bool proceduraAccelerata { get; set; }
        //public GiustificazioniAggiudicazioneDiretta giustificazioniAggiudicazioneDiretta { get; set; }
    }

    public class DatiBaseProceduraA2_29
    {
        public TipoProcedura tipoProcedura { get; set; }
        public List<GiustificazioniAggiudicazioneDiretta> giustificazioniAggiudicazioneDiretta { get; set; }
    }

    public class DatiBaseProceduraP2_16
    {
        public TipoProcedura tipoProcedura { get; set; }
        public bool proceduraAccelerata { get; set; }
        //public GiustificazioniAggiudicazioneDiretta giustificazioniAggiudicazioneDiretta { get; set; }
    }

    public class DatiBaseStrumentiProcedura
    {
        public AccordoQuadro accordoQuadro { get; set; }
        public SistemaDinamicoAcquisizione sistemaDinamicoAcquisizione { get; set; }
        public bool astaElettronica { get; set; }
    }

    public class AccordoQuadro
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class SistemaDinamicoAcquisizione
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class Subappalto
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    /*
    public class DatiBaseTermineInvio
    {
        public string scadenzaPresentazioneInvito { get; set; }
        public string oraScadenzaPresentazioneInvito { get; set; }
    }
    */

    public class GiustificazioniAggiudicazioneDiretta
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class ModalitaAcquisizione
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class OggettoPrincipaleContratto
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class Lotti
    {
        public string lotIdentifier { get; set; }
        public List<CategorieMerceologiche> categorieMerceologiche { get; set; }
        //public List<CondizioniNegoziatum>? condizioniNegoziata { get; set; } = null;
        public ContrattiDisposizioniParticolari contrattiDisposizioniParticolari { get; set; }
        public CodIstat codIstat { get; set; }
        public bool afferenteInvestimentiPNRR { get; set; }
        public bool acquisizioneCup { get; set; }
        public List<string> cupLotto { get; set; }
        public string cup { get; set; }
        public string motivoEsclusioneOrdinarioSpeciale { get; set; }
        public ModalitaAcquisizione modalitaAcquisizione { get; set; }
        public OggettoPrincipaleContratto oggettoPrincipaleContratto { get; set; }
        public prestazioniComprese prestazioniComprese { get; set; }
        public bool servizioPubblicoLocale { get; set; }
        public bool ripetizioniEConsegneComplementari { get; set; }
        public bool lavoroOAcquistoPrevistoInProgrammazione { get; set; }
        //public string? cui { get; set; }
        public string ccnl { get; set; }
        public List<TipologiaLavoro> tipologiaLavoro { get; set; }
        public bool opzioniRinnovi { get; set; }

        public IpotesiCollegamento ipotesiCollegamento { get; set; }

        public Categoria categoria { get; set; }
        public QuadroEconomicoStandard quadroEconomicoStandard { get; set; }
        //public DatiBase datiBase { get; set; }
        //public DatiBaseContratto datiBaseContratto { get; set; }
        //public DatiBaseAggiuntivi datiBaseAggiuntivi { get; set; }
        //public DatiBaseAggiudicazione datiBaseAggiudicazione { get; set; }
        //public DatiBaseTermineInvio datiBaseTermineInvio { get; set; }
        //public DatiBaseImporto datiBaseImporto { get; set; }
        //public DatiBaseCPV datiBaseCPV { get; set; }
        //public DatiBaseAccessibilità datiBaseAccessibilit { get; set; }
        //public DatiBaseDocumenti datiBaseDocumenti { get; set; }
        public bool? strumentiElettroniciSpecifici { get; set; }

    }

    public class FunzioniSvolte
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class MotivoUrgenza
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class prestazioniComprese
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class QuadroEconomicoStandard
    {
        public decimal impLavori { get; set; }
        public decimal impServizi { get; set; }
        public decimal impForniture { get; set; }
        public decimal impTotaleSicurezza { get; set; }
        public decimal ulterioriSommeNoRibasso { get; set; }
        public decimal impProgettazione { get; set; }
        public decimal sommeOpzioniRinnovi { get; set; }
        public decimal sommeRipetizioni { get; set; }
        public decimal sommeADisposizione { get; set; }
    }

    public class QuadroEconomicoConcessioni
    {
        public decimal impLavori { get; set; }
        public decimal impServizi { get; set; }
        public decimal impForniture { get; set; }
        public decimal finanziamentiCanoniPA { get; set; }
        public decimal entrateUtenza { get; set; }
        public decimal introitoAttivo { get; set; }
        public decimal impTotaleSicurezza { get; set; }
        public decimal ulterioriSommeRibasso { get; set; }
        public decimal sommeOpzioniRinnovi { get; set; }
        public decimal sommeADisposizione { get; set; }
    }

    public class BaseModel
    {
        public Scheda scheda { get; set; }
    }

    public class BaseModelP7_2
    {
        public SchedaP7_2 scheda { get; set; }
    }

    public class BaseModelModificaP7_2 : BaseModelP7_2
    {
        public string idAppalto { get; set; }
    }


    public class BaseModelAD3
    {
        public SchedaAD3 scheda { get; set; }
    }

    public class BaseModelModificaAD3 : BaseModelAD3
    {
        public string idAppalto { get; set; }
    }

    public class BaseModelModifica : BaseModel
    {
        public string idAppalto { get; set; }
    }

    public class BaseModelAD2_25
    {
        public SchedaAd2_25 scheda { get; set; }
    }
    public class Scheda
    {
        public Codice codice { get; set; }
        public string versione { get; set; }
        public Body body { get; set; }
    }

    public class BaseModelP7_1_2
    {
        public SchedaP7_1_2 scheda { get; set; }
    }
    public class BaseModelP7_1_3
    {
        public SchedaP7_1_3 scheda { get; set; }
    }
    public class BaseModelModificaP7_1_3 : BaseModelP7_1_3
    {
        public string idAppalto { get; set; }
    }


    public class SchedaP7_1_2
    {
        public Codice codice { get; set; }
        public string versione { get; set; }
        public BodyP7_1_2 body { get; set; }
    }

    public class SchedaP7_1_3
    {
        public Codice codice { get; set; }
        public string versione { get; set; }
        public BodyP7_1_3 body { get; set; }
    }

    public class BodyP7_1_3
    {
        public AnacFormP7_1_3 anacForm { get; set; }
    }

    public class AnacFormP7_1_3
    {
        public List<StazioniAppaltanti> stazioniAppaltanti { get; set; }
        public AppaltoP7_1_2 appalto { get; set; }
        public List<LottiP7_1_3> lotti { get; set; }
    }

    public class LottiP7_1_3 : LottiP7_1_2
    {
        public bool strumentiElettroniciSpecifici { get; set; }
    }

    public class SchedaAd2_25
    {
        public Codice codice { get; set; }
        public string versione { get; set; }
        public BodyAD2_25 body { get; set; }
    }
    public class SchedaAD3
    {
        public Codice codice { get; set; }
        public string versione { get; set; }
        public BodyAD3 body { get; set; }
    }

    #region SchedaP7_2
    public class SchedaP7_2
    {
        public Codice codice { get; set; }
        public string versione { get; set; }
        public BodyP7_2 body { get; set; }
    }

    public class BodyP7_2
    {
        public AnacFormP7_2 anacForm { get; set; }
        public string espd { get; set; }
    }

    public class AnacFormP7_2
    {
        public List<StazioniAppaltanti> stazioniAppaltanti { get; set; }
        public AppaltoP7_2 appalto { get; set; }
        public List<LottiP7_2> lotti { get; set; }
    }

    public class AppaltoP7_2 : Appalto
    {
        public MotivazioneCIG motivazioneCIG { get; set; }
        public DatiBase datiBase { get; set; }
        public DatiBaseProcedura datiBaseProcedura { get; set; }
    }

    public class MotivazioneCIG
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class LottiP7_2
    {
        public string lotIdentifier { get; set; }
        public List<CategorieMerceologiche> categorieMerceologiche { get; set; }
        public bool saNonSoggettaObblighi24Dicembre2015 { get; set; }
        public bool iniziativeNonSoddisfacenti { get; set; }
        public List<CondizioniNegoziata> condizioniNegoziata { get; set; }
        public ContrattiDisposizioniParticolari contrattiDisposizioniParticolari { get; set; }
        public CodIstat codIstat { get; set; }
        public bool servizioPubblicoLocale { get; set; }
        public bool lavoroOAcquistoPrevistoInProgrammazione { get; set; }
        public string cui { get; set; }

        public bool ripetizioniEConsegneComplementari { get; set; }
        public IpotesiCollegamento ipotesiCollegamento { get; set; }
        //public MotivoCollegamento motivoCollegamento { get; set; }
        public bool opzioniRinnovi { get; set; }
        public bool afferenteInvestimentiPNRR { get; set; }
        public bool acquisizioneCup { get; set; }
        public List<string> cupLotto { get; set; }
        public string ccnl { get; set; }
        //public ModalitaAcquisizione modalitaAcquisizione { get; set; }
        public List<TipologiaLavoro> tipologiaLavoro { get; set; }
        public Categoria categoria { get; set; }
        public prestazioniComprese prestazioniComprese { get; set; }
        public List<Finanziamento> finanziamenti { get; set; }
        public TipoRealizzazione tipoRealizzazione { get; set; }
        public DatiBaseP7_2 datiBase { get; set; }
        public QuadroEconomicoStandard quadroEconomicoStandard { get; set; }
        public DatiBaseTerminiInvio datiBaseTerminiInvio { get; set; }

		public DatiBaseDocumenti datiBaseDocumenti { get; set; }

	}

    public class CondizioniNegoziata
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class IpotesiCollegamento
    {
        public List<string> cigCollegato { get; set; }
        public MotivoCollegamento motivoCollegamento { get; set; }
    }

    public class MotivoCollegamento
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }
    public class Finanziamento
    {
        public TipoFinanziamento tipoFinanziamento { get; set; }
        public double importo { get; set; }

    }

    public class TipoRealizzazione
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class DatiBaseP7_2
    {
        public OggettoContratto oggettoContratto { get; set; }
        public string oggetto { get; set; }
        public decimal importo { get; set; }
    }

    public class OggettoContratto
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class DatiBaseTerminiInvio
    {
        public DateTime oraScadenzaPresentazioneOfferte { get; set; }
    }

	public class DatiBaseTerminiInvio2
	{
		public DateTime? scadenzaPresentazioneInvito { get; set; }

		public DateTime? oraScadenzaPresentazioneOfferte { get; set; }

	}

	#endregion


	public class Stato
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class StazioniAppaltanti
    {
        public string codiceFiscale { get; set; }
        public string codiceAusa { get; set; }
        public string codiceCentroCosto { get; set; }
        public List<FunzioniSvolte> funzioniSvolte { get; set; }
        public bool saTitolare { get; set; }
    }

    public class TipoProcedura
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }


    public class RispostaCreaAppalto : RispostaBase
    {

        public string idAppalto { get; set; }

    }

    public class Errori
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
        public string dettaglio { get; set; }
    }

    public class RispostaBase
    {
        public int status { get; set; }
        public string detail { get; set; }
        public string title { get; set; }
        public string type { get; set; }
        public List<Errori> errori { get; set; }
    }

    public class RispostaCig : RispostaBase
    {
        public int totRows { get; set; }
        public int totPages { get; set; }
        public int currentPage { get; set; }
        public int elementPage { get; set; }
        public List<Tipologica> result { get; set; }

    }

    public class RispostaCreaScheda
    {
        public string instance { get; set; }
        public int status { get; set; }
        public string title { get; set; }
        public string detail { get; set; }
        public string type { get; set; }
        public string idScheda { get; set; }
    }


    public class Tipologica
    {
        public string cig { get; set; }
        public string lotIdentifier { get; set; }
    }
    public class RispostaServizi : RispostaBase
    {
        public List<ListaEsiti> listaEsiti { get; set; }
        public class Dettaglio
        {
            public string idTipologica { get; set; }
            public string codice { get; set; }
        }

        public class Esito
        {
            public string idTipologica { get; set; }
            public string codice { get; set; }
        }

        public class ListaEsiti
        {
            public string idAppalto { get; set; }
            public string idScheda { get; set; }
            public string idAvviso { get; set; }
            public Esito esito { get; set; }
            public TipoOperazione tipoOperazione { get; set; }
            public DateTime dataControllo { get; set; }
            public Dettaglio dettaglio { get; set; }
            public List<Errori> errori { get; set; }
        }

        public class TipoOperazione
        {
            public string idTipologica { get; set; }
            public string codice { get; set; }
        }
    }

    public class IdAppalto
    {
        public string idAppalto { get; set; }
    }

    public class UtilsConvert
    {
        public static decimal ToDecimal(object value)
        {
            if (value is string)
            {
                if (InStr(1, Convert.ToString(0.5), ",") > 0)
                {
                    value = ((string)value).Replace(".", ",");
                }
                return Convert.ToDecimal(value);

            }
            else
            {
                return ToDecimal(value.ToString());
            }

        }

        public static string ToString(object value)
        {
            if (value == null)
            {
                return "";
            }
            else
            {
                return value.ToString();
            }
        }

        public static bool ToBool(object value)
        {
            if (value == null || value is System.DBNull)
            {
                return false;
            }
            else
            {
                if (value is bool)
                {
                    return (bool)value;
                }
                else if (value is string)
                {
                    return value.ToString() == "true";
                }
            }
            throw new NotImplementedException();
        }

        public static int InStr(int start, string string1, string string2)
        {
            const int retDefault = -1;
            int retPos;

            //lo start non può essere minore o uguale di 1, in caso di errore forziamo la sua correzione
            if (start < 1)
            {
                start = 1;
            }

            try
            {
                if ((string1 is null) || (string2 is null)) return retDefault;

                retPos = string1.IndexOf(string2, start - 1, StringComparison.Ordinal);
            }
            catch (Exception ex) when (ex is ArgumentOutOfRangeException || ex is ArgumentNullException)
            {
                return retDefault;
            }

            return retPos;
        }
    }

    public class EsitoOperazione
    {
        public string idAppalto { get; set; }
        public string tipoOperazione { get; set; }
        public string tipoRicerca { get; set; }
    }


    public class RispostaAusaCDC
    {
        public int code { get; set; }
        public string status { get; set; }
        public string title { get; set; }
        public List<ItemRispostaAusaCDC> items { get; set; }
    }

    public class ItemRispostaAusaCDC
    {
        public SchedaRispostaAusaCDC scheda { get; set; }
        public string Ts { get; set; }
    }

    public class SchedaRispostaAusaCDC
    {
        public DocumentoRispostaAusaCDC documento { get; set; }
        public StazioneAppaltante stazioneAppaltante { get; set; }
        public string Ts { get; set; }
    }

    public class DocumentoRispostaAusaCDC
    {
        public string tipo { get; set; }
        public string versione { get; set; }
    }

    public class StazioneAppaltante                                         //✔️
    {
        public StatoAUSA statoAusa { get; set; }                            //✔️
        public List<CentroDiCosto> centriDiCosto { get; set; }
        public string codiceausa { get; set; }
        public AUSARispostaAusaCDC ausa { get; set; }
    }

    public class StatoAUSA                                                  //✔️
    {
        public string stato { get; set; }
        public string dataInizio { get; set; }
        public string dataFine { get; set; }
    }

    public class CentroDiCosto                                              //✔️
    {
        public StatoAUSA stato { get; set; }
        public string denominazioneCentroDiCosto { get; set; }
        public ContattiRispostaAusaCDC contatti { get; set; }
        public string flagSoggettoAggregatore { get; set; }
        public string idCentroDiCosto { get; set; }
        public LocalizzazioneRispostaAusaCDC localizzazione { get; set; }
    }

    public class CentroDiCostoLight
    {
        public string denominazioneCentroDiCosto { get; set; }
        public string idCentroDiCosto { get; set; }
    }

    public class ContattiRispostaAusaCDC
    {
        public string telefono { get; set; }
        public string mailPEC { get; set; }
        public string email { get; set; }
    }

    public class LocalizzazioneRispostaAusaCDC
    {
        public string cap { get; set; }
    }

    public class AUSARispostaAusaCDC
    {
        // Aggiungi altri campi specifici di AUSA qui
    }

    public class TipologiaAvvalimento
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public enum TipoScheda
    {
        P1_16 = 1,
        AD_3 = 2,
        S2 = 3,
        P2_16 = 4,
        AD2_25 = 5,
        AD_4 = 6,
        AD_5 = 7,
        P6_1 = 8,
        P6_2 = 9,
        P7_2 = 10,
        S1 = 11,
        A1_29 = 12,
        S3 = 13,
        SC1 = 14,
        P7_1_2 = 15,
        P7_1_3 = 16,
        P1_19 = 17,
        A2_29 = 18,
        NAG = 19,
        P2_19 = 20,
        A7_1_2 = 21
    }

    public class NullExcludeConverter<T> : JsonConverter<T>
    {
        //QUesta classe è stata creata come tentativo di serializzazione json di un oggetto con attributi opzionali. ma non ha funzionato
        public override T Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            return JsonSerializer.Deserialize<T>(ref reader, options);
        }

        public override void Write(Utf8JsonWriter writer, T value, JsonSerializerOptions options)
        {
            var properties = typeof(T).GetProperties();

            writer.WriteStartObject();

            foreach (var property in properties)
            {
                var propertyValue = property.GetValue(value);
                if (propertyValue != null)
                {
                    writer.WritePropertyName(property.Name);
                    JsonSerializer.Serialize(writer, propertyValue, options);
                }
            }

            writer.WriteEndObject();
        }
    }

}