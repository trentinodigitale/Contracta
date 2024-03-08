using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Reflection;
using System.Security.Authentication;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Net.Security;
using RestSharp;
using System.Security.Principal;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Runtime.InteropServices;
using System.Xml.Linq;
using System.Runtime.InteropServices.ComTypes;

namespace ProtocolloPiTre
{
    public partial class ProtocolloPiTre : System.Web.UI.Page
    {

        //string endPointTND = "http://sfw194582.ced.adds/Insiel.eProcurement.Protocol.Web"; //Recuperare da web.config
        //string endPointBarerToken = "http://sfw194582.ced.adds/Insiel.eProcurement.Protocol.Web"; //Recuperare da web.config e chiedere spiegazioni sul suo significato
        //string endPointProtocollo = "http://sfw194582.ced.adds/Insiel.eProcurement.Protocol.Web";


        string endPointTND = ConfigurationManager.AppSettings["TND.endPointProtocollo"];
        string ConnectionString = ConfigurationManager.AppSettings["db.conn"];
        string PIVA_Ente = "";
        

        X509Certificate2 cert = null;
        Dictionary<string, string> fileLIST = new Dictionary<string, string>();
        SqlConnection sqlConn;

        string directoryTemporanea = ConfigurationManager.AppSettings["app.dir_download"];
        string errorInterval = ConfigurationManager.AppSettings["docer.mail.error"];
        string mailAlert = ConfigurationManager.AppSettings["docer.mailbackoffice"];
        string strSimulazione = ConfigurationManager.AppSettings["TND.Simulazione"];

        string strPathCertificate = ConfigurationManager.AppSettings["TND.PathCertificate"];        
        string strPwdCertificate = ConfigurationManager.AppSettings["TND.PwdCertificate"];
        string CODE_ADM= ConfigurationManager.AppSettings["TND.CODE_ADM"];
        string CODE_ADM_CREATE = ConfigurationManager.AppSettings["TND.CODE_ADM_CREATE"];
        string CODE_SENDER_GARA_APERTA = ConfigurationManager.AppSettings["TND.CODE_SENDER_GARA_APERTA"];
        string RAGSOC_SENDER_GARA_APERTA = ConfigurationManager.AppSettings["TND.RAGSOC_SENDER_GARA_APERTA"];
        string RAGSOC_OE_GARA_APERTA = ConfigurationManager.AppSettings["TND.RAGSOC_OE_GARA_APERTA"];
    

        public const SslProtocols _Tls12 = (SslProtocols)0x00000C00;
        public const SecurityProtocolType Tls12 = (SecurityProtocolType)_Tls12;

        bool Simulazione = false;

        string tab_id = "";
        string mode = "";
        bool esito = false;
        string strSql;
        string oggettoFascicolo = "";
        string noteFascicolo = "";
        string IdAziEnte = "";

        string FascicoloInp = "";
        string AnnoFascicoloInp = "";
        string tipoDoc = "";
        string tipobandogara = "";
        string ProceduraGara = "";

        InfoDoc doc = new InfoDoc();

        protected void Page_Load(object sender, EventArgs e)
        {

            string strCause = "";
            string CodiceAnagrafica = "";
            string DescrizioneAnagrafica = "";
            string cf = "";
            string RagSoc = "";

            


            

            if (strSimulazione == "1")
                Simulazione = true;

            // esempio url da chiamare
            // http://localhost:52655/ProtocolloPiTre.aspx?ID=7287

            try
            {


                //-- PARAMETRI
                //--     MODE : 'protocolla', 'verifica'
                //--     ID  ( ID della v_protgen, del record che si vuole protocollare )

                strCause = "Lettura dei parametri in querystring ";
                tab_id = Request.QueryString["ID"];
                mode = Request.QueryString["MODE"];

                oggettoFascicolo = Request.QueryString["OGGETTO_FASCICOLO"];
                noteFascicolo = Request.QueryString["NOTE_FASCICOLO"];

                FascicoloInp = Request.QueryString["FascicoloGenerale"];
                //AnnoFascicoloInp = Request.QueryString["anno_fascicolo"];
                if (string.IsNullOrEmpty(FascicoloInp))
                    FascicoloInp = "";

                IdAziEnte = Request.QueryString["IdAziEnte"];

                if (string.IsNullOrEmpty(oggettoFascicolo))
                    oggettoFascicolo = "oggetto";

                if (string.IsNullOrEmpty(noteFascicolo))
                    noteFascicolo = "note";

                if (string.IsNullOrEmpty(tab_id))
                {
                    Response.StatusCode = 500;
                    Response.StatusDescription = "Parametro ID obbligatorio";
                    Response.Write("0#Parametro ID obbligatorio");
                    //Response.End()  ;
                    return;
                }

                if (string.IsNullOrEmpty(mode))
                    mode = "";

                SqlCommand cmd1;
                SqlDataReader rs;


                strCause = "Apre la connessione al db ";

                sqlConn = new SqlConnection(ConnectionString);
                sqlConn.Open();

                string idDocumento = getVProtgenDato(tab_id, "appl_id_evento");   //'-- id del documento
                string ingressoUscita = getVProtgenDato(tab_id, "modalita");     //'I = Ingresso  U = Uscita

                doc.Id = idDocumento;

                string fascicolo = "";
                string strTitolo = "";                

                

                // recupera il fascicolo dal documento

                if (mode.ToUpper() == "VERIFICA_FASCICOLO")
                {
                    idDocumento = tab_id;
                    ingressoUscita = "U";
                }

                strCause = "Recupera Fascicolo";
                esito = RecuperaFascicolo(idDocumento, ingressoUscita, out fascicolo, out strTitolo);

                if (mode.ToUpper() == "VERIFICA_FASCICOLO")
                {
                    strCause = "VERIFICA_FASCICOLO";

                    if (!string.IsNullOrEmpty(FascicoloInp))
                        if (FascicoloInp != fascicolo)
                            fascicolo = FascicoloInp;

                    if (fascicolo == "")
                    {
                        inserisciEsito(tab_id, "KO");
                        Response.Write("0#Fascicolo vuoto");
                        return;
                    }
                    string Errore = "";
                    esito = ControlloFascicolo(fascicolo, out Errore);

                    if (Errore == "")
                    {
                        inserisciEsito(tab_id, "OK");
                        Response.Write("1#OK");
                        return;
                    }
                    else
                    {
                        inserisciEsito(tab_id, "KO");
                        Response.Write("0#" + Errore);
                        return;
                    }
                   
                }


                if (mode.ToUpper() == "CREA_FASCICOLO")
                {                   

                    strCause = "CREA_FASCICOLO";
                    //inserisciEsito(tab_id, "OK");              

                   

                    if (fascicolo=="")
                        Response.Write("0#" + "Fascicolo non trovato (campo necessario alla protocollazione)");
                    else
                        Response.Write("1#" + fascicolo);

                    return;
                }


                strCause = "Controllo se per l'id richiesto esiste gia un protocollo generale";

                string ProtocolloGenerale = getVProtgenDato(tab_id, "ProtocolloGenerale");

                if (!string.IsNullOrEmpty(ProtocolloGenerale))
                {

                    settaEsito(false, tab_id);
                    Response.Write("1#OK");
                    return;

                }

                // INIZIO PROTOCOLLAZIONE
                strCause = "Inizio Protocollazione - recupero dati v_protgen";

                InfoRec recInfo = new InfoRec();

                Dictionary<string, InfoRec> ListInfoRecDest ;
                

                recInfo.TipoProtocollo = "";
                recInfo.CodeSender = "";


                string oggettoProtocollo = getVProtgenDato(tab_id, "Oggetto");
                string fascicoloPrimario = getVProtgenDato(tab_id, "FascicoloGenerale");
                
                tipoDoc = getVProtgenDato(tab_id, "tipoDoc");

                if (tipoDoc == "BANDO_GARA" || tipoDoc == "BANDO")
                    GetDatiBando(idDocumento, out tipobandogara, out ProceduraGara);

                       
                string discriminanteAllegato = getVProtgenDato(tab_id, "allegatoProtocollo");
                string tabellaAllegati = getVProtgenDato(tab_id, "tabellaAllegatiProtocollo");

                string tmp = getVProtgenDato(tab_id, "attivo");
                int isAttivo;
                string IdAzi;
                string IdAziMittDest;

                if (tmp == "")
                    isAttivo = 1;
                else
                    isAttivo = Int32.Parse(tmp);

                if (isAttivo == 0)
                {
                    strCause = "chiudo il giro per flusso non attivo";

                    settaProtocollo("", "", tab_id);
                    settaEsito(false, tab_id);

                    Response.Write("1#OK");
                    return;


                }



                if (isAttivo == 1 && idDocumento != "" && ingressoUscita != "" && oggettoProtocollo != "")
                {
                    strCause = "Protocollazione - inizio recupero aoo";

                    //algoritmo = getVProtgenDato(db, tab_id, "algoritmo")
                    string aoo = getVProtgenDato(tab_id, "aoo");

                    //strSql = "select cast(idazi as varchar) as idazi from Document_protocollo_datiAOO with(nolock) inner join Aziende a with(nolock)  on azilog=codiceEnte and aziDeleted=0 where codiceAOO = '" + aoo.Replace("'", "''") + "'";
                    strSql = "select cast(idazi as varchar) as idazi from Aziende a with(nolock) WHERE azilog = '" + aoo.Replace("'", "''") + "'";

                    cmd1 = new SqlCommand(strSql, sqlConn);
                    using (rs = cmd1.ExecuteReader())
                    {

                        if (rs.Read())
                        {
                            IdAzi = rs.GetString(rs.GetOrdinal("idazi"));

                        }
                        else
                            throw new Exception("Errore recupero ente per AOO=" + aoo + " - controllare tabella Document_protocollo_datiAOO");


                    }

                    string ragsoc2;
                    string ragsoc;
                    string cf2 = "";

                    GetDatiAnag(IdAzi, out PIVA_Ente, out cf2, out ragsoc2);
                    
                    recInfo.IdAziEnte = Convert.ToInt32 (IdAzi);

                    //strCause = "recupero PIVA ente";
                    //PIVA_Ente = GetPIVA_CF(IdAzi);

                    recInfo.PivaEnte  = PIVA_Ente;
                    recInfo.CFEnte = cf2;
                    recInfo.RagSocEnte = ragsoc2 ;

                    IdAziMittDest = "0";

                    strCause = "recupero codice fiscale mittente o destinatario";

                    strSql = "select distinct value from v_protgen_dati with (nolock) where idheader = " + tab_id + " and DZT_Name = 'IdAzi' and isnull(Value,'') <> ''";

                    cmd1 = new SqlCommand(strSql, sqlConn);
                    using (rs = cmd1.ExecuteReader())
                    {

                        if (rs.Read())
                        {
                            IdAziMittDest = rs.GetString(rs.GetOrdinal("value"));
                        }
                        else                            
                        {
                            //throw new Exception("Errore recupero idazi per mittente o destinatario");
                            // caso della procedura aperta (senza destinatari)
                            IdAziMittDest = "0";
                            recInfo.IdAziOE = 0;
                            recInfo.PivaOE = "";
                            recInfo.CFOE = "";
                            //recInfo.RagSocOE = RAGSOC_SENDER_GARA_APERTA;
                            recInfo.RagSocOE = RAGSOC_OE_GARA_APERTA;
                            recInfo.TipoProtocollo = "P";

                            recInfo.PivaEnte = "";
                            recInfo.CFEnte = "";
                            //recInfo.RagSocEnte  = "Ufficio gare servizi e forniture";
                            //recInfo.CodeSender = "U354";
                            recInfo.RagSocEnte = RAGSOC_SENDER_GARA_APERTA;
                            recInfo.CodeSender = CODE_SENDER_GARA_APERTA;

                        }
                    }

                    

                    //cf = GetPIVA_CF(IdAziMittDest, false);
                    string PIVA = "";

                    // caso della procedura negoziata
                    if (ProceduraGara == "15478")
                    {
                        recInfo.IdAziOE = 0;
                        recInfo.PivaOE = "";
                        recInfo.CFOE = "";
                        recInfo.RagSocOE = RAGSOC_OE_GARA_APERTA;
                        //recInfo.TipoProtocollo = "";
                        recInfo.TipoProtocollo = "P";

                        recInfo.PivaEnte = "";
                        recInfo.CFEnte = "";
                        recInfo.RagSocEnte = RAGSOC_SENDER_GARA_APERTA;
                        recInfo.CodeSender = CODE_SENDER_GARA_APERTA;
                    }
                    else if (IdAziMittDest != "0")
                    { 
                        GetDatiAnag(IdAziMittDest, out PIVA, out cf, out ragsoc);
                        recInfo.IdAziOE = Convert.ToInt32(IdAziMittDest);
                        recInfo.PivaOE  = PIVA;
                        recInfo.CFOE = cf;
                        recInfo.RagSocOE = ragsoc;
                        recInfo.TipoProtocollo = "";
                        recInfo.CodeSender = "";
                    }

                    setVProtgenDato(tab_id, "TND_Sender", recInfo.IdAziEnte.ToString() + " - " + recInfo.RagSocEnte);
                    setVProtgenDato(tab_id, "TND_Recipient", recInfo.IdAziOE.ToString() + " - " + recInfo.RagSocOE);

                    strCause = "gestione allegati";

                    if (discriminanteAllegato == "")
                        discriminanteAllegato = "Allegato";


                    if (tabellaAllegati == "")
                        tabellaAllegati = "ctl_doc_value";

                    bool allegatiMancanti = false;

                    if (tipoDoc.ToUpper() != "CHIARIMENTI_PORTALE" && tipoDoc.ToUpper() != "DETAIL_CHIARIMENTI_BANDO")


                        strSql = "SET NOCOUNT ON " +
                             " select dbo.GetColumnValue( Value, '*', 4) as chiave , idrow " +
                             "  into #Temp" +
                             " from " + tabellaAllegati + " with (nolock) " +
                             " where dse_id = 'ALLEGATI_PROTOCOLLO' and dzt_name = '" + discriminanteAllegato.Replace("'", "''") + "' and idHeader = " + idDocumento +
                             " order by idrow asc" +
                             " select att_obj as blob , replace(isnull(att_name,'temp'),':','') as nome " +
                             " from #Temp with (nolock) " +
                             "                        INNER JOIN ctl_attach  with (nolock) ON chiave = att_hash " +
                             " order by idrow asc" +
                             " DROP TABLE #temp";

                    else



                        strSql = "SET NOCOUNT ON " +
                                " select dbo.GetColumnValue( Value, '*', 4) as chiave , idrow into #Temp " +
                                "          from Document_Chiarimenti_Protocollo with (nolock) " +
                                "          where dzt_name = '" + discriminanteAllegato.Replace("'", "''") + "' and idHeader = " + idDocumento +
                                "          order by idrow asc " +
                                "   select att_obj as blob , replace(isnull(att_name,'temp'),':','') as nome " +
                                "          from #Temp with (nolock) " +
                                "                         INNER JOIN ctl_attach  with (nolock) ON chiave = att_hash " +
                                " order by idrow asc" +
                                " DROP TABLE #temp";

                    int k = 0;

                    cmd1 = new SqlCommand(strSql, sqlConn);
                    using (rs = cmd1.ExecuteReader())
                    {

                        if (rs.Read())
                        {
                            allegatiMancanti = false;
                            do
                            {
                                strCause = "Recupero il blob dell'allegato " + rs.GetString(rs.GetOrdinal("nome"));

                                k = k + 1;
                                int ndx = rs.GetOrdinal("blob");
                                long len = rs.GetBytes(ndx, 0, null, 0, 0);
                                byte[] values = { };

                                string uniqueStr = DateTime.Now.Hour.ToString() + DateTime.Now.Minute.ToString() + DateTime.Now.Second.ToString() + DateTime.Now.Millisecond.ToString() + cStr(k) + "_UNIQ_";

                                //ReDim values(CInt(len))
                                Array.Resize(ref values, Convert.ToInt32(len));
                                rs.GetBytes(Convert.ToInt32(ndx), 0, values, 0, Convert.ToInt32(len));

                                string pathFile = directoryTemporanea + uniqueStr + rs["nome"];

                                strCause = "Scrivo il file '" + cStr(rs["nome"]) + "' su disco";

                                System.IO.File.WriteAllBytes(pathFile, values);

                                fileLIST.Add(pathFile, cStr(rs["nome"]));


                            } while (rs.Read());

                            setVProtgenDato(tab_id, "TND_EsitoAllegati", "Allegati trovati = " + k.ToString() );

                        }
                        else
                        {
                            allegatiMancanti = true;
                            setVProtgenDato(tab_id, "TND_EsitoAllegati", "Nessun allegato trovato - Protocollazione non possibile");
                        }

                }


                    if (allegatiMancanti == false)
                    {
                        string aziRagioneSociale="";
                        string aziPartitaIVA;
                        string aziLocalitaLeg;
                        string aziStatoLeg;
                        string aziCAPLeg;
                        string aziIndirizzoLeg;
                        //string aziProvinciaLeg;
                        string aziE_Mail;
                        string ProvinciaSigla;
                        string nome;
                        string cognome;
                        string titolo;

                        getDatiDoc(doc);

                        recInfo.titolo = doc.titolo=="" ? doc.Oggetto : doc.titolo ;

                        // questo campo è obbligatorio e non può essere vuoto
                        if (string.IsNullOrEmpty(recInfo.titolo))
                        {
                            if (tipoDoc.ToUpper() == "CHIARIMENTI_PORTALE" || tipoDoc.ToUpper() == "DETAIL_CHIARIMENTI_BANDO")
                            {
                                getDatiChiarimento(doc);
                            }
                            recInfo.titolo = doc.titolo == "" ? doc.Oggetto : doc.titolo;

                            if (string.IsNullOrEmpty(recInfo.titolo))
                                throw new Exception("Impossibile trovare titolo del documento con id=" + doc.Id + " e tipo=" + tipoDoc.ToUpper());
                        }


                        if (IdAziMittDest!="0")
                        { 
                            strSql = "select * from FVG_Prot_GetDatiAnag with(nolock)  where idazi = " + IdAziMittDest;

                            cmd1 = new SqlCommand(strSql, sqlConn);
                            using (rs = cmd1.ExecuteReader())
                            {

                                if (rs.Read())
                                {
                                    aziRagioneSociale = rs.GetString(rs.GetOrdinal("aziRagioneSociale"));
                                    aziPartitaIVA = rs.GetString(rs.GetOrdinal("aziPartitaIVA"));
                                    aziLocalitaLeg = rs.GetString(rs.GetOrdinal("aziLocalitaLeg"));
                                    aziStatoLeg = rs.GetString(rs.GetOrdinal("aziStatoLeg"));
                                    aziCAPLeg = rs.GetString(rs.GetOrdinal("aziCAPLeg"));
                                    aziIndirizzoLeg = rs.GetString(rs.GetOrdinal("aziIndirizzoLeg"));
                                    aziE_Mail = rs.GetString(rs.GetOrdinal("aziE_Mail"));
                                    ProvinciaSigla = rs.GetString(rs.GetOrdinal("ProvinciaSigla"));
                                    nome = rs.GetString(rs.GetOrdinal("nome"));
                                    cognome = rs.GetString(rs.GetOrdinal("cognome"));
                                    titolo = rs.GetString(rs.GetOrdinal("titolo"));

                                    //recInfo.titolo = strTitolo;
                                }
                                else
                                    throw new Exception("Errore recupero dati anagrafici per idazi=" + IdAziMittDest);
                            }
                        }

                        // avviamo la protocollazione vera e propria
                        strCause = "Esegue la ricerca anagrafica del cf " + cf;

                        RagSoc = aziRagioneSociale;

                        

                        // ????? bisogna capire quale campo usare, quello del documento???
                        if (fascicoloPrimario == "")
                            fascicoloPrimario = fascicolo;

                        strCause = "carica elenco dei destinatari multipli";
                        ListInfoRecDest = GetDestinatari(idDocumento, recInfo);

                        strCause = "CreaProtocollo";
                        string Protocollo = "";

                        setVProtgenDato(tab_id, "TND_Fascicolo", fascicoloPrimario);

                        //esito = CreaProtocollo(PIVA_Ente, CodiceAnagrafica, DescrizioneAnagrafica, oggettoProtocollo, oggettoProtocollo, pratica, fileLIST, out Protocollo);
                        string ErroreGestito = "";
                        esito = Protocollazione(tab_id, idDocumento, ingressoUscita,fascicoloPrimario, recInfo, fileLIST, ListInfoRecDest, out Protocollo,out ErroreGestito);
                        if (esito && ErroreGestito=="")
                        {
                            settaProtocollo(Protocollo, getDateTec(), tab_id);
                            settaEsito(false, tab_id);
                        }
                        else
                        {
                            gestioneErrore(tab_id, "ProtocolloPiTre.aspx", strCause + " -- " + ErroreGestito + " -- ID da protocollare:" + tab_id, true);
                            db_trace("ERRORE-PROTOCOLLO. " + ErroreGestito, "ProtocolloPiTre.aspx");

                            Response.StatusCode = 500;
                            Response.StatusDescription = "Errore " + ErroreGestito;
                            Response.Write("0#"  + ErroreGestito);
                            return;
                        }





                    }
                    else
                    {
                        gestioneErrore(tab_id, "ProtocolloPiTre.aspx", strCause + " -- " + "Allegati assenti" + " -- ID da protocollare:" + tab_id, true);
                        db_trace("ERRORE-PROTOCOLLO. Allegati assenti", "ProtocolloPiTre.aspx");

                        Response.StatusCode = 500;
                        Response.StatusDescription = "Non sono presenti documenti da mandare al protocollo";
                        Response.Write("0#Non sono presenti documenti da mandare al protocollo");
                        return;
                    }




                }
                else
                {
                    gestioneErrore(tab_id, "ProtocolloPiTre.aspx", "Dati di protocollazione obbligatori mancanti. -- ID da protocollare:" + tab_id, true);
                    db_trace("ERRORE-PROTOCOLLO.Dati di protocollazione obbligatori mancanti per id v_protgen:" + tab_id, "ProtocolloPiTre.aspx");
                    Response.StatusCode = 500;
                    Response.StatusDescription = "Dati di protocollazione obbligatori mancanti";

                    Response.Write("0#Dati di protocollazione obbligatori mancanti");
                    return;
                }

                Response.Write("1#OK");
                return;

            }
            catch (Exception ex)
            {
                //throw new Exception("Errore nella protocollazione. " + strCause + " - " + ex.Message, ex);
                gestioneErrore( tab_id, "ProtocolloPiTre.aspx", strCause + " - " + ex.ToString() + " -- ID da protocollare:" + tab_id, true);
                db_trace("ERRORE-PROTOCOLLO." + ex.ToString(), "ProtocolloPiTre.aspx");

                //Response.StatusCode = 500;
                //Response.StatusDescription = ex.Message;
                try 
                { 
                    Tools.WriteToEventLog("ProtocolloPiTre - " + strCause + " - " + ex.ToString() + " -- ID da protocollare:" + tab_id);
                }
                catch (Exception)
                {
                }


                Response.Write("0#" + strCause + " - " + ex.ToString());
                return;
            }
            finally
            {
                // chiude la connessione al db
                try
                {
                    if (sqlConn != null)
                        sqlConn.Close();
                }
                catch (Exception)
                {
                }

                //////////////////////////////////////////////////////////////////
                // cancellare tutti i file della collezione fileLIST
                foreach (var item in fileLIST)
                {
                    try
                    {
                        if (Simulazione == false)
                            File.Delete(item.Key);
                    }
                    catch (Exception)
                    {
                    }
                }
                // fine cancellazione tutti i file della collezione fileLIST
                //////////////////////////////////////////////////////////////////
                Response.End();

            }

            //Response.End();
            //return;

        }

        private Dictionary<string, InfoRec >  GetDestinatari(string idDocumento, InfoRec recInfo)
        {
            Dictionary<string, InfoRec> ListInfoRec = new Dictionary<string, InfoRec>();
            string KeyList = "";
            InfoRec recInfo2;

            try
            {
                // caso già acclarato di nessun destinatario torna la lista vuota
                if (recInfo.IdAziOE==0)
                    return ListInfoRec;

                string strSql = "select IdAzi,aziRagioneSociale,codicefiscale,aziPartitaIVA from CTL_DOC_Destinatari with (nolock) where Idheader = " + idDocumento + " and idazi<>" + recInfo.IdAziOE.ToString();
                SqlCommand cmd1;
                SqlDataReader rs;

                cmd1 = new SqlCommand(strSql, sqlConn);
                using (rs = cmd1.ExecuteReader())
                {

                    if (rs.Read())
                    {
                        do
                        {
                            recInfo2=new InfoRec();
                            recInfo2.IdAziOE = rs.GetInt32(rs.GetOrdinal("IdAzi"));  
                            recInfo2.PivaOE = rs.GetString(rs.GetOrdinal("aziPartitaIVA"));
                            recInfo2.CFOE = rs.GetString(rs.GetOrdinal("codicefiscale"));
                            recInfo2.RagSocOE  = rs.GetString(rs.GetOrdinal("aziRagioneSociale"));

                            KeyList = "K" + (ListInfoRec.Count + 1).ToString();
                            ListInfoRec.Add(KeyList, recInfo2);

                        } while (rs.Read()) ;
                    
                    }


                }

                return ListInfoRec;
            }
            catch (Exception ex)
            {
                throw new Exception("GetDestinatari - " + ex.Message, ex);
            }                                    

            
        }
        private void GetDatiBando(string idDocumento, out string tipobandogara, out string ProceduraGara)
        {
            tipobandogara = "";
            ProceduraGara = "";
            string strSql = "";

            try
            {
                strSql = "select  ProceduraGara ,tipobandogara, * from Document_Bando with (nolock)  where idHeader  = " + idDocumento;

                SqlCommand cmd1;                
                SqlDataReader rs;                

                cmd1 = new SqlCommand(strSql, sqlConn);
                using (rs = cmd1.ExecuteReader())
                {

                    if (rs.Read())
                    {
                        ProceduraGara = rs.GetString(rs.GetOrdinal("ProceduraGara"));
                        tipobandogara = rs.GetString(rs.GetOrdinal("tipobandogara"));
                    }


                }               

                
            }
            catch (Exception ex)
            {
                throw new Exception("GetDatiBando - " +  ex.Message, ex);
            }


        }
        private bool ControlloFascicolo(string fascicolo, out string Errore)
        {

            string strCause = "";
            string token = "";
            string IdTitolario = "";
            string ErrorCode = "";
            string ErroreGestito = "";


            try
            {
                Errore = "";
                
                

                strCause = "GetToken";
                token = GetToken();

                strCause = "GetActiveClassificationScheme - recupera i dati del titolario";
                IdTitolario = GetActiveClassificationScheme(token, out ErrorCode, out ErroreGestito);
                // gestione del token scaduto
                if (ErrorCode == "1" && ErroreGestito == "")
                {
                    token = GetToken();
                    IdTitolario = GetActiveClassificationScheme(token, out ErrorCode, out ErroreGestito);
                }

                if (ErroreGestito != "")
                {
                    Errore = ErroreGestito;
                    return false;
                }

                strCause = "GetProject - recupera i dati del fascicolo";
                string PhysicsCollocation = "";
                string IdFascicolo = GetProject(token, fascicolo, IdTitolario, out ErrorCode, out PhysicsCollocation, out ErroreGestito);
                // gestione del token scaduto
                if (ErrorCode == "1" && ErroreGestito == "")
                {
                    token = GetToken();
                    IdFascicolo = GetProject(token, fascicolo, IdTitolario, out ErrorCode, out PhysicsCollocation, out ErroreGestito);
                }

                if (ErroreGestito != "")
                {
                    Errore = ErroreGestito;
                    return false;
                }


                return true;
            }
            catch (Exception ex)
            {
                //TODO: è sempre corretto tornare stringa vuota in caso di eccezione ?
                throw new Exception("ControlloFascicolo - " + strCause + " - "  + ex.Message, ex);
            }

        }

        private bool Protocollazione(string tab_id,string idDocumento, string ingressoUscita, string fascicolo, InfoRec recInfo, Dictionary<string, string> fileLIST, Dictionary<string, InfoRec> ListInfoRecDest,out string Protocollo, out string ErroreGestito)
        {
            string strCause = "";
            string strSql = "";
            bool bFound = false;
            string token = "";
            string IdTitolario = "";
            string ErrorCode = "";
            string PhysicsCollocation = "";
            string IdFascicolo = "";
            string IdPhysicsCollocation = "";
            string CodePhysicsCollocation = "";
            string IdDocument = "";
            int NumAttachLoaded = 0;
            string strAddDocInProject = "";
            int LastStepOK = 0;

            ErroreGestito = "";

            try
            {
                Protocollo = "";

                /// recupera i dati per vedere se per questo documento è già iniziata una protocollazione ed è andata in errore
                //step2
                IdTitolario = getVProtgenDato(tab_id, "TND_IdTitolario");
                if (IdTitolario != "")
                    LastStepOK = 2;
                //step3
                IdFascicolo = getVProtgenDato(tab_id, "TND_IdFascicolo");
                PhysicsCollocation = getVProtgenDato(tab_id, "TND_PhysicsCollocation");
                if (IdFascicolo != "")
                    LastStepOK = 3;
                //step4
                IdPhysicsCollocation = getVProtgenDato(tab_id, "TND_IdPhysicsCollocation");
                CodePhysicsCollocation = getVProtgenDato(tab_id, "TND_CodePhysicsCollocation");
                if (IdPhysicsCollocation != "")
                    LastStepOK = 4;
                //step6
                IdDocument = getVProtgenDato(tab_id, "TND_IdDocument");
                if (IdDocument != "")
                    LastStepOK = 6;
                //step7
                string temp = getVProtgenDato(tab_id, "TND_NumAttachLoaded");

                if (temp != "" && IsNumeric(temp))
                    NumAttachLoaded= Convert.ToInt32(temp);

                if (NumAttachLoaded>0 && NumAttachLoaded == fileLIST.Count )
                    LastStepOK = 7;


                //step8
                strAddDocInProject = getVProtgenDato(tab_id, "TND_AddDocInProject");
                if (strAddDocInProject == "OK")
                    LastStepOK = 8;



                ////////////////////////////////////////////////////////////////////////////
                // STEP 1 - GetToken
                ////////////////////////////////////////////////////////////////////////////
                strCause = "GetToken";
                token = GetToken();
                //token = "SSO=KJB5vXP37YYK1D2HIoRsEpdXI2rEWk5pJAZ/eZCoyZYUofza8LOdgTmwzbpUVgOyHMOjsJ08VG+/XWBY9Y2p1ChvJHbToPcbSZYqzrF5YcMVCInVCPOqBR/2S7Vu7ZGSEvCzrQAVzMW9qE+IqrQ+4w==";
                ////////////////////////////////////////////////////////////////////////////


                ////////////////////////////////////////////////////////////////////////////
                // STEP 2 - GetActiveClassificationScheme
                ////////////////////////////////////////////////////////////////////////////
                if (LastStepOK<2)
                { 
                    strCause = "GetActiveClassificationScheme - recupera i dati del titolario";
                    IdTitolario =GetActiveClassificationScheme(token,out ErrorCode,out ErroreGestito);
                    // gestione del token scaduto
                    if (ErrorCode=="1" && ErroreGestito=="")
                    {
                        token = GetToken();
                        IdTitolario = GetActiveClassificationScheme(token, out ErrorCode, out ErroreGestito);
                    }

                    if (ErroreGestito != "")
                        return false;

                     setVProtgenDato(tab_id, "TND_IdTitolario", IdTitolario);
                }
                ////////////////////////////////////////////////////////////////////////////



                ////////////////////////////////////////////////////////////////////////////
                // STEP 3 - GetProject - recupera i dati del fascicolo
                ////////////////////////////////////////////////////////////////////////////
                ////token = "SSO=KJB5vXP37YYK1D2HIoRsEpdXI2rEWk5pJAZ/eZCoyZYUofza8LOdgTmwzbpUVgOyHMOjsJ08VG+/XWBY9Y2p1ChvJHbToPcbSZYqzrF5YcMVCInVCPOqBR/2S7Vu7ZGSEvCzrQAVzMW9qE+IqrQ+4w==";
                if (LastStepOK < 3)
                {
                    strCause = "GetProject - recupera i dati del fascicolo";

                    IdFascicolo = GetProject(token, fascicolo, IdTitolario, out ErrorCode, out PhysicsCollocation, out ErroreGestito);
                    // gestione del token scaduto
                    if (ErrorCode == "1" && ErroreGestito == "")
                    {
                        token = GetToken();
                        IdFascicolo = GetProject(token, fascicolo, IdTitolario, out ErrorCode, out PhysicsCollocation, out ErroreGestito);
                    }

                    if (ErroreGestito != "")
                        return false;

                    setVProtgenDato(tab_id, "TND_IdFascicolo", IdFascicolo);
                    setVProtgenDato(tab_id, "TND_PhysicsCollocation", PhysicsCollocation);
                }
                ////////////////////////////////////////////////////////////////////////////



                ////////////////////////////////////////////////////////////////////////////
                // STEP 4 - SearchCorrespondents - ricerca la struttura interna associata al fascicolo
                ////////////////////////////////////////////////////////////////////////////
                if (LastStepOK < 4)
                {
                    strCause = "SearchCorrespondents - recupera i dati della stuttura interna " + PhysicsCollocation;


                    IdPhysicsCollocation = SearchCorrespondents(token, PhysicsCollocation, out ErrorCode, out CodePhysicsCollocation, out ErroreGestito);
                    // gestione del token scaduto
                    if (ErrorCode == "1" && ErroreGestito == "")
                    {
                        token = GetToken();
                        IdPhysicsCollocation = SearchCorrespondents(token, PhysicsCollocation, out ErrorCode, out CodePhysicsCollocation, out ErroreGestito);
                    }

                    if (ErroreGestito != "")
                        return false;

                    setVProtgenDato(tab_id, "TND_IdPhysicsCollocation", IdPhysicsCollocation);
                    setVProtgenDato(tab_id, "TND_CodePhysicsCollocation", CodePhysicsCollocation);
                }
                ////////////////////////////////////////////////////////////////////////////


                ////////////////////////////////////////////////////////////////////////////
                // STEP 5 - GetRegisterOrRF - controlla il CodePhysicsCollocation (vi antepone RF)
                ////////////////////////////////////////////////////////////////////////////
                if (LastStepOK < 5)
                {
                    string IdRegisterRF = "";
                    strCause = "GetRegisterOrRF - " + "RF" + CodePhysicsCollocation;

                    IdRegisterRF = GetRegisterOrRF(token, "RF" + CodePhysicsCollocation, out ErrorCode, out ErroreGestito);
                    // gestione del token scaduto
                    if (ErrorCode == "1" && ErroreGestito == "")
                    {
                        token = GetToken();
                        IdRegisterRF = GetRegisterOrRF(token, "RF" + CodePhysicsCollocation, out ErrorCode, out ErroreGestito);
                    }

                    if (ErroreGestito != "")
                        return false;
                }
                ////////////////////////////////////////////////////////////////////////////



                ////////////////////////////////////////////////////////////////////////////
                // STEP 6 - CreateDocument
                ////////////////////////////////////////////////////////////////////////////
                if (LastStepOK < 6)
                {
                    strCause = "CreateDocument";

                    IdDocument = CreateDocument(token, "RF" + CodePhysicsCollocation, ingressoUscita, recInfo, IdPhysicsCollocation, PhysicsCollocation, ListInfoRecDest, out ErrorCode, out ErroreGestito);
                    // gestione del token scaduto
                    if (ErrorCode == "1" && ErroreGestito == "")
                    {
                        token = GetToken();
                        IdDocument = CreateDocument(token, "RF" + CodePhysicsCollocation, ingressoUscita, recInfo, IdPhysicsCollocation, PhysicsCollocation, ListInfoRecDest,out ErrorCode, out ErroreGestito);
                    }

                    if (ErroreGestito != "")
                        return false;

                    setVProtgenDato(tab_id, "TND_IdDocument", IdDocument);
                }
                ////////////////////////////////////////////////////////////////////////////


                ////////////////////////////////////////////////////////////////////////////
                // STEP 7 - Upload allegati
                ////////////////////////////////////////////////////////////////////////////
                bool esitoUpd;

                if (LastStepOK < 7)
                {
                    strCause = "UploadFileToDocument " + IdDocument;

                    bool bIsMain = true;
                    int conta = NumAttachLoaded;
                    int index = 0;

                    if (NumAttachLoaded > 0)
                        bIsMain = false;

                    foreach (string key in fileLIST.Keys.ToList())
                    {
                        index = index + 1;

                        if (index>NumAttachLoaded)
                        { 
                            strCause = "Upload del file " + key;
                            //esito = CaricaFile(PIVA_Ente, key, out strIdFile);
                            esitoUpd = UploadFileToDocument(token, bIsMain, IdDocument, key, fileLIST[key], out ErrorCode, out ErroreGestito);
                            if (ErrorCode == "1" && ErroreGestito == "")
                            {
                                token = GetToken();
                                esitoUpd = UploadFileToDocument(token, bIsMain, IdDocument, key, fileLIST[key], out ErrorCode, out ErroreGestito);
                            }

                            if (bIsMain)
                                bIsMain = false;

                            if (ErroreGestito != "")
                                return false;

                            conta = conta + 1;
                            setVProtgenDato(tab_id, "TND_NumAttachLoaded", conta.ToString());
                            setVProtgenDato(tab_id, "TND_Attach_" + index.ToString(), key + " - " + fileLIST[key]);
                        }


                    }

                }

                ////////////////////////////////////////////////////////////////////////////

                ////////////////////////////////////////////////////////////////////////////
                // STEP 8 - AddDocInProject
                ////////////////////////////////////////////////////////////////////////////

                if (LastStepOK < 8)
                {
                    strCause = "AddDocInProject - Inserimento del documento " + IdDocument + " nel fascicolo " + IdFascicolo;

                    esitoUpd = AddDocInProject(token, IdDocument, IdFascicolo, out ErrorCode, out ErroreGestito);
                    // gestione del token scaduto
                    if (ErrorCode == "1" && ErroreGestito == "")
                    {
                        token = GetToken();
                        esitoUpd = AddDocInProject(token, IdDocument, IdFascicolo, out ErrorCode, out ErroreGestito);
                    }

                    if (ErroreGestito != "")
                        return false;

                    setVProtgenDato(tab_id, "TND_AddDocInProject", "OK");
                }
                ////////////////////////////////////////////////////////////////////////////


                ////////////////////////////////////////////////////////////////////////////
                // STEP 9 - ProtocolPredisposed
                ////////////////////////////////////////////////////////////////////////////
                strCause = "ProtocolPredisposed - Protocollazione del documento " + IdDocument ;
                string ProtOut = "";

                ProtOut = ProtocolPredisposed(token, IdDocument, "RF" + CodePhysicsCollocation, out ErrorCode, out ErroreGestito);
                // gestione del token scaduto
                if (ErrorCode == "1" && ErroreGestito == "")
                {
                    token = GetToken();
                    ProtOut = ProtocolPredisposed(token, IdDocument, "RF" + CodePhysicsCollocation, out ErrorCode, out ErroreGestito);
                }

                if (ErroreGestito != "")
                    return false;
                ////////////////////////////////////////////////////////////////////////////

                Protocollo = ProtOut;
                return true;

                
                
            }
            catch (Exception ex)
            {
                //TODO: è sempre corretto tornare stringa vuota in caso di eccezione ?
                throw new Exception("Protocollazione - " + strCause + " - " + ex.Message, ex);
            }
        }

        
        private string ProtocolPredisposed(string token, string IdDocument, string CodePhysicsCollocation, out string ErrorCode, out string ErroreGestito)
        {

            string strCause = "";

            IRestResponse response;
            HttpStatusCode statusCode = HttpStatusCode.Unused;

            string statusDescription;
            string jsonOutput = "";
            string strOperation = "";
            string strJSON = "";

            ErrorCode = "";
            ErroreGestito = "";

            string ProtOut = "";


            try
            {
                ServicePointManager.ServerCertificateValidationCallback += RemoteCertificateValidate;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | Tls12;

                ServicePointManager.Expect100Continue = true;
                ServicePointManager.DefaultConnectionLimit = 9999;
                ServicePointManager.SetTcpKeepAlive(true, 10000, 1000);

                strCause = "Carica il certificato per l'accesso al servizio";
                try
                {
                    cert = new X509Certificate2(strPathCertificate, strPwdCertificate, X509KeyStorageFlags.MachineKeySet);
                }
                catch (Exception ex2)
                {
                    throw new Exception(ex2.Message + " errore caricamento del certificato");
                }

                strCause = "Chiamata al web service GetActiveClassificationScheme " + endPointTND;
                var client = new RestClient(endPointTND);



                client.ClientCertificates = new X509CertificateCollection() { cert };

                RestRequest request;

                request = new RestRequest(Method.POST);

                request.AddHeader("CODE_ADM", CODE_ADM);
                request.AddHeader("ROUTED_ACTION", "ProtocolPredisposed");
                request.AddHeader("Content-Type", "application/json");
                request.AddHeader("AuthToken", token);

                strJSON = @"{
                              ""CodeRegister"": ""<<CodeRegister>>"",
                              ""CodeRF"": ""<<CodeRF>>"",
                              ""IdDocument"": ""<<IdDocument>>""
                            }";


                strJSON = strJSON.Replace("<<CodeRegister>>", CODE_ADM_CREATE);
                strJSON = strJSON.Replace("<<CodeRF>>", CodePhysicsCollocation);
                strJSON = strJSON.Replace("<<IdDocument>>", IdDocument);

                JToken jsonOK = JToken.Parse(strJSON);
                // Serializzazione del token formattato come JSON valido
                strJSON = jsonOK.ToString(Formatting.Indented);
                request.AddParameter("application/json", strJSON, ParameterType.RequestBody);

                recCreateDocument rec;

                response = client.Execute(request);
                jsonOutput = response.Content; // Contenuto raw come string

                statusCode = response.StatusCode;
                statusDescription = response.StatusDescription;

                if (statusDescription == null)
                    statusDescription = "";

                if (statusCode == System.Net.HttpStatusCode.NoContent)
                {
                    //esito = "Nessuna risposta dal web service";
                    throw new Exception("Errore nell'invocazione del web service : Nessuna risposta dal web service" + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }
                else if (statusCode == System.Net.HttpStatusCode.OK)
                {


                    jsonOutput = jsonOutput.Trim();

                    rec = JsonConvert.DeserializeObject<recCreateDocument>(jsonOutput);

                    if (rec.Code != "0" && !(rec.Code == "1" && rec.ErrorMessage.StartsWith("Il token ha superato")))
                    //throw new Exception("Errore nell'invocazione del web service GetProject - error = " + (rec.ErrorMessage == null ? "" : rec.ErrorMessage));
                    {
                        ErroreGestito = "Errore - ProtocolPredisposed " + (rec.ErrorMessage == null ? "" : " - " + rec.ErrorMessage);
                        return "";
                    }


                    if (rec.Code == "1" && rec.ErrorMessage.StartsWith("Il token ha superato"))
                        ErrorCode = "1";
                    else if (rec.Code != "0")
                        ErrorCode = "2";
                    else
                    {
                        try
                        {
                            ProtOut = rec.Document.Signature;
                        }
                        catch { };
                        if (string.IsNullOrEmpty(ProtOut))
                            ProtOut = "";

                    }

                }
                else
                {
                    throw new Exception("Errore nell'invocazione del web service : " + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }

                //if (IdFascicolo == "" &&  ErrorCode != "1" && ErrorCode != "0" && ErrorCode != "")
                //    throw new Exception("Errore GetProject " + (rec.ErrorMessage == null ? "" : " - " + rec.ErrorMessage));

                return ProtOut;
            }
            catch (Exception ex)
            {
                //TODO: è sempre corretto tornare stringa vuota in caso di eccezione ?
                throw new Exception(strCause + "-" + ex.Message, ex);
            }
        }

        private bool AddDocInProject(string token,  string IdDocument, string IdFascicolo,  out string ErrorCode, out string ErroreGestito)
        {

            string strCause = "";

            IRestResponse response;
            HttpStatusCode statusCode = HttpStatusCode.Unused;

            string statusDescription;
            string jsonOutput = "";
            string strOperation = "";
            string strJSON = "";

            ErrorCode = "";
            ErroreGestito = "";


            try
            {
                ServicePointManager.ServerCertificateValidationCallback += RemoteCertificateValidate;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | Tls12;

                ServicePointManager.Expect100Continue = true;
                ServicePointManager.DefaultConnectionLimit = 9999;
                ServicePointManager.SetTcpKeepAlive(true, 10000, 1000);

                strCause = "Carica il certificato per l'accesso al servizio";
                try
                {
                    cert = new X509Certificate2(strPathCertificate, strPwdCertificate, X509KeyStorageFlags.MachineKeySet);
                }
                catch (Exception ex2)
                {
                    throw new Exception(ex2.Message + " errore caricamento del certificato");
                }

                strCause = "Chiamata al web service GetActiveClassificationScheme " + endPointTND;
                var client = new RestClient(endPointTND);



                client.ClientCertificates = new X509CertificateCollection() { cert };

                RestRequest request;

                request = new RestRequest(Method.POST);

                request.AddHeader("CODE_ADM", CODE_ADM);
                request.AddHeader("ROUTED_ACTION", "AddDocInProject");
                request.AddHeader("Content-Type", "application/json");
                request.AddHeader("AuthToken", token);

                strJSON = @"{
                              ""IdDocument"": ""<<IdDocument>>"",
                              ""IdProject"": ""<<IdProject>>""
                            }";


                strJSON = strJSON.Replace("<<IdDocument>>", IdDocument);                
                strJSON = strJSON.Replace("<<IdProject>>", IdFascicolo);                

                JToken jsonOK = JToken.Parse(strJSON);
                // Serializzazione del token formattato come JSON valido
                strJSON = jsonOK.ToString(Formatting.Indented);
                request.AddParameter("application/json", strJSON, ParameterType.RequestBody);

                recUpload rec;

                response = client.Execute(request);
                jsonOutput = response.Content; // Contenuto raw come string

                statusCode = response.StatusCode;
                statusDescription = response.StatusDescription;

                if (statusDescription == null)
                    statusDescription = "";

                if (statusCode == System.Net.HttpStatusCode.NoContent)
                {
                    //esito = "Nessuna risposta dal web service";
                    throw new Exception("Errore nell'invocazione del web service : Nessuna risposta dal web service" + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }
                else if (statusCode == System.Net.HttpStatusCode.OK)
                {


                    jsonOutput = jsonOutput.Trim();

                    rec = JsonConvert.DeserializeObject<recUpload>(jsonOutput);

                    if (rec.Code != "0" && !(rec.Code == "1" && rec.ErrorMessage.StartsWith("Il token ha superato")))
                    //throw new Exception("Errore nell'invocazione del web service GetProject - error = " + (rec.ErrorMessage == null ? "" : rec.ErrorMessage));
                    {
                        ErroreGestito = "Errore - AddDocInProject " + (rec.ErrorMessage == null ? "" : " - " + rec.ErrorMessage);
                        return false;
                    }


                    if (rec.Code == "1" && rec.ErrorMessage.StartsWith("Il token ha superato"))
                        ErrorCode = "1";
                    else if (rec.Code != "0")
                        ErrorCode = "2";
                    //else
                    //{
                    //    try
                    //    {
                    //        IdDocument = rec.Document.Id;
                    //    }
                    //    catch { };
                    //    if (string.IsNullOrEmpty(IdDocument))
                    //        IdDocument = "";

                    //}

                }
                else
                {
                    throw new Exception("Errore nell'invocazione del web service : " + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }

                //if (IdFascicolo == "" &&  ErrorCode != "1" && ErrorCode != "0" && ErrorCode != "")
                //    throw new Exception("Errore GetProject " + (rec.ErrorMessage == null ? "" : " - " + rec.ErrorMessage));

                return true;
            }
            catch (Exception ex)
            {
                //TODO: è sempre corretto tornare stringa vuota in caso di eccezione ?
                throw new Exception(strCause + "-" + ex.Message, ex);
            }
        }

        private bool UploadFileToDocument(string token, bool bIsMain, string IdDocument, string fileName, string Descr, out string ErrorCode, out string ErroreGestito)
        {
            
            string strCause = "";

            IRestResponse response;
            HttpStatusCode statusCode = HttpStatusCode.Unused;

            string statusDescription;
            string jsonOutput = "";
            string strOperation = "";
            string strJSON = "";

            ErrorCode = "";
            ErroreGestito = "";


            try
            {
                ServicePointManager.ServerCertificateValidationCallback += RemoteCertificateValidate;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | Tls12;

                ServicePointManager.Expect100Continue = true;
                ServicePointManager.DefaultConnectionLimit = 9999;
                ServicePointManager.SetTcpKeepAlive(true, 10000, 1000);

                strCause = "Carica il certificato per l'accesso al servizio";
                try
                {
                    cert = new X509Certificate2(strPathCertificate, strPwdCertificate, X509KeyStorageFlags.MachineKeySet);
                }
                catch (Exception ex2)
                {
                    throw new Exception(ex2.Message + " errore caricamento del certificato");
                }

                strCause = "Chiamata al web service GetActiveClassificationScheme " + endPointTND;
                var client = new RestClient(endPointTND);



                client.ClientCertificates = new X509CertificateCollection() { cert };

                RestRequest request;

                request = new RestRequest(Method.PUT);

                request.AddHeader("CODE_ADM", CODE_ADM);
                request.AddHeader("ROUTED_ACTION", "UploadFileToDocument");
                request.AddHeader("Content-Type", "application/json");
                request.AddHeader("AuthToken", token);

                strJSON = @"{
                          ""IdDocument"": ""<<IdDocument>>"",
                          ""File"": {
                            ""Description"": ""<<Description>>"",
                            ""Content"": ""<<Content>>"",   // bytestream in base64
                            ""Name"": ""<<Name>>""
                          },
                          ""CreateAttachment"": <<CreateAttachment>>,   // false se è il documento firmato (bando firmato), true se sono gli allegati
                          ""Description"": ""<<Description2>>""
                        }";


                strJSON = strJSON.Replace("<<IdDocument>>", IdDocument);
                strJSON = strJSON.Replace("<<Description>>", bIsMain ? "Documento principale" :   Descr );
                strJSON = strJSON.Replace("<<Description2>>", bIsMain ? "Documento principale" :   Descr);
                strJSON = strJSON.Replace("<<CreateAttachment>>", bIsMain ? "false" : "true");
                strJSON = strJSON.Replace("<<Name>>", Descr);
                

                byte[] bytes = { };
                using (FileStream fs = new FileStream(fileName, FileMode.Open, FileAccess.Read))
                {
                    // Create a byte array of file stream length
                    bytes = File.ReadAllBytes(fileName);
                    //Read block of bytes from stream into the byte array
                    fs.Read(bytes, 0, Convert.ToInt32(fs.Length));
                    //Close the File Stream
                    fs.Close();
                }
                strJSON = strJSON.Replace("<<Content>>", Convert.ToBase64String(bytes));

                JToken jsonOK = JToken.Parse(strJSON);
                // Serializzazione del token formattato come JSON valido
                strJSON = jsonOK.ToString(Formatting.Indented);
                request.AddParameter("application/json", strJSON, ParameterType.RequestBody);

                recUpload rec;

                response = client.Execute(request);
                jsonOutput = response.Content; // Contenuto raw come string

                statusCode = response.StatusCode;
                statusDescription = response.StatusDescription;

                if (statusDescription == null)
                    statusDescription = "";

                if (statusCode == System.Net.HttpStatusCode.NoContent)
                {
                    //esito = "Nessuna risposta dal web service";
                    throw new Exception("Errore nell'invocazione del web service : Nessuna risposta dal web service" + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }
                else if (statusCode == System.Net.HttpStatusCode.OK)
                {


                    jsonOutput = jsonOutput.Trim();

                    rec = JsonConvert.DeserializeObject<recUpload>(jsonOutput);

                    if (rec.Code != "0" && !(rec.Code == "1" && rec.ErrorMessage.StartsWith("Il token ha superato")))
                    //throw new Exception("Errore nell'invocazione del web service GetProject - error = " + (rec.ErrorMessage == null ? "" : rec.ErrorMessage));
                    {
                        ErroreGestito = "Errore - CreateDocument " + (rec.ErrorMessage == null ? "" : " - " + rec.ErrorMessage);
                        return false;
                    }


                    if (rec.Code == "1" && rec.ErrorMessage.StartsWith("Il token ha superato"))
                        ErrorCode = "1";
                    else if (rec.Code != "0")
                        ErrorCode = "2";
                    //else
                    //{
                    //    try
                    //    {
                    //        IdDocument = rec.Document.Id;
                    //    }
                    //    catch { };
                    //    if (string.IsNullOrEmpty(IdDocument))
                    //        IdDocument = "";

                    //}

                }
                else
                {
                    throw new Exception("Errore nell'invocazione del web service : " + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }

                //if (IdFascicolo == "" &&  ErrorCode != "1" && ErrorCode != "0" && ErrorCode != "")
                //    throw new Exception("Errore GetProject " + (rec.ErrorMessage == null ? "" : " - " + rec.ErrorMessage));

                return true;
            }
            catch (Exception ex)
            {
                //TODO: è sempre corretto tornare stringa vuota in caso di eccezione ?
                throw new Exception(strCause + "-" + ex.Message, ex);
            }
        }
        private string CreateDocument(string token, string CodePhysicsCollocation,string ingressoUscita, InfoRec recInfo,string IdPhysicsCollocation,string PhysicsCollocation, Dictionary<string, InfoRec> ListInfoRecDest,out string ErrorCode, out string ErroreGestito)
        {
            string IdDocument = "";
            string strCause = "";

            IRestResponse response;
            HttpStatusCode statusCode = HttpStatusCode.Unused;

            string statusDescription;
            string jsonOutput = "";
            string strOperation = "";
            string strJSON = "";

            ErrorCode = "";
            ErroreGestito = "";


            try
            {
                ServicePointManager.ServerCertificateValidationCallback += RemoteCertificateValidate;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | Tls12;

                ServicePointManager.Expect100Continue = true;
                ServicePointManager.DefaultConnectionLimit = 9999;
                ServicePointManager.SetTcpKeepAlive(true, 10000, 1000);

                strCause = "Carica il certificato per l'accesso al servizio";
                try
                {
                    cert = new X509Certificate2(strPathCertificate, strPwdCertificate, X509KeyStorageFlags.MachineKeySet);
                }
                catch (Exception ex2)
                {
                    throw new Exception(ex2.Message + " errore caricamento del certificato");
                }

                strCause = "Chiamata al web service GetActiveClassificationScheme " + endPointTND;
                var client = new RestClient(endPointTND);



                client.ClientCertificates = new X509CertificateCollection() { cert };

                RestRequest request;

                request = new RestRequest(Method.PUT);

                request.AddHeader("CODE_ADM", CODE_ADM);
                request.AddHeader("ROUTED_ACTION", "CreateDocument");
                request.AddHeader("Content-Type", "application/json");
                request.AddHeader("AuthToken", token);

                strJSON = GetJSON_CreateDocument( CodePhysicsCollocation, ingressoUscita, recInfo, IdPhysicsCollocation, PhysicsCollocation,ListInfoRecDest, token ,out ErrorCode , out ErroreGestito   );

                // gestione del token scaduto
                //if (ErrorCode == "1" && ErroreGestito == "")
                //{
                //    token = GetToken();
                //    IdDocument = CreateDocument(token, "RF" + CodePhysicsCollocation, ingressoUscita, recInfo, IdPhysicsCollocation, PhysicsCollocation, ListInfoRecDest, out ErrorCode, out ErroreGestito);
                //}

                if (ErroreGestito != "")
                    throw new Exception("GetJSON_CreateDocument - " + strCause + "-" + ErroreGestito);



                JToken jsonOK = JToken.Parse(strJSON);
                // Serializzazione del token formattato come JSON valido
                strJSON = jsonOK.ToString(Formatting.Indented);
                request.AddParameter("application/json", strJSON, ParameterType.RequestBody);

                recCreateDocument rec;

                response = client.Execute(request);
                jsonOutput = response.Content; // Contenuto raw come string

                statusCode = response.StatusCode;
                statusDescription = response.StatusDescription;

                if (statusDescription == null)
                    statusDescription = "";

                if (statusCode == System.Net.HttpStatusCode.NoContent)
                {
                    //esito = "Nessuna risposta dal web service";
                    throw new Exception("Errore nell'invocazione del web service : Nessuna risposta dal web service" + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }
                else if (statusCode == System.Net.HttpStatusCode.OK)
                {


                    jsonOutput = jsonOutput.Trim();

                    rec = JsonConvert.DeserializeObject<recCreateDocument>(jsonOutput);

                    if (rec.Code != "0" && !(rec.Code == "1" && rec.ErrorMessage.StartsWith("Il token ha superato")))
                    //throw new Exception("Errore nell'invocazione del web service GetProject - error = " + (rec.ErrorMessage == null ? "" : rec.ErrorMessage));
                    {
                        ErroreGestito = "Errore - CreateDocument "  + (rec.ErrorMessage == null ? "" : " - " + rec.ErrorMessage);
                        return "";
                    }


                    if (rec.Code == "1" && rec.ErrorMessage.StartsWith("Il token ha superato"))
                        ErrorCode = "1";
                    //else if (rec.Code != "0")
                    //    ErrorCode = "2";
                    else
                    {
                        try
                        {
                            IdDocument = rec.Document.Id;
                        }
                        catch { };
                        if (string.IsNullOrEmpty(IdDocument))
                            IdDocument = "";

                    }

                }
                else
                {
                    throw new Exception("Errore nell'invocazione del web service : " + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }

                //if (IdFascicolo == "" &&  ErrorCode != "1" && ErrorCode != "0" && ErrorCode != "")
                //    throw new Exception("Errore GetProject " + (rec.ErrorMessage == null ? "" : " - " + rec.ErrorMessage));

                return IdDocument;
            }
            catch (Exception ex)
            {
                //TODO: è sempre corretto tornare stringa vuota in caso di eccezione ?
                throw new Exception(strCause + "-" + ex.Message, ex);
            }
        }

        private string GetJSON_CreateDocument(string CodePhysicsCollocation, string ingressoUscita, InfoRec recInfo, string IdPhysicsCollocation, string PhysicsCollocation, Dictionary<string, InfoRec> ListInfoRecDest,string token, out string ErrorCode, out string ErroreGestito)
        {
            
            string strJSON = "";
            string strReceiver = "";
            string strCause = "";
            ErrorCode = "";
            ErroreGestito = "";

            try
            {
                
                // caso del protocollo in ingresso
                if (ingressoUscita=="I")
                {
                    strJSON = @"{
                                ""CodeRegister"": ""<<CodeRegister>>"",
                                ""CodeRF"": ""<<CodeRF>>"",
                                ""Document"": {
                                    ""DocumentType"": ""<<DocumentType>>"", // protocollo in ingresso
                                    ""Object"": ""<<Object>>"",
                                    ""MeansOfSending"": ""SERVIZI ONLINE"",
                                    ""Predisposed"": true,
                                    ""ArrivalDate"": ""<<ArrivalDate>>"",
                                    ""Recipients"": [
                                        {
                                            ""Code"": ""<<SENDER_CODE>>"",
                                            ""CodeRegisterOrRF"": null,
                                            ""CorrespondentType"": ""U"",
                                            ""Description"": ""<<SENDER_DESCRIPTION>>"",            
                                            ""Id"": ""<<SENDER_ID>>"", 
                                            ""IsCommonAddress"": false,            
                                            ""Name"": """",            
                                            ""Surname"": """",
                                            ""Type"": ""I"",
                                            ""VatNumber"": null
                                        }
                                    ],
                                    ""Sender"": { 

                                        ""Description"": ""<<RECIPIENT_DESCR>>"",
				                        ""NationalIdentificationNumber"":""<<RECIPIENT_ID>>"",
				                        ""Type"": ""O"",
				                        ""CorrespondentType"": ""O"",
				                        ""Name"": """",
				                        ""Surname"": """"
                                    }
                                }
                            }";


                    strJSON = strJSON.Replace("<<CodeRegister>>", CODE_ADM_CREATE);
                    strJSON = strJSON.Replace("<<CodeRF>>", CodePhysicsCollocation);
                    //strJSON = strJSON.Replace("<<DocumentType>>", ingressoUscita == "I" ? "A" : "P");
                    strJSON = strJSON.Replace("<<Object>>", recInfo.titolo);

                    if (recInfo.CodeSender == "") 
                    {                         
                        strJSON = strJSON.Replace("<<SENDER_CODE>>", CodePhysicsCollocation.Substring(0, 2) == "RF" ? CodePhysicsCollocation.Substring(2) : CodePhysicsCollocation);
                        strJSON = strJSON.Replace("<<SENDER_DESCRIPTION>>", PhysicsCollocation);
                        strJSON = strJSON.Replace("<<SENDER_ID>>", IdPhysicsCollocation);
                    }
                    else 
                    { 
                        strJSON = strJSON.Replace("<<SENDER_CODE>>", recInfo.CodeSender);
                        strJSON = strJSON.Replace("<<SENDER_DESCRIPTION>>", recInfo.RagSocEnte );

                        // deve recuperare Id del code sender per "Servizio Appalti"
                        strCause = "SearchCorrespondents - recupera i dati della stuttura interna " + recInfo.CodeSender;
                        string IdPhysicsCollocation2 = "";

                        //vede se salvato in cache
                        IdPhysicsCollocation2 =getVProtgenDato(tab_id, "TND_IdPhysicsCollocation_" + recInfo.CodeSender);

                        if (IdPhysicsCollocation2=="")                        { 

                            IdPhysicsCollocation2 = SearchCorrespondents(token, recInfo.CodeSender, out ErrorCode, out CodePhysicsCollocation, out ErroreGestito, true);
                            // gestione del token scaduto
                            if (ErrorCode == "1" && ErroreGestito == "")
                            {
                                token = GetToken();
                                IdPhysicsCollocation2 = SearchCorrespondents(token, recInfo.CodeSender, out ErrorCode, out CodePhysicsCollocation, out ErroreGestito);
                            }

                            if (ErroreGestito != "")
                                return "";

                            setVProtgenDato(tab_id, "TND_IdPhysicsCollocation_" + recInfo.CodeSender, IdPhysicsCollocation2);
                                //setVProtgenDato(tab_id, "TND_CodePhysicsCollocation", CodePhysicsCollocation);

                        }

                        strJSON = strJSON.Replace("<<SENDER_ID>>", IdPhysicsCollocation2);
                    }

                    

                    if (recInfo.IdAziOE==0)
                    {
                        strJSON = strJSON.Replace("<<RECIPIENT_DESCR>>", recInfo.RagSocOE );
                        if (recInfo.TipoProtocollo != "")
                            // caso della procedura aperta senza destinatari
                            strJSON = strJSON.Replace("<<DocumentType>>", recInfo.TipoProtocollo);
                        else
                            strJSON = strJSON.Replace("<<DocumentType>>", ingressoUscita == "I" ? "A" : "P");
                    }
                    else
                    {
                        strJSON = strJSON.Replace("<<RECIPIENT_DESCR>>", recInfo.RagSocOE + " - " + recInfo.CFOE);
                        strJSON = strJSON.Replace("<<DocumentType>>", ingressoUscita == "I" ? "A" : "P");
                    }

                    strJSON = strJSON.Replace("<<RECIPIENT_ID>>", recInfo.CFOE);
                    strJSON = strJSON.Replace("<<ArrivalDate>>", doc.Data);

                }
                else // caso del protocollo in uscita -- SOLO IN QUESTO CASO SI DEVE GESTIRE IL POSSIBILE MULTI-DESTINATARIO !!!!!!
                {
                    // occhio che il blocco inizia già con la ,
                    strReceiver = @",{
                                ""Description"": ""<<RECIPIENT_DESCR>>"",
				                ""NationalIdentificationNumber"":""<<RECIPIENT_ID>>"",
				                ""Type"": ""O"",
				                ""CorrespondentType"": ""O"",
				                ""Name"": """",
				                ""Surname"": """"
                                 }";

                    strJSON = @"{
                                ""CodeRegister"": ""<<CodeRegister>>"",
                                ""CodeRF"": ""<<CodeRF>>"",
                                ""Document"": {
                                    ""DocumentType"": ""<<DocumentType>>"", // protocollo in uscita
                                    ""Object"": ""<<Object>>"",                                    
                                    ""Predisposed"": true,                                    
                                    ""Recipients"": [
                                        {
                                            ""Description"": ""<<RECIPIENT_DESCR>>"",
				                            ""NationalIdentificationNumber"":""<<RECIPIENT_ID>>"",
				                            ""Type"": ""O"",
				                            ""CorrespondentType"": ""O"",
				                            ""Name"": """",
				                            ""Surname"": """"
                                        }
                                        <<LISTA_RECEIVERS>>
                                    ],
                                    ""Sender"": {            
                                        ""Code"": ""<<SENDER_CODE>>"",
                                        ""CodeRegisterOrRF"": null,
                                        ""CorrespondentType"": ""U"",
                                        ""Description"": ""<<SENDER_DESCRIPTION>>"",            
                                        ""Id"": ""<<SENDER_ID>>"", 
                                        ""IsCommonAddress"": false,            
                                        ""Name"": """",            
                                        ""Surname"": """",
                                        ""Type"": ""I"",
                                        ""VatNumber"": null
                                    }
                                }
                            }";


                    strJSON = strJSON.Replace("<<CodeRegister>>", CODE_ADM_CREATE);
                    strJSON = strJSON.Replace("<<CodeRF>>", CodePhysicsCollocation);
                    
                    strJSON = strJSON.Replace("<<Object>>", recInfo.titolo);

                    if (recInfo.CodeSender == "")
                    { 
                        strJSON = strJSON.Replace("<<SENDER_CODE>>", CodePhysicsCollocation.Substring(0, 2) == "RF" ? CodePhysicsCollocation.Substring(2) : CodePhysicsCollocation);
                        strJSON = strJSON.Replace("<<SENDER_DESCRIPTION>>", PhysicsCollocation);
                        strJSON = strJSON.Replace("<<SENDER_ID>>", IdPhysicsCollocation);
                    }
                    else
                    {
                        strJSON = strJSON.Replace("<<SENDER_CODE>>", recInfo.CodeSender);
                        strJSON = strJSON.Replace("<<SENDER_DESCRIPTION>>", recInfo.RagSocEnte );

                        // deve recuperare Id del code sender per "Servizio Appalti"
                        strCause = "SearchCorrespondents - recupera i dati della stuttura interna " + recInfo.CodeSender;
                        string IdPhysicsCollocation2 = "";

                        //vede se salvato in cache
                        IdPhysicsCollocation2 = getVProtgenDato(tab_id, "TND_IdPhysicsCollocation_" + recInfo.CodeSender);

                        if (IdPhysicsCollocation2 == "")
                        {

                            IdPhysicsCollocation2 = SearchCorrespondents(token, recInfo.CodeSender, out ErrorCode, out CodePhysicsCollocation, out ErroreGestito, true);
                            // gestione del token scaduto
                            if (ErrorCode == "1" && ErroreGestito == "")
                            {
                                token = GetToken();
                                IdPhysicsCollocation2 = SearchCorrespondents(token, recInfo.CodeSender, out ErrorCode, out CodePhysicsCollocation, out ErroreGestito);
                            }

                            if (ErroreGestito != "")
                                return "";

                            setVProtgenDato(tab_id, "TND_IdPhysicsCollocation_" + recInfo.CodeSender, IdPhysicsCollocation2);
                            //setVProtgenDato(tab_id, "TND_CodePhysicsCollocation", CodePhysicsCollocation);

                        }

                        strJSON = strJSON.Replace("<<SENDER_ID>>", IdPhysicsCollocation2);
                    }

                    if (recInfo.IdAziOE == 0)
                    {
                        // caso della gara aperta -- passare "DocumentType": "I" (protocollo interno)
                        strJSON = strJSON.Replace("<<RECIPIENT_DESCR>>", recInfo.RagSocOE );
                        if (recInfo.TipoProtocollo != "")
                            // caso della procedura aperta senza destinatari
                            strJSON = strJSON.Replace("<<DocumentType>>", recInfo.TipoProtocollo);
                        else
                            strJSON = strJSON.Replace("<<DocumentType>>", ingressoUscita == "I" ? "A" : "P");
                    }
                    else
                    {
                        strJSON = strJSON.Replace("<<RECIPIENT_DESCR>>", recInfo.RagSocOE + " - " + recInfo.CFOE);
                        strJSON = strJSON.Replace("<<DocumentType>>", ingressoUscita == "I" ? "A" : "P");
                    }

                    strJSON = strJSON.Replace("<<RECIPIENT_ID>>", recInfo.CFOE);

                    // DESTINATARI MULTIPLI
                    if (ListInfoRecDest.Count > 0)
                    {
                        string tmp = "";
                        string dest = "";

                        foreach (string key in ListInfoRecDest.Keys.ToList())
                        {
                            tmp = strReceiver;
                            InfoRec recInfo2 = ListInfoRecDest[key];

                            tmp = tmp.Replace("<<RECIPIENT_DESCR>>", recInfo2.RagSocOE + " - " + recInfo2.CFOE);
                            tmp = tmp.Replace("<<RECIPIENT_ID>>", recInfo2.CFOE);

                            dest = dest + tmp;

                        }
                        strJSON = strJSON.Replace("<<LISTA_RECEIVERS>>", dest);
                    }
                    else
                    {
                        strJSON = strJSON.Replace("<<LISTA_RECEIVERS>>", "");
                    }

                }

                

                return strJSON;
            }
            catch (Exception ex)
            {
                //TODO: è sempre corretto tornare stringa vuota in caso di eccezione ?
                throw new Exception( "GetJSON_CreateDocument - " + (strCause=="" ? "" : strCause + " - ")   +  ex.Message, ex);
            }
        }
        private string GetRegisterOrRF(string token, string CodePhysicsCollocation, out string ErrorCode,  out string ErroreGestito)
        {
            string IdRegisterRF = "";
            string strCause = "";

            IRestResponse response;
            HttpStatusCode statusCode = HttpStatusCode.Unused;

            string statusDescription;
            string jsonOutput = "";
            string strOperation = "";
            string strJSON = "";

            ErrorCode = "";
            ErroreGestito = "";
            

            try
            {
                ServicePointManager.ServerCertificateValidationCallback += RemoteCertificateValidate;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | Tls12;

                ServicePointManager.Expect100Continue = true;
                ServicePointManager.DefaultConnectionLimit = 9999;
                ServicePointManager.SetTcpKeepAlive(true, 10000, 1000);

                strCause = "Carica il certificato per l'accesso al servizio";
                try
                {
                    cert = new X509Certificate2(strPathCertificate, strPwdCertificate, X509KeyStorageFlags.MachineKeySet);
                }
                catch (Exception ex2)
                {
                    throw new Exception(ex2.Message + " errore caricamento del certificato");
                }

                strCause = "Chiamata al web service GetActiveClassificationScheme " + endPointTND;
                var client = new RestClient(endPointTND);



                client.ClientCertificates = new X509CertificateCollection() { cert };

                RestRequest request;

                request = new RestRequest(Method.GET);

                request.AddHeader("CODE_ADM", CODE_ADM);
                request.AddHeader("ROUTED_ACTION", "GetRegisterOrRF?codeRegister=" + CodePhysicsCollocation);
                request.AddHeader("Content-Type", "application/json");
                request.AddHeader("AuthToken", token);

                //strJSON = @"{
                //        ""Filters"": [
                //            {
                //                ""Name"": ""TYPE"",
                //                ""Value"": ""INTERNAL""
                //            },
                //            {
                //                ""Name"": ""OFFICES"",
                //                ""Value"": ""TRUE""
                //            },
                //            {
                //                ""Name"": ""DESCRIPTION"",
                //                ""Value"": ""<<DESCRIPTION>>""//  campo recuperato nella getproject PhysicsCollocation
                //            }
                //        ]
                //    }";


                //strJSON = strJSON.Replace("<<DESCRIPTION>>", PhysicsCollocation);
                //JToken jsonOK = JToken.Parse(strJSON);
                //// Serializzazione del token formattato come JSON valido
                //strJSON = jsonOK.ToString(Formatting.Indented);
                //request.AddParameter("application/json", strJSON, ParameterType.RequestBody);

                recGetRegisterOrRF rec;

                response = client.Execute(request);
                jsonOutput = response.Content; // Contenuto raw come string

                statusCode = response.StatusCode;
                statusDescription = response.StatusDescription;

                if (statusDescription == null)
                    statusDescription = "";

                if (statusCode == System.Net.HttpStatusCode.NoContent)
                {
                    //esito = "Nessuna risposta dal web service";
                    throw new Exception("Errore nell'invocazione del web service : Nessuna risposta dal web service" + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }
                else if (statusCode == System.Net.HttpStatusCode.OK)
                {


                    jsonOutput = jsonOutput.Trim();

                    rec = JsonConvert.DeserializeObject<recGetRegisterOrRF>(jsonOutput);

                    if (rec.Code != "0" && !(rec.Code == "1" && rec.ErrorMessage.StartsWith("Il token ha superato")))
                    //throw new Exception("Errore nell'invocazione del web service GetProject - error = " + (rec.ErrorMessage == null ? "" : rec.ErrorMessage));
                    {
                        ErroreGestito = "Errore - CodePhysicsCollocation " + CodePhysicsCollocation + (rec.ErrorMessage == null ? "" : " - " + rec.ErrorMessage);
                        return "";
                    }


                    if (rec.Code == "1" && rec.ErrorMessage.StartsWith("Il token ha superato"))
                        ErrorCode = "1";
                    //else if (rec.Code != "0")
                    //    ErrorCode = "2";
                    else
                    {
                        try
                        {
                            IdRegisterRF = rec.Register.Id;
                        }
                        catch { };
                        if (string.IsNullOrEmpty(IdRegisterRF))
                            IdRegisterRF = "";
                        
                    }

                }
                else
                {
                    throw new Exception("Errore nell'invocazione del web service : " + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }

                //if (IdFascicolo == "" &&  ErrorCode != "1" && ErrorCode != "0" && ErrorCode != "")
                //    throw new Exception("Errore GetProject " + (rec.ErrorMessage == null ? "" : " - " + rec.ErrorMessage));

                return IdRegisterRF;
            }
            catch (Exception ex)
            {
                //TODO: è sempre corretto tornare stringa vuota in caso di eccezione ?
                throw new Exception(strCause + "-" + ex.Message, ex);
            }
        }


        private string SearchCorrespondents(string token, string PhysicsCollocation,  out string ErrorCode, out string CodePhysicsCollocation, out string ErroreGestito, bool SearchByCode=false)
        {
            string IdPhysicsCollocation = "";
            string strCause = "";

            IRestResponse response;
            HttpStatusCode statusCode = HttpStatusCode.Unused;

            string statusDescription;
            string jsonOutput = "";
            string strOperation = "";
            string strJSON = "";

            ErrorCode = "";
            ErroreGestito = "";
            CodePhysicsCollocation = "";

            try
            {
                ServicePointManager.ServerCertificateValidationCallback += RemoteCertificateValidate;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | Tls12;

                ServicePointManager.Expect100Continue = true;
                ServicePointManager.DefaultConnectionLimit = 9999;
                ServicePointManager.SetTcpKeepAlive(true, 10000, 1000);

                strCause = "Carica il certificato per l'accesso al servizio";
                try
                {
                    cert = new X509Certificate2(strPathCertificate, strPwdCertificate, X509KeyStorageFlags.MachineKeySet);
                }
                catch (Exception ex2)
                {
                    throw new Exception(ex2.Message + " errore caricamento del certificato");
                }

                strCause = "Chiamata al web service GetActiveClassificationScheme " + endPointTND;
                var client = new RestClient(endPointTND);



                client.ClientCertificates = new X509CertificateCollection() { cert };

                RestRequest request;

                request = new RestRequest(Method.POST);

                request.AddHeader("CODE_ADM", CODE_ADM);
                request.AddHeader("ROUTED_ACTION", "SearchCorrespondents");
                request.AddHeader("Content-Type", "application/json");
                request.AddHeader("AuthToken", token);

                if (SearchByCode)
                    strJSON = @"{
                            ""Filters"": [
                                {
                                    ""Name"": ""TYPE"",
                                    ""Value"": ""INTERNAL""
                                },
                                {
                                    ""Name"": ""OFFICES"",
                                    ""Value"": ""TRUE""
                                },
                                {
                                    ""Name"": ""EXACT_CODE"",
                                    ""Value"": ""<<DESCRIPTION>>""//  campo recuperato nella getproject PhysicsCollocation
                                }
                            ]
                        }";

                else
                    strJSON = @"{
                            ""Filters"": [
                                {
                                    ""Name"": ""TYPE"",
                                    ""Value"": ""INTERNAL""
                                },
                                {
                                    ""Name"": ""OFFICES"",
                                    ""Value"": ""TRUE""
                                },
                                {
                                    ""Name"": ""DESCRIPTION"",
                                    ""Value"": ""<<DESCRIPTION>>""//  campo recuperato nella getproject PhysicsCollocation
                                }
                            ]
                        }";


                strJSON = strJSON.Replace("<<DESCRIPTION>>", PhysicsCollocation);
                JToken jsonOK = JToken.Parse(strJSON);
                // Serializzazione del token formattato come JSON valido
                strJSON = jsonOK.ToString(Formatting.Indented);


                request.AddParameter("application/json", strJSON, ParameterType.RequestBody);

                recSearchCorrespondents rec;

                response = client.Execute(request);
                jsonOutput = response.Content; // Contenuto raw come string

                statusCode = response.StatusCode;
                statusDescription = response.StatusDescription;

                if (statusDescription == null)
                    statusDescription = "";

                if (statusCode == System.Net.HttpStatusCode.NoContent)
                {
                    //esito = "Nessuna risposta dal web service";
                    throw new Exception("Errore nell'invocazione del web service : Nessuna risposta dal web service" + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }
                else if (statusCode == System.Net.HttpStatusCode.OK)
                {


                    jsonOutput = jsonOutput.Trim();

                    rec = JsonConvert.DeserializeObject<recSearchCorrespondents>(jsonOutput);

                    if (rec.Code != "0" && !(rec.Code == "1" && rec.ErrorMessage.StartsWith("Il token ha superato")))
                    //throw new Exception("Errore nell'invocazione del web service GetProject - error = " + (rec.ErrorMessage == null ? "" : rec.ErrorMessage));
                    {
                        ErroreGestito = "Errore - PhysicsCollocation " + PhysicsCollocation + (rec.ErrorMessage == null ? "" : " - " + rec.ErrorMessage);
                        return "";
                    }


                    if (rec.Code == "1" && rec.ErrorMessage.StartsWith("Il token ha superato"))
                        ErrorCode = "1";
                    //else if (rec.Code != "0")
                    //    ErrorCode = "2";
                    else
                    {
                        try
                        {
                            IdPhysicsCollocation = rec.Correspondents[0].Id;
                        }
                        catch { };
                        if (string.IsNullOrEmpty(IdPhysicsCollocation))
                            IdPhysicsCollocation = "";

                        try
                        {
                            CodePhysicsCollocation  = rec.Correspondents[0].Code ;
                        }
                        catch { };
                        if (string.IsNullOrEmpty(CodePhysicsCollocation))
                            CodePhysicsCollocation = "";
                    }

                }
                else
                {
                    throw new Exception("Errore nell'invocazione del web service : " + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }

                //if (IdFascicolo == "" &&  ErrorCode != "1" && ErrorCode != "0" && ErrorCode != "")
                //    throw new Exception("Errore GetProject " + (rec.ErrorMessage == null ? "" : " - " + rec.ErrorMessage));

                return IdPhysicsCollocation;
            }
            catch (Exception ex)
            {
                //TODO: è sempre corretto tornare stringa vuota in caso di eccezione ?
                throw new Exception(strCause + "-" + ex.Message, ex);
            }
        }

        private string GetProject(string token,string fascicolo,string IdTitolario, out string ErrorCode, out string PhysicsCollocation, out string ErroreGestito)
        {
            string IdFascicolo = "";
            string strCause = "";

            IRestResponse response;
            HttpStatusCode statusCode = HttpStatusCode.Unused;

            string statusDescription;
            string jsonOutput = "";
            string strOperation = "";
            string strJSON = "";

            ErrorCode = "";
            ErroreGestito = "";                
            PhysicsCollocation = "";

            try
            {
                ServicePointManager.ServerCertificateValidationCallback += RemoteCertificateValidate;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | Tls12;

                ServicePointManager.Expect100Continue = true;
                ServicePointManager.DefaultConnectionLimit = 9999;
                ServicePointManager.SetTcpKeepAlive(true, 10000, 1000);

                strCause = "Carica il certificato per l'accesso al servizio";
                try
                {
                    cert = new X509Certificate2(strPathCertificate, strPwdCertificate, X509KeyStorageFlags.MachineKeySet);
                }
                catch (Exception ex2)
                {
                    throw new Exception(ex2.Message + " errore caricamento del certificato");
                }

                strCause = "Chiamata al web service GetActiveClassificationScheme " + endPointTND;
                var client = new RestClient(endPointTND);

               

                client.ClientCertificates = new X509CertificateCollection() { cert };

                RestRequest request;

                request = new RestRequest(Method.GET);

                request.AddHeader("CODE_ADM", CODE_ADM);
                request.AddHeader("ROUTED_ACTION", "GetProject?codeProject=" + fascicolo + "&classificationSchemeId=" + IdTitolario);
                request.AddHeader("Content-Type", "application/json");
                request.AddHeader("AuthToken", token);

                //strJSON = @"{
                //              ""Username"": ""USR_EPR_PAT"",
                //              ""CodeRoleLogin"": ""RDA_EPR_PAT"",
                //              ""CodeApplication"": ""ConTRacta"",
                //              ""CodeAdm"": ""PAT_TEST""
                //            }";


                //strJSON = strJSON.Replace("<<CODE_ADM>>", CODE_ADM);
                //JToken jsonOK = JToken.Parse(strJSON);
                //// Serializzazione del token formattato come JSON valido
                //strJSON = jsonOK.ToString(Formatting.Indented);


                //request.AddParameter("application/json", strJSON, ParameterType.RequestBody);

                recProject rec;

                response = client.Execute(request);
                jsonOutput = response.Content; // Contenuto raw come string

                statusCode = response.StatusCode;
                statusDescription = response.StatusDescription;

                if (statusDescription == null)
                    statusDescription = "";

                if (statusCode == System.Net.HttpStatusCode.NoContent)
                {
                    //esito = "Nessuna risposta dal web service";
                    throw new Exception("Errore nell'invocazione del web service : Nessuna risposta dal web service" + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }
                else if (statusCode == System.Net.HttpStatusCode.OK)
                {


                    jsonOutput = jsonOutput.Trim();

                    rec = JsonConvert.DeserializeObject<recProject>(jsonOutput);

                    if (rec.Code != "0" && !(rec.Code == "1" && rec.ErrorMessage.StartsWith("Il token ha superato")))
                    //throw new Exception("Errore nell'invocazione del web service GetProject - error = " + (rec.ErrorMessage == null ? "" : rec.ErrorMessage));
                    {
                        ErroreGestito = "Errore - fascicolo " + fascicolo + (rec.ErrorMessage == null ? "" : " - " + rec.ErrorMessage);
                        return "";
                    }
                    

                    if (rec.Code == "1" && rec.ErrorMessage.StartsWith("Il token ha superato"))
                        ErrorCode = "1";
                    //else if (rec.Code != "0")
                    //    ErrorCode = "2";
                    else
                    { 
                        try
                        {
                            IdFascicolo = rec.Project.Id;
                        }
                        catch { };
                        if (string.IsNullOrEmpty(IdFascicolo))
                            IdFascicolo = "";

                        try
                        {
                            PhysicsCollocation =rec.Project.PhysicsCollocation;
                        }
                        catch { };
                        if (string.IsNullOrEmpty(PhysicsCollocation))
                            PhysicsCollocation = "";
                    }
                        
                }
                else
                {
                    throw new Exception("Errore nell'invocazione del web service : " + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }

                //if (IdFascicolo == "" &&  ErrorCode != "1" && ErrorCode != "0" && ErrorCode != "")
                //    throw new Exception("Errore GetProject " + (rec.ErrorMessage == null ? "" : " - " + rec.ErrorMessage));

                return IdFascicolo;
            }
            catch (Exception ex)
            {
                //TODO: è sempre corretto tornare stringa vuota in caso di eccezione ?
                throw new Exception(strCause + "-" + ex.Message, ex);
            }
        }

        private string GetActiveClassificationScheme(string token, out string ErrorCode, out string ErroreGestito)
        {
            string IdTitolario = "";
            string strCause = "";

            IRestResponse response;
            HttpStatusCode statusCode = HttpStatusCode.Unused;

            string statusDescription;
            string jsonOutput = "";
            string strOperation = "";
            string strJSON = "";
            
            ErrorCode = "";
            ErroreGestito = "";

            try
            {
                ServicePointManager.ServerCertificateValidationCallback += RemoteCertificateValidate;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | Tls12;

                ServicePointManager.Expect100Continue = true;
                ServicePointManager.DefaultConnectionLimit = 9999;
                ServicePointManager.SetTcpKeepAlive(true, 10000, 1000);

                strCause = "Carica il certificato per l'accesso al servizio";
                try
                {
                    cert = new X509Certificate2(strPathCertificate, strPwdCertificate, X509KeyStorageFlags.MachineKeySet);
                }
                catch (Exception ex2)
                {
                    throw new Exception(ex2.Message + " errore caricamento del certificato");
                }

                strCause = "Chiamata al web service GetActiveClassificationScheme " + endPointTND;
                var client = new RestClient(endPointTND);

                //var client = new RestClient("https://ws-t.pitre.tn.it");

                client.ClientCertificates = new X509CertificateCollection() { cert };

                RestRequest request;

                request = new RestRequest(Method.GET);

                request.AddHeader("CODE_ADM", CODE_ADM);
                request.AddHeader("ROUTED_ACTION", "GetActiveClassificationScheme");
                request.AddHeader("Content-Type", "application/json");
                request.AddHeader("AuthToken", token);

                //strJSON = @"{
                //              ""Username"": ""USR_EPR_PAT"",
                //              ""CodeRoleLogin"": ""RDA_EPR_PAT"",
                //              ""CodeApplication"": ""ConTRacta"",
                //              ""CodeAdm"": ""PAT_TEST""
                //            }";


                //strJSON = strJSON.Replace("<<CODE_ADM>>", CODE_ADM);
                //JToken jsonOK = JToken.Parse(strJSON);
                //// Serializzazione del token formattato come JSON valido
                //strJSON = jsonOK.ToString(Formatting.Indented);


                //request.AddParameter("application/json", strJSON, ParameterType.RequestBody);

                recGetActiveClassificationScheme rec;

                response = client.Execute(request);
                jsonOutput = response.Content; // Contenuto raw come string

                statusCode = response.StatusCode;
                statusDescription = response.StatusDescription;

                if (statusDescription == null)
                    statusDescription = "";

                if (statusCode == System.Net.HttpStatusCode.NoContent)
                {
                    //esito = "Nessuna risposta dal web service";
                    throw new Exception("Errore nell'invocazione del web service : Nessuna risposta dal web service" + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }
                else if (statusCode == System.Net.HttpStatusCode.OK)
                {


                    jsonOutput = jsonOutput.Trim();

                    rec = JsonConvert.DeserializeObject<recGetActiveClassificationScheme>(jsonOutput);
                   
                    if (rec.Code != "0" && !(rec.Code == "1" && rec.ErrorMessage.StartsWith("Il token ha superato")))
                    //throw new Exception("Errore nell'invocazione del web service GetActiveClassificationScheme - error = " + (rec.ErrorMessage == null ? "" : rec.ErrorMessage));
                    {
                        ErroreGestito = "Errore " + (rec.ErrorMessage == null ? "" : " - " + rec.ErrorMessage);
                        return "";
                    }


                    if (rec.Code == "1" && rec.ErrorMessage.StartsWith("Il token ha superato"))
                        ErrorCode = "1";
                    //else if (rec.Code != "0" )
                    //    ErrorCode = "2";
                    else
                        IdTitolario = rec.ClassificationScheme.Id;
                }
                else
                {
                    throw new Exception("Errore nell'invocazione del web service : " + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }

                //if (IdTitolario == "" && ErrorCode != "1" && ErrorCode != "0" && ErrorCode != "")
                //    throw new Exception("Errore GetActiveClassificationScheme " + (rec.ErrorMessage == null ? "" : " - " + rec.ErrorMessage));

               

                return IdTitolario;
            }
            catch (Exception ex)
            {
                //TODO: è sempre corretto tornare stringa vuota in caso di eccezione ?
                throw new Exception(strCause + "-" + ex.Message, ex);
            }
        }


        private string GetToken()
        {
            string token = "";
            string strCause = "";

            IRestResponse response;
            HttpStatusCode statusCode = HttpStatusCode.Unused;

            string statusDescription;
            string jsonOutput = "";
            string strOperation = "";
            string strJSON = "";

            try
            {
                ServicePointManager.ServerCertificateValidationCallback += RemoteCertificateValidate;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | Tls12;

                ServicePointManager.Expect100Continue = true;
                ServicePointManager.DefaultConnectionLimit = 9999;
                ServicePointManager.SetTcpKeepAlive(true, 10000, 1000);

                strCause = "Carica il certificato per l'accesso al servizio";
                try
                {
                    cert = new X509Certificate2(strPathCertificate, strPwdCertificate , X509KeyStorageFlags.MachineKeySet);
                }
                catch (Exception ex2)
                {
                    throw new Exception(ex2.Message + " errore caricamento del certificato");
                }               
                
                strCause = "Chiamata al web service GetToken " + endPointTND;
                var client = new RestClient(endPointTND);

                //var client = new RestClient("https://ws-t.pitre.tn.it");

                client.ClientCertificates = new X509CertificateCollection() { cert };

                RestRequest request;
                                
                request = new RestRequest(Method.POST);
               
                request.AddHeader("CODE_ADM", CODE_ADM);
                request.AddHeader("ROUTED_ACTION", "GetToken");
                request.AddHeader("Content-Type", "application/json");

                strJSON = @"{
                              ""Username"": ""USR_EPR_PAT"",
                              ""CodeRoleLogin"": ""RDA_EPR_PAT"",
                              ""CodeApplication"": ""ConTRacta"",
                              ""CodeAdm"": ""PAT_TEST""
                            }";


                strJSON =strJSON.Replace("<<CODE_ADM>>", CODE_ADM);
                JToken jsonOK = JToken.Parse(strJSON);
                // Serializzazione del token formattato come JSON valido
                strJSON = jsonOK.ToString(Formatting.Indented);
                              

                request.AddParameter("application/json", strJSON, ParameterType.RequestBody);

                response = client.Execute(request);
                jsonOutput = response.Content; // Contenuto raw come string

                statusCode = response.StatusCode;
                statusDescription = response.StatusDescription;
                
                if (statusDescription == null)
                    statusDescription = "";

                if (statusCode == System.Net.HttpStatusCode.NoContent)
                {
                    //esito = "Nessuna risposta dal web service";
                    throw new Exception("Errore nell'invocazione del web service : Nessuna risposta dal web service" + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }
                else if (statusCode == System.Net.HttpStatusCode.OK)
                {

                   
                    jsonOutput = jsonOutput.Trim();
                    
                    recGetToken rec = JsonConvert.DeserializeObject<recGetToken>(jsonOutput);
                    token = rec.Token;

                    if (rec.Code != "0")
                        throw new Exception("Errore nell'invocazione del web service GetToken - error = " + (rec.ErrorMessage==null ? "" : rec.ErrorMessage) );

                }
                else
                {
                    throw new Exception("Errore nell'invocazione del web service : " + statusDescription + " - " + jsonOutput + " - Input: " + strJSON);
                }

                if (token=="")
                    throw new Exception("Errore il metodo GetToken ha restituito un token vuoto");

                return token;
            }
            catch (Exception ex)
            {
                //TODO: è sempre corretto tornare stringa vuota in caso di eccezione ?
                throw new Exception(strCause + "-" + ex.Message, ex);
            }
        }

        private static bool RemoteCertificateValidate(object sender, X509Certificate cert, X509Chain chain, SslPolicyErrors error)
        {
            // trust any certificate
            System.Console.WriteLine("Warning, ECCEZIONE DI RemoteCertificateValidate");
            return true;
        }

        private  bool RecuperaFascicolo(string idDocumento, string ingressoUscita,  out string fascicolo, out string strTitolo, bool bCalcTipo = false)
        {
            try
            {
                fascicolo = "";
                strTitolo = "";

                string tipodoc = "";
                string strSql = "";                
                SqlCommand cmd1;
                SqlDataReader rs;
                bool bFound = false;

                if (bCalcTipo) // in questo caso determina ingresso o uscita in base al tipo del documento
                {
                    ingressoUscita = "U";
                    strSql = @"select tipodoc from CTL_DOC a with(nolock)                               
                                where a.Id = " + idDocumento;
                    cmd1 = new SqlCommand(strSql, sqlConn);
                    using (rs = cmd1.ExecuteReader())
                    {

                        if (rs.Read())
                        {
                            bFound = true;
                            tipodoc = rs.GetString(rs.GetOrdinal("tipodoc")).ToUpper();                            
                        }

                    }

                    rs.Close ();
                    //cmd1.Connection.Close ();

                    if (bFound )
                    {
                        if (tipodoc=="OFFERTA")
                            ingressoUscita = "I";
                    }

                }

                bFound = false;
                if (ingressoUscita == "I") // ingresso

                    strSql = @"select rtrim(isnull(a.titolo,'')) as titolo,rtrim(isnull(fascicoloSecondario,'')) as fascicoloSecondario from CTL_DOC a with(nolock)
                                inner join CTL_DOC b with(nolock) on a.LinkedDoc = b.Id and b.TipoDoc like 'bando%' and b.Deleted = 0
                                inner join Document_dati_protocollo with(nolock) on idHeader = b.id
                                where a.Id = " + idDocumento;
                else // uscita

                    strSql = "select rtrim(isnull(a.titolo,'')) as titolo,rtrim(isnull(fascicoloSecondario,'')) as fascicoloSecondario from Document_dati_protocollo with (nolock) inner join CTL_DOC a with(nolock) on a.id=IdHeader  where IdHeader = " + idDocumento;


                cmd1 = new SqlCommand(strSql, sqlConn);
                using (rs = cmd1.ExecuteReader())
                {

                    if (rs.Read())
                    {
                        bFound = true;
                        fascicolo = rs.GetString(rs.GetOrdinal("fascicoloSecondario"));
                        strTitolo = rs.GetString(rs.GetOrdinal("titolo"));
                    }

                }


                return true;
            }
            catch (Exception ex)
            {
                //TODO: è sempre corretto tornare stringa vuota in caso di eccezione ?
                throw new Exception("RecuperaFascicolo - " +  ex.Message, ex);
            }
        }

        private void settaProtocollo(string protocollo, string dataProtocollo, string id)
        {
            string strSql = "";
            string strSql2 = "";
            SqlCommand cmd1;
            SqlDataReader rs;
            SqlCommand cmd2;
            bool bFound = false;

            strSql = "select * from v_protgen_dati  with (nolock) where idheader = " + id + " and DZT_Name = 'ProtocolloGenerale' and isnull(Value,'') <> ''";

            cmd1 = new SqlCommand(strSql, sqlConn);
            using (rs = cmd1.ExecuteReader())
            {

                if (rs.Read())
                {
                    bFound = true;

                }

            }

            if (bFound)
            {
                strSql2 = "update v_protgen_dati set value = '" + protocollo.Replace("'", "''") + "' where idheader = " + id + " and DZT_Name = 'ProtocolloGenerale'";
                cmd2 = new SqlCommand(strSql2, sqlConn);
                cmd2.ExecuteNonQuery();

                strSql2 = "update v_protgen_dati set value = '" + dataProtocollo.Replace("'", "''") + "' where idheader = " + id + " and DZT_Name = 'DataProtocolloGenerale'";
                cmd2 = new SqlCommand(strSql2, sqlConn);
                cmd2.ExecuteNonQuery();
            }
            else
            {
                strSql2 = "insert into v_protgen_dati ( idHeader, dzt_name, value) values ( " + id + ", 'ProtocolloGenerale', '" + protocollo.Replace("'", "''") + "')";
                cmd2 = new SqlCommand(strSql2, sqlConn);
                cmd2.ExecuteNonQuery();

                strSql2 = "insert into v_protgen_dati ( idHeader, dzt_name, value) values ( " + id + ", 'DataProtocolloGenerale', '" + dataProtocollo.Replace("'", "''") + "')";
                cmd2 = new SqlCommand(strSql2, sqlConn);
                cmd2.ExecuteNonQuery();
            }




        }

        /// <summary>
        /// 
        /// </summary>
        /// controlla se esiste l'anagrafica
        /// <param name="cf">Codice Fiscale dell'anagrafica da controllare</param>
        /// <param name="partitaIvaEnte">PartitaIva Ente Appaltante Insiel S.p.A</param>
        // il parametro di out lookupAzi viene passato alla Update in caso di aggiornamento
        /// <returns></returns>
        private bool CheckAnag(string partitaIvaEnte, string cfCheck, string RagSoc) //, out AnagraficaDto lookupAzi)
        {
            bool lookupFound = false;
            string strCause = "";

            //lookupAzi = null;

            HttpClient client = new HttpClient();



            try
            {

                if (Simulazione)
                {
                    //lookupAzi = new AnagraficaDto();

                    //lookupAzi.Id.CodiceAnagrafica = cfCheck;
                    //lookupAzi.Id.DescrizioneAnagrafica = RagSoc;

                    return true;
                }

                strCause = "Init oggetto AnagraficaClient";
                //AnagraficaClient anagraficaClient = new AnagraficaClient(client, endPointTND);

               

                //TipoConfigurazione tipoConfigurazione = TipoConfigurazione.Predefinita;

                //AnagraficaResultDto anagraficaLookup = new AnagraficaResultDto();

                //strCause = "Init oggetto AnagraficaCodiceFiscaleFilterDto";
                //AnagraficaCodiceFiscaleFilterDto filter = new AnagraficaCodiceFiscaleFilterDto
                //{
                //    Connessione = new ConnessioneDto
                //    {
                //        TipoConfigurazione = tipoConfigurazione,
                //        PartitaIvaEnte = partitaIvaEnte,
                //    },
                //    CodiceFiscale = cfCheck
                //};

                //strCause = "Chiamata al metodo CercaPerCodiceFiscale";
                //anagraficaLookup = anagraficaClient.CercaPerCodiceFiscale(filter);



                strCause = "test output CercaPerCodiceFiscale";
                //if (anagraficaLookup.Success == false)
                //    throw new Exception("Errore nell'invocazione del metodo CercaPerCodiceFiscale - " + cStr(anagraficaLookup.ReturnCode) + " - " + cStr(anagraficaLookup.ReturnMessage));

                //lookupFound = anagraficaLookup.Item != null;

                //if (lookupFound)
                //    lookupAzi = anagraficaLookup.Item;

            }
            catch (Exception ex)
            {
                throw new Exception("Errore nel metodo checkAnag. " + strCause + " - " + ex.Message, ex);
            }

            return lookupFound;
        }



        private bool InsertAnag(string partitaIvaEnte, string strRagSoc, string strCF, string strPIVA, string strlocalitaBS, string strStato, string strCAP, string strIndirizzo, string strProvincia, string strEmail, string strNome, string strCognome, string strTitolo, out string CodiceAnagrafica, out string DescrizioneAnagrafica)
        {
            bool bEsito = false;
            string strCause = "";
            HttpClient client = new HttpClient();

            CodiceAnagrafica = "";
            DescrizioneAnagrafica = "";

            try
            {

                //TipoConfigurazione tipoConfigurazione = TipoConfigurazione.Predefinita;

                //// Mapper: Seller+Buyer --> Dto: Preparazione Dto di anagrafica da cercare e/o eventualmente inserire/aggiornare
                //AnagraficaDto a2 = new AnagraficaDto
                //{
                //    Connessione = new ConnessioneDto
                //    {
                //        PartitaIvaEnte = partitaIvaEnte,
                //        TipoConfigurazione = tipoConfigurazione
                //    },

                //    Id = new AnagraficaIdDto
                //    {
                //        CodiceAnagrafica = strCF,
                //        DescrizioneAnagrafica = strRagSoc
                //    },

                //    CodiceFiscale = strCF,
                //    PartitaIva = strPIVA,

                //    Denominazione = strRagSoc, // Se non la si valorizza la mette uguale alla descrizioneAnagrafica che viene salvata!

                    

                //    CodiceTipoAnagrafica = CodiceTipoAnagrafica.Esterni,

                    
                //};

                
                //if (!string.IsNullOrEmpty(strProvincia))
                //    a2.Provincia = strProvincia;

                //if (!string.IsNullOrEmpty(strlocalitaBS))
                //    a2.Localita  = strlocalitaBS;

                //if (!string.IsNullOrEmpty(strStato))
                //    a2.Stato  = strStato;

                //if (!string.IsNullOrEmpty(strCAP))
                //    a2.Cap  = strCAP;

                //if (!string.IsNullOrEmpty(strIndirizzo))
                //    a2.Indirizzo = strIndirizzo;

                //if (!string.IsNullOrEmpty(strEmail))
                //    a2.Email  = strEmail;

                //if (!string.IsNullOrEmpty(strNome))
                //    a2.Nome  = strNome;

                //if (!string.IsNullOrEmpty(strCognome))
                //    a2.Cognome  = strCognome;

                //if (!string.IsNullOrEmpty(strTitolo))
                //    a2.Titolo  = strTitolo;

                


                strCause = "Init oggetto AnagraficaClient";
                //AnagraficaClient anagraficaClient = new AnagraficaClient(client, endPointTND);

                

                strCause = "chiama la funzione di inserimento";
                //AnagraficaIdResultDto anagraficaIdCreata = anagraficaClient.Nuova(a2);





                //if (anagraficaIdCreata.Success == false)
                //{
                //    throw new Exception("Inserimento Anagrafica fallito - " + cStr(anagraficaIdCreata.ReturnCode) + " - " + cStr(anagraficaIdCreata.ReturnMessage));
                //}
                //else
                //{
                //    bEsito = true;
                //    CodiceAnagrafica = cStr(anagraficaIdCreata.Item.CodiceAnagrafica);
                //    DescrizioneAnagrafica = cStr(anagraficaIdCreata.Item.DescrizioneAnagrafica);

                    

                //};





            }
            catch (Exception ex)
            {
                throw new Exception("Errore nel metodo InsertAnag. " + strCause + " - " + ex.Message, ex);
            }

            return bEsito;
        }

        //private bool UpdateAnag(string partitaIvaEnte, AnagraficaDto lookupAzi, string strRagSoc, string strCF, string strPIVA, string strlocalitaBS, string strStato, string strCAP, string strIndirizzo, string strProvincia, string strEmail, string strNome, string strCognome, string strTitolo)
         private bool UpdateAnag(string partitaIvaEnte,  string strRagSoc, string strCF, string strPIVA, string strlocalitaBS, string strStato, string strCAP, string strIndirizzo, string strProvincia, string strEmail, string strNome, string strCognome, string strTitolo)
        {
            bool bEsito = false;
            string strCause = "";
            HttpClient client = new HttpClient();



            try
            {

                if (Simulazione)
                {
                    return true;
                }

                //TipoConfigurazione tipoConfigurazione = TipoConfigurazione.Predefinita;

               

                //lookupAzi.Connessione.PartitaIvaEnte = partitaIvaEnte;
                //lookupAzi.Connessione.TipoConfigurazione = tipoConfigurazione;
                
                //lookupAzi.PartitaIva = strPIVA;
                //lookupAzi.Denominazione = strRagSoc;
                

                //if (!string.IsNullOrEmpty(strProvincia))
                //    lookupAzi.Provincia = strProvincia;                

                //if (!string.IsNullOrEmpty(strlocalitaBS))
                //    lookupAzi.Localita = strlocalitaBS;

                //if (!string.IsNullOrEmpty(strStato))
                //    lookupAzi.Stato = strStato;

                //if (!string.IsNullOrEmpty(strCAP))
                //    lookupAzi.Cap = strCAP;

                //if (!string.IsNullOrEmpty(strIndirizzo))
                //    lookupAzi.Indirizzo = strIndirizzo;

                //if (!string.IsNullOrEmpty(strEmail))
                //    lookupAzi.Email = strEmail;

                //if (!string.IsNullOrEmpty(strNome))
                //    lookupAzi.Nome = strNome;

                //if (!string.IsNullOrEmpty(strCognome))
                //    lookupAzi.Cognome = strCognome;

                //if (!string.IsNullOrEmpty(strTitolo))
                //    lookupAzi.Titolo = strTitolo;

                //lookupAzi.CodiceTipoAnagrafica = CodiceTipoAnagrafica.Esterni;
                             


                strCause = "Init oggetto AnagraficaClient";
                //AnagraficaClient anagraficaClient = new AnagraficaClient(client, endPointTND);

                

                strCause = "chiama la funzione di aggiornamento";
                //ResultDto anagraficaIdResult = anagraficaClient.Aggiorna(lookupAzi);

                //if (anagraficaIdResult.Success == false)
                //    throw new Exception("Variazione Anagrafica fallita - " + cStr(anagraficaIdResult.ReturnCode) + " - " + cStr(anagraficaIdResult.ReturnMessage));
                //else
                //    bEsito = true;







            }
            catch (Exception ex)
            {
                throw new Exception("Errore nel metodo UpdateAnag. " + strCause + " - " + ex.Message, ex);
            }

            return bEsito;
        }


        private bool CreaProtocollo(string partitaIvaEnte, string CodiceAnagrafica, string DescrizioneAnagrafica, string OggettoDocumento, string OggettoProt, string strNumeroPratica, Dictionary<string, string> fileLIST, out string protocolOutput)
        {
            bool bEsito = false;
            protocolOutput = "";
            string strCause = "";
            //HttpClient client = new HttpClient();



            try
            {

                if (Simulazione)
                {                    

                    protocolOutput =  DateTime.Now.Hour.ToString() + DateTime.Now.Minute.ToString() + DateTime.Now.Second.ToString() + DateTime.Now.Millisecond.ToString() + "/" + DateTime.Now.Millisecond.ToString();

                    return true;
                }


                //TipoConfigurazione tipoConfigurazione = TipoConfigurazione.Predefinita;

                int ProgressivoDocumento =0;
                int ProgressivoMovimento = 0;

                string NumeroPratica = "";
                string[] subs;
                bool bb = false;

                if (!string.IsNullOrEmpty(strNumeroPratica))
                {
                    subs = strNumeroPratica.Split('-');
                    // elimina gli spazi in testa e coda
                    for (int j = 0; j < 4; j++)
                    { 
                        if (j==0)
                            subs[j] = subs[j].Substring(0, subs[j].Length - 1);
                        else if (j==3)
                            subs[j] = subs[j].Substring(1);
                        else
                        { 
                            subs[j] = subs[j].Substring(1);
                            subs[j] = subs[j].Substring(0, subs[j].Length-1 );
                        }
                    }

                                         
                        NumeroPratica = Trascodifica(strNumeroPratica, "", true);
                   
                    
                }

                    


                if (!string.IsNullOrEmpty(NumeroPratica))
                {
                    subs = NumeroPratica.Split('/');

                    if (subs.Length == 2)
                    {                     
                        if (IsNumeric(subs[0]))
                            ProgressivoDocumento = Convert.ToInt32(subs[0]);
                        if (IsNumeric(subs[1]))
                                ProgressivoMovimento = Convert.ToInt32(subs[1]);
                    }
                }

                HttpClient client = new HttpClient();
                //ProtocolloClient protocolloClient = new ProtocolloClient(client, endPointTND);

                //ProtocolloInserisciDto Protocollo;

               

                // REMARK: OK Tested
                //if ( string.IsNullOrEmpty(NumeroPratica) || ProgressivoDocumento==0 )

                     //Protocollo = new ProtocolloInserisciDto
                     //   {
                     //       Connessione = new ConnessioneDto
                     //       {
                     //           PartitaIvaEnte = partitaIvaEnte,
                     //           TipoConfigurazione = tipoConfigurazione
                     //       },

                     //       OggettoDocumento = new ProtocolloInserisciDto.OggettoDoc
                     //       {
                     //           Oggetto = OggettoDocumento, // TODO : Va chiesta ad Insiel che convenzione vogliono
                     //       },

                     //       OggettoProtocollo = OggettoProt, // TODO : Va chiesta ad Insiel che convenzione vogliono

                     //       Verso = Verso.InArrivo,

                     //       // !!! Deve riferire il (progDoc, progMovi) di una pratica esistente e già protocollata
                            

                     //       // !!! Deve riferire il (descrizione, codice) di una anagrafica seller esistente e già protocollata
                     //       Mittenti = new List<ProtocolloInserisciDto.Mittente>
                     //       {
                     //           new ProtocolloInserisciDto.Mittente
                     //           {
                                   
                     //               Codice = CodiceAnagrafica ,  //"62748740106",
                     //               Descrizione = DescrizioneAnagrafica
                     //           }
                     //       }

                     //       };
                //else

                    //Protocollo = new ProtocolloInserisciDto
                    //{
                    //    Connessione = new ConnessioneDto
                    //    {
                    //        PartitaIvaEnte = partitaIvaEnte,
                    //        TipoConfigurazione = tipoConfigurazione
                    //    },

                    //    OggettoDocumento = new ProtocolloInserisciDto.OggettoDoc
                    //    {
                    //        Oggetto = OggettoDocumento, // TODO : Va chiesta ad Insiel che convenzione vogliono
                    //    },

                    //    OggettoProtocollo = OggettoProt, // TODO : Va chiesta ad Insiel che convenzione vogliono

                    //    Verso = Verso.InArrivo,

                    //    // !!! Deve riferire il (progDoc, progMovi) di una pratica esistente e già protocollata
                    //    Pratiche = new List<PraticaIdDto>
                    //    {
                    //        new PraticaIdDto
                    //        {
                    //            // dati della pratica
                    //            ProgressivoDocumento = ProgressivoDocumento ,
                    //            ProgressivoMovimento = ProgressivoMovimento
                    //        }
                    //    },

                    //    // !!! Deve riferire il (descrizione, codice) di una anagrafica seller esistente e già protocollata
                    //    Mittenti = new List<ProtocolloInserisciDto.Mittente>
                    //    {
                    //        new ProtocolloInserisciDto.Mittente
                    //        {                   
                    //            Codice = CodiceAnagrafica ,  //"62748740106",
                    //            Descrizione = DescrizioneAnagrafica
                    //        }
                    //    }

                    //};


                // questi sono gli ALLEGATI da passare al protocollo dopo averli caricati
                // test
                //int i = 0;
                //foreach (var item in fileLIST)
                //{
                //    i++;
                //    Documento doc = new Documento();
                //    if (i == 1)
                //        doc.Primario = true;
                //    else
                //        doc.Primario = false;

                //    doc.Id = item.Value; // Id tornato da upload;
                //    doc.Nome = Path.GetFileName(item.Key); //nome file;

                //    Protocollo.Documenti.Add(doc);
                //}





                //var protocolloCreato = protocolloClient.Inserisci(Protocollo);                

                //if (protocolloCreato.Success == false)
                //    throw new Exception("Inserimento Protocollo fallito - " + cStr(protocolloCreato.ReturnCode) + " - " + cStr(protocolloCreato.ReturnMessage));
                //else
                //{
                //    if (protocolloCreato.Item != null)
                //    {

                //        var f5 = new ProtocolloIdFilterDto()
                //        {
                //            Connessione = new ConnessioneDto
                //            {
                //                PartitaIvaEnte = partitaIvaEnte,
                //                TipoConfigurazione = tipoConfigurazione
                //            },

                //            Id = new ProtocolloIdDto()
                //            {
                //                ProgressivoDocumento = protocolloCreato.Item.ProgressivoDocumento,
                //                ProgressivoMovimento = protocolloCreato.Item.ProgressivoMovimento
                //            }
                //        };

                //        var result4 = protocolloClient.CercaPerId(f5);
                //        //protocolloClient.CercaPerId

                //        if (result4.Success == false )
                //            throw new Exception("Fallita la ricerca tramite CercaPerId del protocollo creato - " + cStr(protocolloCreato.Item.ProgressivoDocumento.ToString()) + " - " + cStr(protocolloCreato.Item.ProgressivoMovimento.ToString()));
                //        else
                //        {

                //            //var aa = new ProtocolloIdentificatoreDto
                //            //result4.Item.Dettaglio.
                //            bEsito = true;
                //            //protocolOutput = DateTime.Now.Year.ToString() + "." + protocolloCreato.Item.ProgressivoDocumento + "/" + protocolloCreato.Item.ProgressivoMovimento;
                //            //protocolOutput =  protocolloCreato.Item.ProgressivoDocumento + "/" + protocolloCreato.Item.ProgressivoMovimento;
                            
                //            protocolOutput = cStr(result4.Item.Dettaglio.RegCodAna.ToString()) + "-" + cStr(result4.Item.Dettaglio.RegCodReg.ToString()) + "-" + Right( "0000000" + cStr(result4.Item.Dettaglio.ProtoNumProt.ToString()),7) + "-" + cStr(result4.Item.Dettaglio.ProtoApProt.ToString());
                //        }
                //    }
                //    else
                //        throw new Exception("Inserimento Protocollo fallito - " + cStr(protocolloCreato.ReturnCode) + " - " + cStr(protocolloCreato.ReturnMessage));

                //}

            }
            catch (Exception ex)
            {
                throw new Exception("Errore nel metodo CreaProtocollo. " + strCause + " - " + ex.Message, ex);
            }

            return bEsito;
        }

        private bool VerificaPratica(string partitaIvaEnte, int ProgressivoDocumento, int ProgressivoMovimento,string codiceUfficio,string CodiceRegistro,int Numero,int Anno, out int ProgressivoDocumentoOut, out int ProgressivoMovimentoOut)
        {
            bool bEsito = false;
            string strCause = "";
            HttpClient client = new HttpClient();

            ProgressivoDocumentoOut = 0;
            ProgressivoMovimentoOut = 0;

            try
            {
                

                //TipoConfigurazione tipoConfigurazione = TipoConfigurazione.Predefinita;


                //PraticaClient praticaClient = new PraticaClient(client, endPointTND);




                //RichiestaDto richiestaDto = new RichiestaDto
                //{
                //    Connessione = new ConnessioneDto
                //    {
                //        PartitaIvaEnte = partitaIvaEnte,
                //        TipoConfigurazione = tipoConfigurazione
                //    }
                //};

                

                //if (ProgressivoDocumento>0)
                //{ 
                //    PraticaIdFilterDto f = new PraticaIdFilterDto()
                //    {
                //        Connessione = new ConnessioneDto
                //        {
                //            PartitaIvaEnte = partitaIvaEnte,
                //            TipoConfigurazione = tipoConfigurazione
                //        },

                //        Id = new PraticaIdDto()
                //        {
                //            ProgressivoDocumento = ProgressivoDocumento,
                //            ProgressivoMovimento = ProgressivoMovimento
                //        }
                //    };
                //    praticaClient.Dettagli(f);

                //    var prRes = praticaClient.CercaPerId(f);

                //    if (prRes.Success == false)
                //        //throw new Exception("Cerca Pratica fallito - " + cStr(prRes.ReturnCode) + " - " + cStr(prRes.ReturnMessage));
                //    bEsito = false;
                //    else
                //        bEsito = true;

                //}
                //else
                //{ 
                //    PraticaFilterDto f2 = new PraticaFilterDto
                //    {
                //        Connessione = new ConnessioneDto
                //        {
                //            PartitaIvaEnte = partitaIvaEnte,
                //            TipoConfigurazione = tipoConfigurazione
                //        },
                //        //CodiceUfficioOperante = codiceUfficio,
                //        Numero = new NumeroRangeDto
                //        {
                //            Da = Numero,
                //            A=Numero
                //        },
                //        Anno = new AnnoRangeDto
                //        {
                //            Da =Anno,
                //            A=Anno
                //        },
                //        CodiceRegistro = new CodiceRegistroFilterDto
                //        {
                //            CodiceRegistro = CodiceRegistro
                //        },
                //    };

                

                //    var pratiche = praticaClient.Interroga(f2);

                //    if (pratiche.Success == false)
                //        bEsito = false;
                //    else
                //    {
                //        bEsito = true;
                //        ProgressivoDocumentoOut = Convert.ToInt32(pratiche.Items.ElementAt(0).Id.ProgressivoDocumento);
                //        ProgressivoMovimentoOut = Convert.ToInt32(pratiche.Items.ElementAt(0).Id.ProgressivoMovimento);
                //    }

                //}


            }
            catch (Exception ex)
            {
                throw new Exception("Errore nel metodo VerificaPratica. " + strCause + " - " + ex.Message, ex);
            }

            return bEsito;
        }

        private bool CreaPratica(string partitaIvaEnte, string Oggetto, string Note, out string strPratica)
        {
            bool bEsito = false;
            string strCause = "";
            strPratica = "";
            HttpClient client = new HttpClient();



            try
            {

                if (Simulazione)
                {
                    strPratica = DateTime.Now.Hour.ToString() + DateTime.Now.Minute.ToString() + DateTime.Now.Second.ToString() + DateTime.Now.Millisecond.ToString() + "/" + DateTime.Now.Millisecond.ToString();
                    string ss1 = Trascodifica(strPratica, strPratica);                    
                    return true;
                }


                //TipoConfigurazione tipoConfigurazione = TipoConfigurazione.Predefinita;

                //PraticaApriDto pratica = new PraticaApriDto()
                //{
                //    Connessione = new ConnessioneDto
                //    {
                //        PartitaIvaEnte = partitaIvaEnte,
                //        TipoConfigurazione = tipoConfigurazione
                //    },
                //    Anno = DateTime.Now.Year,
                //    Oggetto = Oggetto,
                //    Data = DateTime.Now,
                //    Note = Note
                //};

                //PraticaClient praticaClient = new PraticaClient(client, endPointTND);




                //RichiestaDto richiestaDto = new RichiestaDto
                //{
                //    Connessione = new ConnessioneDto
                //    {
                //        PartitaIvaEnte = partitaIvaEnte,
                //        TipoConfigurazione = tipoConfigurazione
                //    }
                //};             


                //var praticaCreata = praticaClient.Apri(pratica);

                

                //if (praticaCreata.Success == false)
                //    throw new Exception("Cerca Pratica fallito - " + cStr(praticaCreata.ReturnCode) + " - " + cStr(praticaCreata.ReturnMessage));
                //else
                //{

                    //var f5 = new PraticaIdFilterDto
                    //{
                    //    Connessione = new ConnessioneDto
                    //    {
                    //        PartitaIvaEnte = partitaIvaEnte,
                    //        TipoConfigurazione = tipoConfigurazione
                    //    },

                    //    Id = new PraticaIdDto()
                    //    {
                    //        ProgressivoDocumento = praticaCreata.Item.ProgressivoDocumento,
                    //        ProgressivoMovimento = praticaCreata.Item.ProgressivoMovimento
                    //    }
                    //};

                    //strCause= "CercaPerId con i seguenti dati: " + praticaCreata.Item.ProgressivoDocumento.ToString() + "/" + praticaCreata.Item.ProgressivoMovimento.ToString();
                    //var result4 = praticaClient.CercaPerId(f5);

                    //if (result4.Success == false)
                    //    throw new Exception("Errore nel metodo CreaPratica. Fallito il metodo CercaPerId - " + strCause );
                    //else
                    //{
                        
                    //    strPratica = cStr(result4.Item.IdentificatorePratica.CodiceUfficio.ToString()) + " - " + cStr(result4.Item.IdentificatorePratica.CodiceRegistro.ToString())    + " - " + DateTime.Now.Year.ToString() + " - "  + cStr(result4.Item.IdentificatorePratica.Numero.ToString());                        
                    //    bEsito = true;

                    //    string ss = Trascodifica(strPratica, praticaCreata.Item.ProgressivoDocumento.ToString() + "/" + praticaCreata.Item.ProgressivoMovimento.ToString());

                    //}                                       
                    

                    
                //}


            }
            catch (Exception ex)
            {
                throw new Exception("Errore nel metodo CreaPratica. " + strCause + " - " + ex.Message, ex);
            }

            return bEsito;
        }


        private bool CaricaFile(string partitaIvaEnte, string fileName, out string IdFile)

        {
            bool bEsito = false;
            string strCause = "";
            IdFile = "";
            HttpClient client = new HttpClient();



            try
            {


                if (Simulazione)
                {
                    IdFile = "FILE" + DateTime.Now.Hour.ToString() + DateTime.Now.Minute.ToString() + DateTime.Now.Second.ToString() + DateTime.Now.Millisecond.ToString();

                    return true;
                }

                //TipoConfigurazione tipoConfigurazione = TipoConfigurazione.Predefinita;
                //FileTransferClient fileTransferClient = new FileTransferClient(client, endPointTND);

                

                var checksum = CalculateMD5(fileName);

                byte[] bytes = { };
                using (FileStream fs = new FileStream(fileName, FileMode.Open, FileAccess.Read))
                {
                    // Create a byte array of file stream length
                    bytes = File.ReadAllBytes(fileName);
                    //Read block of bytes from stream into the byte array
                    fs.Read(bytes, 0, Convert.ToInt32(fs.Length));
                    //Close the File Stream
                    fs.Close();
                }

                //FileTransferUploadDto fileDto = new FileTransferUploadDto
                //{
                //    Connessione = new ConnessioneDto
                //    {
                //        PartitaIvaEnte = partitaIvaEnte,
                //        TipoConfigurazione = tipoConfigurazione
                //    },
                //    BinaryData = bytes,
                //    Md5Checksum = checksum
                //};

                //var fileIdDto = fileTransferClient.UploadFile(fileDto);
                //if (fileIdDto.Success == false)
                //    throw new Exception("CaricaFile - " + cStr(fileIdDto.ReturnCode) + " - " + cStr(fileIdDto.ReturnMessage));
                //else
                //{

                //    bEsito = true;
                //    IdFile = fileIdDto.Item.Id;
                //}

            }
            catch (Exception ex)
            {
                throw new Exception("Errore nel metodo CaricaFile. " + strCause + " - " + ex.Message, ex);
            }

            return bEsito;
        }



        public static string cStr(object str)
        {
            try
            {
                if (str == null)
                {
                    return "";
                }

                return Convert.ToString(str);
            }
            catch
            {
                //TODO: è sempre corretto tornare stringa vuota in caso di eccezione ?
                return "";
            }
        }

        static string CalculateMD5(string filename)
        {
            using (var md5 = MD5.Create())
            {
                using (var stream = File.OpenRead(filename))
                {
                    var hash = md5.ComputeHash(stream);
                    return BitConverter.ToString(hash).Replace("-", "").ToLowerInvariant();
                }
            }
        }

        public string settaEsito(bool inErrore, string id)
        {
            string strSql = "select * from v_protgen_dati  with (nolock) where idheader = " + id + " and DZT_Name = 'ESITO_DOCER' and isnull(Value,'') <> ''";
            string strSql2 = "";

            SqlCommand cmd1;
            SqlCommand cmd2;
            SqlDataReader rs;
            //int myIdHeader = 0;
            string esito = "";

            if (inErrore)
                esito = "ERROR";
            else
                esito = "OK";

            bool bFound = false;

            cmd1 = new SqlCommand(strSql, sqlConn);
            using (rs = cmd1.ExecuteReader())
            {

                if (rs.Read())
                {
                    bFound = true;

                }


            }


            if (bFound)
            {
                strSql2 = "update v_protgen_dati set value = '" + esito.Replace("'", "''") + "' where idheader = " + id + " and DZT_Name = 'ESITO_DOCER'";
                cmd2 = new SqlCommand(strSql2, sqlConn);
                cmd2.ExecuteNonQuery();

            }
            else
            {

                strSql2 = "insert into v_protgen_dati ( idHeader, dzt_name, value) values ( " + id + ", 'ESITO_DOCER', '" + esito.Replace("'", "''") + "')";
                cmd2 = new SqlCommand(strSql2, sqlConn);
                cmd2.ExecuteNonQuery();
            }

            return "";

        }



        public string inserisciEsito(string idDoc, string messaggio)
        {
            string strSql = "";
            string strSql2 = "";

            if (idDoc == null || idDoc == "")
                return "";

            strSql = "select * from ctl_doc_value with (nolock) where dse_id = 'ESITO_PROT_GEN' and dzt_name = 'verifica_fascicolo' and idHeader = " + idDoc;

            SqlCommand cmd1;
            SqlCommand cmd2;
            SqlDataReader rs;

            bool bFound = false;

            cmd1 = new SqlCommand(strSql, sqlConn);
            using (rs = cmd1.ExecuteReader())
            {

                if (rs.Read())
                {
                    bFound = true;

                }


            }

            if (bFound)
            {
                strSql2 = "update ctl_doc_value set value = '" + messaggio.Replace("'", "''") + "' where dse_id = 'ESITO_PROT_GEN' and dzt_name = 'verifica_fascicolo' and idHeader = " + idDoc;
                cmd2 = new SqlCommand(strSql2, sqlConn);
                cmd2.ExecuteNonQuery();

            }
            else
            {

                strSql2 = "insert into ctl_doc_value ( idHeader, dse_id, dzt_name, value) values ( " + idDoc + ", 'ESITO_PROT_GEN', 'verifica_fascicolo', '" + messaggio.Replace("'", "''") + "')";
                cmd2 = new SqlCommand(strSql2, sqlConn);
                cmd2.ExecuteNonQuery();
            }

            return "";
        }

        public string GetPIVA_CF(string idazi, bool isPIVA = true)
        {
            string strSql = "";
            string output = "";


            if (isPIVA)
                strSql = "select case when substring(azipartitaiva,1,2)='IT' then substring(azipartitaiva,3,50) else azipartitaiva end as out from aziende with (nolock) where idazi=" + idazi;
            else
                strSql = "select vatvalore_ft as out from dm_attributi with (nolock) where idapp=1 and dztnome='codicefiscale' and lnk=" + idazi;

            SqlCommand cmd1;

            SqlDataReader rs;

            cmd1 = new SqlCommand(strSql, sqlConn);
            using (rs = cmd1.ExecuteReader())
            {

                if (rs.Read())
                {
                    output = rs.GetString(rs.GetOrdinal("out"));

                }
                else
                    throw new Exception("Recupero Dati fallito per IdAzi=" + idazi);


            }

            return output;
        }

        private void GetDatiAnag(string idazi,  out string PIVA, out string cf, out string ragsoc)
        {
            string strSql = "";
            PIVA = "";
            cf = "";
            ragsoc  = "";


            
            strSql = "select case when substring(azipartitaiva,1,2)='IT' then substring(azipartitaiva,3,50) else azipartitaiva end as out,aziragionesociale,vatvalore_ft from aziende with (nolock) inner join dm_attributi with (nolock) ON idapp=1 and dztnome='codicefiscale' and lnk=idazi where idazi=" + idazi;
            
            SqlCommand cmd1;

            SqlDataReader rs;

            cmd1 = new SqlCommand(strSql, sqlConn);
            using (rs = cmd1.ExecuteReader())
            {

                if (rs.Read())
                {
                    PIVA = rs.GetString(rs.GetOrdinal("out"));
                    ragsoc = rs.GetString(rs.GetOrdinal("aziragionesociale"));
                    cf = rs.GetString(rs.GetOrdinal("vatvalore_ft"));

                }
                else
                    throw new Exception("Recupero Dati fallito per IdAzi=" + idazi);


            }
            
        }

        public static bool IsNumeric(string s)
        {
            float output;
            return float.TryParse(s, out output);
        }



        public string getVProtgenDato(string tab_id, string campo)
        {
            string strSql = "select value from v_protgen_dati with (nolock) where idheader = " + tab_id + " and DZT_Name = '" + campo.Replace("'", "''") + "' and isnull(Value,'') <> ''";

            string output = "";



            SqlCommand cmd1;
            SqlDataReader rs;

            cmd1 = new SqlCommand(strSql, sqlConn);
            using (rs = cmd1.ExecuteReader())
            {

                if (rs.Read())
                {
                    output = rs.GetString(rs.GetOrdinal("value"));

                }


            }

            return output;
        }

        public void getDatiChiarimento(InfoDoc doc)
        {

            try
            {

                string strSql = @"select Protocol ,  isnull(b.Titolo,'') as titolo , isnull(b.Protocollo,'') as ProtocolloBando,
                                    convert(varchar(10), DataCreazione , 103 ) + ' ' +
                                    convert(varchar(5), DataCreazione , 108 ) as DataCreazione
                                        from Document_Chiarimenti a with (nolock) 
                                            inner join CTL_DOC b with (nolock)  on b.Id = a.ID_ORIGIN 
                                            where a.id = " + doc.Id;



                SqlCommand cmd1;
                SqlDataReader rs;

                cmd1 = new SqlCommand(strSql, sqlConn);
                using (rs = cmd1.ExecuteReader())
                {

                    if (rs.Read())
                    {
                        //doc.TipoDoc = rs.GetString(rs.GetOrdinal("TipoDoc"));
                        doc.Data = rs.GetString(rs.GetOrdinal("DataCreazione"));
                        doc.titolo = "Richiesta chiarimento " + rs.GetString(rs.GetOrdinal("Protocol")) + " del " + doc.Data + " sulla gara " + rs.GetString(rs.GetOrdinal("titolo")) + " - " + rs.GetString(rs.GetOrdinal("ProtocolloBando"));
                        doc.Oggetto = "";

                    }


                }
            }
            catch (Exception ex)
            {
                throw new Exception("Errore getDatiChiarimento - id =  " + doc.Id + " - " + ex.Message, ex);
            }


        }

        public void getDatiDoc(InfoDoc doc)
        {

            try
            {

                string strSql = @"select convert(varchar(10), case when DataInvio is null then Data else DataInvio end , 103 ) + ' ' +
                                convert(varchar(5), case when DataInvio is null then Data else DataInvio end , 108 ) as data1,
                                TipoDoc , isnull(Titolo,'') as titolo,isnull(body,'') as body
                                    from ctl_doc with (nolock)
                                      where id = " + doc.Id ;

                

                SqlCommand cmd1;
                SqlDataReader rs;

                cmd1 = new SqlCommand(strSql, sqlConn);
                using (rs = cmd1.ExecuteReader())
                {

                    if (rs.Read())
                    {
                        doc.TipoDoc  = rs.GetString(rs.GetOrdinal("TipoDoc"));
                        doc.Data = rs.GetString(rs.GetOrdinal("data1"));
                        doc.titolo  = rs.GetString(rs.GetOrdinal("titolo"));
                        doc.Oggetto  = rs.GetString(rs.GetOrdinal("body"));

                    }


                }
            }
            catch (Exception ex)
            {
                throw new Exception("Errore getDatiDoc - id =  " + doc.Id  + " - " + ex.Message, ex);
            }


        }


        private void gestioneErrore(string tab_id, string chiamante, string msgErrore, bool alertMail)
        {
            SqlConnection sqlConn1 = null;



            try
            {
                sqlConn1 = new SqlConnection(ConnectionString);
                sqlConn1.Open();
                settaEsito(true, tab_id);

                SqlCommand cmd1;
                SqlDataReader rs;
                DateTime dt;

                bool bFound = false;

                string strSql = "select data as data from v_protgen_dati with (nolock) where DZT_Name = 'ERRORE_PROTOCOLLO' and IdHeader = " + tab_id + " and Value = '" + msgErrore.Replace("'", "''") + "'";

                cmd1 = new SqlCommand(strSql, sqlConn1);
                using (rs = cmd1.ExecuteReader())
                {

                    if (rs.Read())
                    {
                        dt = rs.GetDateTime(rs.GetOrdinal("data"));
                        bFound = true;
                    }
                }

                if (bFound)
                {
                    strSql = "update v_protgen_dati set data=GETDATE() where DZT_Name = 'ERRORE_PROTOCOLLO' and IdHeader = " + tab_id + " and Value = '" + msgErrore.Replace("'", "''") + "'";
                    cmd1 = new SqlCommand(strSql, sqlConn1);
                    cmd1.ExecuteNonQuery();
                }
                else
                {
                    strSql = "INSERT INTO v_protgen_dati(IdHeader,DZT_Name,Value,data) VALUES ( " + tab_id + " ,'ERRORE_PROTOCOLLO', '" + msgErrore.Replace("'", "''") + "' ,getdate())";
                    cmd1 = new SqlCommand(strSql, sqlConn1);
                    cmd1.ExecuteNonQuery();
                }


                strSql = "IF exists(select value from v_protgen_dati with (nolock) where DZT_Name = 'NUMERO_TENTATIVI' and IdHeader = " + tab_id + ") ";
                strSql = strSql + "BEGIN";
                strSql = strSql + "	UPDATE v_protgen_dati";
                strSql = strSql + "		SET Value = cast( Value as int) + 1";
                strSql = strSql + "		WHERE DZT_Name = 'NUMERO_TENTATIVI' and idheader = " + tab_id;
                strSql = strSql + " END";
                strSql = strSql + " ELSE";
                strSql = strSql + " BEGIN";
                strSql = strSql + "	INSERT INTO v_protgen_dati(IdHeader,DZT_Name,Value) ";
                strSql = strSql + "		VALUES (" + tab_id + ",'NUMERO_TENTATIVI', '1')";
                strSql = strSql + " END";

                cmd1 = new SqlCommand(strSql, sqlConn1);
                cmd1.ExecuteNonQuery();


            }
            catch (Exception)
            {


            }
            finally
            {
                try
                {
                    if (sqlConn1 != null)
                        sqlConn1.Close();
                }
                catch (Exception)
                {

                }
            }


        }


        private void setVProtgenDato(string tab_id, string dztName, string valore)
        {
            SqlConnection sqlConn1 = null;

            int idrow=0;

            try
            {
                sqlConn1 = new SqlConnection(ConnectionString);
                sqlConn1.Open();                

                SqlCommand cmd1;
                SqlDataReader rs;
                DateTime dt;

                bool bFound = false;

                string strSql = "select idrow from v_protgen_dati with (nolock) where DZT_Name = '" + dztName + "' and IdHeader = " + tab_id ;

                cmd1 = new SqlCommand(strSql, sqlConn1);
                using (rs = cmd1.ExecuteReader())
                {

                    if (rs.Read())
                    {
                        idrow = rs.GetInt32(rs.GetOrdinal("idrow"));
                        bFound = true;
                    }
                }

                if (bFound)
                {
                    strSql = "update v_protgen_dati set value='" + valore.Replace("'", "''") + "' where idrow = " + idrow.ToString();                    
                    cmd1 = new SqlCommand(strSql, sqlConn1);
                    cmd1.ExecuteNonQuery();
                }
                else
                {
                    strSql = "INSERT INTO v_protgen_dati(IdHeader,DZT_Name,Value,data) VALUES ( " + tab_id + " ,'" + dztName + "', '" + valore.Replace("'", "''") + "' ,getdate())";
                    cmd1 = new SqlCommand(strSql, sqlConn1);
                    cmd1.ExecuteNonQuery();
                }

            }
            catch (Exception)
            {


            }
            finally
            {
                try
                {
                    if (sqlConn1 != null)
                        sqlConn1.Close();
                }
                catch (Exception)
                {

                }
            }


        }

        public string Trascodifica(string ValIn, string ValOut,bool bGet = false )
        {
            string strSql = "";
            string strSql2 = "";

            string strOut = "";

            //if (idDoc == null || idDoc == "")
            //    return "";

            //strSql = "select * from ctl_doc_value with (nolock) where dse_id = 'ESITO_PROT_GEN' and dzt_name = 'verifica_fascicolo' and idHeader = " + idDoc;
            try
            { 
                strSql = "select ValIn, valout from CTL_Transcodifica with (nolock) where dztNome = 'FascicoloProtocollo' and Sistema = 'ProtocolloPiTre' and  Plant='' and ValIn = '" + ValIn + "'";

                SqlCommand cmd1;
                SqlCommand cmd2;
                SqlDataReader rs;

                bool bFound = false;

                cmd1 = new SqlCommand(strSql, sqlConn);
                using (rs = cmd1.ExecuteReader())
                {

                    if (rs.Read())
                    {
                        bFound = true;
                        strOut=rs.GetString(rs.GetOrdinal("valout"));

                    }


                }

                if (bGet)
                    return strOut;

                if (bFound)
                {
                    strSql2 = "update CTL_Transcodifica set valout = '" + ValOut.Replace("'", "''") + "' where dztNome = 'FascicoloProtocollo' and Sistema = 'ProtocolloPiTre' and Plant='' and ValIn = '" + ValIn + "'";
                    cmd2 = new SqlCommand(strSql2, sqlConn);
                    cmd2.ExecuteNonQuery();

                }
                else
                {

                    strSql2 = "insert into CTL_Transcodifica ( dztNome, Sistema,Plant, ValIn, valout) values (  'FascicoloProtocollo', 'ProtocolloPiTre','', '" + ValIn.Replace("'", "''") + "','" + ValOut.Replace("'", "''") + "' )";
                    cmd2 = new SqlCommand(strSql2, sqlConn);
                    cmd2.ExecuteNonQuery();
                }

                return "";
            }
            catch (Exception)
            {
                return "";
            }

        }

        private void db_trace(string messaggio, string chiamante)
        {
            string strSql = "";
            SqlCommand cmd1;

            try
            {
                strSql = "INSERT INTO CTL_LOG_UTENTE" +
                    " (ip " +
                    ",idpfu " +
                    " ,datalog " +
                    " ,paginaDiArrivo " +
                    " ,paginaDiPartenza " +
                    " ,querystring " +
                    " ,form " +
                    " ,browserUsato) " +
                    " VALUES " +
                    " ('' " +
                    " ,''" +
                    " ,getDate()  " +
                    " ,'' " +
                    " ,'' " +
                    " ,'" + chiamante.Replace("'", "''") + "' " +
                    " ,'" + messaggio.Replace("'", "''") + "' " +
                    " ,'')";

                cmd1 = new SqlCommand(strSql, sqlConn);
                cmd1.ExecuteNonQuery();
            }
            catch (Exception)
            {

            }
        }

        private string getDateTec()
        {
            string data = "";

            data = DateTime.Now.Year.ToString();
            data = data + "-" + Right("00" + DateTime.Now.Month.ToString(), 2);
            data = data + "-" + Right("00" + DateTime.Now.Day.ToString(), 2);

            return data;
        }


        public static string Right(string input, int count)
        {
            return input.Substring(Math.Max(input.Length - count, 0), Math.Min(count, input.Length));
        }

        private bool SimulaChiamata()
        {
            bool esito=false;

            Simulazione = false;

            string PIVA_Ente = "00118410323";
            string cf = "04178170652";
            //string cf = "01369030669";

            string RagSoc = "AFSoluzioni SRL";

            string CodiceAnagrafica;
            string DescrizioneAnagrafica;
            string strCause;

            //AnagraficaDto lookupAzi;
            //esito = CheckAnag(PIVA_Ente, cf, RagSoc, out lookupAzi);

            if (esito)
            {
                //CodiceAnagrafica = cStr(lookupAzi.Id.CodiceAnagrafica);
                //DescrizioneAnagrafica = cStr(lookupAzi.Id.DescrizioneAnagrafica);
                strCause = "Esegue la variazione anagrafica del cf " + cf;
                //esito = UpdateAnag(PIVA_Ente, lookupAzi, RagSoc, cf, "04178170652", "Salerno", "Italia", "84100", "via Migliaro", "SA", "", "prova", "prova", "prova");
            }
            else
            {
                strCause = "Esegue inserimento anagragico di cf/RagSoc " + cf + "/" + RagSoc;
                esito = InsertAnag(PIVA_Ente, RagSoc, cf, "04178170652", "Salerno", "Italia", "84100", "via Migliaro", "SA", "", "prova", "prova", "prova", out CodiceAnagrafica, out DescrizioneAnagrafica);
            }

            //strCause = "CreaPratica";
            string pratica = "";
            esito = CreaPratica(PIVA_Ente, "Oggetto", "Note", out pratica);
            // elimina YYYY. iniziale
            //string[] array = pratica.Split('.');
            //if (array.Length == 2)
            //    pratica = array[1];

            string strIdFile;

            // ATTENZIONE IL NOME DI OGNI FILE DEVE ESSERE UNIVOCO!!!!!


            fileLIST.Add("C:\\temp\\test.pdf.p7m", "");
            fileLIST.Add("C:\\temp\\test.pdf", "");

            //foreach (var item in fileLIST)
            foreach (string key in fileLIST.Keys.ToList())
            {
                //esito = CaricaFile("00118410323", item.Key, out strIdFile);
                strCause = "Upload del file " + key;
                esito = CaricaFile(PIVA_Ente, key, out strIdFile);
                // nella chiave c'è il path del file e nel value l'ID ritornato da loro
                // il primo elemento è quello principale
                //fileLIST[item.Key] = strIdFile;
                fileLIST[key] = strIdFile;
            }

            //esito = CaricaFile("00118410323", strFilePath, out strIdFile);

            strCause = "CreaProtocollo";
            string Protocollo = "";
            
            //esito = CreaProtocollo(PIVA_Ente, CodiceAnagrafica, DescrizioneAnagrafica, "Oggetto documento", "Oggetto protocollo", pratica, fileLIST, out Protocollo);


            return esito;
        }


    }
}