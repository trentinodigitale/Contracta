using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.CommonModule.Exceptions;
using eProcurementNext.CtlProcess;
using eProcurementNext.Document.CtlDocument;
using eProcurementNext.HTML;
using Microsoft.AspNetCore.Http;
using Microsoft.VisualBasic;
using System.Data;
using System.Data.SqlClient;
using System.Xml;
using static eProcurementNext.CommonDB.Basic;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using static eProcurementNext.CommonModule.XmlUtil;
using static eProcurementNext.HTML.Basic;
using Caption = eProcurementNext.HTML.Caption;

namespace eProcurementNext.Document.CTLDOCOBJ
{
    /// <summary>
    /// questa classe descrive un documento
    /// un documento rappresenta un'insieme di informazioni correlate fra di loro o meglio dire sezioni
    /// ogni sezione rappresenta dei dati , il documento tiene insieme tutti questi dati
    /// ogni sezione è responsabile della propria porzione di dati sia in termini di salvataggio che di recupero dei dati
    /// </summary>
    public class Document
    {

        ////'-- paraqmetri di configurazione
        ////'-- SHOWCAPTION = YES indica che deve essere mostrata la caption sul documento
        ////'-- CUSTOM_CAPTION = nome colonna che contiene la chiave di ML sostitutiva di quella base
        public string Id;////'-- identificativo del documento come tipologia
        public string Caption;


        public string strTable;
        public string strFieldId;

        public Toolbar ObjToolbar;////'-- toolbar associata al documento

        public string strHelp;////'-- indirizzo della pagina di help

        private Dictionary<string, ISectionDocument> _Sections;
		
		public Dictionary<string, ISectionDocument> Sections ////'-- collezioni delle sezioni che compongono il documento
        {
            get { return _Sections; }
            set
            {
                var oldDictionary = value;
                var comparer = StringComparer.OrdinalIgnoreCase;
                if (value == null)
                {
                    _Sections = value;
                }
                else
                {
                    _Sections = new Dictionary<string, ISectionDocument>(oldDictionary, comparer);
                }
            }
        }

        public dynamic? ObjCustomizer = null;////'-- classe associata alla gestione del documento

        public string param; //' -- parametri per il documento

        public string mp_IDDoc;////'-- identificativo del documento sul database
        public string cryptoKey = string.Empty; //Chiave di cifratura, comune per tutte le sezioni e recuperata solo se almeno una delle sezioni richiede la cifratura dei dati in sessione

        private string mp_Permission;

        private string mp_Suffix;
        private string mp_User;
        private string mp_Num;

        private bool _ReadOnly;
        public bool ReadOnly = false; //'-- indica se il documento � in sola lettura, il default � false cio� si pu� scrivere

        private string mp_strConnectionString;

        private string Request_QueryString;

        public string Msg;////'-- contiene messaggi che il documento deve mostrare all'utente
        public string MsgCommand;////'-- contiene il comando che deve essere eseguito sul messaggio
        private string mp_setCurFolder;////'-- viene settata internamente per dirottare il folder corrente se avvalorato

        ////'-- Variabili per attivare il disegno di una sezione xml 'esterna' al documento stesso
        private string mp_key_template_xml;
        private string mp_view_xml;

        public string mp_accessible;
        private Session.ISession mp_ObjSession;
        public bool PrintMode; ////'-- se true indica che il documento � sato richiesto per la stampa. questo implica che i modelli al caricamento verranno richiesti in sola lettura per evitare filtri applicati

        private readonly EprocResponse _response;
        private readonly HttpContext _context;
        private readonly Session.ISession _session;

        public Document(HttpContext context, Session.ISession session, EprocResponse response)
        {
            this._context = context;
            this._session = session;
            _response = response;
        }

        ////'-- avvalora la collezione con i javascript necessari al corretto
        ////'-- funzionamento del controllo
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library/")
        {
            if (!JS.ContainsKey("document"))
            {
                JS.Add("document", @"<script src=""" + Path + @"jscript/document/document.js"" ></script>");
            }
            if (!JS.ContainsKey("setVisibility"))
            {
                JS.Add("setVisibility", @"<script src=""" + Path + @"jscript/setVisibility.js"" ></script>");
            }
            if (!JS.ContainsKey("ExecFunction"))
            {
                JS.Add("ExecFunction", @"<script src=""" + Path + @"jscript/ExecFunction.js"" ></script>");
            }

            if (ObjToolbar != null)
            {
                ObjToolbar.JScript(JS, Path);
            }

            if (ObjCustomizer != null)
            {
                ObjCustomizer.JScript(JS, Path);
            }

            ////'-- invoca su tutte le sezioni l'inizializzazione
            if (Sections != null)
            {

                foreach (KeyValuePair<string, ISectionDocument> objSec in Sections)
                {
                    objSec.Value.JScript(JS, Path);
                }

            }

            string strJS;
            strJS = GetParamURL(Request_QueryString.ToString(), "JScript");

            if (!string.IsNullOrEmpty(strJS))
            {
                if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), "PATHJScript")))
                {
                    if (!JS.ContainsKey(strJS))
                    {
                        JS.Add(strJS, @"<script src=""" + GetParamURL(Request_QueryString.ToString(), "PATHJScript") + "jsapp/" + strJS + @".js"" ></script>");
                    }
                }
                else
                {
                    if (!JS.ContainsKey(strJS))
                    {
                        JS.Add(strJS, @"<script src=""../../CustomDoc/jsapp/" + strJS + @".js"" ></script>");
                    }
                }
            }

        }

        /// <summary>
        /// Funzione per recuperare la chiave di cifratura del documento e settarla come variabile del documento stesso
        /// </summary>
        /// <param name="cnLocal">Connession SQL già aperta dal chiamante</param>
        /// <param name="tran">SQL Transaction associata alla connessione passata in input</param>
        /// <param name="idCtlDoc">ID tabellare della CTL_DOC sulla quale si basa il documento principale</param>
        /// <returns>La chiave di cifratura associata al documento</returns>
        public string setCryptoKey(SqlConnection? cnLocal = null, SqlTransaction? tran = null, int idCtlDoc = 0)
        {
            //Se la chiave non è stata già inizializzata la recuperiamo e la associamo al documento ( la cifratura è richiesta sulla seezione ma non cambia tra le varie sezioni )
            if (string.IsNullOrEmpty(this.cryptoKey))
            {
                this.cryptoKey = getDocumentCryptoKey(cnLocal, tran, idCtlDoc);
            }
            return this.cryptoKey;
        }

        /// <summary>
        /// Funzione per settare in modo forzato una chiave di cifratura scelta dal chiamante
        /// </summary>
        /// <param name="key">Chiave di cifratura che si vuole forzare</param>
        /// <returns>La chiave di cifratura associata al documento</returns>
        public string setCryptoKey(string key)
        {
            if (string.IsNullOrEmpty(this.cryptoKey))
            {
                this.cryptoKey = key;
            }
            return this.cryptoKey;
        }

        private string getDocumentCryptoKey(SqlConnection? cnLocal = null, SqlTransaction? tran = null, int idCtlDoc = 0)
        {
            /*
             *  - Ci sarà sempre bisogno della ctl_doc per recuperare la chiave di cifratura
             *  - Nel log chiamando la stored 'AFS_CRYPT_KEY_SESSION' inseriremo come traccia 'Richiesta Chiave Cifratura Sessione'
             */

            string ret = string.Empty;
            string strSQL = string.Empty;
            CommonDbFunctions cdf = new();

            if (!IsNumeric(mp_IDDoc))
            {
                //La cifratura si può applicare solo ad un documento già persistente sul DB, con un IDDOC già generato.
                return ret;
            }

            string localIdDoc = mp_IDDoc;

            //Se il documento non è imperniato sulla CTL_DOC la sezione cifrata chiamerà questo metodo passando anche l'iddoc della ctl_doc sula quale trovare poi la chiave di cifratura
            if (idCtlDoc > 0)
            {
                localIdDoc = CStr(idCtlDoc);
            }

            var sqlParams = new Dictionary<string, object?>
            {
                { "@IdPfu", CInt(mp_User) },
                { "@IdDoc", CInt(localIdDoc) },
            };

            strSQL = "Exec AFS_CRYPT_KEY_SESSION @IdPfu, @IdDoc";
            TSRecordSet rs = cdf.GetRSReadFromQuery_(strSQL, mp_strConnectionString, conn: cnLocal, parCollection: sqlParams, trans: tran);

            if (rs != null && rs.RecordCount > 0)
            {
                rs.MoveFirst();
                ret = CStr(rs["chiave"]);

                if (string.IsNullOrEmpty(ret))
                {
                    throw new DataEncryptionException("crypto key null or empty");
                }
            }
            else
            {
                throw new DataEncryptionException("crypto key not found");
            }

            return ret;
        }

        private void InitLocal(Session.ISession session)
        {

            Request_QueryString = GetQueryStringFromContext(_context.Request.QueryString);

            mp_strConnectionString = ApplicationCommon.Application.ConnectionString;

            mp_Suffix = CStr(session[Session.SessionProperty.SESSION_SUFFIX]);
            mp_User = CStr(session["IdPfu"]);
            mp_Permission = CStr(session["Funzionalita"]);
            mp_key_template_xml = GetParam(param, "XML_KEY_TEMPLATE");
            mp_view_xml = GetParam(param, "XML_VIEW");

            if (ObjCustomizer != null)
            {
                ObjCustomizer.InitLocal(session);
            }

            mp_accessible = CStr(ApplicationCommon.Application["ACCESSIBLE"]).ToUpper();

            mp_ObjSession = session;
        }

        public void Destroy()
        {

            Request_QueryString = null!;

            if (ObjCustomizer != null)
            {
                ObjCustomizer.objDocument = null;
                ObjCustomizer = null;
            }

            ////'-- rimuovo tutte le sezioni
            Sections = null!;
            ObjToolbar = null!;
        }


        /// <summary>
        /// restituisce la pagina HTML che rappresenta il documento
        /// </summary>
        /// <param name="objResp"></param>
        /// <param name="ObjSession"></param>
        /// <exception cref="Exception"></exception>
        public void Html(EprocResponse objResp, Session.ISession ObjSession)
        {

            string strCause = "";

            try
            {

                if (GetParam(param, "SHOWCAPTION") == "YES")
                {

                    Caption objCaption = new Caption();

                    objCaption.Init(ObjSession);
                    objCaption.strPath = "../images/Caption/";

                    objCaption.ShowExit = false;


                    objCaption.OnExit = "RemoveMessageFromMem();self.close();";

                    strCause = "Disegno la caption del documento";
                    if (IsMasterPageNew() && GetParamURL(Request_QueryString, "lo").ToLower() != "drawer")
                    {
                        objResp.Write(@"<div class=""pageTitle captionDocument"">");
                        objResp.Write(objCaption.SetCaption(ApplicationCommon.CNV(Caption, ObjSession), "", "", "", "CAPTION_DOCUMENT_ID"));
                        objResp.Write(@"</div>");
                    }
                    else
                    {
                        objResp.Write(objCaption.SetCaption(ApplicationCommon.CNV(Caption, ObjSession), "", "", "", "CAPTION_DOCUMENT_ID"));
                    }
                }


                ////'-- disegna la tollbar se presente
                if (ObjToolbar != null && GetParamURL(this.Request_QueryString, "lo").ToLower() != "drawer")
                {

                    strCause = "Disegno la toolbar del documento";

                    ObjToolbar.strPath = "../images/toolbar/";
                    ObjToolbar.mp_accessible = this.mp_accessible;
                    ObjToolbar.Html(objResp);

                }


                if (!ReadOnly)
                {

                    int k;
                    bool mostrato;
                    string strHelpObblig;
                    mostrato = false;

                    strHelpObblig = ApplicationCommon.CNV("i campi obbligatori sono indicati da label in grassetto", ObjSession);

                    if (!strHelpObblig.Contains("???", StringComparison.Ordinal))
                    {

                        ////'-- Se è presente la chiave di multilinguismo e nelle sezioni di tipo caption
                        ////'-- c'è almeno 1 campo obbligatorio
                        foreach (var objSec in Sections)
                        {

                            if (objSec.Value.TypeSection == "CAPTION")
                            {
                                for (k = 1; k <= objSec.Value.mp_Mod.Fields.Count; k++)
                                { //To objSec.mp_Mod.Fields.count
                                    if (objSec.Value.mp_Mod.Fields.ElementAt(k - 1).Value.Obbligatory)
                                    {
                                        objResp.Write(strHelpObblig);
                                        mostrato = true;
                                        break;
                                    }
                                }
                            }

                            if (mostrato)
                            {
                                break;
                            }

                        }

                    }

                }

                string strClass;
                strClass = GetParam(param, "CLASS");

                if (!string.IsNullOrEmpty(strClass))
                {
                    objResp.Write(@"<DIV  class=""" + strClass + @""" id=""ID_" + strClass + @""" >");
                }

                string strFolder;
                strFolder = GetParam(param, "FOLDER");


                ////'-- nel caso il documento sia suddiviso per folder
                if (!string.IsNullOrEmpty((strFolder.Trim())))
                {
                    ////'-- idfolder,caption,sez1[,sezn][~idfolder,caption,sez1[,sezn]]
                    ////'-- per idfolder = NOFOLDER vengono fuori dal folder
                    strCause = "Disegno le sezioni in folder";
                    ShowSecInFolder(strFolder, objResp, ObjSession);

                }
                else
                {

                    ////'-- disegna tutte le sezioni
                    if (Sections != null)
                    {

                        foreach (var objSec in Sections)
                        {

                            strCause = "Disegno la sezione " + objSec.Value.Id;
                            objSec.Value.Html(objResp, ObjSession);


                        }

                    }

                }
                ////'-- disegna il controllo custom se presente
                if (ObjCustomizer != null)
                {

                    ObjCustomizer.Html(objResp, ObjSession);

                }

                if (!string.IsNullOrEmpty(strClass))
                {
                    objResp.Write("</DIV>");
                }

                /// Disegno Toolbar in basso FaseII drawer
                 
                if (ObjToolbar != null && GetParamURL(this.Request_QueryString, "lo").ToLower() == "drawer")
                {
                    objResp.Write(@"<div id=""bottomButtonsContainer"">");
                    strCause = "Disegno la toolbar del documento";

                    ObjToolbar.strPath = "../images/toolbar/";
                    ObjToolbar.mp_accessible = this.mp_accessible;
                    ObjToolbar.Html(objResp);

                    objResp.Write(@"</div>");
                }


            }
            catch (Exception ex)
            {

                string save_err;
                save_err = ex.Message;

                TraceErr(ex, ApplicationCommon.Application.ConnectionString, "Document.html" + ":" + ex.Message + "-" + strCause);
                throw new Exception(strCause + " - ERR:" + save_err, ex);
            }

        }

        ////'-- esegue un comando sul documento
        public void Command(string strCommand, string param, dynamic form)
        {

            if (ObjCustomizer != null)
            {
                ObjCustomizer.Command(strCommand, param, form);
            }

        }

        ////'-- carico il documento
        public void Load(Session.ISession session, string idDoc)
        {

            mp_IDDoc = idDoc;

            InitLocal(session);

            ////'-- invoca su tutte le sezioni l'inizializzazione
            if (Sections != null)
            {
                #region Loading asincrono delle sezioni del documento (disabilitato)
                //se l'eccezione riguarda un errore di concorrenza dei tasks, attivo la modalità sincrona
                //try
                //{
                //	LoadAllSectionsAsync(Sections, session, idDoc).Wait();

                //}
                //catch (Exception ex)
                //{
                //	if (ex is AggregateException && ex.InnerException is InvalidOperationException)
                //	{
                //		foreach (var objSec in Sections)
                //		{
                //			objSec.Value.Load(session, idDoc);
                //		}
                //	}
                //	else
                //	{
                //		throw ex;
                //	}
                //}
                #endregion

                using SqlConnection sqlConn = new SqlConnection(mp_strConnectionString);
                sqlConn.Open();

                foreach (var objSec in Sections)
                {
                    objSec.Value.Load(session, idDoc, sqlConn);
                }

            }

            if (ObjCustomizer != null)
            {
                ObjCustomizer.Load(session, idDoc);
            }

            ////'-- Controlla la toolbar per eliminare i comandi non coerenti
            CheckToolbar();


        }

        async System.Threading.Tasks.Task LoadAllSectionsAsync(Dictionary<string, ISectionDocument> Sections, Session.ISession session, string idDoc)
        {
            List<Exception>? exList = new();
            var tasks = Sections.Select(async objSec =>
            {
                await LoadSection(objSec.Value, session, idDoc, exList);
            });
            await Task.WhenAll(tasks);
            //TODO migliorare codice: se una sezione va in eccezione devo fermare il WhenAll (e il caricamento delle altre sezioni)
            if (exList.Count != 0)
            {
                throw exList.First();
            }
        }

        async System.Threading.Tasks.Task LoadSection(ISectionDocument objSec, Session.ISession session, string idDoc, List<Exception> exList)
        {
            await Task.Run(() =>
            {
                try
                {
                    objSec.Load(session, idDoc);
                }
                catch (Exception ex)
                {
                    lock (exList)
                    {
                        exList.Add(ex);
                    }
                }
            });
        }

        ////'-- salvo il documento
        public bool Save(Session.ISession session)
        {
            bool boolToReturn;
            string strCause;

            if (ReadOnly)
            {
                //'Msg = cnv("Il documento � in sola lettura, non � possibile salvare", session)
                boolToReturn = false;
                return boolToReturn;

            }

            boolToReturn = true;

            SqlConnection conn = new SqlConnection();
            SqlTransaction trans;

            mp_strConnectionString = ApplicationCommon.Application.ConnectionString;

            CommonDbFunctions cdf = new CommonDbFunctions();
            conn = cdf.SetConnection(mp_strConnectionString);

            //'Apre connessione
            strCause = "Apre connessione";
            conn.Open();


            string ReferenceKey;////'-- identifica la chiave di collegamento fra i dati delle varie sessioni
            Dictionary<dynamic, dynamic> mpMEM = new Dictionary<dynamic, dynamic>();////'-- è un'area di memoria dove le varie sezioni possono collezionare dati utili alle altre sezioni

            ReferenceKey = mp_IDDoc;

            strCause = "begin transazione";
            trans = conn.BeginTransaction();

            try
            {

                if (ObjCustomizer != null)
                {
                    strCause = "Save ObjCustomizer";
                    boolToReturn = ObjCustomizer.Save(session, ReferenceKey, mpMEM, conn, trans);
                }

                if (boolToReturn)
                {
                    ////'-- invoca su tutte le sezioni l'inizializzazione
                    if (Sections != null)
                    {

                        foreach (var objSec in Sections)
                        {

                            strCause = "save sezione = " + objSec.Value.Id;
                            boolToReturn = objSec.Value.Save(session, ref ReferenceKey, mpMEM, conn, trans);
                            if (!boolToReturn)
                            {
                                break;
                            }

                        }

                    }
                }


                if (boolToReturn)
                {

                    ////'-- effettua la commit
                    strCause = "effettua la commit";
                    trans.Commit();

                    ////'-- rimuovo dalla memoria in sessione le aree di memoria delle sezzioni
                    strCause = "rimuovo dalla memoria in sessione le aree di memoria delle sezzioni";
                    RemoveMem(session);

                    mp_IDDoc = ReferenceKey;

                }
                else
                {

                    strCause = "Rollback Transazione";
                    trans.Rollback();

                }


                strCause = "Close connection";
                conn.Close();

                return boolToReturn;
            }
            catch (Exception ex)
            {

                boolToReturn = false;


                string DescError = ex.Message;
                string SSource = "";

                if (ex.Source != null)
                    SSource = ex.Source;



                ////'-- effettua il roolbak della transazione
                try
                {
                    trans.Rollback();
                }
                catch { }

                conn.Close();

                Msg = "Errore nel salvataggio : " + Environment.NewLine + DescError + " - " + strCause + " - " + SSource;

                TraceErr(ex, mp_strConnectionString, Msg);

                if (CStr(ApplicationCommon.Application["dettaglio-errori"]).ToLower() != "yes")
                {
                    Msg = ApplicationCommon.CNV("INFO_UTENTE_ERRORE_PROCESSO", session) + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
                }

                return boolToReturn;
            }
        }

        /// <summary>
        /// effettua l'inizializzazione del documento nuovo
        /// </summary>
        /// <param name="mp_ObjSession"></param>
        /// <param name="idDoc"></param>
        /// <exception cref="Exception"></exception>
        public void InitializeNew(Session.ISession mp_ObjSession, string idDoc)
        {

            string strCause = "";
            try
            {

                mp_IDDoc = idDoc;
                InitLocal(mp_ObjSession);

                ////'-- invoca su tutte le sezioni l'inizializzazione
                if (Sections != null)
                {


                    foreach (var objSec in Sections)
                    {
                        strCause = "initialize sezione=" + objSec.Value.Id;
                        objSec.Value.InitializeNew(mp_ObjSession, idDoc);
                    }

                }

                if (ObjCustomizer != null)
                {
                    strCause = "custom initialize";
                    ObjCustomizer.InitializeNew(mp_ObjSession);
                }

                ////'-- Controlla la toolbar per eliminare i comandi non coerenti
                strCause = "CheckToolbar";
                CheckToolbar();

            }
            catch (Exception ex)
            {
                string save_err;
                save_err = ex.Message;

                TraceErr(ex, ApplicationCommon.Application.ConnectionString, "InitializeNew()" + ":" + ex.Message + "-" + strCause);
                throw new Exception(strCause + " - " + save_err, ex);
            }
        }


        /// <summary>
        /// carico il documento
        /// </summary>
        /// <param name="session"></param>
        /// <param name="Request_Form"></param>
        public void UpdateContentInMem(Session.ISession session, IFormCollection? Request_Form)
        {
            if (ObjCustomizer != null)
            {
                ObjCustomizer.UpdateContentInMem(session);
            }


            ////'-- invoca su tutte le sezioni l'inizializzazione
            if (Sections != null)
            {
                foreach (var objSec in Sections)
                {
                    objSec.Value.UpdateContentInMem(session, Request_Form);
                }
            }
        }

        /// <summary>
        /// controlla se il documento puo' essere salvato
        /// nel caso sia presente un problema viene avvalorata la propiet� Msg del documeto
        /// che riporta il problema davisualizzare
        /// </summary>
        /// <param name="session"></param>
        /// <returns></returns>
        public bool CanSave(Session.ISession session)
        {
            bool boolToReturn;
            string strFolder;
            strFolder = GetParam(param, "FOLDER");
            string[] vetFolder;
            int cur;
            int count;
            string ListSec;
            string strDescBlocco;

            string[] paramFolder;
            string[] paramFolderCheck;
            //Dim obj As Object
            //Dim objSec As Object


            boolToReturn = true;

            if (ObjCustomizer != null)
            {
                boolToReturn = ObjCustomizer.CanSave(session);
            }

            if (boolToReturn)
            {

                ////'-- nel caso il documento sia suddiviso per folder
                if (!string.IsNullOrEmpty(strFolder.Trim()))
                {

                    vetFolder = Strings.Split(strFolder, "~");
                    cur = 1;
                    count = vetFolder.Length - 1;

                    //On Error Resume Next
                    int numFolder;

                    numFolder = 0;

                    int i;
                    int j;
                    int numF;

                    ////'-- Ciclo sui folder da controllare
                    for (i = 0; i <= count; i++)
                    {
                        ListSec = "";

                        paramFolderCheck = Strings.Split(vetFolder[i], ":");
                        paramFolder = Strings.Split(paramFolderCheck[0], ",");

                        numF = paramFolder.Length - 1;
                        strDescBlocco = "";


                        ////'-- verifica la presenza della sezione
                        for (j = 3; j <= numF; j++)
                        {
                            try
                            {
                                var _obj = Sections[paramFolder[j]];

                                boolToReturn = _obj.CanSave(session);
                                if (paramFolder[0] != "NOFOLDER" && !boolToReturn)
                                {
                                    mp_setCurFolder = paramFolder[0];
                                }
                                if (!boolToReturn)
                                {
                                    return boolToReturn;
                                }

                            }
                            catch { }

                        }



                    }


                }
                else
                {
                    ////'-- invoca su tutte le sezioni l'inizializzazione
                    if (Sections != null)
                    {

                        foreach (var objSec in Sections)
                        {
                            boolToReturn = objSec.Value.CanSave(session);

                            if (boolToReturn == false)
                            {
                                return boolToReturn;
                            }
                        }

                    }
                }
            }
            return boolToReturn;

        }

        ////'-- Controlla la toolbar per eliminare i comandi non coerenti
        private void CheckToolbar()
        {

            string strCause = "";
            try
            {

                TSRecordSet rs;
                string strSql;

                //Apriamo la connessione sql 1 sola volta per tutte le verifiche toolbar, con la using lasciamo la close alla dispose automatica
                using SqlConnection conn = new SqlConnection(mp_strConnectionString);
                conn.Open();

                string lstrSTORED;
                lstrSTORED = GetParam(param, "STORED");
                if (!string.IsNullOrEmpty(lstrSTORED))
                {

                    strSql = "Exec " + lstrSTORED + " '" + Id + " ' , '" + mp_IDDoc + "' , '" + mp_User + "'";

                }
                else
                {

                    if (Strings.Left(mp_IDDoc, 3).ToUpper() == "NEW")
                    {
                        strSql = "Select * from " + strTable + " where " + strFieldId + " = -1";
                    }
                    else
                    {
                        ////'-- carica il record del documento
                        strSql = "Select * from " + strTable + " where " + strFieldId + " = " + mp_IDDoc;
                    }
                }

                ////'-- recupera dal DB la vista per effettuare il controllo
                strCause = "recupera dal DB la vista per effettuare il controllo SQL=" + strSql;
                CommonDbFunctions cdf = new CommonDbFunctions();
                rs = cdf.GetRSReadFromQuery_(strSql, mp_strConnectionString);

                strCause = "Verifico le condizioni della toolbar del documento";

                ////'-- testo le condizioni della toolbar principale del documento
                verificaCondizioniToolbars(ObjToolbar, rs, prevConn: conn);

                ////'-- itero sulle sezioni del documento e su tutte le sezioni che hanno una toolbar
                ////'-- eseguo la verifica delle condizioni
                if (Sections != null)
                {
                    foreach (var objSec in Sections)
                    {
                        strCause = "Verifico le condizioni della toolbar della sezione " + objSec.Value.Id;
                        if (objSec.Value.ObjToolbar != null)
                        {
                            verificaCondizioniToolbars(objSec.Value.ObjToolbar, rs, prevConn: conn);
                        }

                    }

                }

            }
            catch (Exception ex)
            {

                string save_err;
                save_err = ex.Message;

                TraceErr(ex, ApplicationCommon.Application.ConnectionString, "CheckToolbar" + ":" + ex.Message + "-" + strCause);

                throw new Exception(strCause + " - ERR:" + save_err, ex);

            }
        }

        public void Excel(EprocResponse objResp, Session.ISession ObjSession)
        {

            //Dim objSec As Object

            string strFolder;
            strFolder = GetParam(param, "FOLDER");


            ////'-- nel caso il documento sia suddiviso per folder
            if (!string.IsNullOrEmpty(strFolder.Trim()))
            {
                ////'-- idfolder,caption,sez1[,sezn][~idfolder,caption,sez1[,sezn]]
                ////'-- per idfolder = NOFOLDER vengono fuori dal folder

                ExcelSecInFolder(strFolder, objResp, ObjSession);

            }
            else
            {

                ////'-- disegna tutte le sezioni
                if (Sections != null)
                {

                    foreach (var objSec in Sections)
                    {

                        objSec.Value.Excel(objResp, ObjSession);

                    }

                }
            }

        }

        public void RemoveMem(Session.ISession session)
        {
            if (Sections != null)
            {
                foreach (var objSec in Sections)
                {

                    objSec.Value.RemoveMem(session);
                }
            }
        }


        ////'-- effettua l'inizializzazione del documento nuovo
        public void InitializeFrom(Session.ISession mp_ObjSession, string param)
        {

            string strSql;
            string sqlFrom;
            string view;
            string strFrom;
            string idFrom;
            string[] v;
            string[] v2;
            string fieldCaption;
            TSRecordSet rs;

            ////'-- determina se cambiare la caption in funzione della provenienza
            sqlFrom = GetParam(this.param, "VIEW_FROM");
            fieldCaption = GetParam(param, "CUSTOM_CAPTION");
            if (!string.IsNullOrEmpty(sqlFrom) && !string.IsNullOrEmpty(fieldCaption))
            {

                v = Strings.Split(param, ",");
                strFrom = v[0];
                idFrom = v[1];
                idFrom = idFrom.Replace("<ID_USER>", mp_ObjSession[Session.SessionProperty.SESSION_USER]);

                ////'-- verifico se la vista di partenza � in verticale
                if (strFrom.Contains('~', StringComparison.Ordinal))
                {
                    v2 = Strings.Split(strFrom, "~");
                    strFrom = v2[0];
                }

                ////'-- prendo la vista dai parametri della sezione + la sorgente
                view = sqlFrom + "_" + strFrom;
                strSql = "Select * from " + view + " where  ID_FROM in(  " + idFrom + " )";

                ////'-- recupera dal DB la vista per effettuare il controllo
                CommonDbFunctions cdf = new CommonDbFunctions();
                rs = cdf.GetRSReadFromQuery_(strSql, mp_strConnectionString);

                if (rs != null && rs.RecordCount > 0 && rs.ColumnExists(fieldCaption))
                {
                    string strCaption = CStr(rs[fieldCaption]);
                    if (!string.IsNullOrEmpty(strCaption))
                    {
                        Caption = strCaption;
                    }

                }



            }

            ////'-- invoca su tutte le sezioni l'inizializzazione
            if (Sections != null)
            {

                foreach (var objSec in Sections)
                {
                    objSec.Value.InitializeFrom(mp_ObjSession, param);
                }

            }

            if (ObjCustomizer != null)
            {
                ObjCustomizer.InitializeFrom(mp_ObjSession, param);
            }

            ////'-- Controlla la toolbar per eliminare i comandi non coerenti
            CheckToolbar();

        }


        ////'-- strFolder � composto da
        //'-- idfolder,<cur>,caption,sez1[,sezn][~idfolder,caption,sez1[,sezn]]
        //'-- per idfolder = NOFOLDER vengono fuori dal folder

        private void ShowSecInFolder(string strFolder, EprocResponse objResp, Session.ISession ObjSession)
        {

            Folder objFolder = new Folder();
            ToolbarButton lab;
            int cur;
            int count;
            string[] vetFolder;
            string[] paramFolder;
            string[] paramFolderCheck;
            string[,] paramSec = new string[20, 20];
            Dictionary<string, string> collFolder = new Dictionary<string, string>();
            Dictionary<string, string> collFolderError = new Dictionary<string, string>();
            string ListSec;
            string[] ListSecNoFolder = new string[0];
            string strCurFolder = "";
            bool bNoFolder;
            bool ShowFolder;
            //Dim obj As Object
            string SetCaptionFolder = "";

            bNoFolder = false;

            vetFolder = Strings.Split(strFolder, "~");
            cur = 1;
            count = vetFolder.Length - 1;

            //On Error Resume }
            int numFolder;
            string ListFolder = "";

            numFolder = 0;

            int i;
            int j;
            int numF;
            string strDescBlocco;

            objFolder.Init(ObjSession);
            objFolder.strPath = "../../images/general/LabelTabDocument/";

            //'-- determino quanti folder disegnare
            for (i = 0; i <= count; i++)
            {
                ListSec = "";

                //'-- verifico la presenza di un controllo per l'apertura della sezione
                paramFolderCheck = Strings.Split(vetFolder[i], ":");

                paramFolder = Strings.Split(paramFolderCheck[0], ","); //' Split(vetFolder(i), ",")

                numF = paramFolder.Length - 1;

                if (paramFolder[0] == "NOFOLDER")
                {
                    ListSecNoFolder = paramFolder;
                    bNoFolder = true;
                }
                else
                {

                    //'-- verifica la presenza della sezione
                    for (j = 3; j <= numF; j++)
                    {

                        if (Sections.ContainsKey(paramFolder[j]))
                        {
                            ListSec = ListSec + "," + paramFolder[j];
                        }

                    }

                    SetCaptionFolder = "";

                    //'-- se esiste almeno una sezione disegno il folder
                    if (!string.IsNullOrEmpty(ListSec))
                    {

                        ShowFolder = true;

                        //'-- in caso di presenza di controllo verifico se posso visualizzare il folder
                        if ((paramFolderCheck.Length - 1) > 0)
                        {

                            //'-- effettuo il controllo per determinare se visualizzare la sezione o un messaggio
                            strDescBlocco = ChekAperturaSezione(paramFolder[0], paramFolderCheck[1], ObjSession);
                            string[] VetDesc;
                            VetDesc = Strings.Split(strDescBlocco, "~");

                            if (Strings.Left(strDescBlocco, 8) == "CAPTION:")
                            {
                                SetCaptionFolder = Strings.Mid(VetDesc[0], 9);

                                if ((VetDesc.Length - 1) > 0)
                                {
                                    strDescBlocco = VetDesc[1];
                                }
                                else
                                {
                                    strDescBlocco = "";
                                }
                            }

                            if (!string.IsNullOrEmpty(strDescBlocco))
                            {
                                if (strDescBlocco == "NON_VISIBILE")
                                {
                                    ShowFolder = false;
                                }
                                else
                                {
                                    collFolderError.Add(paramFolder[0], strDescBlocco);
                                }
                            }
                            else
                            {
                                collFolderError.Add(paramFolder[0], "");
                            }
                        }
                        else
                        {
                            collFolderError.Add(paramFolder[0], "");
                        }

                        if (ShowFolder)
                        {

                            //'-- in caso di presenza di controllo lo reintroduco nella lista degli oggetti
                            if ((paramFolderCheck.Length - 1) > 0)
                            {
                                ListSec = ListSec + ":" + paramFolderCheck[1];
                            }

                            collFolder.Add(paramFolder[0], paramFolder[0] + ListSec);

                            if (paramFolder[1] == "cur")
                            {
                                strCurFolder = paramFolder[0];
                            }

                            //'-- aggiunta label per folder
                            lab = new ToolbarButton();
                            lab.Id = paramFolder[0];
                            lab.Target = "self";
                            lab.paramTarget = "'FLD_" + paramFolder[0] + "' ";
                            if (!string.IsNullOrEmpty(SetCaptionFolder))
                            {
                                lab.Text = ApplicationCommon.CNV(SetCaptionFolder, ObjSession);
                            }
                            else
                            {
                                lab.Text = ApplicationCommon.CNV(paramFolder[2], ObjSession);
                            }
                            lab.OnClick = "DocShowFolder( 'FLD_" + paramFolder[0] + "' );tdoc";

                            objFolder.Buttons.Add(paramFolder[0], lab);

                            numFolder = numFolder + 1;
                            ListFolder = ListFolder + ",'FLD_" + paramFolder[0] + "'";

                        }
                    }
                }
            }

            //'-- sezioni fuori folder
            if (bNoFolder)
            {

                numF = ListSecNoFolder.Length - 1;

                for (j = 3; j <= numF; j++)
                {
                    if (Sections.ContainsKey(ListSecNoFolder[j]))
                    {
                        var _obj = Sections[ListSecNoFolder[j]];
                        _obj.Html(objResp, ObjSession);

                    }
                }

                //objResp.Flush

            }


            //'-- ciclo sui folder e per ogni folder inserisco una div
            for (i = 1; i <= objFolder.Buttons.Count; i++)
            {

                strDescBlocco = "";

                objResp.Write($@"<div id=""FLD_" + objFolder.Buttons.ElementAt(i - 1).Value.Id + @"""");


                objResp.Write($@" class=""display_none""");


                objResp.Write($@">" + Environment.NewLine);

                objFolder.LabelSelected = i;
                objFolder.indexFolder = "_" + CStr(i);
                objFolder.Html(objResp);

                //'-- disegno le sezioni del folder
                ListSec = collFolder[objFolder.Buttons.ElementAt(i - 1).Value.Id];

                //'-- verifico la presenza di un controllo per l'apertura della sezione
                paramFolderCheck = Strings.Split(ListSec, ":");
                if ((paramFolderCheck.Length - 1) > 0)
                {
                    ListSec = paramFolderCheck[0];

                    //'-- effettuo il controllo per determinare se visualizzare la sezione o un messaggio
                    strDescBlocco = collFolderError[objFolder.Buttons.ElementAt(i - 1).Value.Id];

                }

                if (string.IsNullOrEmpty(strDescBlocco))
                {

                    paramFolder = Strings.Split(ListSec, ",");

                    numF = paramFolder.Length - 1;

                    for (j = 1; j <= numF; j++)
                    {
                        if (Sections.ContainsKey(paramFolder[j]))
                        {
                            var obj = Sections[paramFolder[j]];
                            obj.Html(objResp, ObjSession);
                        }
                    }

                }
                else
                {

                    objResp.Write($@"<table class=""DOC_SECTION_ACCESS_DENIED"" width=""100%""><tr><td valign=""middle"" align=""center"">");
                    objResp.Write(strDescBlocco);
                    objResp.Write($@"</td></tr></table>" + Environment.NewLine);


                }


                objResp.Write($@"</div>" + Environment.NewLine);
                //objResp.Flush


            }

            //'-- recupera se presente il folder precedenetmente selezionato
            IFormCollection? Request_Form = _context.Request.HasFormContentType ? _context.Request.Form : null;
            //Set Request_Form = ObjSession(RequestForm)
            string strSecName = "";
            //'-- se nell'oggetto � stato chiesto di dirottare la visualizzazione su un folder preciso
            if (!string.IsNullOrEmpty(mp_setCurFolder))
            {
                strCurFolder = "FLD_" + mp_setCurFolder;
            }
            else
            {
                if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), "CUR_FLD_SELECTED_ON_DOC")))
                {
                    strCurFolder = GetParamURL(Request_QueryString.ToString(), "CUR_FLD_SELECTED_ON_DOC");
                }
                else
                {
                    if (!string.IsNullOrEmpty(GetValueFromForm(Request_Form, "CUR_FLD_SELECTED_ON_DOC")))
                    {
                        strCurFolder = GetValueFromForm(Request_Form, "CUR_FLD_SELECTED_ON_DOC");
                    }
                    else
                    {
                        //'-- nel caso in cui non � stato espresso un folder specifico si verifica se in precedenza si era posizionati su di un folder
                        //Dim sessionASP As Object


                        //Set sessionASP = ObjSession(5)
                        strSecName = "DOC_MEM_CUR_FOLDER_" + this.Id + "_" + this.mp_IDDoc;

                        if (!string.IsNullOrEmpty(CStr(_session[strSecName])))
                        {
                            strCurFolder = CStr(_session[strSecName]);
                        }
                        else
                        {
                            //'-- atrimenti si usa il default espresso in configurazione sul documento
                            strCurFolder = "FLD_" + strCurFolder;
                        }
                    }
                }
            }

            HTML_HiddenField(objResp, "CUR_FLD_SELECTED_ON_DOC", strCurFolder);

            objResp.Write($@"<script type=""text/javascript"">" + Environment.NewLine);
            objResp.Write($@"var vetFolder=[''" + ListFolder + "];" + Environment.NewLine);
            objResp.Write($@"var numFolder = " + numFolder + ";" + Environment.NewLine);
            objResp.Write($@"function tdoc(){{}};");
            objResp.Write($@"function DocShowFolder( sname ){{ " + Environment.NewLine);
            objResp.Write($@" var i;" + Environment.NewLine);
            objResp.Write($@" /* Se il folder che voglio aprire � presente nel DOM */ " + Environment.NewLine);
            objResp.Write($@" if ( getObj(sname) ) " + Environment.NewLine);
            objResp.Write($@" {{" + Environment.NewLine);
            objResp.Write($@"     for( i = 1 ; i <= numFolder ; i++ ){{ try{{ setVisibility( getObj( vetFolder[i] ) , 'none' ); }}catch(e){{}};}}" + Environment.NewLine);
            objResp.Write($@"     try{{ setVisibility( getObj( sname ) , '' ); }}catch(e){{}};" + Environment.NewLine);
            objResp.Write($@"     try{{  getObj( 'CUR_FLD_SELECTED_ON_DOC' ).value = sname; }}catch(e){{}};" + Environment.NewLine);
            objResp.Write($@"     var nocache = new Date().getTime();" + Environment.NewLine);
            objResp.Write($@"     try{{  ajax = GetXMLHttpRequest(); if(ajax){{ ajax.open('GET', 'DocumentCurFolder.asp?DOCUMENT=" + strSecName + $@"&nocache=' + nocache + '&FOLDER=' + escape( sname  ) , true); ajax.send(null); }}}}catch(e){{}};" + Environment.NewLine);
            objResp.Write($@" }}" + Environment.NewLine);
            objResp.Write($@" else " + Environment.NewLine);
            objResp.Write($@" {{ " + Environment.NewLine);
            objResp.Write($@"     // In assenza di un folder sul quale portarci vado sul primo " + Environment.NewLine);
            objResp.Write($@"     DocShowFolder( vetFolder[1] );" + Environment.NewLine);
            objResp.Write($@" }} " + Environment.NewLine);
            objResp.Write($@"}}" + Environment.NewLine);
            objResp.Write($@"DocShowFolder( '" + strCurFolder + "' );" + Environment.NewLine);
            objResp.Write($@"</script>");

        }


        //'-- restituisce la pagina HTML che rappresenta il documento
        public void ToPrint(EprocResponse objResp, Session.ISession ObjSession)
        {

            //Dim objSec As Object

            if (GetParam(param, "SHOWCAPTION") == "YES")
            {
                Caption objCaption = new Caption();
                objResp.Write($@"<link rel=stylesheet href=""../Themes/caption.css"" type=""text/css""/>");

                objCaption.Init(ObjSession);
                objCaption.strPath = "../images/Caption/";

                objCaption.PrintMode = true;

                objResp.Write(objCaption.SetCaption(ApplicationCommon.CNV(Caption, ObjSession)));

                //Set objCaption = Nothing
            }

            //'-- disegna la tollbar se richiesto esplicitamente
            if (GetParamURL(Request_QueryString.ToString(), "SHOWTOOLBAR") == "YES")
            {
                if (ObjToolbar != null)
                {

                    ObjToolbar.strPath = "../images/toolbar/";
                    ObjToolbar.Html(objResp);

                }
            }

            string strFolder;
            strFolder = GetParam(param, "FOLDER");


            //'-- nel caso il documento sia suddiviso per folder
            if (!string.IsNullOrEmpty(strFolder.Trim()))
            {
                //'-- idfolder,caption,sez1[,sezn][~idfolder,caption,sez1[,sezn]]
                //'-- per idfolder = NOFOLDER vengono fuori dal folder


                PrintSecInFolder(strFolder, objResp, ObjSession);




            }
            else
            {

                //'-- disegna tutte le sezioni
                if (Sections != null)
                {

                    foreach (var objSec in Sections)
                    {

                        //'--se una sezione non si deve stampare nn la disegno
                        if (Strings.InStr(1, "," + UCase(GetParamURL(Request_QueryString.ToString(), "NO_SECTION_PRINT")) + ",", "," + objSec.Value.Id.ToUpper() + ",") <= 0)
                        {

                            objSec.Value.ToPrint(objResp, ObjSession);

                            //objResp.Flush

                        }

                    }

                }

            }

        }



        private void PrintSecInFolder(string strFolder, EprocResponse objResp, Session.ISession ObjSession)
        {

            Folder objFolder = new Folder();
            ToolbarButton lab = new ToolbarButton();
            int cur;
            int count;
            string[] vetFolder;
            string[] paramFolder;
            string[] paramFolderCheck;
            string[,] paramSec = new string[20, 20];
            Dictionary<string, string> collFolder = new Dictionary<string, string>();
            string ListSec;
            string[] ListSecNoFolder = new string[0];
            string strCurFolder;
            bool bNoFolder;
            bNoFolder = false;
            vetFolder = Strings.Split(strFolder, "~");
            //Dim obj As Object
            cur = 1;
            count = vetFolder.Length - 1;
            //On Error Resume Next
            int numFolder;
            string ListFolder = "";
            numFolder = 0;
            int i;
            int j;
            int numF;
            string strDescBlocco;
            string SetCaptionFolder;

            Dictionary<string, string> collFolderError = new Dictionary<string, string>();
            bool ShowFolder;

            objFolder.Init(ObjSession);
            objFolder.strPath = "../../images/general/LabelTabDocument/";

            //'-- determino quanti folder disegnare
            for (i = 0; i <= count; i++)
            {
                ListSec = "";

                //'-- verifico la presenza di un controllo per l'apertura della sezione
                paramFolderCheck = Strings.Split(vetFolder[i], ":");

                paramFolder = Strings.Split(paramFolderCheck[0], ",");

                numF = paramFolder.Length - 1;

                if (paramFolder[0] == "NOFOLDER")
                {
                    ListSecNoFolder = paramFolder;
                    bNoFolder = true;
                }
                else
                {

                    SetCaptionFolder = "";

                    //'-- verifica la presenza della sezione
                    for (j = 3; j <= numF; j++)
                    {
                        try
                        {
                            var _obj = Sections[paramFolder[j]];
                            ListSec = ListSec + "," + paramFolder[j];
                        }
                        catch
                        {

                        }
                    }

                    //'-- se esiste almeno una sezione disegno il folder
                    if (!string.IsNullOrEmpty(ListSec))
                    {


                        ShowFolder = true;

                        //'-- in caso di presenza di controllo verifico se posso visualizzare il folder
                        if ((paramFolderCheck.Length - 1) > 0)
                        {

                            //'-- effettuo il controllo per determinare se visualizzare la sezione o un messaggio
                            strDescBlocco = ChekAperturaSezione(paramFolder[0], paramFolderCheck[1], ObjSession);
                            string[] VetDesc;
                            VetDesc = Strings.Split(strDescBlocco, "~");

                            if (Strings.Left(strDescBlocco, 8) == "CAPTION:")
                            {
                                SetCaptionFolder = Strings.Mid(VetDesc[0], 9);

                                if ((VetDesc.Length - 1) > 0)
                                {
                                    strDescBlocco = VetDesc[1];
                                }
                                else
                                {
                                    strDescBlocco = "";
                                }
                            }

                            if (!string.IsNullOrEmpty(strDescBlocco))
                            {
                                if (strDescBlocco == "NON_VISIBILE")
                                {
                                    ShowFolder = false;
                                }
                                else
                                {
                                    collFolderError.Add(paramFolder[0], strDescBlocco);
                                }
                            }
                            else
                            {
                                collFolderError.Add(paramFolder[0], "");
                            }
                        }
                        else
                        {
                            collFolderError.Add(paramFolder[0], "");
                        }

                        if (ShowFolder == true)
                        {

                            //'-- in caso di presenza di controllo lo reintroduco nella lista degli oggetti
                            if ((paramFolderCheck.Length - 1) > 0)
                            {
                                ListSec = ListSec + ":" + paramFolderCheck[1];
                            }

                            collFolder.Add(paramFolder[0], paramFolder[0] + ListSec);

                            if (paramFolder[1] == "cur")
                            {
                                strCurFolder = paramFolder[0];
                            }

                            //'-- aggiunta label per folder
                            lab = new ToolbarButton();
                            lab.Id = paramFolder[0];
                            lab.Target = "self";
                            //'lab.paramTarget = "'FLD_" & paramFolder(0) & "' "
                            if (!string.IsNullOrEmpty(SetCaptionFolder))
                            {
                                lab.Text = ApplicationCommon.CNV(SetCaptionFolder, ObjSession);
                            }
                            else
                            {
                                lab.Text = ApplicationCommon.CNV(paramFolder[2], ObjSession);
                            }
                            //'lab.OnClick = "DocShowFolder( 'FLD_" & paramFolder(0) & "' );tdoc"
                            objFolder.Buttons.Add(paramFolder[0], lab);

                            numFolder = numFolder + 1;
                            ListFolder = ListFolder + ",'FLD_" + paramFolder[0] + "'";

                        }
                    }
                }
            }

            //'-- sezioni fuori folder
            if (bNoFolder)
            {

                numF = (ListSecNoFolder.Length - 1);

                for (j = 3; j <= numF; j++)
                {
                    try
                    {
                        var _obj = Sections[ListSecNoFolder[j]];
                        _obj.ToPrint(objResp, ObjSession);
                    }
                    catch { }

                }

                //objResp.Flush


            }

            //'-- ciclo sui folder e per ogni folder inserisco una div
            for (i = 1; i <= objFolder.Buttons.Count; i++)
            {

                strDescBlocco = "";

                objResp.Write($@"<div id=""FLD_" + objFolder.Buttons.ElementAt(i - 1).Value.Id + @""">" + Environment.NewLine);
                objFolder.LabelSelected = i;

                objFolder.PrintMode = true;

                objFolder.Html(objResp);

                //'-- disegno le sezioni del folder
                ListSec = collFolder[objFolder.Buttons.ElementAt(i - 1).Value.Id];

                //'-- verifico la presenza di un controllo per l'apertura della sezione
                paramFolderCheck = Strings.Split(ListSec, ":");
                if ((paramFolderCheck.Length - 1) > 0)
                {
                    ListSec = paramFolderCheck[0];

                    //'-- effettuo il controllo per determinare se visualizzare la sezione o un messaggio
                    strDescBlocco = collFolderError[objFolder.Buttons.ElementAt(i - 1).Value.Id];
                }

                if (string.IsNullOrEmpty(strDescBlocco))
                {
                    paramFolder = Strings.Split(ListSec, ",");

                    numF = (paramFolder.Length - 1);

                    for (j = 1; j <= numF; j++)
                    {
                        try
                        {

                            var _obj = Sections[paramFolder[j]];
                            //'--se una sezione non si deve stampare nn la disegno
                            if (Strings.InStr(1, "," + GetParamURL(Request_QueryString.ToString(), "NO_SECTION_PRINT").ToUpper() + ",", "," + _obj.Id.ToUpper() + ",") <= 0)
                            {
                                _obj.ToPrint(objResp, ObjSession);
                            }
                        }
                        catch { }
                    }
                }
                else
                {
                    objResp.Write($@"<table class=""PRN_DOC_SECTION_ACCESS_DENIED"" width=""100%""><tr><td valign=""middle"" align=""center"">");
                    objResp.Write(strDescBlocco);
                    objResp.Write($@"</td></tr></table>" + Environment.NewLine);
                }
                objResp.Write($@"</div>" + Environment.NewLine);
                //objResp.Flush
            }
        }

        public void xml(EprocResponse objResp)
        {
            openXmlDocument(Id, mp_Suffix, objResp);

            //'-- crea l'xml di tutte le sezioni
            if (Sections != null)
            {
                foreach (var objSec in Sections)
                {
                    objSec.Value.xml(objResp);
                }
            }

            //'-- Se � stato passato il parametro XML_KEY_TEMPLATE
            //'-- attivo il meccanismo di disegno di una sezione xml aggiuntiva
            //'-- per il recupero di dati non presenti in modo diretto nel documento
            if (!string.IsNullOrEmpty(Trim(mp_key_template_xml)))
            {
                string strSql;
                TSRecordSet rs;
                string templateXml;

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@mp_key_template_xml", mp_key_template_xml);
                strSql = "select dbo.CNV_ESTESA( ML_Description ,'I') as ML_Description from lib_multilinguismo where ML_KEY = @mp_key_template_xml";

                CommonDbFunctions cdf = new CommonDbFunctions();
                rs = cdf.GetRSReadFromQuery_(strSql, mp_strConnectionString, sqlParams);

                if (rs.RecordCount > 0)
                {
                    rs.MoveFirst();
                    templateXml = CStr(rs["ML_Description"]);

                    sqlParams.Clear();
                    sqlParams.Add("@mp_IDDoc", CInt(mp_IDDoc));
                    strSql = "select * from " + Replace(mp_view_xml, " ", "") + " where iddoc = @mp_IDDoc";
                    rs = cdf.GetRSReadFromQuery_(strSql, mp_strConnectionString, sqlParams);

                    if (rs.RecordCount > 0)
                    {
                        rs.MoveFirst();

                        objResp.Write(elabTemplate(templateXml, rs, objResp, mp_strConnectionString));
                    }
                }
            }

            //'-- disegna il controllo custom se presente
            if (ObjCustomizer != null)
            {
                //On Error Resume Next
                try
                {
                    ObjCustomizer.xml(objResp);
                }
                catch
                {

                }

                //On Error GoTo 0
            }


            closeXmlDocument(Id, objResp);

            //'--rilascio memoria�
            //Set objSec = Nothing


            //Exit Sub


        }


        //'-- effettuo il controllo per determinare se visualizzare la sezione o un messaggio  
        private string? ChekAperturaSezione(string FOLDER, string SQL_STORED, Session.ISession ObjSession)
        {

            string stringToReturn = string.Empty;

            string strSql;
            TSRecordSet rs;
            string Blocco = string.Empty;

            string strOutputMessage = string.Empty;

            var sqlParams = new Dictionary<string, object?>();

            try
            {
                sqlParams.Add("@FOLDER", FOLDER);
                sqlParams.Add("@mp_IDDoc", mp_IDDoc);
                sqlParams.Add("@mp_User", mp_User);
                strSql = "exec " + SQL_STORED + " @FOLDER, @mp_IDDoc, @mp_User";

                CommonDbFunctions cdf = new CommonDbFunctions();
                rs = cdf.GetRSReadFromQuery_(strSql, mp_strConnectionString, sqlParams);

                if (rs.RecordCount > 0)
                {
                    rs.MoveFirst();
                    Blocco = CStr(rs["Blocco"]);
                }
            }
            catch
            {
                return stringToReturn;
            }


            stringToReturn = Blocco;

            if (!string.IsNullOrEmpty(Blocco) && Blocco != "NON_VISIBILE")
            {

                string[] v;
                v = Strings.Split(Blocco, "~");

                strOutputMessage = Blocco;

                if (Strings.Left(UCase(Blocco), 8) == "CAPTION:")
                {

                    strOutputMessage = "";

                    //'--recupero testo soggetto a ML oppure NO
                    if ((v.Length - 1) > 0)
                    {
                        strOutputMessage = v[1];
                    }

                }

                //'--se testo diverso da vuoto ed � richiesto non applico multilinguismo
                if (!string.IsNullOrEmpty(strOutputMessage))
                {

                    if (Strings.Left(strOutputMessage.ToUpper(), 6) != "NO_ML:")
                    {
                        strOutputMessage = ApplicationCommon.CNV(strOutputMessage, ObjSession);
                    }
                    else
                    {
                        strOutputMessage = Strings.Mid(strOutputMessage, 7);
                    }

                }

                if (Strings.Left(Blocco.ToUpper(), 8) == "CAPTION:")
                {
                    stringToReturn = v[0] + "~" + strOutputMessage;
                }
                else
                {
                    stringToReturn = strOutputMessage;
                }

            }

            return stringToReturn;

        }

        private void ExcelSecInFolder(string strFolder, EprocResponse objResp, Session.ISession ObjSession)
        {

            string SetCaptionFolder;
            Folder objFolder = new Folder();
            ToolbarButton lab = new ToolbarButton();
            int cur;
            int count;
            string[] vetFolder;
            string[] paramFolder;
            string[] paramFolderCheck;
            string[,] paramSec = new string[20, 20];
            Dictionary<string, string> collFolder = new Dictionary<string, string>();
            string ListSec;
            string[] ListSecNoFolder = new string[0];
            string strCurFolder;
            bool bNoFolder;

            bNoFolder = false;
            vetFolder = Strings.Split(strFolder, "~");

            //Dim obj As Object
            cur = 1;
            count = (vetFolder.Length - 1);

            //On Error Resume Next
            int numFolder;
            string ListFolder = "";
            numFolder = 0;

            int i;
            int j;
            int numF;
            string strDescBlocco;

            objFolder.Init(ObjSession);
            objFolder.strPath = "../../images/general/LabelTabDocument/";

            //'-- determino quanti folder disegnare
            for (i = 0; i <= count; i++)
            {
                ListSec = "";

                //'-- verifico la presenza di un controllo per l'apertura della sezione
                paramFolderCheck = Strings.Split(vetFolder[i], ":");

                paramFolder = Strings.Split(paramFolderCheck[0], ",");

                numF = paramFolder.Length - 1;

                if (paramFolder[0] == "NOFOLDER")
                {
                    ListSecNoFolder = paramFolder;
                    bNoFolder = true;
                }
                else
                {
                    //'-- verifica la presenza della sezione
                    for (j = 3; j <= numF; j++)
                    {
                        if (Sections.ContainsKey(paramFolder[j]))
                            ListSec = ListSec + "," + paramFolder[j];
                    }

                    //'-- se esiste almeno una sezione disegno il folder
                    if (!string.IsNullOrEmpty(ListSec))
                    {

                        //'-- in caso di presenza di controllo lo reintroduco nella lista degli oggetti
                        if ((paramFolderCheck.Length - 1) > 0)
                        {
                            ListSec = ListSec + ":" + paramFolderCheck[1];
                        }

                        collFolder.Add(paramFolder[0], paramFolder[0] + ListSec);

                        if (paramFolder[1] == "cur")
                        {
                            strCurFolder = paramFolder[0];
                        }

                        //'-- aggiunta label per folder
                        lab = new ToolbarButton();
                        lab.Id = paramFolder[0];
                        lab.Target = "self";
                        //'lab.paramTarget = "'FLD_" & paramFolder(0) & "' "
                        lab.Text = ApplicationCommon.CNV(paramFolder[2], ObjSession);
                        //'lab.OnClick = "DocShowFolder( 'FLD_" & paramFolder(0) & "' );tdoc"
                        objFolder.Buttons.Add(paramFolder[0], lab);

                        numFolder = numFolder + 1;
                        ListFolder = ListFolder + ",'FLD_" + paramFolder[0] + "'";
                    }
                }
            }

            //'-- sezioni fuori folder
            if (bNoFolder)
            {

                numF = ListSecNoFolder.Length - 1;

                for (j = 3; j <= numF; j++)
                {
                    try
                    {
                        var _obj = Sections[ListSecNoFolder[j]];
                        _obj.Excel(objResp, ObjSession);
                    }
                    catch { }

                }

                //objResp.Flush

            }

            //'-- ciclo sui folder e per ogni folder inserisco una div
            for (i = 1; i <= objFolder.Buttons.Count; i++)
            {

                strDescBlocco = "";
                SetCaptionFolder = "";

                //'-- disegno le sezioni del folder
                ListSec = collFolder[objFolder.Buttons.ElementAt(i - 1).Value.Id];

                //'-- verifico la presenza di un controllo per l'apertura della sezione
                paramFolderCheck = Strings.Split(ListSec, ":");
                if ((paramFolderCheck.Length - 1) > 0)
                {
                    ListSec = paramFolderCheck[0];

                    //'-- effettuo il controllo per determinare se visualizzare la sezione o un messaggio
                    strDescBlocco = ChekAperturaSezione(objFolder.Buttons.ElementAt(i - 1).Value.Id, CStr(paramFolderCheck[1]), ObjSession);

                }

                string[] VetDesc;
                VetDesc = Strings.Split(strDescBlocco, "~");

                if (Strings.Left(strDescBlocco, 8) == "CAPTION:")
                {
                    SetCaptionFolder = Strings.Mid(VetDesc[0], 9);

                    if ((VetDesc.Length - 1) > 0)
                    {
                        strDescBlocco = VetDesc[1];
                    }
                    else
                    {
                        strDescBlocco = "";
                    }
                }

                if (string.IsNullOrEmpty(strDescBlocco))
                {

                    if (!string.IsNullOrEmpty(SetCaptionFolder))
                    {
                        objResp.Write($@"<div class=""EXCEL_DOC_SECTION""  ><b>" + ApplicationCommon.CNV(SetCaptionFolder, ObjSession) + "</b></div>" + Environment.NewLine);
                    }
                    else
                    {
                        objResp.Write($@"<div class=""EXCEL_DOC_SECTION""  ><b>" + objFolder.Buttons.ElementAt(i - 1).Value.Text + "</b></div>" + Environment.NewLine);
                    }

                }

                objFolder.LabelSelected = i;

                //'-- disegno le sezioni del folder
                //'ListSec = collFolder(objFolder.Buttons(i).Id)


                if (string.IsNullOrEmpty(strDescBlocco))
                {

                    paramFolder = Strings.Split(ListSec, ",");


                    numF = paramFolder.Length - 1;

                    for (j = 1; j <= numF; j++)
                    {
                        try
                        {
                            var _obj = Sections[paramFolder[j]];
                            _obj.Excel(objResp, ObjSession);

                        }
                        catch
                        {

                        }


                    }

                }
                else
                {
                    if (strDescBlocco != "NON_VISIBILE")
                    {
                        objResp.Write($@"<table class=""EXCEL_DOC_SECTION_ACCESS_DENIED"" ><tr><td valign=""middle"" align=""center"">");
                        objResp.Write(strDescBlocco);
                        objResp.Write($@"</td></tr></table>" + Environment.NewLine);
                    }

                }


                //objResp.Flush


            }


        }

        //'-- response
        //'-- vettore di sessione
        //'-- params: stringa/queryString contenente : (Se params non viene passato non si attiver� la gestione con footer e header)
        //'--         * Numero di righe per pagina            / ROWS_FOR_PAGE
        //'--         * Chiave di multilinguismo per footer   / KEY_ML_FOOTER_PRINT
        //'--         * Chiave di multilinguismo per l'header / KEY_ML_HEADER_PRINT
        //'--         * Totale pagine di stampa               / TOT_PAGINE
        //'-- startPage       : Numero della pagina da cui partire con la numerazione per la stampa degli allegati
        //'-- strHtmlHeader   : Html che andr� come testata ( vince rispetto alla chiave passata in params )
        //'-- strHtmlFooter   : Html che andr� come footer ( vince rispetto alla chiave passata in params )
        //'-- contaPagine     : Se true il giro di stamper� servir� solo per incrementare il parametro 'startPage' cos� da far sapere al
        //'--                   al chiamante quante sarenno le pagine totali e quindi passare un TOT page corretto dell'header e/o nel footer - es: 1 di 20

        public void toPrintExtraContent(EprocResponse response, Session.ISession ObjSession, string _params = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {

            //'-- Stampo eventuali allegati in coda alla pagina di stampa

            //Dim objSec As Object

            if (Sections != null)
            {

                //'-- Controllo se ci sono domini multivalore con valori al loro interno
                string TempstartPage;
                TempstartPage = "0";

                foreach (var objSec in Sections)
                {

                    objSec.Value.toPrintExtraContent(response, ObjSession, _params, TempstartPage, "", "", true);

                }

                //'-- Se c'� almeno 1 elemento multivalore contenente dei dati
                if (TempstartPage != 0.ToString())
                {

                    if (string.IsNullOrEmpty(_params))
                    {
                        response.Write("<hr/>");
                        response.Write("<center><h2>" + HtmlEncode(ApplicationCommon.CNV("Allegati_stampa", ObjSession)) + "</h2></center>");
                    }

                }

                foreach (var objSec in Sections)
                {

                    objSec.Value.toPrintExtraContent(response, ObjSession, _params, startPage, strHtmlHeader, strHtmlFooter, contaPagine);

                }

            }

            //'--rilascio memoria
            //Set objSec = Nothing

        }

        public void verificaCondizioniToolbars(Toolbar toolbar, TSRecordSet rs, SqlConnection? prevConn = null)
        {

            string strCause = "";
            try
            {

                bool isNew;
                string strCon;
                int n;
                int j;

                if (Strings.Left(mp_IDDoc, 3).ToUpper() == "NEW")
                {
                    isNew = true;
                }
                else
                {
                    isNew = false;
                }


                //'-- determina la necessità di cambiare la caption di default con una versione specializzata
                string fieldCaption;
                fieldCaption = GetParam(param, "CUSTOM_CAPTION");
                if (!string.IsNullOrEmpty(fieldCaption) && rs != null)
                {
                    if (rs.RecordCount > 0)
                    {
                        //'-- se la caption è presente e non è null
                        if (rs[fieldCaption] is not null)
                        {
                            object valCaption = rs[fieldCaption];
                            if (valCaption is string && !string.IsNullOrEmpty((string?)valCaption))
                            {
                                Caption = (string)rs[fieldCaption];
                            }
                        }
                    }
                }

                n = toolbar.Buttons.Count;

                j = 1;
                while (j <= n)
                {

                    strCon = toolbar.Buttons.ElementAt(j - 1).Value.Condition;

                    if (!string.IsNullOrEmpty(strCon.Trim()))
                    {
                        //Normalizzo la condizione per sostituire il TAB con lo spazio. avevamo delle condizioni in errore per la presenza di 1 tab al posto dello spazio
                        strCon = strCon.Replace("\t", " ");
                        strCon = $" {strCon} ";

                        //'-- sostituisco le condizioni basi
                        strCon = strCon.Replace(" IsNew() ", IIF(isNew, " 'true' ", " 'false' "));
                        strCon = strCon.Replace(" IsReadOnly() ", IIF(ReadOnly, " 'true' ", " 'false' "));
                        strCon = strCon.Replace(" IdUser() ", " '" + CStr(mp_User) + "' ");
                        strCon = strCon.Replace(" IdAzi() ", " '" + CStr(_session["IDAZI"]) + "' ");
                        strCon = strCon.Replace(" IsSingleWin() ", " 'true' ");

                        //'-- sostituisco la funzione UserFunz( x ) per verificare se l'utente ha UN PERMESSO
                        strCon = ReplacePermissionUser(strCon);

                        if (rs.Columns is not null)
                        {
                            //'--sostituisce i valori dei campi sulla condizione
                            for (int i = 0; i < rs.Columns.Count; i++)
                            {

                                if (isNew)
                                {
                                    strCon = ReplaceInsensitive(strCon, $" {rs.Columns[i].ColumnName} ", " '' ");
                                }
                                else
                                {
                                    strCon = ReplaceInsensitive(strCon, $" {rs.Columns[i].ColumnName} ", @" '" + Strings.Replace(Strings.Replace((rs.Fields == null || IsNull(rs.Fields[i]) ? "" : CStr(rs.Fields[i])), "'", "$"), @"""", "$") + "' ");
                                }
                            }
                        }

                        strCon = strCon.Replace(@"#", @"=");
                        strCon = strCon.Replace(@"'", @"""");

                        //codice aggiunto fix eProcNext
                        strCon.Replace(@"=", @"==");

                        strCause = "eval condizione=" + strCon;

                        string[] vetCon;
                        vetCon = Strings.Split(strCon, "~~~");

                        bool? eval1 = (!string.IsNullOrEmpty(vetCon[0])) ? BasicDocument.Eval(vetCon[0], prevConn) : null;
                        bool? eval2 = ((vetCon.Length - 1) > 0) ? BasicDocument.Eval(vetCon[1], prevConn) : null;

                        //'-- la prima condizione determina l'abilitazione
                        toolbar.Buttons.ElementAt(j - 1).Value.Enabled = true;
                        if (!string.IsNullOrEmpty(vetCon[0]))
                        {
                            if (eval1 == false)
                            {
                                toolbar.Buttons.ElementAt(j - 1).Value.Enabled = false;
                            }
                        }

                        //'-- la seconda nasconde il bottone
                        if ((vetCon.Length - 1) > 0)
                        {
                            if (eval2 == false)
                            {
                                string keyOfIndex = toolbar.Buttons.ElementAt(j - 1).Key;
                                toolbar.Buttons.Remove(keyOfIndex);
                                j--;
                                n--;
                            }
                        }

                    }

                    j++;

                }

            }
            catch (Exception ex)
            {
                string save_err = ex.Message;

                TraceErr(ex, ApplicationCommon.Application.ConnectionString, "verificaCondizioniToolbars" + " - " + save_err + "-" + strCause);
                throw new Exception(strCause + " - " + save_err, ex);
            }

        }

        private string ReplacePermissionUser(String strCond)
        {
            int i;
            string Valore;
            string Attivo;
            string sostituire;
            int e;

            i = Strings.InStr(strCond, " UserFunz(");
            while (i > 0)
            {

                e = Strings.InStr(i + 10, strCond, ")");

                Valore = Strings.Mid(strCond, i + 10, e - (i + 10));

                Attivo = Strings.Mid(mp_Permission, CInt(Valore), 1);

                sostituire = Strings.Mid(strCond, i, e - i + 1);

                //'-- se attivo � vuoto perch� mi trovo fuori sessione e non ho la stringa dei permessi
                //'-- per non farlo andare in errore lo faccio diventare 0
                strCond = Replace(strCond, sostituire, " " + IIF(string.IsNullOrEmpty(Attivo), "0", Attivo) + " ");

                i = Strings.InStr(strCond, " UserFunz(");
            }

            return strCond;
        }

        //'-- Parametri :
        //'--         - templ = Template stile template mail
        //'--         - objDocument   = recordset
        public static string elabTemplate(string templ, TSRecordSet objDocument, dynamic ScopeLayer, string connectionString)
        {
            CommonDbFunctions cdf = new();
            //On Error Resume Next
            long l;
            long i;
            long j;
            string[] ss;
            string c;
            bool b;
            Dictionary<string, string> Coll = new Dictionary<string, string>();
            string Value;
            string template;

            template = templ;

            TSRecordSet rs;

            string strTipo;
            string strField;
            string strItem;
            dynamic Valore;
            //Dim x As Variant

            l = template.Length;
            b = false;
            j = 0;

            for (i = 1; i <= l; i++)
            {

                //' legge il carattere i-esimo
                c = Strings.Mid(template, (int)i, 1);

                if (c == "#")
                {
                    if (!b)
                    {
                        b = true;
                        j = i;
                    }
                    else
                    {
                        b = false;
                        strItem = Strings.Mid(template, (int)j + 1, (int)i - (int)j - 1);
                        //On Error Resume Next
                        if (!Coll.ContainsKey(strItem))
                        {
                            Coll.Add(strItem, strItem);
                        }
                        //err.Clear
                        //On Error GoTo 0
                    }
                }

            }

            //' -- STEP 2: scorre la collezione dei campi da calcolare e poi li rimpiazza nell'espressione con il valore
            foreach (var x in Coll)
            {

                ss = Strings.Split(x.Value, ".");
                strTipo = ss[0].ToUpper();
                strField = ss[1];

                switch (strTipo)
                {

                    case "DOCUMENT":

                        Valore = "";

                        if (cdf.FieldExistsInRS(objDocument, strField))
                        {
                            Valore = GetValueFromRS(objDocument.Fields[strField]);
                        }

                        if (IsNull(Valore))
                        {
                            Valore = "";
                        }

                        template = Replace(template, CStr("#" + x.Value + "#"), CStr(Valore));
                        break;

                    case "ML":

                        var sqlParams = new Dictionary<string, object?>();
                        sqlParams.Add("@strField", strField);
                        string strSql = "select dbo.CNV_ESTESA( ML_Description ,'I') as ML_Description from LIB_Multilinguismo where ML_KEY = @strField and ML_LNG = 'I'";

                        rs = cdf.GetRSReadFromQuery_(strSql, connectionString, sqlParams);

                        Value = string.Empty;

                        if (!(rs.EOF && rs.BOF))
                        {
                            rs.MoveFirst();
                            Value = CStr(rs["ML_Description"]);
                        }

                        if (string.IsNullOrEmpty(Value))
                        {
                            Value = $"???{strField}???";
                        }

                        template = Replace(template, $"#{CStr(x.Value)}#", Value);

                        break;
                    default:

                        Valore = "";

                        if (cdf.FieldExistsInRS(objDocument, strField))
                        {
                            if (!IsNull(GetValueFromRS(objDocument.Fields[strField])))
                            {
                                Valore = GetValueFromRS(objDocument.Fields[strField]);
                            }
                        }

                        template = Replace(template, CStr("#" + CStr(x.Value) + "#"), CStr(Valore));
                        break;
                }
            }

            return template;
        }
    }
}

namespace eProcurementNext.Document.CTLDOC
{
    public class Document
    {
        private Session.ISession mp_ObjSession;//'-- oggetto che contiene il vettore base con gli elementi della libreria
        public string mp_idDoc;//'-- identificativo del documento sul DB
        public string mp_TypeDoc;//'-- nome del tipo documento
        private string mp_strcause;
        private string mp_Permission;
        private string mp_Attrib;
        private string mp_suffix;
        private string mp_Filter;
        private long mp_User;
        private string mp_Num;
        private string mp_Mode;
        private string mp_queryString;
        private string mp_Command;
        private string mp_Param;
        private string mp_StrMsg;
        private string mp_strConnectionString;
        private CTLDOCOBJ.Document? mp_ObjHtml;
        private string mp_UpDateParent;
        private string Request_QueryString;
        private IFormCollection? Request_Form;
        private int mp_ICONMSG; //As TypeMSGIcon
        private Session.ISession mp_Session;//' oggetto che punta alla sessione ASP
        private bool mp_bPassatoXSave;
        private bool mp_save;//'-- inidica che lo stato del  salvataggio
        private string mp_ActionMSG;//'-- azioneda eseguire su ok del messaggio
        private string mp_accessible;
        private string mp_afterProcess;

        private readonly EprocResponse _response;
        private readonly HttpContext _context;
        private readonly Session.ISession _session;

        public Document(HttpContext context, Session.ISession session, EprocResponse response)
        {
            this._context = context;
            this._session = session;
            _response = response;

            mp_UpDateParent = "yes";
            mp_StrMsg = "Informazione";
            mp_ICONMSG = MSG_INFO;
            mp_afterProcess = "";
        }


        /// <summary>
        /// Metodo di avvio del documento
        /// </summary>
        /// <param name="session"></param>
        /// <param name="response"></param>
        /// <returns></returns>
        /// <exception cref="Exception"></exception>

        public string run(Session.ISession session, EprocResponse response)
        {

            try
            {
                //ottimizzazione per le performance: per tutta la durata della request non si salveranno i dati sulla collection mongo, ma solo alla fine.
                //  aggiorna i dati nell'oggetto session ma non salva per ogni settaggio, si aspetta una richiesta esplicita di salvataggio chiamando il metodo save()
                session.AutoSave = false;

                //'-- recupero variabili di sessione
                mp_strcause = "recupero variabili di sessione";
                InitLocal(session);

                if (mp_Mode != "NEW" && mp_Mode != "OPEN" && mp_Mode != "CREATEFROM")
                {

                    //'-- recupera il documento da visualizzare
                    mp_strcause = "recupera il documento da visualizzare";
                    //MongoLog mongoLog = new();
                    //long startInitGUIObject = DateTime.Now.Ticks;
                    InitGUIObject();
                    //long endInitGUIObject = DateTime.Now.Ticks;
                    //mongoLog.Insert("InitGUIObject document", startInitGUIObject, endInitGUIObject);

                    //'-- esegue i comandi
                    mp_strcause = "esegue i comandi";
                    ExecuteCommand();
                }
                else
                {

                    //'-- in questi casi se siste sul documento la memoria la devo liberare
                    mp_strcause = "in questi casi se siste sul documento la memoria la devo liberare";
                    DOC_FreeSectionMem(session, mp_TypeDoc, mp_idDoc);

                }

                //'--se richiesto non disegna l'output
                //'--NOTA BENE : da gestire correttamente per evitare outpu sui comandi delle sezioni
                if (GetParamURL(Request_QueryString.ToString(), "OUTPUT") != "NO")
                {

                    //'-- disegna il documento
                    mp_strcause = "disegna il documento";
                    Draw(response);

                }

                //'-- Libera il documento dalla memoria
                if (mp_ObjHtml != null)
                {
                    mp_strcause = "Libera il documento dalla memoria";
                    mp_ObjHtml.Destroy();
                    mp_ObjHtml = null;
                }

                return mp_idDoc;
            }
            catch (Exception ex)
            {
                throw new Exception($"CTLDOC.Document.Run() - STRCAUSE=:[{mp_strcause}] - Ex.Message:{ex.Message}", ex);
            }
            finally
            {
                session.AutoSave = true;
                session.Save();
            }
        }

        private void InitLocal(Session.ISession session)
        {

            string strP;

            mp_ICONMSG = MSG_INFO;

            mp_ObjSession = session;

            Request_QueryString = GetQueryStringFromContext(_context.Request.QueryString);
            Request_Form = _context.Request.HasFormContentType ? _context.Request.Form : null;


            mp_strConnectionString = ApplicationCommon.Application.ConnectionString;
            mp_suffix = session[Session.SessionProperty.SESSION_SUFFIX];
            mp_User = CLng(session["IdPfu"]);
            mp_Permission = CStr(session["Funzionalita"]);
            mp_Session = session;

            mp_Mode = GetParamURL(Request_QueryString.ToString(), "MODE");
            mp_Command = GetParamURL(Request_QueryString.ToString(), "COMMAND");
            mp_Param = GetParamURL(Request_QueryString.ToString(), "PARAM");
            mp_TypeDoc = GetParamURL(Request_QueryString.ToString(), "DOCUMENT");

            //'-- recupera l'identificativo del documento
            if (mp_Mode == "NEW")
            {
                ;
            }
            else
            {

                mp_idDoc = GetParamURL(Request_QueryString.ToString(), "IDDOC");
                //' odiros 23 agosto 2021
                if (string.IsNullOrEmpty(mp_idDoc))
                {
                    mp_idDoc = GetParamURL(CStr(Request_QueryString), "IDDOC");
                }

            }

            if (string.IsNullOrEmpty(mp_idDoc))
            {
                mp_idDoc = DOC_GetNewID(mp_Session);
            }

            string SingleWin;
            bool bUpdateParent = true;

            SingleWin = CStr(ApplicationCommon.Application["SINGLEWIN"]).ToUpper();

            if (string.IsNullOrEmpty(SingleWin))
            {
                //Se la variabile non c'è testa quella vecchia dell'accessibilità
                bUpdateParent = false;
            }
            else
            {

                //' se c'è usa la variabile SINGLEWIN
                if (SingleWin == "NO")
                {
                    bUpdateParent = true;
                }
                else
                {
                    bUpdateParent = false;
                }

            }


            //'--Se sono in accessibilità non permetto il reload del parent
            if (bUpdateParent)
            {

                if (!IsEmpty(GetParamURL(Request_QueryString.ToString(), "UpdateParent")))
                {
                    mp_UpDateParent = GetParamURL(Request_QueryString.ToString(), "UpdateParent");
                }

            }
            else
            {

                mp_UpDateParent = "NO";

            }

            mp_queryString = CStr(Request_QueryString);


            //'-- tolgo comandi e modalita' per evitare che si ripresentino
            strP = GetParamURL(Request_QueryString.ToString(), "PROCESS_PARAM");
            mp_queryString = mp_queryString.Replace("&PROCESS_PARAM=" + strP, "");
            mp_queryString = mp_queryString.Replace("PROCESS_PARAM=" + strP, "");
            mp_queryString = mp_queryString.Replace("&MODE=" + mp_Mode, "");
            mp_queryString = mp_queryString.Replace("MODE=" + mp_Mode, "");
            mp_queryString = mp_queryString.Replace("&COMMAND=" + mp_Command, "");
            mp_queryString = mp_queryString.Replace("COMMAND=" + mp_Command, "");
            mp_queryString = mp_queryString.Replace("&PARAM=" + mp_Param, "");
            mp_queryString = mp_queryString.Replace("PARAM=" + mp_Param, "");
            mp_queryString = mp_queryString.Replace("&IDDOC=" + mp_idDoc, "");
            mp_queryString = mp_queryString.Replace("IDDOC=" + mp_idDoc, "");


            string strCUR_FLD_SELECTED_ON_DOC;
            strCUR_FLD_SELECTED_ON_DOC = GetParamURL(Request_QueryString.ToString(), "CUR_FLD_SELECTED_ON_DOC");
            mp_queryString = mp_queryString.Replace("&CUR_FLD_SELECTED_ON_DOC=" + strCUR_FLD_SELECTED_ON_DOC, "");
            mp_queryString = mp_queryString.Replace("CUR_FLD_SELECTED_ON_DOC=" + strCUR_FLD_SELECTED_ON_DOC, "");
            mp_queryString = mp_queryString.Replace("&SHOWSAVEOBBLIG=YES", "");



            strP = GetParamURL(Request_QueryString.ToString(), "PROCESS");
            mp_queryString = mp_queryString.Replace("&PROCESS=" + strP, "");
            mp_queryString = mp_queryString.Replace("PROCESS=" + strP, "");

            mp_queryString = mp_queryString + "&IDDOC=" + mp_idDoc;

            //'-- se il primo carattere � & lo tolgo
            if (Strings.Left(mp_queryString, 1) == "&")
            {
                mp_queryString = Strings.Mid(mp_queryString, 2);
            }

            mp_accessible = CStr(ApplicationCommon.Application["ACCESSIBLE"]).ToUpper();

        }

        //'-- effettuo il disegno del documento
        public void Draw_Layout(EprocResponse response)
        {

            try
            {

                Dictionary<string, string> JS = new Dictionary<string, string>();
                //Dim objSec As Object


                if (mp_Mode == "REMOVE_FROM_MEM")
                {

                    if (mp_ObjHtml != null)
                    {

                        mp_ObjHtml.RemoveMem(mp_ObjSession);
                        mp_ObjHtml.Destroy();

                        mp_ObjHtml = null;

                    }

                    return;
                }



                if (mp_Mode == "SHOW" && (string.IsNullOrEmpty(mp_Command) || mp_Command == "PROCESS" || mp_Command == "SAVE" || mp_Command == "RELOAD" || mp_Command == "CANSAVE"))
                {

                    Form form = new Form();
                    //'-- disegna il documento
                    ActiveExtendedAttrib Ext = new ActiveExtendedAttrib();


                    //'--aggiungo iframe per esporta excel
                    response.Write($@"<div ");


                    response.Write($@"class=""display_none"">");


                    response.Write(HTML_iframe("ExcelDocument", "../loading.html"));
                    response.Write($@"</div>");

                    //'-- nel caso si debba visualizzare un messaggio si inserisce lo script
                    if (!string.IsNullOrEmpty(mp_ObjHtml.Msg))
                    {

                        //'-- disegna il messaggio over
                        if (ApplicationCommon.Application["SHOW_OVER_MSG"] != "no")
                        {
                            HTML_OverMessagebox(response, "OVER_MSG", mp_ObjHtml.Msg, ApplicationCommon.CNV(mp_StrMsg, mp_ObjSession), CInt(mp_ICONMSG), 10, 70, true);
                        }

                        //'-- il messaggio esce se non ho chiesto di non visualizzarlo o non � una INFO
                        if (((ApplicationCommon.Application["SHOW_MSG_INFO"] == "yes" || GetParamURL(Request_QueryString.ToString(), "SHOW_MSG_INFO") == "yes") && LCase(GetParam(mp_ObjHtml.param, "SHOW_MSG")) != "no") || mp_ICONMSG != MSG_INFO)
                        {
                            if (IsMasterPageNew() && mp_ICONMSG == 1 && mp_ActionMSG == null)
                            {
                                _session["toastMSG"] = "ML=YES&MSG=" + URLEncode(mp_ObjHtml.Msg) + "&CAPTION=" + URLEncode(ApplicationCommon.CNV(mp_StrMsg, mp_ObjSession)) + "&ICO=" + mp_ICONMSG;
                            }
                            else
                            {
                                response.Write(ShowMessageBoxModale(mp_ObjHtml.Msg, ApplicationCommon.CNV(mp_StrMsg, mp_ObjSession), "../", mp_ICONMSG, mp_ActionMSG)); //'Iif ((mp_StrMsg = "Errore", MSG_ERR, MSG_INFO))
                            }



                        }

                    }

                    //'--aggiungo configurazione del documento come rafforzativo per non effettuare aggiornamento dell'opener
                    if (mp_UpDateParent == "yes" && GetParam(mp_ObjHtml.param, "UPDATEPARENT").ToLower() != "no" && !string.IsNullOrEmpty(mp_Command))
                    {

                        response.Write($@"<script type=""text/javascript"" >try{{ parent.opener.RefreshContent();}} catch( e ) {{" + Environment.NewLine);
                        response.Write($@"try{{ parent.opener.document.location = parent.opener.document.location;}} catch( e ) {{}}; }};</script>" + Environment.NewLine);

                    }

                    //'-- inserisco la query string per utilizzarla su eventuali comandi
                    HTML_HiddenField(response, "CommandQueryString", mp_queryString);
                    HTML_HiddenField(response, "IDDOC", mp_idDoc);
                    HTML_HiddenField(response, "TYPEDOC", mp_TypeDoc);
                    HTML_HiddenField(response, "PATHAPPLICATION", mp_Session["PATHAPPLICATION"]);
                    HTML_HiddenField(response, "SUFFIX_LANGUAGE", mp_suffix);


                    form.id = "FORMDOCUMENT";
                    form.Action = "document.asp";
                    response.Write(form.OpenForm());
                    //'Response.Write "<form method=""post"" enctype="""" action=""""  id=""FORMDOCUMENT"" onsubmit=""return false"">"

                    //'-- PREVENZIONE ATTACCHI "CROSS SITE REQUEST FORGERY" --
                    if (CStr(mp_Session["TS_NomeCampoToken"]) != "")
                    {
                        HTML_HiddenField(response, CStr(mp_Session["TS_NomeCampoToken"]), CStr(mp_Session["TS_ValoreCampoToken"]));
                    }


                    //'-- disegno il contenuto del documento
                    mp_ObjHtml.Html(response, mp_ObjSession);

                    if (!string.IsNullOrEmpty(mp_afterProcess))
                    {

                        //'-- A processo eseguito, se � andato tutto bene, chiamo la funzione javascript
                        //'-- afterProcess(), che se presente sul javascript specifico del documento, permetter�
                        //'-- l'esecuzione di codice client subito dopo l'esecuzione di un processo
                        //'-- ( come ad esempio il ricarico di un documento che non � il corrente )
                        response.Write($@"<script type=""text/javascript"">" + Environment.NewLine);
                        response.Write($@"try {{" + Environment.NewLine);
                        response.Write($@"afterProcess('" + EncodeJSValue(mp_afterProcess) + "');" + Environment.NewLine);
                        response.Write($@"}}catch(e){{}}" + Environment.NewLine);
                        response.Write($@"</script>" + Environment.NewLine);

                    }


                    response.Write(form.CloseForm());

                    //'-- riporta sul client lo stato del documento
                    HTML_HiddenField(response, "DOCUMENT_READONLY", IIF(mp_ObjHtml.ReadOnly, "1", "0"));



                    //'--inserisco il frame per i comandi
                    response.Write(HTML_iframe(mp_TypeDoc + "_Command_" + mp_idDoc, "../loading.html", 0, @" style=""display:none"" "));

                    Ext.Html(response);


                }
                else
                {

                    //'-- se la modalit� non � di visualizzazione allora si crea la pagina che serve alla visualizzazione

                    //'-- se � stato invocato un comando
                    if (mp_Mode == "SHOW" && !string.IsNullOrEmpty(mp_Command))
                    {


                        //'-- nel caso si debba visualizzare un messaggio si inserisce lo script
                        if (!string.IsNullOrEmpty(mp_ObjHtml.Msg))
                        {



                            response.Write(ShowMessageBoxModale(mp_ObjHtml.Msg, ApplicationCommon.CNV(mp_StrMsg, mp_ObjSession), "../", mp_ICONMSG)); //'Iif ((mp_StrMsg = "Errore", MSG_ERR, MSG_INFO))



                            //'if ( mp_Command = "PROCESS" ) {
                            //'-- si invoca il refresch del documento
                            response.Write($@"<script type=""text/javascript"" >" + Environment.NewLine);

                            //'--aggiungo configurazione del documento come rafforzativo per non effettuare aggiornamento dell'opener
                            if (mp_UpDateParent == "yes" && LCase(GetParam(mp_ObjHtml.param, "UPDATEPARENT")) != "no")
                            {
                                //'Response.Write "try{ parent.opener.document.location = parent.opener.document.location;} catch( e ) {};" + Environment.NewLine
                                response.Write($@"try{{ parent.opener.RefreshContent();}} catch( e ) {{" + Environment.NewLine);
                                response.Write($@"try{{ parent.opener.document.location = parent.opener.document.location;}} catch( e ) {{}}; }};" + Environment.NewLine);
                            }

                            //'response.Write($@"parent.location = 'document.asp?MODE=SHOW&" & mp_queryString & "';" + Environment.NewLine
                            if (mp_bPassatoXSave && !mp_save)
                            { //' -- con errore
                                response.Write($@"parent.RefreshPage('MODE=SHOW&SHOWSAVEOBBLIG=YES&" + mp_queryString + "');" + Environment.NewLine);
                            }
                            else if (mp_Command != "PROCESS")
                            {
                                response.Write($@"parent.RefreshPage('MODE=SHOW&" + mp_queryString + "');" + Environment.NewLine);
                            }
                            else
                            {
                                response.Write($@"parent.location = 'document.asp?MODE=SHOW&" + mp_queryString + "';" + Environment.NewLine);
                            }
                            response.Write($@"</script>" + Environment.NewLine);
                            //'}


                        }
                        else
                        {

                            //'-- se il comando è su una sezione si aggiorna solo la sezione
                            if (mp_Command.Contains('.', StringComparison.Ordinal))
                            {

                                string[] v;

                                v = Strings.Split(mp_Command, ".");
                                if (v[0] == "CUSTOMSECTION")
                                {
                                    response.Write(JavaScript(JS));
                                }
                                else
                                {
                                    //'-- altrimenti invoca il comando sulla sezione
                                    mp_ObjHtml.Sections[v[0]].JScript(JS, "../");
                                    response.Write(JavaScript(JS));
                                    try
                                    {
                                        mp_ObjHtml.Sections[v[0]].Command(mp_ObjSession, response);
                                    }
                                    catch (Exception ex)
                                    {

                                        throw new Exception($"Errore chiamata command sulla sezione {v[0]}", ex);
                                    }

                                }

                            }
                            else
                            {

                                response.Write($@"<script type=""text/javascript"" >" + Environment.NewLine);

                                //'-- altrimenti si invoca il refresch del documento
                                //'-- insieme ar refresh del chiamante per aggiornarne la lista
                                //'--aggiungo configurazione del documento come rafforzativo per non effettuare aggiornamento dell'opener
                                if (LCase(GetParam(mp_ObjHtml.param, "UPDATEPARENT")) != "no")
                                {

                                    response.Write($@"try{{ parent.opener.RefreshContent();}} catch( e ) {{" + Environment.NewLine);
                                    response.Write($@"try{{ parent.opener.document.location = parent.opener.document.location;}} catch( e ) {{}}; }};" + Environment.NewLine);

                                }

                                //'Response.Write "try{ parent.opener.document.location = parent.opener.document.location;} catch( e ) {};" + Environment.NewLine
                                response.Write($@"parent.location = 'document.asp?MODE=SHOW&" + mp_queryString + "';" + Environment.NewLine);
                                //'response.Write($@"parent.RefreshPage('');" + Environment.NewLine
                                response.Write($@"</script>" + Environment.NewLine);

                            }
                        }
                    }
                    else
                    {
                        if (IsMasterPageNew())
                        {
                            response.Write($@"<table class=""loaderDocumentFaseII"" width=""100%"" ");

                        }
                        else
                        {
                            response.Write($@"<table width=""100%"" ");
                        }


                        response.Write($@">");


                        response.Write($@"<tr><td width=""100%"" height=""100%"" align=""center"" valign=""center"" >");
                        if (IsMasterPageNew())
                        {
                            response.Write($@"
                                <div class=""INFO_BOX_TB noWidth noHeight noPosition fa-3x"">
                                  <i class=""fas fa-circle-notch fa-spin""></i>
                                </div>
                            ");
                        }
                        else
                        {
                            HTML_SinteticHelp(response, ApplicationCommon.CNV("Loading document...", mp_ObjSession), "clessidra.gif", "", "../images/grid/");

                        }
                        response.Write($@"</td></tr></table>");

                        HTML_HiddenField(response, "IDMSG", "DOC_" + mp_TypeDoc + "_" + mp_idDoc);

                        response.Write($@"<script type=""text/javascript"" >" + Environment.NewLine);

                        string strCUR_FLD_SELECTED_ON_DOC;
                        strCUR_FLD_SELECTED_ON_DOC = GetParamURL(Request_QueryString.ToString(), "CUR_FLD_SELECTED_ON_DOC");
                        if (!string.IsNullOrEmpty(strCUR_FLD_SELECTED_ON_DOC))
                        {
                            strCUR_FLD_SELECTED_ON_DOC = "&CUR_FLD_SELECTED_ON_DOC=" + strCUR_FLD_SELECTED_ON_DOC;
                        }

                        response.Write($@"document.location = 'document.asp?MODE=SHOW&" + mp_queryString + IIF(mp_Mode.ToUpper() == "CREATEFROM", "&PARAM=" + HtmlEncode(mp_Param), "") + strCUR_FLD_SELECTED_ON_DOC + "'; ");

                        //'response.Write($@"debugger;" + Environment.NewLine
                        response.Write($@"</script>" + Environment.NewLine);

                        //'            }
                    }
                }

                //Set JS = Nothing
                //Exit Function

            }
            catch (Exception ex)
            {

                //Set JS = Nothing
                //Dim n As Long
                //Dim d As String
                //Dim s As String

                //n = err.Number
                //d = err.Description
                //s = err.Source
                throw new Exception(ex.Source + ex.Message + " : [" + mp_strcause + "]", ex);
                //'err.Raise n, s , d & " : [" & mp_strcause & "]"
                //err.Raise n, s & " : [" & mp_strcause & "]", d
            }
        }


        //metodo richiamato solo da Document.cls //spostato nella classe Document (EprocNext.Document)
        public static void HTML_OverMessagebox(EprocResponse response, string Id, string Message, string Caption, int Icon, int top, int left, bool bAlignRight = false)
        {
            MsgBox Msg = new MsgBox();

            string strStyle = "";
            strStyle = strStyle + "z-index = 2;position: absolute;overflow: hidden; width = 300;backgroundColor = yellow; ";

            switch (Icon)
            {

                case 1:             //'"info.gif"
                    Msg.Icon = "../domain/state_Info.gif";
                    break;
                case 2:                 //'"err.gif"
                    Msg.Icon = "../domain/State_Err.gif";
                    break;
                case 3:             //'"ask.gif"
                    Msg.Icon = "ask.gif";
                    break;
                case 4:             //'"ask.gif"
                    Msg.Icon = "../domain/State_Warning.gif";
                    break;
                default:
                    Msg.Icon = "../domain/state_Info.gif";
                    break;
            }


            Msg.Resize = false;
            Msg.CaptionOK = "";
            Msg.Caption = Caption;
            Msg.Message = Message;
            Msg.Style = "OverMsg";
            Msg.strPath = "../images/MsgBox/";

            Msg.id = "MSG_" + Id;

            string OnMouseOver;
            string OnMouseOut;
            OnMouseOver = "OnMouseOver_" + Id;
            OnMouseOut = "OnMouseOut_" + Id;
            string OnResize;
            OnResize = "OnResize_" + Id;

            response.Write(@"<div class=""OVER_MSG"" id=""" + Id + @""" name=""" + Id + @""" ");
            response.Write(@" onmouseover=""" + OnMouseOver + @"();"" ");
            response.Write(@" onmouseout=""" + OnMouseOut + @"();"" ");
            response.Write(@" style=""" + strStyle + @""" >" + Environment.NewLine);

            Msg.Html(response);

            response.Write("</div>");

            //'-- definisce la grandezza della finestra del messaggio
            response.Write($@"<script type=""text/javascript"" language=""javascript"">" + Environment.NewLine);
            response.Write($@"function " + OnMouseOver + "()" + Environment.NewLine);
            response.Write($@"{{" + Environment.NewLine);
            response.Write($@"getObj('" + Id + "').style.height = getObj('MSG_" + Id + "').offsetHeight + 10; " + Environment.NewLine);
            response.Write($@"}}" + Environment.NewLine);
            response.Write($@"function " + OnMouseOut + "()" + Environment.NewLine);
            response.Write($@"{{" + Environment.NewLine);
            response.Write($@"getObj('" + Id + "').style.height = getObj('MSG_" + Id + "').rows.item(0).offsetHeight + 5; " + Environment.NewLine);
            response.Write($@"}}" + Environment.NewLine);
            response.Write($@"getObj('" + Id + "').style.top = " + top + ";" + Environment.NewLine);
            response.Write($@"getObj('" + Id + "').style.left = " + left + ";" + Environment.NewLine);
            response.Write(OnMouseOut + "();" + Environment.NewLine);

            if (bAlignRight == true)
            {
                response.Write($@"var Old" + OnResize + " = window.onresize;" + Environment.NewLine);
                response.Write($@"function " + OnResize + "(  )" + Environment.NewLine);
                response.Write($@"{{" + Environment.NewLine);
                response.Write($@"getObj('" + Id + "').style.left = document.body.clientWidth - getObj('" + Id + "').offsetWidth - " + left + ";" + Environment.NewLine);
                response.Write($@"try{{Old" + OnResize + "();}}catch( e ) {{}};" + Environment.NewLine);
                response.Write($@"}}" + Environment.NewLine);

                response.Write($@"getObj('" + Id + "').style.left = document.body.clientWidth - getObj('" + Id + "').offsetWidth - " + left + ";" + Environment.NewLine);
                response.Write($@"window.onresize = " + OnResize + ";" + Environment.NewLine);
            }

            //'-- imposto nel resize della pagina lo spostamento della finestra
            response.Write("</script>" + Environment.NewLine);
        }


        //metodo richiamato solo da Document.cls
        public static void DOC_FreeSectionMem(Session.ISession session, string typeDoc, string idDoc)
        {
            try
            {
                //Dim objDB As Object
                string strSecName;
                TSRecordSet rs;

                //Dim sessionASP As Object
                //Set sessionASP = session(OBJSESSION)

                CommonDbFunctions cdf = new CommonDbFunctions();

                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@typeDoc", typeDoc);
                string strSql = "select * from LIB_DocumentSections with(nolock) where DSE_DOC_ID = @typeDoc";

                //'-- recupero il recordset delle sezioni"
                rs = cdf.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, sqlParams);

                if (rs.RecordCount == 0)
                {
                    strSql = "select * from CTL_DocumentSections with(nolock) where DSE_DOC_ID = @typeDoc";
                    rs = cdf.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, sqlParams);
                }

                //'-- per ogni sezione azzero l'area precedentemente utilizzata
                if (rs.RecordCount > 0)
                {
                    rs.MoveFirst();
                    while (!rs.EOF)
                    {
                        strSecName = $"DOC_SEC_MEM_{typeDoc}_{idDoc}_{CStr(rs["DSE_ID"])}";
                        session[strSecName] = string.Empty;
                        rs.MoveNext();
                    }
                }
            }
            catch (Exception ex)
            {
                //err.Clear
                //Set objDB = Nothing
                //Set rs = Nothing
                //Set sessionASP = Nothing
            }
        }

        private void InitGUIObject()
        {

            //'-- se l'oggetto non era presente si procede alla creazione
            if (mp_ObjHtml == null)
            {
                Lib_dbDocument objDB = new Lib_dbDocument(_context, _session, _response);

                //'-- recupero la struttura del documento
                mp_strcause = "recupero la struttura del documento";
                mp_ObjHtml = objDB.GetDocument(mp_TypeDoc, mp_Permission, mp_suffix, 0, mp_ObjSession, mp_strConnectionString);

                //'-- azzero eventuali messaggi precedenti
                mp_ObjHtml.Msg = "";
                mp_ObjHtml.MsgCommand = "";

                switch (mp_Mode)
                {
                    case "NEW":
                        mp_strcause = "MODE=" + mp_Mode + " - InitializeNew";
                        mp_ObjHtml.InitializeNew(mp_ObjSession, mp_idDoc);
                        break;

                    case "REMOVE_FROM_MEM":
                        mp_strcause = "InitGuiObject:REMOVE_FROM_MEM";
                        mp_ObjHtml.mp_IDDoc = mp_idDoc;
                        break;
                    case "SHOW":

                        if (UCase(GetParamURL(Request_QueryString.ToString(), "COMMAND")) == "PRINT")
                        {
                            mp_ObjHtml.PrintMode = true;
                        }

                        if (UCase(GetParamURL(Request_QueryString.ToString(), "READONLY")) == "YES")
                        {
                            mp_ObjHtml.ReadOnly = true;
                        }

                        if (Strings.Left(mp_idDoc, 3) == "new")
                        {
                            mp_strcause = "MODE=" + mp_Mode + " - InitializeNew";
                            mp_ObjHtml.InitializeNew(mp_ObjSession, mp_idDoc);
                            if (!string.IsNullOrEmpty(mp_Param))
                            { //'-- sul create from viene inizializzato il param per ereditare i campi
                                mp_strcause = "MODE=" + mp_Mode + " - InitializeFrom";
                                mp_ObjHtml.InitializeFrom(mp_ObjSession, mp_Param);
                            }
                        }
                        else
                        {
                            mp_strcause = "MODE=" + mp_Mode + " - Load";
                            mp_ObjHtml.Load(mp_ObjSession, mp_idDoc);
                        }

                        //'-- aggiorna il documento in memoria con i dati del documento presi dal client
                        mp_strcause = "aggiorna il documento in memoria con i dati del documento presi dal client";
                        mp_ObjHtml.UpdateContentInMem(mp_ObjSession, Request_Form);

                        break;
                    case "OPEN":

                        if (UCase(GetParamURL(Request_QueryString.ToString(), "READONLY")) == "YES")
                        {

                            mp_ObjHtml.ReadOnly = true;

                        }
                        mp_strcause = "MODE=" + mp_Mode + " - Load";
                        mp_ObjHtml.Load(mp_ObjSession, mp_idDoc);
                        mp_strcause = "InitGuiObject:MODE=" + mp_Mode + " - RemoveMem";
                        mp_ObjHtml.RemoveMem(mp_ObjSession);
                        break;
                    default:
                        break;


                }

            }
            else
            {
                //'-- azzero eventuali messaggi precedenti
                mp_strcause = "azzero eventuali messaggi precedenti";
                mp_ObjHtml.Msg = "";
                mp_ObjHtml.MsgCommand = "";

            }


            if (GetParamURL(Request_QueryString.ToString(), "SHOWSAVEOBBLIG") == "YES")
            {
                mp_strcause = "CanSave";
                mp_ObjHtml.CanSave(mp_ObjSession);
            }



        }

        private void AddMsgLink(Session.ISession sessionASP, string KeyMsg)
        {

            //On Error Resume Next
            //Dim collMSG As Collection 'Variant
            dynamic collMSG;//Dictionary<string, string>?
            collMSG = sessionASP["CollectionMsgKey"];

            if (collMSG == null)
            {
                collMSG = new Dictionary<string, string>();
            }

            collMSG.Add(KeyMsg, KeyMsg);
            //err.Clear

            sessionASP["CollectionMsgKey"] = collMSG;

        }

        //'-- esegue i comandi sul documento
        private void ExecuteCommand()
        {
            bool bExec;

            if (!string.IsNullOrEmpty(mp_Command))
            {

                switch (mp_Command)
                {

                    case "PROCESS":

                        //'-- se il salvataggio è andato a buon fine oppure il documento è in sola lettura
                        mp_strcause = "ExecuteCommand:PROCESS:se il salvataggio è andato a buon fine oppure il documento è in sola lettura";
                        if (Save() || mp_ObjHtml.ReadOnly)
                        {

                            string[] vP;
                            string[] vS;
                            bExec = true;

                            //'-- verifica se eseguire il controlllo dei campi obbligatori prima dell'invio
                            mp_strcause = "ExecuteCommand:verifica se eseguire il controlllo dei campi obbligatori prima dell'invio";
                            vP = Strings.Split(CStr(GetParamURL(Request_QueryString.ToString(), "PROCESS_PARAM")), ",");
                            vS = Strings.Split(vP[0], ":");

                            if (GetParam(mp_ObjHtml.param, "CANSAVE") == "NO" && vS.Length - 1 > 1)
                            {
                                if (vS[2] == "CHECKOBBLIG")
                                {
                                    bExec = mp_ObjHtml.CanSave(mp_ObjSession);
                                }
                            }

                            if (bExec)
                            {
                                mp_strcause = "ExecuteCommand:ExecuteProcess";
                                if (ExecuteProcess())
                                {

                                    //'-- se il processo � andato a buon fine lo ricarico
                                    mp_strcause = "ExecuteCommand:se il processo è andato a buon fine lo ricarico";
                                    mp_ObjHtml.RemoveMem(mp_ObjSession);

                                    //'-- verifica se deve aprire un docuemnto differente dopo il processo
                                    mp_strcause = "ExecuteCommand:verifica se deve aprire un docuemnto differente dopo il processo";
                                    if (vP.Length - 1 > 1)
                                    {

                                        if (!string.IsNullOrEmpty(vP[2]))
                                        {
                                            //Dim objDB As Object

                                            Lib_dbDocument objDB = new Lib_dbDocument(_context, _session, _response);//CreateObject("CTLDB.Lib_dbDocument")

                                            //'-- sostituisco sulla query string il tipo documento
                                            mp_queryString = mp_queryString.Replace("&DOCUMENT=" + mp_TypeDoc, "");
                                            mp_queryString = mp_queryString.Replace("DOCUMENT=" + mp_TypeDoc, "");
                                            if (Strings.Left(mp_queryString, 1) == "&")
                                            {
                                                mp_queryString = Strings.Mid(mp_queryString, 2);
                                            }

                                            mp_TypeDoc = vP[2];
                                            mp_queryString = mp_queryString + "&DOCUMENT=" + mp_TypeDoc;



                                            //'-- recupero la struttura del documento dai metadati
                                            mp_strcause = "ExecuteCommand:recupero la struttura del documento dai metadati";
                                            mp_ObjHtml = objDB.GetDocument(mp_TypeDoc, mp_Permission, mp_suffix, 0, mp_ObjSession, mp_strConnectionString);

                                            //'-- azzero eventuali messaggi precedenti
                                            mp_ObjHtml.Msg = "";
                                            mp_ObjHtml.MsgCommand = "";
                                        }

                                    }


                                }
                                else
                                {

                                    //'-- se il processo non � andato a buon fine lo ricarico
                                    mp_strcause = "ExecuteCommand:se il processo non è andato a buon fine lo ricarico";
                                    mp_ObjHtml.RemoveMem(mp_ObjSession);

                                }

                            }
                            //'-- carico il documento in memoria
                            mp_strcause = "ExecuteCommand:carico il documento in memoria";
                            mp_ObjHtml.Load(mp_ObjSession, mp_idDoc);

                        }

                        break;
                    case "RELOAD":

                        //'-- effettua il ricaricamento dal disco del documento
                        mp_strcause = "ExecuteCommand:RELOAD:effettua il ricaricamento dal disco del documento";
                        mp_ObjHtml.RemoveMem(mp_ObjSession);
                        mp_ObjHtml.Load(mp_ObjSession, mp_idDoc);

                        break;
                    case "SAVE":

                        //'-- effettua il salvataggio del documento
                        mp_strcause = "ExecuteCommand:effettua il salvataggio del documento";
                        if (Save())
                        {
                            //'-- dopo salvato il documento viene ricaricato, per consentire
                            //'-- a meccanismi del DB di aggiornare i dati - esempio trigger
                            //'-- per ottenere protocolli
                            mp_strcause = "ExecuteCommand:Save:carico il documento in memoria";
                            mp_ObjHtml.Load(mp_ObjSession, mp_idDoc);

                        }
                        break;
                    case "EXCEL":

                        //'-- aggiorna il documento in memoria con i dati del documento presi dal client
                        mp_strcause = "ExecuteCommand:aggiorna il documento in memoria con i dati del documento presi dal client";
                        mp_ObjHtml.UpdateContentInMem(mp_ObjSession, Request_Form);

                        break;
                    case "PRINT":

                        //'-- se � richiesta la firma si esegue il salvataggio del documento
                        mp_strcause = "ExecuteCommand:PRINT:se è richiesta la firma si esegue il salvataggio del documento";
                        if (UCase(GetParamURL(Request_QueryString.ToString(), "SIGN")) == "YES")
                        {

                            mp_strcause = "ExecuteCommand:PRINT:effettua il salvataggio del documento";
                            if (Save())
                            {
                                //'-- dopo salvato il documento viene ricaricato, per consentire
                                //'-- a meccanismi del DB di aggiornare i dati - esempio trigger
                                //'-- per ottenere protocolli
                                mp_strcause = "ExecuteCommand:PRINT:carico il documento in memoria";
                                mp_ObjHtml.Load(mp_ObjSession, mp_idDoc);
                                //'-- svuoto il messaggi per evitare dialog non necessarie
                                mp_ObjHtml.Msg = "";
                            }

                        }
                        else
                        {
                            //'-- aggiorna il documento in memoria con i dati del documento presi dal client
                            mp_strcause = "ExecuteCommand:PRINT:aggiorna il documento in memoria con i dati del documento presi dal client";
                            mp_ObjHtml.UpdateContentInMem(mp_ObjSession, Request_Form);
                        }


                        //'-- Se passato il parametro TOOLBAR (cio� si � spostato l'invio dopo l'anteprima di stampa)
                        //'-- aggiungo un controllo di canSave prima di qualsiasi operazione
                        if (GetParam(mp_ObjHtml.param, "CANSAVE") == "NO" && CStr(GetParamURL(Request_QueryString.ToString(), "TOOLBAR_PRINT")).Trim() != "")
                        {
                            mp_strcause = "ExecuteCommand:aggiungo un controllo di canSave";
                            bExec = mp_ObjHtml.CanSave(mp_ObjSession);
                        }
                        break;
                    case "CANSAVE":
                        mp_strcause = "ExecuteCommand:CANSAVE";
                        bExec = mp_ObjHtml.CanSave(mp_ObjSession);
                        break;


                }

            }


        }

        private bool Save()
        {

            CommonDbFunctions cdf = new CommonDbFunctions();

            bool boolToReturn;
            mp_bPassatoXSave = true;


            //' Prima di testare i CanSave effettuiamo il controllo BLOCK_SAVE
            string blockSave;
            string strSqlBlockSave;
            TSRecordSet rs;
            //Dim objDB As Object


            //'--non effettuo salvataggio se il form � vuoto
            mp_strcause = "non effettuo salvataggio se il form è vuoto";
            if (Request_Form != null && Request_Form.Count == 0)
            {

                boolToReturn = false;
                mp_strcause = "rimuovo dalla memoria il documento";
                mp_ObjHtml.RemoveMem(mp_ObjSession);
                mp_strcause = "carico in memoria il documento";
                mp_ObjHtml.Load(mp_ObjSession, mp_idDoc);

                mp_ObjHtml.Msg = ApplicationCommon.CNV("Operazione bloccata. Impossibile salvare il documento con form vuoto", mp_ObjSession);

                //Set rs = Nothing

                return boolToReturn;


            }


            //Set objDB = CreateObject("ctldb.clsTabManage")

            //'-- Se la tabella perno del documento � la ctl_doc posso usare una query di blocco di default
            if (mp_ObjHtml.strTable.ToUpper() == "CTL_DOC")
            {
                strSqlBlockSave = "select id from ctl_doc where id = <ID_DOC> and statofunzionale <> 'InLavorazione'";
            }
            else
            {
                strSqlBlockSave = "";
            }

            blockSave = GetParam(mp_ObjHtml.param, "BLOCK_SAVE");

            if (!string.IsNullOrEmpty(blockSave) && blockSave.Trim() != "")
            {
                strSqlBlockSave = blockSave;
            }

            //'-- se la query di controllo non � vuota e non stiamo nel caso di idDoc "new"
            if (!string.IsNullOrEmpty(strSqlBlockSave) && IsNumeric(mp_idDoc))
            {
                //'Se la query di blocco ritorna record
                //'blocco il salvataggio del documento con un messaggio
                //'e faccio una removeMem e reload del documento

                strSqlBlockSave = strSqlBlockSave.Replace("<ID_DOC>", CStr(CLng(mp_idDoc)));
                strSqlBlockSave = strSqlBlockSave.Replace("<ID_USER>", CStr(mp_User));

                rs = cdf.GetRSReadFromQuery_(strSqlBlockSave, mp_strConnectionString);

                if (rs.RecordCount > 0)
                {
                    boolToReturn = false;

                    mp_ObjHtml.RemoveMem(mp_ObjSession);
                    mp_ObjHtml.Load(mp_ObjSession, mp_idDoc);

                    mp_ObjHtml.Msg = ApplicationCommon.CNV("Operazione bloccata. Il documento non è più in una fase che consente l'aggiornamento nel sistema", mp_ObjSession);

                    //Set rs = Nothing

                    return boolToReturn;
                }
            }

            //'-- aggiorna il documento in memoria con i dati del documento presi dal client
            mp_strcause = "Save:aggiorna il documento in memoria con i dati del documento presi dal client";
            mp_ObjHtml.UpdateContentInMem(mp_ObjSession, Request_Form);

            if (GetParam(mp_ObjHtml.param, "CANSAVE") == "NO")
            {
                boolToReturn = true;
            }
            else
            {
                mp_strcause = "Save:CanSave";
                boolToReturn = mp_ObjHtml.CanSave(mp_ObjSession);
            }

            mp_save = boolToReturn;
            if (boolToReturn)
            {

                //'-- prova ad effettuare il salvataggio dei dati
                mp_strcause = "Save:prova ad effettuare il salvataggio dei dati";
                boolToReturn = mp_ObjHtml.Save(mp_ObjSession);
                if (boolToReturn)
                {

                    //'-- dopo il salvataggio se il documento era nuovo rimuovo
                    //'-- dalla sessione il veccio ed inserisco il nuovo
                    if (mp_idDoc != mp_ObjHtml.mp_IDDoc)
                    {

                        //'Set mp_Session("DOC_" & mp_TypeDoc & "_" & mp_idDoc) = Nothing
                        mp_queryString = mp_queryString.Replace("&IDDOC=" + mp_idDoc, "");
                        mp_queryString = mp_queryString.Replace("IDDOC=" + mp_idDoc, "");
                        if (Strings.Left(mp_queryString, 1) == "&")
                        {
                            mp_queryString = Strings.Mid(mp_queryString, 2);
                        }
                        mp_idDoc = mp_ObjHtml.mp_IDDoc;
                        mp_queryString = mp_queryString + "&IDDOC=" + mp_idDoc;

                        //'DOC_SetInMem mp_Session, mp_ObjHtml

                        //'if ( mp_idDoc <> "" ) {
                        //'}

                    }


                    //'            //'-- dopo salvato il documento viene ricaricato, per consentire
                    //'            //'-- a meccanismi del DB di aggiornare i dati - esempio trigger
                    //'            //'-- per ottenere protocolli
                    //'
                    //'            mp_ObjHtml.Load mp_ObjSession, mp_idDoc

                    mp_ObjHtml.Msg = ApplicationCommon.CNV("Salvataggio - Correttamente eseguito", mp_ObjSession);

                }
                else
                {

                    //'--per visualizzare eccezione generata sul salva
                    if (!string.IsNullOrEmpty(mp_ObjHtml.Msg))
                    {
                        mp_ICONMSG = MSG_ERR;
                    }

                }

            }
            else
            {
                mp_ICONMSG = MSG_WARNING;
            }

            return boolToReturn;


        }

        //'-- esegue un processo legato al documento
        private bool ExecuteProcess()
        {
            bool boolToReturn = true;
            string strDescrRetCode = "";
            dynamic vIdMp;
            dynamic vRetCode;
            string[] vP = new string[0];

            try
            {
                vP = Strings.Split(CStr(GetParamURL(Request_QueryString.ToString(), "PROCESS_PARAM")), ",");

                vIdMp = mp_ObjSession[Session.SessionProperty.SESSION_WORKROOM];

                ClsElab obj = new ClsElab();

                mp_strcause = $"esecuzione processo -{vP[0]}-{vP[1]}- iddoc={mp_idDoc}- iduser={mp_User.ToString()}";

                vRetCode = obj.Elaborate(vP[0], vP[1], mp_idDoc, mp_User, ref strDescrRetCode, vIdMp, mp_strConnectionString);

                if (vRetCode != ELAB_RET_CODE.RET_CODE_OK)
                {
                    mp_strcause = "InitMessageProcess";
                    InitMessageProcess(CInt(vRetCode), strDescrRetCode);

                    if (vRetCode == ELAB_RET_CODE.RET_CODE_ERROR)
                    {
                        boolToReturn = false;
                    }
                    else
                    {
                        boolToReturn = true;
                    }
                }
                else
                {
                    //'-- faccio eseguire la afterProcess e come parametro gli passo il nome del processo eseguito
                    mp_afterProcess = vP[0];

                    string nomeProcesso = string.Empty;

                    if (vP[0].Contains(':', StringComparison.Ordinal))
                    {
                        string[] vP2 = vP[0].Split(":");
                        nomeProcesso = vP2[0];
                    }
                    else
                    {
                        nomeProcesso = vP[0];
                    }

                    mp_StrMsg = "Informazione";
                    mp_ICONMSG = MSG_INFO;
                    // mp_ObjHtml.Msg = ApplicationCommon.CNV(vP[0], mp_ObjSession) + ApplicationCommon.CNV(" - Correttamente eseguito", mp_ObjSession);
                    mp_ObjHtml.Msg = ApplicationCommon.CNV(nomeProcesso, mp_ObjSession) + ApplicationCommon.CNV(" - Correttamente eseguito", mp_ObjSession);
                }

                //'-- controlla se il processo (vRetCode <> 1) non vuole messaggio di output
                //'-- aggiunto per garantire il comportamento come prima per� con un nuovo parametro NEVER_MSG
                if ((vP.Length - 1) > 2 && boolToReturn)
                {
                    //'--If UCase(vP(3)) = "NO_MSG" Then
                    if (vP[3].ToUpper() == "NEVER_MSG")
                    {
                        mp_StrMsg = "Informazione";
                        mp_ICONMSG = 0;
                        mp_ObjHtml.Msg = "";
                    }
                }

                //'-- controlla se il processo (vRetCode = 0 -> andato OK) non vuole messaggio di output
                if ((vP.Length - 1) > 2 && vRetCode == ELAB_RET_CODE.RET_CODE_OK)
                {
                    if (vP[3].ToUpper() == "NO_MSG")
                    {
                        mp_StrMsg = "Informazione";
                        mp_ICONMSG = 0;
                        mp_ObjHtml.Msg = "";
                    }
                }
            }
            catch (Exception ex)
            {
                string s = ex.Message;
                boolToReturn = false;

                if (LCase(CStr(ApplicationCommon.Application["dettaglio-errori"])) == "yes")
                {
                    mp_ObjHtml.Msg = ApplicationCommon.CNV("Errore esecuzione comando : ", mp_ObjSession) + vP[0] + Environment.NewLine + "<br/>Numero : " + Environment.NewLine + "<br/>Descrizione : " + s + Environment.NewLine + " <br> - FUNZIONE : CTLDoc.Document.ExecuteProcess - STRCAUSE=:[" + mp_strcause + "] ";
                }
                else
                {
                    mp_ObjHtml.Msg = ApplicationCommon.CNV("INFO_UTENTE_ERRORE_PROCESSO", mp_ObjSession) + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
                }

                mp_StrMsg = "Errore";
                mp_ICONMSG = MSG_ERR;
                //err.Clear
            }

            return boolToReturn;
        }

        public void Draw(EprocResponse response)
        {
            try
            {

                switch (CStr(GetParamURL(Request_QueryString.ToString(), "OPERATION")))
                {
                    case "EXCEL":
                        mp_strcause = "Draw_Excel";
                        Draw_Excel(response);
                        break;
                    case "PRINT":
                        mp_strcause = "Draw_Print";
                        Draw_Print(response);
                        break;

                    case "XML":
                        mp_strcause = "Draw_Xml";
                        Draw_Xml(mp_ObjSession, response);
                        break;

                    default:
                        mp_strcause = "Draw_Layout";
                        Draw_Layout(response);
                        break;
                }

                //Exit Function
            }
            catch (Exception ex)
            {
                //'err.Raise n, s, d & " : [" & mp_strcause & "]"
                throw new Exception(ex.Source + " - FUNZIONE : CTLDoc.Document.Draw - STRCAUSE=:[" + mp_strcause + "] " + ex.Message, ex);
                //err.Raise n, s & " - FUNZIONE : CTLDoc.Document.Draw - STRCAUSE=:[" & mp_strcause & "] ", d
            }
        }

        private void Draw_Excel(EprocResponse response)
        {
            try
            {
                //'-- disegno il contenuto del documento
                mp_ObjHtml.Excel(response, mp_ObjSession);
            }
            catch (Exception ex)
            {
                throw new Exception("Draw_Excel", ex);
            }
        }

        //'-- prende in input il valore ritornato dall'elaborazione del processo
        //'-- e costruisce i parametri per visualizzare il messaggio all'utente
        private void InitMessageProcess(int vRetCode, string strDescrRetCode)
        {
            string[] v;
            int i;
            int c;
            string[] v1;
            int i1;
            int c1;
            string strMsg = "";
            string testo;

            //'-- se errore
            if (vRetCode == (int)ELAB_RET_CODE.RET_CODE_ERROR || vRetCode == (int)ELAB_RET_CODE.RET_CODE_ERROR_NOCNV)
            {
                mp_ICONMSG = MSG_ERR;
                mp_StrMsg = "Errore";
            }
            else
            {
                mp_ICONMSG = MSG_INFO;
                mp_StrMsg = "Informazione";
            }

            //'-- recupero il messaggio da visualizzare
            v = Strings.Split(strDescrRetCode, "#@#");
            c = v.Length - 1;
            for (i = 0; i <= c; i++)
            {
                testo = v[i];

                if (Strings.InStr(1, v[i], "~~") > 0)
                {

                    v1 = Strings.Split(strDescrRetCode, "~~");
                    c1 = v1.Length - 1;
                    for (i1 = 0; i1 <= c1; i1++)
                    {
                        if (Strings.Left(v1[i1], 7) == "@TITLE=")
                        {
                            //'-- recupero la caption del messaggio se presente
                            mp_StrMsg = Strings.Mid(v1[i1], 8);
                        }
                        else if (Strings.Left(v1[i1], 6) == "@ICON=")
                        {
                            //'-- recupero l'icona se presente
                            mp_ICONMSG = CInt(Strings.Mid(v1[i1], 7));
                        }
                        else if (Strings.Left(v1[i1], 8) == "@ACTION=")
                        {
                            //' l'action vuole il formato nomeFunzione@@@@parametro
                            mp_ActionMSG = "ExecDocProcess@@@@" + Strings.Mid(v1[i1], 9);
                        }
                        else
                        {
                            testo = v1[i1];
                            strMsg = strMsg + ApplicationCommon.CNV(CStr(v1[i1]), mp_ObjSession) + " ";
                        }
                    }
                }
                else
                {
                    //'-- se � un errore di tipo 'NOCNV'
                    if (vRetCode == (int)ELAB_RET_CODE.RET_CODE_ERROR_NOCNV)
                    {
                        strMsg = strMsg + CStr(testo) + " ";
                    }
                    else
                    {
                        strMsg = strMsg + ApplicationCommon.CNV(CStr(testo), mp_ObjSession) + " ";
                    }
                }
            }

            mp_ObjHtml.Msg = strMsg;
        }

        private void Draw_Print(EprocResponse response)
        {
            try
            {
                Dictionary<string, string> JS = new Dictionary<string, string>();
                Form form = new Form();

                response.Write(Title(ApplicationCommon.CNV(mp_ObjHtml.Caption, mp_ObjSession)));

                response.Write(@"<div id=""contenuto"" > " + Environment.NewLine);

                //'-- inserisce i java script necessari
                mp_strcause = "inserisce i java script necessari";

                if (!JS.ContainsKey("ExecFunction"))
                {
                    JS.Add("ExecFunction", @"<script src=""../jscript/ExecFunction.js"" ></script>");
                }
                if (!JS.ContainsKey("getObj"))
                {
                    JS.Add("getObj", @"<script src=""../jscript/getObj.js"" ></script>");
                }

                response.Write(JavaScript(JS));
                mp_ObjHtml.JScript(JS, "../");

                HTML_HiddenField(response, "DOCUMENT_READONLY", "1");

                if (!string.IsNullOrEmpty(mp_ObjHtml.Msg))
                {
                    //'--eseguo execdococommand sull'opener per fare il cansave
                    //'-- inserisce lo script per il salto pagina relativo alla sezione
                    response.Write($@"<script type=""text/javascript"" language=""javascript"" >" + Environment.NewLine);
                    response.Write($@" window.opener.ExecDocCommand( '#CANSAVE#' );" + Environment.NewLine);
                    response.Write($@"</script>" + Environment.NewLine);

                    response.Write($@"<script type=""text/javascript"" >" + Environment.NewLine);
                    //'Response.Write "try{ window.opener.ShowWorkInProgress(false); }catch(e){}"
                    response.Write($@"self.close();" + Environment.NewLine);
                    response.Write($@"</script>" + Environment.NewLine);

                    //'Response.Write ShowMessageBoxModale(mp_ObjHtml.Msg, "Errore", "../", MSG_ERR, "OPENER")
                }
                else
                {
                    form.id = "FORMDOCUMENTPRINT";
                    form.Action = "";
                    response.Write(form.OpenForm());

                    //'-- PREVENZIONE ATTACCHI "CROSS SITE REQUEST FORGERY" --
                    if (!string.IsNullOrEmpty(CStr(mp_Session["TS_NomeCampoToken"])))
                    {
                        HTML_HiddenField(response, CStr(mp_Session["TS_NomeCampoToken"]), CStr(mp_Session["TS_ValoreCampoToken"]));
                    }

                    mp_ObjHtml.ToPrint(response, mp_ObjSession);

                    //'-- Stampa eventuali allegati in coda alla pagina di stampa
                    mp_ObjHtml.toPrintExtraContent(response, mp_ObjSession);

                    response.Write(form.CloseForm());
                }

                response.Write("</div>");
            }
            catch (Exception ex)
            {
                throw new Exception(mp_strcause, ex);
                //RaiseError mp_strcause
            }
        }

        private void Draw_Xml(Session.ISession mp_ObjSession, EprocResponse response)
        {
            try
            {
                ScopeLayer ScopeLayer = new ScopeLayer(_context);
                ScopeLayer.InitNew(null, response, mp_ObjSession, CInt(1));
                //'(inputObj As Object, outputObj As Object, mp_session As Variant, outputType As Integer)
                //'-- crea l'xml del' documento
                mp_ObjHtml.xml(response);

                //Exit Function
            }
            catch (Exception ex)
            {
                response.Write("ERRORE CREAZIONE DOCUMENTO XML " + ex.Message);

                //err.Clear
            }
        }
    }
}

namespace eProcurementNext.Document.CtlDocument
{
    //Classe con metodi di utilità per le librerie Document
    public static class BasicDocument
    {
        public static bool isReadOnlySection(string param, string idDoc, string idUser, string strConnectionString, dynamic? _params = null, SqlConnection? prevConn = null)
        {
            bool boolToReturn;
            bool ret;
            dynamic parametriExtra;
            TSRecordSet rs;
            string strSql;
            string readOnlyParam;

            ret = false;
            boolToReturn = false;

            if ((_params) != null)
            {
                parametriExtra = _params;
            }

            if (string.IsNullOrEmpty(param.Trim()))
            {
                return boolToReturn;
            }

            readOnlyParam = Trim(CStr(GetParam(param, "READONLY")));

            if (!string.IsNullOrEmpty(readOnlyParam))
            {

                if (readOnlyParam.ToUpper() == "YES")
                {
                    ret = true;
                }
                else
                {
                    //'-- se il contenuto del parametro READONLY inizia per SQL:
                    if (Strings.Left(readOnlyParam, 4).ToUpper() == "SQL:" && Strings.Left(idDoc, 3).ToUpper() != "NEW" && !string.IsNullOrEmpty(idDoc.Trim()))
                    {
                        strSql = Strings.Mid(readOnlyParam, 5);

                        if (string.IsNullOrEmpty(strSql.Trim()))
                        {
                            return boolToReturn;
                        }

                        CommonDbFunctions cdb = new();
                        strSql = Replace(strSql, "<ID_DOC>", CStr(idDoc));
                        strSql = Replace(strSql, "<ID_USER>", CStr(idUser));

                        rs = cdb.GetRSReadFromQuery_(strSql, strConnectionString, conn: prevConn);

                        if (rs.RecordCount > 0)
                        {
                            ret = true;
                        }
                        else
                        {
                            ret = false;
                        }
                    }
                }
            }

            boolToReturn = ret;
            return boolToReturn;
        }
        public static void FreeModelMemDoc(Session.ISession session, string Name, string idDoc)
        {
            string strModelNameCache;

            strModelNameCache = "CTL_MODEL_" + Name + "_" + idDoc;

            session[strModelNameCache] = "";
            session[strModelNameCache + "_GetFilteredFields"] = "";
            session[strModelNameCache + "_Field"] = "";
            session[strModelNameCache + "_FieldProp"] = "";
            session[strModelNameCache + "_NumField"] = "";
            session[strModelNameCache + "_Template"] = "";
        }

        /// <summary>
        /// Funzione utile a valutare un condizione logica/booleana in linguaggio vbscript 
        /// </summary>
        /// <param name="condizione">Codice vbscript da valutare</param>
        /// <param name="prevConn">Connessione SQL aperta sul chiamante</param>
        /// <returns>true se il codice vbscript ritorna vero, false altrimenti</returns>
        /// <exception cref="Exception"></exception>
        public static bool Eval(string condizione, SqlConnection? prevConn = null)
        {
            #region Parsing InStr
            do
            {
                var startIndexOfInStr = condizione.ToLower().IndexOf("instr", StringComparison.Ordinal);
                if (startIndexOfInStr is -1 or 0) continue;

                var inStrSubString = condizione[startIndexOfInStr..];
                var indexOfFirstParOpen = -1;
                var counterParOpen = 0;
                var counterParClosed = 0;
                var endIndexOfInStr = -1;
                var indexOfFirstComma = -1;
                var indexOfSecondComma = -1;
                var counterOfDoubleApices = 0;

                for (var i = 0; i < inStrSubString.Length; i++)
                {
                    switch (inStrSubString[i])
                    {
                        case '(':
                            {
                                counterParOpen++;
                                if (indexOfFirstParOpen == -1)
                                {
                                    indexOfFirstParOpen = i + startIndexOfInStr;
                                }

                                break;
                            }
                        case ')':
                            counterParClosed++;
                            break;
                        case '"':
                            counterOfDoubleApices++;
                            break;
                        default:
                            {
                                if (counterOfDoubleApices % 2 == 0 && inStrSubString[i] == ',' && indexOfFirstComma == -1)
                                {
                                    indexOfFirstComma = i + startIndexOfInStr;
                                }else if(counterOfDoubleApices % 2 == 0 && inStrSubString[i] == ',' && indexOfFirstComma != -1 && indexOfSecondComma == -1)
                                {
                                    indexOfSecondComma = i + startIndexOfInStr;
                                    if(condizione.Contains("InStr( 1 ,", StringComparison.Ordinal)) {
                                        condizione = condizione.Replace("InStr( 1 ,", "InStr(    ");
                                    }
                                    indexOfFirstComma = indexOfSecondComma;
                                }

                                break;
                            }
                    }

                    if (counterParOpen <= 0 || counterParClosed != counterParOpen) continue;

                    endIndexOfInStr = i + startIndexOfInStr;
                    break;
                }
                if (endIndexOfInStr != -1 && indexOfFirstComma != -1)
                {
                    var tempString1 = condizione.Substring(indexOfFirstParOpen + 1, indexOfFirstComma - indexOfFirstParOpen - 1);
                    var tempString2 = condizione.Substring(indexOfFirstComma + 1, endIndexOfInStr - indexOfFirstComma - 1);
                    if (tempString1.Contains("\" + \"", StringComparison.Ordinal))
                    {
                        tempString1 = tempString1.Replace("\" + \"", "");

                    }
                    if (tempString1.Trim().StartsWith("\"", StringComparison.Ordinal))
                    {
                        tempString1 = tempString1.Trim();
                        tempString1 = tempString1[(tempString1.IndexOf("\"", StringComparison.Ordinal) + 1)..];
                    }
                    if (tempString1.Trim().EndsWith("\"", StringComparison.Ordinal))
                    {
                        tempString1 = tempString1.Trim()[..tempString1.LastIndexOf("\"", StringComparison.Ordinal)];
                    }
                    if (tempString2.Contains("\" + \"", StringComparison.Ordinal))
                    {
                        tempString2 = tempString2.Replace("\" + \"", "");

                    }
                    if (tempString2.Trim().StartsWith("\"", StringComparison.Ordinal))
                    {
                        tempString2 = tempString2.Trim();
                        tempString2 = tempString2[(tempString2.IndexOf("\"", StringComparison.Ordinal) + 1)..];
                    }
                    if (tempString2.Trim().EndsWith("\"", StringComparison.Ordinal))
                    {
                        tempString2 = tempString2.Trim()[..tempString2.LastIndexOf("\"", StringComparison.Ordinal)];
                    }


                    var result = Strings.InStr(tempString1.Trim(), tempString2.Trim());
                    var subString1 = condizione[..startIndexOfInStr];
                    var subString2 = $@" ({result} ";
                    var subString3 = condizione[endIndexOfInStr..];
                    condizione = subString1 + subString2 + subString3;
                }
                else
                {
                    throw new Exception("Error Eval 1, cond: " + condizione);
                }

            } while (condizione.ToLower().Contains("instr", StringComparison.Ordinal));
            #endregion

            #region Parsing IsNull
            var startIndexOfIsNull = condizione.ToLower().IndexOf("isnull", StringComparison.Ordinal);
            if (startIndexOfIsNull != -1 && startIndexOfIsNull != 0)
            {
                var isNullSubString = condizione[startIndexOfIsNull..];
                var indexOfFirstParOpen = -1;
                var endIndexOfIsNull = -1;

                for (var i = 0; i < isNullSubString.Length; i++)
                {
                    if (isNullSubString[i] == '(')
                    {
                        if (indexOfFirstParOpen == -1)
                        {
                            indexOfFirstParOpen = i + startIndexOfIsNull;
                        }

                    }

                    if (isNullSubString[i] != ')') continue;

                    if (endIndexOfIsNull == -1)
                    {
                        endIndexOfIsNull = i + startIndexOfIsNull;
                    }
                }
                if (endIndexOfIsNull != -1 && indexOfFirstParOpen != -1)
                {
                    var tempString1 = condizione.Substring(indexOfFirstParOpen + 1, endIndexOfIsNull - 1 - indexOfFirstParOpen);
                    var subString1 = condizione[..startIndexOfIsNull];
                    var subString2 = $@" '{IsNull(tempString1)}' ".ToLower();
                    var subString3 = condizione[(endIndexOfIsNull + 1)..];
                    condizione = subString1 + subString2 + subString3;
                }
                else
                {
                    throw new Exception("Error Eval 1, cond: " + condizione);
                }


            }
            #endregion

            #region Custom replace
            condizione = condizione.Replace(@"""", "'");
            if (condizione.Trim() == "1")
            {
                condizione = " 1 = 1 ";
            }
            if (condizione.ToLower().Contains("and 0 and", StringComparison.Ordinal))
            {
                condizione = condizione.Replace("and 0 and", "and 0 = 1 and");
            }
            if (condizione.ToLower().Contains(@" or 'false' )", StringComparison.Ordinal))
            {
                condizione = condizione.Replace(@" or 'false' )", @" or 0 = 1 )");
            }
            if (condizione.ToLower().StartsWith(@" 1 and ", StringComparison.Ordinal))
            {
                condizione = condizione.ToLower().Remove(0, @" 1 and ".Length).Insert(0, @" 1 = 1 and");
            }
            if (condizione.ToLower().EndsWith(" and 0 ", StringComparison.Ordinal))
            {
                var place = condizione.ToLower().LastIndexOf(" and 0 ", StringComparison.Ordinal);
                condizione = condizione.ToLower().Remove(place, " and 0 ".Length).Insert(place, @" and 0 = 1 ");
            }
            if (condizione.ToLower().Contains(" = false", StringComparison.Ordinal))
            {
                condizione = condizione.Replace(" = false", " = 'false'");
            }
            #endregion

            var query = @$"IF ( {condizione} )
                                BEGIN
                                    select 1 as esito
                                END
                                ELSE
                                BEGIN
                                    select 0 as esito
                                END";

            var dataTable = new DataTable();
            SqlConnection conn = prevConn;

            //Se il chiamante mi sta passando una connessione sql sfrutto quella inveve di aprirne una nuova
            if (prevConn is null)
            {
                conn = new SqlConnection(ApplicationCommon.Application.ConnectionString);
            }
           
            var cmd = new SqlCommand(query, conn);

            try
            {
                var da = new SqlDataAdapter(cmd);
                da.Fill(dataTable);
               
                int esito = Convert.ToInt32(dataTable.Rows[0]["esito"]);
                return esito == 1;
            }
            catch (Exception ex)
            {
                if (condizione.Trim() == "0" || condizione.Trim().ToLower().StartsWith("0 and", StringComparison.Ordinal) || condizione.Trim() == "(0 )" || condizione.Trim() == "(  0  )" || condizione.Trim() == "( 0 )")
                {
                    return false;
                }
                throw new Exception("Error Eval, cond: " + condizione + Environment.NewLine + "Eccezione: " + ex.Message, ex);
            }
        }
    }

    public class Sec_Approval : ISectionDocument
    {
        //'-- MODEL_CICLE = nome modello per la griglia del ciclo di approvazione
        //'-- MODEL_STEP = nome modello per gli step eseguiti
        //'-- USERROLE = nome dell'atributo utente che contiene i profili associati per default UserRole
        //'-- READONLY = contiene il yes se la sezione � in sola lettura
        //'-- EDITABLEFORCOMPILER = yes indica che il compiratore puo inserire allegati e note,
        //'per compilatore si intende colui che ha il permesso di aprire il documeto in scrittura

        public string Id { get; set; }
        public string Caption { get; set; }
        public string strTable { get; set; }
        public string strFieldId { get; set; }
        public string strFieldIdRow { get; set; }
        public string strTableFilter { get; set; }
        public string strModelName { get; set; }
        public long PosPermission { get; set; }
        public string mp_idDoc { get; set; }
        public Toolbar ObjToolbar { get; set; }
        public string strHelp { get; set; }
        public CTLDOCOBJ.Document objDocument { get; set; }
        public string param { get; set; }

        public string _typeSection = "APPROVAL";
        public string TypeSection { get { return _typeSection; } set { _typeSection = value; } }
        public Model mp_Mod { get; set; }
        public Dictionary<string, Field> mp_Columns { get; set; }
        public dynamic[,] mp_Matrix { get; set; }

        //'---------------------------------------------------------------------------
        //'-- Elementi personali della sezione
        //'---------------------------------------------------------------------------

        private long mp_User;                       //'-- identificativo dell'utente che ha caricato il documento
        private string mp_suffix;
        private string mp_strConnectionString;
        private string mp_Permission;
        private string Request_QueryString;
        private IFormCollection? Request_Form;
        public TSRecordSet mp_rsCicle { get; set; }
        public TSRecordSet mp_rsCicleStep { get; set; }
        public TSRecordSet mp_rsCicleCheck;
        public Dictionary<string, Field> mp_ColumnsC { get; set; }
        public Dictionary<string, Grid_ColumnsProperty> mp_ColumnsPropertyC;
        public Dictionary<string, Field> mp_ColumnsS { get; set; }
        public int mp_numRec { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }

        public Dictionary<string, Grid_ColumnsProperty> mp_ColumnsPropertyS;
        public Grid mp_objGridCicle;
        public Grid mp_objGridStep;
        public Model mp_objMod;
        private bool mp_InCharge;                   //'-- definisce se il documento � in carico all'utente e quindi deve poter inserire note
                                                    //'-- allegati e poter effettuare approvazioni oppure no
        private bool mp_InCompiler;                 //'-- vale true se il documento � getito dal compilatore                     
        private bool firstLoad;                     //'-- evita che vengano ricaricati i moodelli di base

        private readonly EprocResponse _response;
        private readonly HttpContext _context;
        private readonly Session.ISession _session;

        public Sec_Approval(HttpContext context, Session.ISession session, EprocResponse response)
        {
            TypeSection = "APPROVAL";
            firstLoad = true;
            //this._accessor = accessor;
            this._context = context;
            this._session = session;
            _response = response;

        }

        /// <summary>
        /// '-- funzione di inizializzazione della sezione --
        /// '-- questa funzione � indispensabile al corretto funzionamento e viene invocata da CTL_DB al caricamento del docuemnto
        /// </summary>
        /// <param name="pId"></param>
        /// <param name="model"></param>
        /// <param name="pCaption"></param>
        /// <param name="pTable"></param>
        /// <param name="pstrFieldId"></param>
        /// <param name="pFieldIdRow"></param>
        /// <param name="pTableFilter"></param>
        /// <param name="strToolbar"></param>
        /// <param name="help"></param>
        /// <param name="session"></param>
        /// <exception cref="NotImplementedException"></exception>

        public void Init(string pId, string model, string pCaption, string pTable, string pstrFieldId, string pFieldIdRow, string pTableFilter, string strToolbar, string help, Session.ISession session)
        {
            Id = pId;
            strTable = pTable;
            Caption = pCaption;
            strFieldId = pstrFieldId;
            strHelp = help;
            strFieldIdRow = pFieldIdRow;

            if (string.IsNullOrEmpty(strFieldIdRow))
            {
                strFieldIdRow = strFieldId;
            }

            strTableFilter = pTableFilter;
            strModelName = model;
        }

        public void Html(EprocResponse response, Session.ISession OBJSESSION)
        {
            bool tbOpen;

            tbOpen = false;

            InitLocal(OBJSESSION);

            //'-- apro la div
            response.Write($@"<div class=""Total"" id=""" + Id + @""" name=""" + Id + @"""  >");

            //'-- se il documento non � nuovo ( se nuovo il documento contiene nell'id 'newN'
            if (IsNumeric(mp_idDoc))
            {

                response.Write($@"<table width=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0"" ><tr><td valign=""top""  width=""100%""  >");
                tbOpen = true;

                if (!string.IsNullOrEmpty(GetParam(param, "ACTIVESEL")))
                {
                    mp_objGridCicle.ActiveSelection = CInt(GetParam(param, "ACTIVESEL"));
                }
                mp_objGridCicle.SetLockedInfo(0, 0);

                //'-- se non si è chiesto di nascondere il ciclo di approvazione
                if (UCase(Trim(CStr(GetParam(param, "HIDDENCICLE")))) != "YES")
                {
                    mp_objGridCicle.Html(response);
                }

                response.Write($@"<br/></td></tr>");

                response.Write($@"<tr><td valign=""top""  width=""100%""  >");

                if (!string.IsNullOrEmpty(GetParam(param, "ACTIVESEL")))
                {
                    mp_objGridStep.ActiveSelection = CInt(GetParam(param, "ACTIVESEL"));
                }
                mp_objGridStep.SetLockedInfo(0, 0);
                mp_objGridStep.Html(response);

                response.Write($@"<br/></td></tr>");

            }
            //'---------------------------------------------------------------------
            //'-- aggiungo il modello dei due campi per gli allegati e le note se il documento � in carico
            //'---------------------------------------------------------------------
            if (mp_InCharge || mp_InCompiler)
            {

                //'-- apre la tabella se non � stato fatto prima
                if (tbOpen == false)
                {
                    response.Write($@"<table width=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0"" >"); //'<tr><td valign=""top""  width=""100%""  >"
                    tbOpen = true;
                }


                response.Write($@"<tr><td valign=""top""  width=""100%""  >");
                Window win = new Window();

                win.Path = "../images/window/style";

                if (ApplicationCommon.Application["ShowImages"] != "0")
                {
                    win.Init("winApprovNote" + Id, "", true, Window.Cuscino);
                }
                else
                {
                    win.Init("winApprovNote" + Id, "", true, Window.NOIMAGES);
                }


                win.width = "100%";
                win.PositionAbsolute = false;
                win.Html(response, mp_objMod);
                //Set win = Nothing

                response.Write($@"<br/></td></tr>");

            }

            if (tbOpen == true)
            {
                response.Write($@"</table>");
            }

            response.Write($@"</div>");
        }

        /// <summary>
        /// '-- il metodo Command di una sezione norlmamente � invocato direttamente da una pagina per eseguire
        /// //'-- un comando il cui scopo � influenzare la sezione di pertinenza di provenienza
        /// //'-- ad esempio l'aggiunta di un record in una griglia
        /// </summary>
        /// <param name="session"></param>
        /// <param name="response"></param>
        public void Command(Session.ISession session, EprocResponse response)
        {

        }
        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library")
        {

        }

        public bool CanSave(Session.ISession session)
        {
            return true;
        }

        public void Excel(EprocResponse response, Session.ISession OBJSESSION)
        {
            bool tbOpen;

            tbOpen = false;

            //'-- apro la div
            response.Write(@"<div class=""Total"" id=""" + Id + @""" name=""" + Id + @"""  >");

            //'-- se il documento non � nuovo ( se nuovo il documento contiene nell'id 'newN'
            if (IsNumeric(mp_idDoc))
            {

                tbOpen = true;
                response.Write(@"<table width=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0"" ><tr><td valign=""top""  width=""100%""  >");

                mp_objGridCicle.Excel(response);

                response.Write("<br/></td></tr>");

                //'---------------------------------------------------------------------
                //'-- disegno il modello degli step di approvazione
                //'---------------------------------------------------------------------

                response.Write(@"<tr><td valign=""top""  width=""100%""  >");
                mp_objGridStep.Excel(response);

                response.Write("<br/></td></tr>");

            }

            //'---------------------------------------------------------------------
            //'-- aggiungo il modello dei due campi per gli allegati e le note se il documento � in carico
            //'---------------------------------------------------------------------
            if (mp_InCharge || mp_InCompiler)
            {

                //'-- apre la tabella se non � stato fatto prima
                if (tbOpen == false)
                {
                    response.Write($@"<table width=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0"" ><tr><td valign=""top""  width=""100%""  >");
                }

                response.Write($@"<tr><td valign=""top""  width=""100%""  >");
                mp_objMod.Excel(response);
                response.Write($@"<br/></td></tr>");


            }

            response.Write("</div>");
        }

        public void InitializeFrom(Session.ISession OBJSESSION, string idDoc)
        {

        }
        /// <summary>
        /// '-- metodo pubblico per linizializzazione della sezione su un oggetto nuovo
        /// </summary>
        /// <param name="OBJSESSION"></param>
        /// <param name="idDoc"></param>
        public void InitializeNew(Session.ISession OBJSESSION, string idDoc)
        {
            //'-- per la copertina non � necessario effettuare operazioni ( almeno per il momento POI??? )
            mp_idDoc = idDoc;


            //'-- SE IL DOCUMENTO è NUOVO la sezione è in carico al compilatore
            if (!IsNumeric(idDoc))
            {
                mp_InCompiler = true;
            }
            else
            {
                mp_InCompiler = false;
            }



            InitLocal(OBJSESSION);


            //'-- effettuo il caricamento siolo la prima volta
            if (firstLoad)
            {
                firstLoad = false;

                LibDbModelExt objDBM = new();



                //'---------------------------------------------------------------------
                //'-- carica la griglia per il ciclo di approvazione
                //'---------------------------------------------------------------------
                Dictionary<string, Field> tempMp_ColumnsC = new Dictionary<string, Field>();

                objDBM.GetFilteredFields(GetParam(param, "MODEL_CICLE"), ref tempMp_ColumnsC, ref mp_ColumnsPropertyC, mp_suffix, 0, 0, mp_strConnectionString, OBJSESSION, false);

                this.mp_ColumnsC = tempMp_ColumnsC;



                mp_objGridCicle = new Grid();
                mp_objGridCicle.Columns = mp_ColumnsC;
                mp_objGridCicle.ColumnsProperty = mp_ColumnsPropertyC;

                mp_objGridCicle.id = "GridCicle";
                mp_objGridCicle.width = "100%";
                mp_objGridCicle.Editable = false;



                mp_objGridCicle.Caption = ApplicationCommon.CNV("Ciclo di approvazione", OBJSESSION);


                //'---------------------------------------------------------------------
                //'-- carica la griglia per gli step eseguiti
                //'---------------------------------------------------------------------

                Dictionary<string, Field> tempMp_ColumnsS = new Dictionary<string, Field>();
                objDBM.GetFilteredFields(GetParam(param, "MODEL_STEP"), ref tempMp_ColumnsS, ref mp_ColumnsPropertyS, mp_suffix, 0, 0, mp_strConnectionString, OBJSESSION, false);
                this.mp_ColumnsS = tempMp_ColumnsS;

                //'-- per ogni attributo ridefinisce il percorso di lavoro
                foreach (var fld in mp_ColumnsS)
                {
                    fld.Value.Path = "../../";
                }

                mp_objGridStep = new Grid();
                mp_objGridStep.Columns = mp_ColumnsS;
                mp_objGridStep.ColumnsProperty = mp_ColumnsPropertyS;


                mp_objGridStep.id = "GridStep";
                mp_objGridStep.width = "100%";
                mp_objGridStep.Editable = false;



                mp_objGridStep.Caption = ApplicationCommon.CNV("Operazioni sulla richiesta", OBJSESSION);



                //'---------------------------------------------------------------------
                //'-- aggiungo il modello dei due campi per gli allegati e le note se il documento � in carico
                //'---------------------------------------------------------------------
                mp_objMod = objDBM.GetFilteredModel(strModelName, mp_suffix, mp_User, 0, mp_strConnectionString, true, OBJSESSION);


            }


            LoadFromMem(OBJSESSION);

        }
        /// <summary>
        /// '-- carica la copertina ( il modello ) con le informazioni estratte dal DB
        /// </summary>
        /// <param name="session"></param>
        /// <param name="idDoc"></param>
        /// <exception cref="NotImplementedException"></exception>
        public void Load(Session.ISession session, string idDoc, SqlConnection? prevConn = null)
        {
            //Dim objDB As Object
            TSRecordSet rsUP;
            string strSql;
            bool binMem;
            TSRecordSet mp_rsCicleCheck;
            CommonDbFunctions cdb = new CommonDbFunctions();
            //Set objDB = CreateObject("ctldb.clsTabManage")

            mp_idDoc = idDoc;

            //'-- prepara le strutture della sezione
            InitializeNew(session, idDoc);

            mp_InCharge = false;
            mp_InCompiler = false;

            //'-- provo a caricare dalla sessione le aree di memoria del docuemento
            LoadFromMem(session);
            binMem = IsInMem(session);

            var sqlParams = new Dictionary<string, object?>();

            //'-- SE LA SEZIONE NON � IN SOLA LETTURA VERIFICA SE � IN CARICO ALL'UTENTE
            if (UCase(GetParam(param, "READONLY")) != "YES")
            {
                if (binMem == false)
                {
                    //'-- carica il recordset che contiene i passi di approvazione

                    sqlParams.Add("@mp_idDoc", CInt(mp_idDoc));
                    strSql = $"Select * from {strTable} with(nolock) where {strFieldId} = @mp_idDoc and APS_IsOld=0 and {strTableFilter} order by APS_ID_ROW";

                    mp_rsCicleCheck = cdb.GetRSReadFromQuery_(CStr(strSql), mp_strConnectionString, sqlParams);

                    mp_rsCicleCheck.Filter("");
                    mp_rsCicleCheck.Filter("APS_State = 'InCharge'");

                    //'-- verif (ico che esista un record in carico
                    if (mp_rsCicleCheck.RecordCount > 0 && objDocument.ReadOnly == false)
                    {

                        //'-- vedo se il mio profilo � fra quelli in carico
                        rsUP = User_GetInfoAttrib(mp_User, GetParam(param, "USERROLE"), mp_strConnectionString);
                        rsUP.Filter("attValue = '" + mp_rsCicleCheck.Fields["APS_UserProfile"] + "'");

                        //'-- se esiste un record sull'utente che ha lo stesso profilo dell'utente collegato
                        //'-- allora signif (ica che lui � abilitato all'approvazione
                        if (rsUP.RecordCount > 0)
                        {

                            mp_InCharge = true;

                        }
                    }


                    //'-- se il documento non � in sola lettura si verif (ica se il documento � in carico al compilatore
                    if (mp_InCompiler == false && objDocument.ReadOnly == false && mp_InCharge == false && UCase(GetParam(param, "EDITABLEFORCOMPILER")) == "YES")
                    {

                        //'-- si filtrano i record di approvazione considerati vecchi
                        mp_rsCicleCheck.Filter("");
                        mp_rsCicleCheck.Filter("APS_IsOld = 0");
                        if (mp_rsCicleCheck.RecordCount == 0)
                        {
                            //'-- se il documento non ha record nel ciclo di approvazione all'ora vuol dire che
                            //'-- � gestito dal compilatore ed � nuovo o nel secondo giro di approvazione
                            mp_InCompiler = true;
                        }
                        else if (mp_rsCicleCheck.RecordCount == 1)
                        {
                            //'-- in questo caso si controlla che l'unico record sia quello del compilatore
                            if (CStr(mp_rsCicleCheck.Fields["APS_State"]) == "Compiled")
                            {
                                mp_InCompiler = true;
                            }
                        }

                    }

                }

            }

            //'-- se non � abilitato cerco di rimuovere dal documento i comandi per l'approvazione
            if (mp_InCharge == false)
            {
                //On Error Resume Next
                //'-- verif (ico se � necessario mettere readonly il documento
                if (LCase(GetParam(param, "READONLY_NOT_INCHARGE")) == "yes")
                {
                    objDocument.ReadOnly = true;
                }
                objDocument.ObjToolbar.Buttons.Remove("APPROVE");
                objDocument.ObjToolbar.Buttons.Remove("NOTAPPROVE");
                //On Error GoTo 0
            }

            //'-- si caricano in memoria le aree per la visualizzazione del documento

            //'-- se il documento non � nuovo ( se nuovo il documento contiene nell'id 'newN'
            sqlParams.Clear();
            if (IsNumeric(mp_idDoc))
            {

                //'-- recupero i RS dei dati
                if (binMem == false)
                {
                    sqlParams.Add("@mp_idDoc", CInt(mp_idDoc));
                    sqlParams.Add("@USERROLE", GetParam(param, "USERROLE"));
                    strSql = $"Select APS_ID_ROW, pfuNome, APS_UserProfile, APS_State  from {strTable}, profiliutente  p1";
                    strSql = $"{strSql} where ";
                    strSql = $"{strSql} p1.idpfu = APS_idpfu And {strFieldId} = @mp_idDoc And {strTableFilter}";
                    strSql = $"{strSql} and APS_IsOld = 0  union ";

                    strSql = $"{strSql}Select APS_ID_ROW, pfuNome ,APS_UserProfile , APS_State  from {strTable}, profiliutente  p1, profiliutenteattrib  p2 ";
                    strSql = $"{strSql} where  p1.idpfu = p2.idpfu and p2.dztNome = @USERROLE and ";
                    strSql = $"{strSql} p2.attValue = APS_UserProfile And {strFieldId} = @mp_idDoc And {strTableFilter}";
                    strSql = $"{strSql} and APS_IsOld = 0 and APS_idpfu = 0 and p1.pfuDeleted = 0";

                    strSql = $"{strSql} order by APS_ID_ROW";

                    //'-- carica il ciclo
                    mp_rsCicle = cdb.GetRSReadFromQuery_(strSql, mp_strConnectionString, sqlParams);

                }

                mp_objGridCicle.RecordSet(mp_rsCicle, "APS_ID_ROW", false);

                //'---------------------------------------------------------------------
                //'-- step di approvazione
                //'---------------------------------------------------------------------
                if (binMem == false)
                {
                    sqlParams.Clear();
                    sqlParams.Add("@mp_idDoc", CInt(mp_idDoc));
                    strSql = $"Select pfunome , {strTable}.* from profiliutente , {strTable} where idpfu = APS_idpfu and {strFieldId} = @mp_idDoc and {strTableFilter}";
                    strSql = $"{strSql} and APS_IdPfu <> '' order by APS_ID_ROW";

                    mp_rsCicleStep = cdb.GetRSReadFromQuery_(strSql, mp_strConnectionString, sqlParams);
                }

                mp_objGridStep.RecordSet(mp_rsCicleStep, "APS_ID_ROW", false);
            }

            //'---------------------------------------------------------------------
            //'-- aggiungo il modello dei due campi per gli allegati e le note se il documento � in carico
            //'---------------------------------------------------------------------
            if ((mp_InCharge || mp_InCompiler) && binMem == false)
            {

                TSRecordSet rs;
                if (IsNumeric(mp_idDoc))
                {
                    sqlParams.Clear();
                    sqlParams.Add("@mp_idDoc", CInt(mp_idDoc));
                    strSql = $"Select * from {strTable} where {strFieldId} = @mp_idDoc and {strTableFilter}";
                    if (mp_InCompiler == true)
                    {
                        strSql = $"{strSql} and APS_State = 'Compiled' and APS_IsOld = 0 ";
                    }
                    else
                    {
                        strSql = $"{strSql} and APS_State = 'InCharge' ";
                    }

                    rs = cdb.GetRSReadFromQuery_(strSql, mp_strConnectionString, sqlParams);

                    if (rs != null)
                    {
                        if (rs.RecordCount > 0)
                        {
                            mp_objMod.SetFieldsValue(rs.Fields);
                        }
                    }
                }
            }

            //'-- memorizzo le aree in memoria per riutilizzarle
            SaveInMem(session);

        }

        public void RemoveMem(Session.ISession session)
        {
            string strSecName;

            strSecName = $"DOC_SEC_MEM_{objDocument.Id}_{objDocument.mp_IDDoc}_{Id}";

            session[strSecName] = string.Empty;

            session[strSecName + "_mp_rsCicle"] = null;
            session[strSecName + "_mp_rsCicleStep"] = null;
            session[strSecName + "_Note"] = string.Empty;
            session[strSecName + "_Allegato"] = string.Empty;
            session[strSecName + "_NextApprover"] = string.Empty;
            session[strSecName + "_mp_InCharge"] = string.Empty;
            session[strSecName + "_mp_InCompiler"] = string.Empty;
        }

        public bool Save(Session.ISession session, ref string ReferenceKey, Dictionary<dynamic, dynamic> mpMEM, SqlConnection conn, SqlTransaction trans)
        {
            bool boolToReturn = true;
            Dictionary<string, Field> Columns = new Dictionary<string, Field>();
            Dictionary<string, Grid_ColumnsProperty> ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();
            TSRecordSet rs = new();
            SqlConnection? cnLocal = null;
            try
            {

                boolToReturn = true;

                string strSql;
                int i;
                int nc;
                CommonDbFunctions cdb = new CommonDbFunctions();

                //'-----------------------------------------------------------------------------
                //'-- occorre verificare che esistano ancora i presupposti al salvataggio dei dati
                //'-----------------------------------------------------------------------------
                //'-----------------------------------------------------------------------------
                //'-----------------------------------------------------------------------------

                if (mp_InCharge || mp_InCompiler)
                {

                    InitLocal(session);

                    //'-- apro la connessione
                    if (conn == null)
                    {

                        cnLocal = cdb.SetConnection(mp_strConnectionString);

                        cnLocal.Open();
                        trans = cnLocal.BeginTransaction();
                    }
                    else
                    {
                        cnLocal = conn;
                    }


                    LibDbModelExt objDB = new LibDbModelExt(); //CreateObject("ctldb.lib_dbModelExt")
                    objDB.GetFilteredFields(strModelName, ref Columns, ref ColumnsProperty, "I", 0, 0, mp_strConnectionString, session, true);
                    //Set objDB = Nothing


                    //'-- prendo il recordset dei passi di approvazione
                    strSql = "Select * from " + strTable + " where " + strFieldId + " = " + CLng(ReferenceKey) + " and " + strTableFilter;
                    if (mp_InCompiler)
                    {
                        strSql = strSql + " and APS_IsOld = 0 and APS_State = 'Compiled' order by APS_ID_ROW";
                    }
                    else
                    {
                        strSql = strSql + " and APS_IsOld = 0 and APS_State = 'InCharge' order by APS_ID_ROW";
                    }
                    rs.OpenWithTransaction(strSql, conn, trans);
                    DataRow dr;
                    bool isNewRecord = rs.RecordCount == 0 && mp_InCompiler == true ? true : false;
                    dr = isNewRecord ? rs.AddNew() : rs.Fields;
                    //'-- aggiungo le informazioni di base per il record aggiunto sul compilatore
                    if (rs.RecordCount == 0 && mp_InCompiler == true)
                    {

                        TSRecordSet rsU;
                        rsU = User_GetInfoAttrib(mp_User, "UserRoleDefault", mp_strConnectionString);
                        if (rsU.RecordCount == 0)
                        {
                            rsU = User_GetInfoAttrib(mp_User, "UserRole", mp_strConnectionString);
                        }

                        if (rsU.RecordCount > 0)
                        {
                            dr["APS_UserProfile"] = rsU.Fields["attValue"];
                        }
                        else
                        {
                            dr["APS_UserProfile"] = "";
                        }


                        string strDocName;
                        strDocName = "";
                        strDocName = GetParam(param, "DOC_APPROVE");
                        if (string.IsNullOrEmpty(strDocName))
                        {
                            strDocName = objDocument.Id;
                        }

                        dr["APS_Doc_Type"] = strDocName; //'objDocument.Id
                        dr["APS_ID_DOC"] = ReferenceKey;
                        dr["APS_State"] = "Compiled";
                        dr["APS_IdPfu"] = mp_User;
                        dr["APS_IsOld"] = 0;

                        //Set rsU = Nothing
                    }

                    nc = Columns.Count;
                    if (rs.RecordCount > 0 || mp_InCompiler)
                    {
                        dynamic? valoreCampo;
						var sqlParams = new Dictionary<string, object?>();
						//'-- per ogni campo del modello prelevo il valore dal form e lo memorizzo nel RS
						for (i = 1; i <= nc; i++)
                        { //To nc
                            Field objField = Columns.ElementAt(i - 1).Value;


                            //On Error Resume Next
                            objField.Value = GetValueFromForm(Request_Form, objField.Name);
                            valoreCampo = objField.RSValue();
                            //On Error GoTo Herr


                            dr[objField.Name] = valoreCampo;
                            sqlParams.TryAdd(objField.Name, valoreCampo);

                            //Set objField = Nothing
                        }

                        if (isNewRecord)
                        {
                            rs.Update(dr, strFieldIdRow, strTable);
                        }
                        else
                        {
                            rs.Update(dr, strFieldIdRow, strTable, sqlParams);
                        }


                        //'-- chiudo ed esco
                        //rs.Close();

                    }

                    if (conn == null)
                    {
                        trans.Commit();
                    }
                    if (conn == null)
                    {
                        cnLocal.Close();
                    }

                    rs = null;
                    cnLocal = null;

                    //ReleaseCollection();
                    //ReleaseCollection();
                    Columns = null;
                    ColumnsProperty = null;

                }



            }
            catch (Exception ex)
            {
                //'If Not rs Is Nothing Then rs.Close
                //ReleaseCollection();
                //ReleaseCollection();
                Columns = null;
                ColumnsProperty = null;

                //if (conn == null){
                trans.Rollback();
                //}
                //if (conn == null){
                conn.Close();
                //}
                if (cnLocal != null)
                {
                    cnLocal.Close();
                }
                rs = null;
                cnLocal = null;

                boolToReturn = false;
                Request_Form = null;

                objDocument.Msg = ApplicationCommon.CNV("Errore nel salvataggio " + Caption + " - " + ex.Message, session);
            }

            return boolToReturn;

        }

        public void ToPrint(EprocResponse response, Session.ISession OBJSESSION)
        {
            bool tbOpen;

            tbOpen = false;

            InitLocal(OBJSESSION);

            //'-- apro la div
            response.Write(@"<div class=""Total"" id=""" + Id + @""" name=""" + Id + @"""  >");

            //'-- se il documento non � nuovo ( se nuovo il documento contiene nell'id 'newN'
            if (IsNumeric(mp_idDoc))
            {

                response.Write(@"<table width=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0"" ><tr><td valign=""top""  width=""100%""  >");
                tbOpen = true;

                mp_objGridCicle.Editable = false;
                mp_objGridCicle.PrintMode = true;
                mp_objGridCicle.Html(response);

                response.Write(@"<br/></td></tr>");

                response.Write(@"<tr><td valign=""top""  width=""100%""  >");

                mp_objGridStep.Editable = false;
                mp_objGridStep.PrintMode = true;
                mp_objGridStep.Html(response);

                response.Write("<br/></td></tr>");

            }
            //'---------------------------------------------------------------------
            //'-- aggiungo il modello dei due campi per gli allegati e le note se il documento � in carico
            //'---------------------------------------------------------------------

            if (tbOpen == true)
            {
                response.Write("</table>");
            }

            response.Write("</div>");
        }

        public void toPrintExtraContent(EprocResponse response, Session.ISession OBJSESSION, string _params = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {

        }

        public void UpdateContentInMem(Session.ISession session, IFormCollection? Request_Form = null)
        {
            //Dim Request_Form As Object
            //Set Request_Form = session(RequestForm)
            if (Request_Form != null)
                mp_objMod.UpdFieldsValue(Request_Form);
            else
                mp_objMod.UpdFieldsValue(this.Request_Form);
            //'-- aggiorna l'area di memoria con i campi del modello per note e allegato
            SaveInMem(session);

        }

        public void xml(EprocResponse ScopeLayer)
        {
            addXmlSection(Id, TypeSection, ScopeLayer);

            mp_objGridCicle.xml(ScopeLayer, "CICLE");
            mp_objGridStep.xml(ScopeLayer, "STEPS");

            ScopeLayer.Write(@"<MODEL id=""" + mp_objMod.id + @""">" + Environment.NewLine);

            mp_objMod.xml(ScopeLayer);

            ScopeLayer.Write(@"</MODEL>" + Environment.NewLine);

            closeXmlSection(Id, ScopeLayer);
        }

        public void InitLocal(Session.ISession session)
        {
            //On Error Resume Next

            mp_suffix = session[Session.SessionProperty.SESSION_SUFFIX];
            if (string.IsNullOrEmpty(mp_suffix))
            {
                mp_suffix = "I";
            }


            mp_strConnectionString = ApplicationCommon.Application.ConnectionString;
            Request_QueryString = GetQueryStringFromContext(_context.Request.QueryString);
            this.Request_Form = _context.Request.HasFormContentType ? _context.Request.Form : null;


            mp_User = CLng(session[Session.SessionProperty.SESSION_USER]);
            mp_Permission = CStr(session[Session.SessionProperty.SESSION_PERMISSION]);
        }

        /// <summary>
        /// '-- recupera dalla sessione di lavoro ASP le variabili per gestire la griglia paginata
        /// </summary>
        /// <param name="session"></param>
        /// <returns></returns>
        private bool IsInMem(Session.ISession session)
        {
            //Dim sessionASP As Object
            string strSecName;

            if (objDocument.ReadOnly == true || UCase(GetParam(param, "READONLY")) == "YES")
            {
                //IsInMem = False
                //Exit Function
                return false;
            }

            strSecName = "DOC_SEC_MEM_" + objDocument.Id + "_" + objDocument.mp_IDDoc + "_" + Id;

            //Set sessionASP = session(OBJSESSION)

            //'-- verifica se la sezione ha delle aree di memoria in sessione
            if (!string.IsNullOrEmpty(session[strSecName]))
            {
                return true;
            }
            else
            {
                return false;
            }

            //Set sessionASP = Nothing
        }

        /// <summary>
        /// '-- salva inella sessione di lavoro ASP le variabili per gestire la griglia paginata
        /// </summary>
        private void SaveInMem(Session.ISession session)
        {

            string strSecName;


            if (objDocument.ReadOnly || UCase(GetParam(param, "READONLY")) == "YES")
            {
                return;
            }

            strSecName = "DOC_SEC_MEM_" + objDocument.Id + "_" + objDocument.mp_IDDoc + "_" + Id;


            session[strSecName] = "yes";
            CommonDbFunctions cdf = new CommonDbFunctions();
            session[strSecName + "_mp_rsCicle"] = cdf.getSerializedTS(mp_rsCicle);
            session[strSecName + "_mp_rsCicleStep"] = cdf.getSerializedTS(mp_rsCicleStep);
            session[strSecName + "_Note"] = (mp_objMod.Fields["APS_Note"].Value != null) ? mp_objMod.Fields["APS_Note"].Value : "";
            session[strSecName + "_Allegato"] = (mp_objMod.Fields["APS_Allegato"].Value != null) ? mp_objMod.Fields["APS_Allegato"].Value : "";

            try
            {
                session[strSecName + "_NextApprover"] = (mp_objMod.Fields["APS_NextApprover"].Value != null) ? mp_objMod.Fields["APS_NextApprover"].Value : "";
            }
            catch { }

            session[strSecName + "_mp_InCharge"] = mp_InCharge;
            session[strSecName + "_mp_InCompiler"] = mp_InCompiler;

        }

        /// <summary>
        /// '-- recupera dalla sessione di lavoro ASP le variabili
        /// </summary>
        /// <param name="session"></param>
        private void LoadFromMem(Session.ISession session)
        {

            string strSecName;

            if (objDocument.ReadOnly == true || UCase(GetParam(param, "READONLY")) == "YES")
            {
                return;
            }

            strSecName = "DOC_SEC_MEM_" + objDocument.Id + "_" + objDocument.mp_IDDoc + "_" + Id;

            //'-- verifica se la sezione ha delle aree di memoria in sessione
            if (!string.IsNullOrEmpty(session[strSecName]))
            {
                CommonDbFunctions cdf = new CommonDbFunctions();

                mp_rsCicle = cdf.getDeserializedTS(session[strSecName + "_mp_rsCicle"]);
                mp_rsCicleStep = cdf.getDeserializedTS(session[strSecName + "_mp_rsCicleStep"]);
                mp_objMod.Fields["APS_Note"].Value = session[strSecName + "_Note"];
                mp_objMod.Fields["APS_Allegato"].Value = session[strSecName + "_Allegato"];

                try
                {
                    mp_objMod.Fields["APS_NextApprover"].Value = session[strSecName + "_NextApprover"];
                }
                catch
                {

                }

                mp_InCharge = CBool(session[strSecName + "_mp_InCharge"]);
                mp_InCompiler = CBool(session[strSecName + "_mp_InCompiler"]);

            }

        }

        public void AddRecord(Session.ISession session, int fromRow = -1, bool bCount = true)
        {
            throw new NotImplementedException();
        }

        public void UpdRecord(Session.ISession session)
        {
            throw new NotImplementedException();
        }

        public int GetIndexColumn(string strAttrib)
        {
            throw new NotImplementedException();
        }
    }

    public class Sec_Caption : ISectionDocument
    {
        public string Id { get; set; }
        public string Caption { get; set; }
        public string strTable { get; set; }
        public string strFieldId { get; set; }
        public string strFieldIdRow { get; set; }
        public string strTableFilter { get; set; }
        public string strModelName { get; set; }
        public long PosPermission { get; set; }
        public string mp_idDoc { get; set; }
        public Toolbar ObjToolbar { get; set; }
        public string strHelp { get; set; }
        public CTLDOCOBJ.Document objDocument { get; set; }
        public string param { get; set; }
        public string TypeSection { get; set; }
        public Model mp_Mod { get; set; }
        public Dictionary<string, Field> mp_Columns { get; set; }
        public dynamic[,] mp_Matrix { get; set; }
        public Dictionary<string, Field> mp_ColumnsC { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public Dictionary<string, Field> mp_ColumnsS { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public TSRecordSet mp_rsCicle { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public TSRecordSet mp_rsCicleStep { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public int mp_numRec { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }

        //'---------------------------------------------------------------------------
        //'-- Elementi personali della sezione
        //'---------------------------------------------------------------------------

        private long mp_User; //'-- identificativo dell'utente che ha caricato il documento
        private string mp_suffix;
        private string mp_strConnectionString;
        private string mp_Permission;

        private string mp_idSectionTable; //'-- identificativo della riga di tabella riferita alla sezione
        //'-- il suo valore va usato con il campo strFieldIdRow
        //'-- se � pieno significa che ci si riferisce al record il cui campo contiene questo valore

        //'-- la sezione Caption possiede un modello per la visualizzazione delle informazioni
        public Window mp_Win;

        private bool mp_editable;

        private string Request_QueryString;

        private readonly EprocResponse _response;
        private readonly HttpContext _context;
        private readonly Session.ISession _session;

        public Sec_Caption(HttpContext context, Session.ISession session, EprocResponse response)
        {
            TypeSection = "CAPTION";
            this._context = context;
            this._session = session;
            _response = response;
        }


        public bool CanSave(Session.ISession session)
        {
            bool boolToReturn = false;
            //'-- controlla che i campi obbligatori siano stati inseriti

            if (!mp_editable)
            {
                boolToReturn = true;
                return boolToReturn;
            }

            mp_Mod.CleanError();

            if (mp_Mod != null)
            {

                string strObbligField;

                strObbligField = GetParam(param, "OBLIG_FIELD");

                if (!string.IsNullOrEmpty(strObbligField))
                {

                    if (CheckObblig(strObbligField, session))
                    {
                        boolToReturn = false;
                        objDocument.Msg = ApplicationCommon.CNV("Salvataggio non possibile per mancanza informazioni", session);
                    }
                    else
                    {
                        boolToReturn = true;
                    }

                }
                else
                {

                    if (mp_Mod.CheckObblig())
                    {
                        boolToReturn = false;
                        objDocument.Msg = ApplicationCommon.CNV("Salvataggio non possibile per mancanza informazioni", session);
                    }
                    else
                    {
                        boolToReturn = true;
                    }

                }

                if (mp_Mod.checkValidation())
                {
                    boolToReturn = false;
                    objDocument.Msg = ApplicationCommon.CNV("Salvataggio non possibile per informazioni scorrette", session);
                }

                if (!boolToReturn)
                {
                    SetObbligML(session);
                }

            }
            return boolToReturn;
        }

        public void Excel(EprocResponse response, Session.ISession OBJSESSION)
        {
            //'-- apro la div
            response.Write(@"<div class=""cover"" id=""" + Id + @""" name=""" + Id + @"""  >");


            //'-- disegno il modello
            if (mp_Mod != null)
            {


                mp_Mod.Excel(response);


            }
            else
            {
                response.Write("Il modello [" + Id + "] di copertina non è stato avvalorato");
            }


            //'-- chiudo la div
            response.Write("</div><br/>");
        }

        public void Html(EprocResponse response, Session.ISession OBJSESSION)
        {
            string strCause = "";
            try
            {


                string strJSOnLoad;


                //'--centro il tutto se richiesto
                if (UCase(GetParam(param, "CENTER")) == "YES")
                {
                    response.Write("<center>");
                }


                //'-- apro la div
                response.Write(@"<div class=""cover"" id=""" + Id + @""" name=""" + Id + @"""  >");



                //'-- disegno il modello
                if (mp_Mod != null)
                {


                    if (objDocument.ReadOnly || !mp_editable)
                    {

                        mp_Mod.Editable = false;

                    }
                    else
                    {


                        //'-- se il modello è editabile ed è stato passato il parametro di cifratura sulla sezione
                        if (Strings.Left(GetParam(param, "CRYPT"), 3) == "YES")
                        {

                            int tmpk;

                            for (tmpk = 0; tmpk < mp_Mod.Fields.Count; tmpk++)
                            {
                                //'-- se è un allegato
                                if (mp_Mod.Fields.ElementAt(tmpk).Value.getType() == 18)
                                {

                                    if (Trim(CStr(mp_Mod.Fields.ElementAt(tmpk).Value.strFormat)) == "")
                                    {
                                        mp_Mod.Fields.ElementAt(tmpk).Value.strFormat = "INTC";
                                    }
                                    else
                                    {
                                        mp_Mod.Fields.ElementAt(tmpk).Value.strFormat = mp_Mod.Fields.ElementAt(tmpk).Value.strFormat + "C";
                                    }

                                }
                            }

                        }

                    }

                    string fieldNotEdit;
                    fieldNotEdit = GetParam(param, "COLUMN_NOT_EDITABLE");


                    strCause = "Setto i campi non editabili tramite il COLUMN_NOT_EDITABLE";


                    //'-- se è stato indicato il campo dei non editabili determina in che posizione della matrice si trova
                    if (!string.IsNullOrEmpty(fieldNotEdit))
                    {
                        string val;
                        int i;

                        if (!IsNull(mp_Mod.Fields[fieldNotEdit].Value))
                        {

                            val = UCase(CStr(mp_Mod.Fields[fieldNotEdit].Value));
                            for (i = 1; i <= mp_Mod.Fields.Count; i++)
                            {
                                if (InStrVb6(1, val, " " + UCase(mp_Mod.Fields.ElementAt(i - 1).Value.Name) + " ") > 0)
                                {
                                    mp_Mod.Fields.ElementAt(i - 1).Value.SetEditable(false);
                                }
                            }


                        }
                        else
                        {
                            throw new Exception("CtlDocument.Sec_Caption.html()" + fieldNotEdit + " è null");
                        }


                    }



                    if (UCase(GetParam(param, "SEC_FIELD")) == "YES")
                    {
                        mp_Mod.id = Id + "_MODEL";
                        mp_Mod.UseNameOnField = 1;
                    }



                    strCause = "Disegno il modello";


                    if (LCase(GetParam(param, "WIN")) != "no")
                    {
                        mp_Win.Html(response, mp_Mod);
                    }
                    else
                    {
                        mp_Mod.Html(response);
                    }


                    mp_Mod.UseNameOnField = 0;

                    //'--esegue jscript onload
                    response.Write(@"<script  type=""text/javascript"">" + Environment.NewLine);
                    strJSOnLoad = GetParam(param, "JSOnLoad");
                    if (LCase(strJSOnLoad) == "yes")
                    {


                        response.Write(this.Id + "_OnLoad(); ");


                    }
                    response.Write("</script>" + Environment.NewLine);


                }
                else
                {
                    response.Write("Il modello [" + Id + "] di copertina non è stato avvalorato");
                }



                //'-- chiudo la div
                response.Write("</div><br/>");


                //'--centro il tutto se richiesto
                if (UCase(GetParam(param, "CENTER")) == "YES")
                {
                    response.Write("</center>");
                }

                //'-- aggiungo un iframe per eventuali comandi
                response.Write(HTML_iframe(Id + "_Command_" + mp_idDoc, "../loading.html", 0, @" style=""display:none"" "));

            }
            catch (Exception ex)
            {
                string save_err;
                save_err = ex.Message;

                TraceErr(ex, ApplicationCommon.Application.ConnectionString, $"Sec_caption.html() strCause = {strCause} - StackTrace : {ex.ToString()}");

                throw new Exception(strCause + " - ERR:" + save_err, ex);
            }
        }

        public void Init(string pId, string model, string pCaption, string pTable, string pstrFieldId, string pFieldIdRow, string pTableFilter, string strToolbar, string help, Session.ISession session)
        {
            Id = pId;
            strTable = pTable;
            Caption = ApplicationCommon.CNV(pCaption, session);
            strFieldId = pstrFieldId;
            strHelp = help;
            strFieldIdRow = pFieldIdRow;

            if (string.IsNullOrEmpty(strFieldIdRow))
            {
                strFieldIdRow = strFieldId;
            }
            strTableFilter = pTableFilter;

            mp_suffix = CStr(session[Session.SessionProperty.SESSION_SUFFIX]);
            if (string.IsNullOrEmpty(mp_suffix))
            {
                mp_suffix = "I";
            }
            mp_strConnectionString = ApplicationCommon.Application.ConnectionString;
            mp_User = CLng(session[Session.SessionProperty.SESSION_USER]);
            mp_Permission = CStr(session[Session.SessionProperty.SESSION_PERMISSION]);

            //'-- carica il modello associato alla caption
            strModelName = model;

            mp_Win = new Window();
            mp_Win.Path = "../images/window/style";
            mp_Win.Init(Id + "_win", Caption, true, Window.Label);
            mp_Win.width = "100%";
            mp_Win.PositionAbsolute = false;

            Request_QueryString = GetQueryStringFromContext(_context.Request.QueryString);
        }

        public void InitializeFrom(Session.ISession OBJSESSION, string param)
        {
            mp_editable = !BasicDocument.isReadOnlySection(param, mp_idDoc, CStr(mp_User), mp_strConnectionString);

            if (!string.IsNullOrEmpty(GetParam(this.param, "VIEW_FROM")))
            {
                ReadFrom(OBJSESSION, param);
            }
        }

        public void InitializeNew(Session.ISession OBJSESSION, string idDoc)
        {
            bool bEditable;
            TSRecordSet rsMod;
            string strModel;

            bEditable = true;

            mp_editable = !BasicDocument.isReadOnlySection(param, mp_idDoc, CStr(mp_User), mp_strConnectionString, Request_QueryString);

            //'-- per la copertina non è necessario effettuare operazioni
            mp_idDoc = idDoc;

            if (mp_Mod == null)
            {

                LibDbModelExt objDB = new LibDbModelExt();

                if (objDocument.ReadOnly || !mp_editable)
                {
                    bEditable = false;
                }


                //'-- recupero il nome del modello dinamicamente se previsto
                if (GetParam(param, "DYNAMIC_MODEL") == "yes")
                {
                    if (UCase(Strings.Left(mp_idDoc, 3)) != "NEW")
                    {
                        CommonDbFunctions cdb = new CommonDbFunctions();

                        var sqlParams = new Dictionary<string, object?>();
                        sqlParams.Add("@Id", Id);
                        sqlParams.Add("@mp_idDoc", CInt(mp_idDoc));
                        rsMod = cdb.GetRSReadFromQuery_("Select MOD_Name from CTL_DOC_SECTION_MODEL with(nolock) where DSE_ID = @Id and IdHeader = @mp_idDoc", mp_strConnectionString, sqlParams);
                        if (rsMod.RecordCount > 0)
                        {
                            rsMod.MoveFirst();
                            strModel = CStr(rsMod["MOD_Name"]);
                            strModelName = strModel;
                        }
                    }
                }

                if (UCase(GetParam(param, "SAVE_MODEL")) == "YES")
                {
                    mp_Mod = objDB.GetFilteredModelCTL(strModelName, mp_suffix, mp_User, OBJSESSION, 0, mp_strConnectionString, IIF(objDocument.PrintMode, false, bEditable), mp_idDoc);
                }
                else
                {
                    mp_Mod = objDB.GetFilteredModelCTL(strModelName, mp_suffix, mp_User, OBJSESSION, 0, mp_strConnectionString, IIF(objDocument.PrintMode, false, bEditable));
                }

                if (IsInMem(OBJSESSION))
                {
                    LoadFromMem(OBJSESSION);
                }

                //'-- mette l'owner del documento
                if (!string.IsNullOrEmpty(GetParam(param, "FIELD_OWNER")))
                {
                    mp_Mod.SetFieldValue(GetParam(param, "FIELD_OWNER"), mp_User);
                }

            }
            else
            {
                //'-- altrimenti salvo il Modello in memoria
                if (UCase(GetParam(param, "SAVE_MODEL")) == "YES")
                {
                    if (string.IsNullOrEmpty(OBJSESSION["CTL_MODEL_" + strModelName + "_" + mp_idDoc]))
                    {
                        LibDbModelExt objDb = new LibDbModelExt();
                        objDb.SaveModelInCache(OBJSESSION, "CTL_MODEL_" + strModelName + "_" + mp_idDoc, mp_Mod.Fields, mp_Mod.PropFields, mp_suffix, mp_User, CInt(0), mp_strConnectionString, OBJSESSION, bEditable, mp_Mod.Template, mp_Mod.param, mp_idDoc);
                    }

                }

            }
        }

        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library")
        {
            //On Error Resume Next

            if (mp_Mod != null)
            {
                mp_Mod.JScript(JS, Path);
            }
            if (mp_Win != null)
            {
                mp_Win.JScript(JS, Path);
            }
        }

        public void Load(Session.ISession session, string idDoc, SqlConnection? prevConn = null)
        {
            mp_idDoc = idDoc;

            mp_editable = !BasicDocument.isReadOnlySection(param, mp_idDoc, CStr(mp_User), mp_strConnectionString, Request_QueryString, prevConn);

            Read(session, prevConn);

        }

        public bool Save(Session.ISession session, ref string ReferenceKey, Dictionary<dynamic, dynamic> mpMEM, SqlConnection conn, SqlTransaction trans)
        {
            bool boolToReturn;
            TSRecordSet rsMod;
            string strCause = "";
            IFormCollection? Request_Form;

            try
            {

                if (!mp_editable)
                {
                    boolToReturn = true;
                    return boolToReturn;
                }

                bool bWRITE_VERTICAL;

                bWRITE_VERTICAL = (LCase(GetParam(param, "WRITE_VERTICAL")) == "yes");

                boolToReturn = true;

                Request_Form = this._context.Request.HasFormContentType ? this._context.Request.Form : null;

                string strModel = "";

                //'-- nel caso di record nuovo
                if ((LCase(Strings.Left(ReferenceKey, 3)) == "new" ||
                        string.IsNullOrEmpty(ReferenceKey) ||
                        (string.IsNullOrEmpty(mp_idSectionTable) && strFieldId != strFieldIdRow)) &&
                        !bWRITE_VERTICAL)
                {

                    strCause = "blocco IF caso nuovo record";

                    //'-- nella terza condizione di or si indica che se non è presente un record di riferimento per la sezione
                    //'-- e la sezione si basa su una tabella differente da quella di base allora è da inserire il record
                    mp_idSectionTable = ReferenceKey;
                    mp_idSectionTable = Add(objDocument.Id + "_" + Id + "_SAVE", Request_Form, conn, session, trans);

                    //'-- se il campo chiave è uguale a quello di riga
                    //'-- oppure quello di riga è vuoto vuol dire che la tabella è quella del documento
                    //'-- in tal caso se il docuemnto è nuovo
                    //'-- si preleva il nuovo ID e si ritorna in ReferenceKey
                    if (UCase(strFieldId) == UCase(strFieldIdRow) || string.IsNullOrEmpty(strFieldIdRow))
                    {
                        ReferenceKey = mp_idSectionTable;
                    }

                }
                else
                {

                    if (string.IsNullOrEmpty(mp_idSectionTable) || bWRITE_VERTICAL)
                    {
                        //'-- Da gestire meglio, funziona solo se le copertine sono sulla stessa tabella
                        mp_idSectionTable = ReferenceKey;
                    }

                    strCause = "Composizione nome modello di salvataggio";

                    strModel = objDocument.Id + "_" + Id + "_SAVE";

                    //'-- recupero il nome del modello dinamicamente se previsto
                    if (GetParam(param, "DYNAMIC_MODEL_SAVE") == "yes")
                    {
                        strCause = "select per CTL_DOC_SECTION_MODEL";

                        CommonDbFunctions cdb = new CommonDbFunctions();
                        var sqlParams = new Dictionary<string, object?>();
                        sqlParams.Add("@Id", $"{Id}_SAVE");
                        sqlParams.Add("@mp_idDoc", CInt(mp_idDoc));
                        rsMod = cdb.GetRSReadFromQuery_("select MOD_Name from CTL_DOC_SECTION_MODEL with(nolock) where DSE_ID = @Id and IdHeader = @mp_idDoc", mp_strConnectionString, sqlParams);
                        if (rsMod.RecordCount > 0)
                        {
                            rsMod.MoveFirst();
                            strModel = CStr(rsMod["MOD_Name"]);
                        }
                    }

                    strCause = "Invocazione metodo di salvataggio 'Upd'";

                    //'-- nel caso di salvataggio
                    Upd(strModel, Request_Form, conn, session, trans);
                }

                string[] v_C;

                //'-------------------
                //'-- CRYPT ----------
                //'-------------------
                //'-- nel caso della cifratura dopo il salvataggio si richiede la cifratura dei dati
                if (Strings.Left(GetParam(param, "CRYPT"), 3) == "YES")
                {
                    strCause = "Richiesta cifratura della sezione";

                    string attreccezzioni;
                    string strFilter;

                    strFilter = string.Empty;
                    v_C = Strings.Split(GetParam(param, "CRYPT"), "~");

                    if ((v_C.Length - 1) >= 1)
                    {
                        attreccezzioni = v_C[1];
                    }
                    else
                    {
                        attreccezzioni = "";
                    }

                    if (bWRITE_VERTICAL)
                    {
                        strFilter = $" DSE_ID = '{Id}' ";
                    }

                    strCause = "Invocazione stored AFS_CRYPT_DATI";
                    CommonDbFunctions cdb = new CommonDbFunctions();
                    var sqlParams = new Dictionary<string, object?>();
                    sqlParams.Add("@strTable", strTable);
                    sqlParams.Add("@strFieldId", strFieldId);
                    sqlParams.Add("@ReferenceKey", ReferenceKey);
                    sqlParams.Add("@strModel", strModel);
                    sqlParams.Add("@attreccezzioni", attreccezzioni);
                    //sqlParams.Add("@strFilter", strFilter);
                    cdb.ExecuteWithTransaction($"exec AFS_CRYPT_DATI @strTable, @strFieldId, @ReferenceKey, @strModel, @attreccezzioni, '{strFilter}'", ApplicationCommon.Application.ConnectionString, conn, trans, parCollection: sqlParams);
                }

                return boolToReturn;
            }
            catch (Exception ex)
            {
                boolToReturn = false;
                Request_Form = null;

                if (LCase(CStr(ApplicationCommon.Application["dettaglio-errori"])) == "yes")
                {
                    objDocument.Msg = $"Errore nel salvataggio {Caption} - {strCause} - {ex.Message}";
                }
                else
                {
                    objDocument.Msg = ApplicationCommon.CNV("INFO_UTENTE_ERRORE_PROCESSO", session) + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
                }

                TraceErr(ex, ApplicationCommon.Application.ConnectionString, $"Sec_Caption.save() - {strCause} - {ex.ToString()}");

                throw new Exception("CtlDocument.Sec_Caption.Save( ) - " + strCause, ex);
            }

        }

        public void ToPrint(EprocResponse response, Session.ISession OBJSESSION)
        {
            string strJSOnLoad;
            int numCol;
            int c;


            //'--centro il tutto se richiesto
            if (UCase(GetParam(param, "CENTER")) == "YES")
            {
                response.Write("<center>");
            }

            //'-- apro la div
            response.Write(@"<div class=""cover"" id=""" + Id + @""" name=""" + Id + @"""  >");


            //'-- disegno il modello
            if (mp_Mod != null)
            {

                mp_Mod.Editable = false;
                mp_Mod.PrintMode = true;

                if (UCase(GetParam(param, "SEC_FIELD")) == "YES")
                {
                    mp_Mod.id = Id + "_MODEL";
                    mp_Mod.UseNameOnField = 1;
                }

                if (LCase(GetParam(param, "WIN")) != "no")
                {
                    mp_Win.Html(response, mp_Mod);
                }
                else
                {
                    mp_Mod.Html(response);
                }

                //'--esegue jscript onload
                response.Write(@"<script type=""text/javascript"">" + Environment.NewLine);
                strJSOnLoad = GetParam(param, "JSOnLoad");
                if (LCase(strJSOnLoad) == "yes")
                {

                    response.Write(this.Id + "_OnLoad(); ");

                }
                response.Write("</script>" + Environment.NewLine);

            }
            else
            {
                response.Write("Il modello [" + Id + "] di copertina non è stato avvalorato");
            }


            //'-- chiudo la div
            response.Write("</div><br/>");

            //'--centro il tutto se richiesto
            if (UCase(GetParam(param, "CENTER")) == "YES")
            {
                response.Write("</center>");
            }
        }

        public void toPrintExtraContent(EprocResponse response, Session.ISession OBJSESSION, string _params = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {

            int numCol;
            int c;

            numCol = mp_Mod.Fields.Count;

            for (c = 0; c < numCol; c++)
            {
                try
                {
                    mp_Mod.Fields.ElementAt(c).Value.toPrintExtraContent(response, OBJSESSION, _params, startPage, strHtmlHeader, strHtmlFooter, contaPagine);
                }
                catch { }
            }

        }

        public void UpdateContentInMem(Session.ISession session, IFormCollection? Request_Form)
        {

            if (mp_Mod != null)
            {
                //'--   nel caso si adotti di nomi specifici per sezione si recuperano i dati manualmente
                if (UCase(GetParam(param, "SEC_FIELD")) == "YES")
                {
                    mp_Mod.id = Id + "_MODEL";
                    mp_Mod.UseNameOnField = 1;
                }

                mp_Mod.UpdFieldsValue(Request_Form);

                mp_Mod.UseNameOnField = 0;

            }
            SaveInMem(session);

        }

        public void xml(EprocResponse ScopeLayer)
        {

            addXmlSection(Id, TypeSection, ScopeLayer);

            mp_Mod.xml(ScopeLayer);

            closeXmlSection(Id, ScopeLayer);
        }


        /// <summary>
        /// il metodo Command di una sezione norlmamente � invocato direttamente da una pagina per eseguire
        /// un comando il cui scopo � influenzare la sezione di pertinenza di provenienza
        /// ad esempio l'aggiunta di un record in una griglia
        /// </summary>
        /// <param name="session"></param>
        /// <param name="response"></param>
        public void Command(Session.ISession session, EprocResponse response)
        {

            //'--initilocal session

            string[] vcommand;


            //'-- recupera il comando da eseguire
            vcommand = Strings.Split(CStr(GetParamURL(Request_QueryString, "COMMAND")), ".");

            switch (UCase(vcommand[1]))
            {

                case "RELOAD":

                    RemoveMem(session);
                    Load(session, mp_idDoc);

                    //'--se richiesto non disegna l'output
                    if (GetParamURL(Request_QueryString.ToString(), "OUTPUT") != "NO")
                    {

                        //'-- disegna la SEZIONE
                        Html(response, session);

                        //'-- inserisce il comando per sostituirla nel documento
                        response.Write($@"<script type=""text/javascript"" language=""javascript"" >;");
                        response.Write($@"       try {{ parent.getObj( '" + Id + "' ).innerHTML = ");
                        response.Write($@"       getObj( '" + Id + "' ).innerHTML; }} catch( e ) {{ }};");
                        response.Write($@"</script>" + Environment.NewLine);

                    }
                    break;
                default:
                    break;

            }


            response.Write($@"<script type=""text/javascript"" language=""javascript"" >;");
            response.Write($@"       try {{ ");
            response.Write($@"       parent." + Id + "_AFTER_COMMAND( '" + UCase(vcommand[1]) + "' ); }} catch( e ) {{ }};");
            response.Write($@"</script>" + Environment.NewLine);

            SaveInMem(session);


        }


        private string Add(string strModel, IFormCollection? Request_Form, SqlConnection? conn = null, Session.ISession? session = null, SqlTransaction? trans = null)
        {

            string strCause = "";
            try
            {

                string strSql;
                SqlConnection cnLocal;
                TSRecordSet rs = new TSRecordSet();

                Dictionary<string, Field> Columns = new Dictionary<string, Field>();
                Dictionary<string, Grid_ColumnsProperty> ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();

                int i;
                int nc;


                //'-- apro la connessione
                if (conn == null)
                {
                    cnLocal = new SqlConnection(mp_strConnectionString);
                    cnLocal.Open();
                    trans = cnLocal.BeginTransaction();
                }
                else
                {
                    cnLocal = conn;
                }


                LibDbModelExt objDB = new LibDbModelExt();


                objDB.GetFilteredFieldsCTL(strModel, ref Columns, ref ColumnsProperty, "I", mp_User, 0, mp_strConnectionString, session, true, "");

                string newID;
                nc = Columns.Count;
                if (nc > 0)
                {


                    //'-- prendo il recordset dei clienti
                    strSql = $"select * from {strTable} where {strFieldIdRow} = -1 ";
                    rs.Open(strSql, ApplicationCommon.Application.ConnectionString, connection: cnLocal, transaction: trans);

                    //'-- aggiungo il nuovo record prelevando i dati dal modello
                    DataRow dr = rs.AddNew();

                    dynamic? valoreCampo;

                    //'-- mette l'owner del documento
                    if (!string.IsNullOrEmpty(GetParam(param, "FIELD_OWNER")))
                    {
                        strCause = "Setto il campo FIELD_OWNER";
                        dr[GetParam(param, "FIELD_OWNER")] = mp_User;
                    }

                    //'-- per ogni campo del modello prelevo il valore dal form e lo memorizzo nel RS
                    for (i = 1; i <= nc; i++)
                    {// To nc
                        Field objField = Columns.ElementAt(i - 1).Value;

                        //'-- PRENDO IL VALORE DAL MODELLO ALTRIMENTI DAL FORM
                        //'-- PERCHE' ALCUNI CAMPI POTREBBERO NON ESSERE SU QUESTO MODELLO
                        //On Error Resume Next
                        try
                        {
                            valoreCampo = mp_Mod.Fields[objField.Name].RSValue();
                            strCause = "Setto sulla tabella il campo " + objField.Name;
                            dr[objField.Name] = valoreCampo == null ? DBNull.Value : valoreCampo;

                        }
                        catch
                        {

                            //err.Clear
                            //On Error GoTo Herr

                            strCause = "Recupero il valore di " + objField.Name;

                            //'-- Controllo di sicurezza per xss. sui tipi text e textArea
                            if ((objField.getType() == 1 || objField.getType() == 3))
                            {

                                if (CStr(objField.strFormat).Contains("H", StringComparison.Ordinal))
                                {



                                    if (GetValueFromForm(Request_Form, objField.Name).Contains("<script>", StringComparison.Ordinal) || GetValueFromForm(Request_Form, objField.Name).Contains("<meta>", StringComparison.Ordinal))
                                    {
                                        BlackList objDBBL = new BlackList();//CreateObject("ctldb.BlackList")
                                        //'-- Se non siamo in modalit� di sviluppo aggiungiamo l'ip alla blacklist
                                        if (!objDBBL.isDevMode(session))
                                        {
                                            objDBBL.addIp(objDBBL.getAttackInfo(_context, CStr(session["IdPfu"]), ATTACK_QUERY_TABLE), session, mp_strConnectionString);
                                            strCause = ApplicationCommon.CNV("Attacco alla sicurezza", session);
                                            //err.Number = -1
                                            //err.Raise - 1, "SEC_Caption.Add", CNV("Ip bloccato. Inviati dati malevoli", session)
                                            throw new Exception("SEC_Caption.Add" + ApplicationCommon.CNV("Ip bloccato. Inviati dati malevoli"));
                                            //Exit Function
                                        }
                                    }




                                }

                            }

                            objField.Value = GetValueFromForm(Request_Form, objField.Name);
                            valoreCampo = objField.RSValue();
                            strCause = "Setto sulla tabella il campo " + objField.Name;
                            try
                            {
                                dr[objField.Name] = valoreCampo == null ? DBNull.Value : valoreCampo;
                            }
                            catch { }

                        }
                        //Set objField = Nothing
                    }

                    //On Error GoTo Herr

                    //'-- nel caso � stato definito il field per lo stato il docuemnto viene messo a salvato
                    if (!string.IsNullOrEmpty(GetParam(param, "STATE_FIELD")))
                    {

                        strCause = "Setto il campo FIELD_OWNER";
                        dr[GetParam(param, "STATE_FIELD")] = "Saved";

                    }

                    //'-- se si tratta di una tabella collegata si inserisce il valore della relazione
                    if (strFieldId != strFieldIdRow)
                    {
                        strCause = "Setto il campo di relazione con la tabella del documento :" + strFieldId + "";
                        dr[strFieldId] = mp_idSectionTable;
                    }

                    //OLDCODE
                    //rs.Update(dr, strFieldIdRow, strTable);

                    //'-- recupero l'identificativo del record
                    //'rs.Resync


                    //OLDCODE
                    //newID = CStr(rs.Fields[strFieldIdRow]);

                    //NEWCODE
                    newID = CStr(rs.Update(dr, strFieldIdRow, strTable).id);

                    //'-- chiudo ed esco
                    //rs.Close();

                    //'-- salvo il modello
                    if (UCase(GetParam(param, "SAVE_MODEL")) == "YES")
                    {
                        LibDbModelExt objDB2 = new LibDbModelExt();  //Set objDB = CreateObject("ctldb.lib_dbModelext")
                        objDB2.SaveDocModel(strModelName, session, cnLocal, mp_idDoc, mp_idSectionTable);
                        //Set objDB = Nothing
                    }



                }
                else
                {
                    strCause = "";
                    throw new Exception("SEC_Caption.Add" + "Salvataggio sezione [" + Id + "] manca il modello [" + strModel + "]");
                    //err.Raise -1, "SEC_Caption.Add", "Salvataggio sezione [" & Id & "] manca il modello [" & strModel & "]"

                }
                if (conn == null)
                {
                    trans.Commit();
                    cnLocal.Close();
                }

                return newID;

            }
            catch (Exception ex)
            {

                trans.Rollback();
                conn.Close();

                throw new Exception("CtlDocument.Sec_Caption.Add( ) - " + strCause, ex);
            }

        }


        private void Upd(string strModel, IFormCollection? Request_Form, SqlConnection? conn = null, Session.ISession? session = null, SqlTransaction? trans = null)
        {


            SqlConnection cnLocal;
            //'-- apro la connessione
            if (conn == null)
            {
                cnLocal = new SqlConnection(mp_strConnectionString);
                //'cnLocal.ConnectionTimeout = lTimeout
                cnLocal.Open();
                trans = cnLocal.BeginTransaction();
            }
            else
            {
                cnLocal = conn;
            }

            try
            {

                string strSql;
                TSRecordSet rs = new TSRecordSet();
                Dictionary<string, Field> Columns = new Dictionary<string, Field>();
                Dictionary<string, Grid_ColumnsProperty> ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();
                Field objField;
                int i;
                int nc;

                bool bWRITE_VERTICAL;

                bWRITE_VERTICAL = (LCase(GetParam(param, "WRITE_VERTICAL")) == "yes");




                //rs.CursorLocation = CursorLocationEnum.adUseServer
                //rs.CursorType = adOpenKeyset
                //rs.LockType = adLockPessimistic
                //Set rs.ActiveConnection = cnLocal

                //if (conn Is Nothing Then cnLocal.BeginTrans


                LibDbModelExt objDB = new LibDbModelExt();// CreateObject("ctldb.lib_dbModelext")


                objDB.GetFilteredFieldsCTL(strModel, ref Columns, ref ColumnsProperty, "I", mp_User, 0, mp_strConnectionString, session, true, "");


                nc = Columns.Count;
                if (nc > 0)
                {

                    //'-- in caso in cui il salvataggio � verticale si cancella il contenuto precedente
                    if (bWRITE_VERTICAL)
                    {
                        CommonDbFunctions cdb = new CommonDbFunctions();

                        var sqlParams = new Dictionary<string, object?>();
                        sqlParams.Add("@mp_idSectionTable", CLng(mp_idSectionTable));
                        sqlParams.Add("@Id", Id);

                        cdb.ExecuteWithTransaction($"DELETE from {strTable} where idHeader = @mp_idSectionTable and DSE_ID = @Id", ApplicationCommon.Application.ConnectionString, cnLocal, trans, parCollection: sqlParams);
                    }

                    //'-- prendo il recordset
                    strSql = $"select * from {strTable} where {strFieldIdRow} = {CLng(mp_idSectionTable)}";

                    if (!string.IsNullOrEmpty(strTableFilter))
                    {
                        strSql = strSql + " and " + strTableFilter;
                    }

                    rs.Open(strSql, ApplicationCommon.Application.ConnectionString, connection: cnLocal, transaction: trans);

                    dynamic? valoreCampo;

                    var parCollection = new Dictionary<string, object?>();

                    //'-- per ogni campo del modello prelevo il valore dal form e lo memorizzo nel RS
                    for (i = 1; i <= nc; i++)
                    {
                        objField = Columns.ElementAt(i - 1).Value;

                        //'-- PRENDO IL VALORE DAL MODELLO ALTRIMENTI DAL FORM
                        //'-- PERCHE' ALCUNI CAMPI POTREBBERO NON ESSERE SU QUESTO MODELLO
                        try
                        {
                            if (bWRITE_VERTICAL)
                            {
                                valoreCampo = mp_Mod.Fields[objField.Name].TechnicalValue();
                            }
                            else
                            {
                                valoreCampo = mp_Mod.Fields[objField.Name].RSValue();
                            }

                        }
                        catch
                        {

                            //'-- Controllo di sicurezza per xss. sui tipi text e textArea
                            if (objField.getType() == 1 || objField.getType() == 3)
                            {

                                if (CStr(objField.strFormat).Contains("H", StringComparison.Ordinal))
                                {

                                    if (GetValueFromForm(Request_Form, objField.Name).Contains("<script>", StringComparison.Ordinal) || GetValueFromForm(Request_Form, objField.Name).Contains("<meta>", StringComparison.Ordinal))
                                    {

                                        BlackList objDBBL = new BlackList();
                                        objDBBL.addIp(objDBBL.getAttackInfo(_context, CStr(session["IdPfu"]), ATTACK_QUERY_TABLE), session, mp_strConnectionString);

                                        throw new Exception($@"""SEC_Caption.Add"", " + ApplicationCommon.CNV("Ip bloccato. Inviati dati malevoli", session));

                                    }

                                }

                            }

                            objField.Value = GetValueFromForm(Request_Form, objField.Name);

                            if (bWRITE_VERTICAL)
                            {
                                valoreCampo = objField.TechnicalValue();
                            }
                            else
                            {
                                valoreCampo = objField.RSValue();
                            }


                        }


                        if (bWRITE_VERTICAL)
                        {

                            DataRow dr = rs.AddNew();

                            dr["IdHeader"] = mp_idSectionTable;
                            dr["DSE_ID"] = Id;
                            dr["Row"] = 0;
                            dr["DZT_Name"] = objField.Name;
                            dr["Value"] = valoreCampo;

                            rs.Update(dr, strFieldIdRow, strTable);
                        }
                        else
                        {
                            //'-- Gestiamo i casi di attributi non presenti nel recordset
                            if (rs.ColumnExists(objField.Name))
                            {
                                //rs.Fields[objField.Name] = valoreCampo;
                                if (!parCollection.ContainsKey(objField.Name))
                                {
                                    parCollection.Add(objField.Name, valoreCampo);
                                }
                                else
                                {
                                    parCollection[objField.Name] = valoreCampo;
                                }
                            }
                            
                        }

                    }

                    //'-- nel caso � stato definito il field per lo stato il documento viene messo a salvato
                    if (!string.IsNullOrEmpty(GetParam(param, "STATE_FIELD")))
                    {
                        rs.Fields[GetParam(param, "STATE_FIELD")] = "Saved";
                        parCollection.Add(GetParam(param, "STATE_FIELD"), "Saved");

                    }

                    if (parCollection.Count != 0)
                    {
                        rs.Update(rs.Fields, strFieldIdRow, strTable, parCollection);
                    }

                    //'-- salvo il modello
                    if (UCase(GetParam(param, "SAVE_MODEL")) == "YES")
                    {
                        LibDbModelExt objDB2 = new LibDbModelExt();//CreateObject("ctldb.lib_dbModelext")
                        objDB2.SaveDocModel(strModelName, session, cnLocal, mp_idDoc, mp_idDoc);
                    }

                }
                if (conn == null)
                {
                    trans.Commit();
                    cnLocal.Close();
                }
            }
            catch (Exception ex)
            {
                trans.Rollback();
                cnLocal.Close();

                throw new Exception(" CtlDocument.Sec_Caption.Upd( ), " + ex.Message, ex);
            }
        }

        //'-- ritorna l'identificativo di riga
        private void Read(Session.ISession session, SqlConnection? prevConn = null)
        {

            string strCause = "";
            try
            {

                string strSql;
                TSRecordSet rs;
                TSRecordSet rsMod;

                XmlDocument objXML = new XmlDocument();
                XmlNodeList objNodeList;

                objXML.PreserveWhitespace = true;

                string view;
                string strCon;
                string[] v2;
                bool bVerticalRead;
                string lstrSTORED;

                bVerticalRead = false;

                //'-- SE LA SCRITTURA è VERTICALE PER DEFAULT ANCHE LA LETTURA è VERTICALE
                if (LCase(GetParam(param, "WRITE_VERTICAL")) == "yes")
                {
                    bVerticalRead = true;
                }

                //'-- prendo la lista dai parametri della sezione
                view = GetParam(param, "VIEW");
                if (string.IsNullOrEmpty(view))
                {
                    view = strTable;
                }
                else
                {

                    //'-- controlla se per la vista è prevista la lettura in verticale o orizzontale
                    if (view.Contains('~', StringComparison.Ordinal))
                    {
                        v2 = Strings.Split(view, "~");
                        view = v2[0];
                        if (v2[1] == "V")
                        {
                            bVerticalRead = true;
                        }
                        else
                        {
                            bVerticalRead = false;
                        }
                    }

                }



                //'-------------------
                //'-- CRYPT ----------
                //'-------------------
                string[] v_C;
                v_C = Strings.Split(GetParam(param, "CRYPT"), "~");
                string PresenteCifratura;
                PresenteCifratura = "no";


                //'-- prendo il recordset legato alla tabella principale del documento
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@mp_idDoc", CInt(mp_idDoc));
                strSql = $"select * from {view} where {strFieldId} = @mp_idDoc";

                //'-- se la memorizzazione è in verticale si aggiunge alla condizione il nome della sezione
                if (bVerticalRead)
                {
                    sqlParams.Add("@Id", Id);
                    strSql = $"{strSql} and DSE_ID = @Id";
                }

                if (!string.IsNullOrEmpty(strTableFilter))
                {
                    //BVEP-5944 è stato necessario rimuovere strTableFilter dagli sql parameters in quanto veniva gestito come una stringa
                    //Es con sql parameters:
                    //strSql -> select * from Document_MicroLotti_Dettagli where idHeader = 477989
                    //strTableFilter -> Tipodoc='INFO_ADD_MacchinariAgricoli_1_MOD_Modello_430396 '
                    //diventava -> select * from Document_MicroLotti_Dettagli where idHeader = 477989 and 'Tipodoc='INFO_ADD_MacchinariAgricoli_1_MOD_Modello_430396 ''
                    //
                    //sqlParams.Add("@TableFilter", strTableFilter);
                    //strSql = $"{strSql} and @TableFilter";
                    strSql = $"{strSql} and {strTableFilter}";
                }

                CommonDbFunctions cdb = new CommonDbFunctions();
                //'-------------------
                //'-- CRYPT ----------
                //'-------------------
                //'-- nel caso della cifratura aggiunge la colonna che decifra i dati
                string Fieldkey = string.Empty;
                if (Left(GetParam(param, "CRYPT"), 3) == "YES")
                {
                    PresenteCifratura = "YES";

                    if ((v_C.Length - 1) == 2)
                    {
                        Fieldkey = v_C[2];
                    }
                    else
                    {
                        Fieldkey = strFieldId;
                    }
                }

                //'-- se è presente la stored per recuperare i dati essa sa se deve effettuare decifratura o lettura in verticale
                lstrSTORED = GetParam(param, "STORED");
                if (!string.IsNullOrEmpty(lstrSTORED))
                {
                    sqlParams.Clear();
                    sqlParams.Add("@DocId", Id);
                    sqlParams.Add("@Id", Id);
                    sqlParams.Add("@mp_idDoc", mp_idDoc);
                    sqlParams.Add("@mp_User", mp_User);

                    strSql = $"Exec {lstrSTORED} @DocId, @Id, @mp_idDoc, @mp_User";
                    rs = cdb.GetRSReadFromQuery_(strSql, mp_strConnectionString, parCollection:sqlParams, conn: prevConn);
                }
                else
                {
                    if (PresenteCifratura == "YES")
                    {
                        sqlParams.Clear();
                        sqlParams.Add("@mp_User", CInt(mp_User));
                        sqlParams.Add("@Id", Id);
                        sqlParams.Add("@Fieldkey", Fieldkey);
                        strSql = strSql.Replace("@mp_idDoc", mp_idDoc);
                        strSql = strSql.Replace("@Id", $@"'{Id}'");
                        //sqlParams.Add("@strSql", strSql);  riga commentata in quanto il parametro non viene effettivamente utilizzato ma viene passata la strSql
                        sqlParams.Add("@strTable", strTable);
                        sqlParams.Add("@strFieldIdRow", strFieldIdRow);
                        rs = cdb.GetRSReadFromQuery_("exec AFS_DECRYPT @mp_User, @Id, @Fieldkey, '" + Strings.Replace(strSql, "'", "''") + "' , @strTable, @strFieldIdRow", mp_strConnectionString, parCollection:sqlParams, conn: prevConn);
                    }
                    else
                    {
                        rs = cdb.GetRSReadFromQuery_(strSql, mp_strConnectionString, parCollection: sqlParams, conn: prevConn);
                    }
                }

                //'--memorizzo la chiave del record corrente per futuri UPDATE
                //'-- se la sezione è quella di testata questo valore coincide con mp_idDoc
                if (rs.RecordCount > 0)
                {
                    mp_idSectionTable = CStr(rs[strFieldIdRow]);
                }

                //'-- recupero il nome del modello dinamicamente se previsto
                if (GetParam(param, "DYNAMIC_MODEL") == "yes")
                {
                    sqlParams.Clear();
                    sqlParams.Add("@Id", Id);
                    sqlParams.Add("@mp_idDoc", CInt(mp_idDoc));
                    rsMod = cdb.GetRSReadFromQuery_("select MOD_Name from CTL_DOC_SECTION_MODEL with(nolock) where DSE_ID = @Id and IdHeader = @mp_idDoc", mp_strConnectionString, parCollection: sqlParams, conn: prevConn);
                    if (rsMod.RecordCount > 0)
                    {
                        rsMod.MoveFirst();
                        strModelName = CStr(rsMod["MOD_Name"]);
                    }
                }

                //'-- verifico se il documento è read only
                if (UCase(GetParamURL(Request_QueryString.ToString(), "COMMAND")) != "PRINT")
                {
                    strCon = GetParam(param, "READONLYCONDITION");
                    if (!string.IsNullOrEmpty(strCon) && LCase(GetParam(param, "WRITE_VERTICAL")) != "yes")
                    {

                        strCon = Replace(strCon, "<ID_USER>", mp_User.ToString());

                        //'--sostituisce i valori dei campi sulla condizione
                        int c;
                        int i;
                        c = rs.Columns.Count - 1;

                        for (i = 0; i <= c; i++)
                        {
                            strCon = ReplaceInsensitive(strCon, " " + rs.Columns[i].ColumnName + " ", " '" + ((rs.Fields == null || rs.Fields[i] == null) ? "" : rs.Fields[i]) + "' ");
                        }
                        strCon = Replace(strCon, "#", "=");
                        strCon = Replace(strCon, @"'", @"""");

                        objDocument.ReadOnly = BasicDocument.Eval(strCon, prevConn);
                    }
                }

                bool bEditable;
                bool bIsInMem;
                string fieldsReloaded;

                bEditable = true;
                fieldsReloaded = GetParam(param, "FIELDS_RELOADED"); //'-- Campi ricaricati sempre dal database anche se la sezione � editabile

                if (mp_Mod == null)
                {
                    LibDbModelExt objDB = new LibDbModelExt();
                    if (objDocument.ReadOnly || !mp_editable)
                    {
                        bEditable = false;
                    }

                    if (UCase(GetParam(param, "SAVE_MODEL")) == "YES")
                    {
                        mp_Mod = objDB.GetFilteredModelCTL(strModelName, mp_suffix, mp_User, session, 0, mp_strConnectionString, IIF(objDocument.PrintMode, false, bEditable), mp_idDoc);
                    }
                    else
                    {
                        mp_Mod = objDB.GetFilteredModelCTL(strModelName, mp_suffix, mp_User, session, 0, mp_strConnectionString, IIF(objDocument.PrintMode, false, bEditable), "");
                    }

                    mp_Mod.Editable = bEditable;
                }
                else
                {

                    if (objDocument.ReadOnly || !mp_editable)
                    {
                        bEditable = false;
                    }

                    LibDbModelExt objDB = new();
                    if (mp_Mod.Editable != bEditable)
                    {
                        if (UCase(GetParam(param, "SAVE_MODEL")) == "YES")
                        {
                            mp_Mod = objDB.GetFilteredModelCTL(strModelName, mp_suffix, mp_User, session, 0, mp_strConnectionString, IIF(objDocument.PrintMode, false, bEditable), mp_idDoc);
                        }
                        else
                        {
                            mp_Mod = objDB.GetFilteredModelCTL(strModelName, mp_suffix, mp_User, session, 0, mp_strConnectionString, IIF(objDocument.PrintMode, false, bEditable), "");
                        }
                    }
                    else
                    {
                        //'-- altrimenti salvo il Modello in memoria
                        if (UCase(GetParam(param, "SAVE_MODEL")) == "YES")
                        {
                            if (string.IsNullOrEmpty(session[$"CTL_MODEL_{strModelName}_{mp_idDoc}"]))
                            {
                                objDB.SaveModelInCache(session, $"CTL_MODEL_{strModelName}_{mp_idDoc}", mp_Mod.Fields, mp_Mod.PropFields, mp_suffix, mp_User, CInt(0), mp_strConnectionString, session, bEditable, mp_Mod.Template, mp_Mod.param, mp_idDoc);
                            }
                        }
                    }

                    mp_Mod.Editable = bEditable;
                }

                bIsInMem = IsInMem(session);

                //'--avvaloro il modello
                if (bIsInMem && bEditable && string.IsNullOrEmpty(fieldsReloaded))
                {
                    LoadFromMem(session);
                }
                else
                {
                    //'-- mette l'owner del documento
                    if (!string.IsNullOrEmpty(GetParam(param, "FIELD_OWNER")))
                    {
                        mp_Mod.SetFieldValue(GetParam(param, "FIELD_OWNER"), mp_User);
                    }

                    if (bIsInMem)
                    {
                        LoadFromMem(session);
                    }

                    //'-- carica il modello dalla tabella di sistema in verticale
                    if (bVerticalRead)
                    {
                        if (!rs.EOF)
                        {
                            rs.MoveFirst();

                            while (!rs.EOF)
                            {
                                strCause = $" setto il campo {CStr(rs["DZT_Name"])} - {CStr(rs["Value"])}";

                                //'-- Se devo ricaricare TUTTI i campi oppure il campo sul quale stiamo iterando è presente tra i campi da ricarire
                                if (!bIsInMem || string.IsNullOrEmpty(fieldsReloaded) || (("," + Trim(fieldsReloaded) + ",").Contains("," + CStr(rs["DZT_Name"]) + ",", StringComparison.Ordinal)))
                                {

                                    mp_Mod.SetFieldValue(CStr(rs["DZT_Name"]), rs["Value"]);

                                    //'-------------------
                                    //'-- CRYPT ----------
                                    //'-------------------
                                    if (PresenteCifratura == "YES" && IsNull(rs["Value"]))
                                    { //'-- se il valore restituito � null allora verifichiamo se � nei dati cifrati

                                        objXML.LoadXml(CStr(rs["AFS_DATI_DECIFRATI"]));

                                        //'Set objNodeList = objXML.getElementsByTagName(rs.Fields("DZT_Name").Value)
                                        objNodeList = objXML.GetElementsByTagName("Value");
                                        if (objNodeList.Count - 1 >= 0)
                                        {
                                            mp_Mod.SetFieldValue(CStr(rs["DZT_Name"]), (objNodeList[0] != null) ? objNodeList[0].InnerText : "");
                                        }

                                    }

                                }

                                rs.MoveNext();

                            }

                        }

                    }
                    else
                    {

                        //'-- si avvalorano i campi del modello
                        if (!bIsInMem)
                        {
                            if (rs.Fields != null)
                                mp_Mod.SetFieldsValue(rs.Fields); //'--se non è in memoria ricarico tutti i campi
                        }
                        else
                        {
                            mp_Mod.SetFilteredFieldsValue(rs.Fields, fieldsReloaded);
                        }

                        if (PresenteCifratura == "YES")
                        {

                            if (IsNull(rs.Fields["AFS_DATI_DECIFRATI"]) == false)
                            {
                                objXML.LoadXml(CStr(rs.Fields["AFS_DATI_DECIFRATI"]));

                                //'-- si scorrono tutti i campi del record e per i campi a null si cerca il valore nel campo cifrato
                                foreach (var el in mp_Mod.Fields)
                                {

                                    //'-- se il valore memorizzato nul modello � null si cerca nella parte decifrata
                                    if (IsNull(el.Value.Value))
                                    {
                                        objNodeList = objXML.GetElementsByTagName(el.Value.Name);
                                        if (objNodeList.Count - 1 >= 0)
                                        {
                                            mp_Mod.SetFieldValue(el.Value.Name, objNodeList[0].InnerText);
                                        }
                                    }


                                }

                            }

                        }

                    }

                    SaveInMem(session);

                }



            }
            catch (Exception ex)
            {
                throw new Exception($" CtlDocument.Sec_Caption.Read() - {strCause} - {ex.Message}", ex);
            }
        }

        private bool CheckObblig(string strObbligField, Session.ISession session)
        {
            bool boolToReturn;
            string[] v;
            int n;
            int i;
			DebugTrace dt = new DebugTrace();
		    v = Strings.Split(strObbligField, ",");
            n = (v.Length - 1);
            boolToReturn = false;

            for (i = 1; i <= n + 1; i++)
            {

                Field el = mp_Mod.Fields[v[i - 1]];

                if (string.IsNullOrEmpty(el.Value) && el.GetEditable())
                {

                    dt.Write("Campo obbligatorio:" + CStr(el.Name) + ", è necessario inserirlo per proseguire");
                    el.Error = 1;
                    el.ErrDescription = ApplicationCommon.CNV("Campo obbligatorio, è necessario inserirlo per proseguire", session);
                    boolToReturn = true;
                    return boolToReturn;
                }

            }

            return boolToReturn;
        }

        public void SetObbligML(Session.ISession session)
        {

            foreach (var el in mp_Mod.Fields)
            {

                if (!string.IsNullOrEmpty(el.Value.ErrDescription))
                {
                    el.Value.ErrDescription = ApplicationCommon.CNV(el.Value.ErrDescription, session);
                }

            }

        }

        /// <summary>
        /// recupera dalla sessione di lavoro ASP le variabili per gestire la griglia paginata
        /// </summary>
        /// <param name="session"></param>
        private void LoadFromMem(Session.ISession session)
        {

            string strSecName;

            if (objDocument.ReadOnly || !mp_editable)
            {
                return;
            }

            strSecName = "DOC_SEC_MEM_" + objDocument.Id + "_" + objDocument.mp_IDDoc + "_" + Id;

            //'-- verifica se la sezione ha delle aree di memoria in sessione
            if (!string.IsNullOrEmpty(session[strSecName]))
            {
                Dictionary<string, dynamic>? col;

                //Se è presente la sentinella per i dati cifrati
                if (!string.IsNullOrEmpty(session[$"{strSecName}_CRYPT"]))
                {

                    initCryptKey(session);

                    var encryptedData = (byte[]?)session[strSecName + "_Value"];
                    col = Cifratura.DecryptGenericData<Dictionary<string, dynamic>>(encryptedData, objDocument.cryptoKey);
                }
                else
                {
                    col = session[strSecName + "_Value"];
                }

                mp_Mod.SetFieldsValue(col);

            }

        }

        private void initCryptKey(Session.ISession session)
        {
            //Se la chiave di cifratura non è stata già recuperata
            if (string.IsNullOrEmpty(objDocument.cryptoKey))
            {
                /*
		         * NOTA : Le sezioni Caption che richiedono la cifratura avranno l'iddoc
		         *          coincidente con la CTL_DOC ed il documento sarà già creato ( non sarà mai new ).
		         *          se così non dovesse essere ( per qualche anomalia ) come chiave di cifratura utilizzeremo l'id della sessione stessa. un objectid mongodb
		         */
                if (IsNumeric(mp_idDoc))
                    objDocument.setCryptoKey(idCtlDoc: CInt(mp_idDoc));
                else
                    objDocument.setCryptoKey(session.SessionID);
            }
        }

        /// <summary>
        /// salva nella sessione di lavoro i dati del modello
        /// </summary>
        /// <param name="session"></param>
        private void SaveInMem(Session.ISession session)
        {
            if (objDocument.ReadOnly || !mp_editable)
            {
                return;
            }

            //Se in configurazione è attiva la cifratura della sessione e SE per questa sezione è richiesta la cifratura
            bool crypt = (Strings.Left(GetParam(param, "CRYPT"), 3) == "YES" && session.EncryptData());

            string strSecName = $"DOC_SEC_MEM_{objDocument.Id}_{objDocument.mp_IDDoc}_{Id}";

            session[strSecName] = "yes";

            if (crypt)
            {
                //evidenziamo con una chiave dedicata che anche i dati in sessione lo sono
                session[$"{strSecName}_CRYPT"] = "yes";

                initCryptKey(session);
            }

            //'-- carichiamo una collezione con i valori del modello
            Dictionary<string, dynamic> col = new();
            foreach (var el in mp_Mod.Fields)
            {
                col.Add(el.Value.Name, el.Value.Value);
            }

            if (crypt)
            {
                session[strSecName + "_Value"] = Cifratura.EncryptGenericData(col, objDocument.cryptoKey);
            }
            else
            {
                session[strSecName + "_Value"] = col;
            }

        }

        /// <summary>
        /// recupera dalla sessione di lavoro ASP le variabili per gestire la griglia paginata
        /// </summary>
        /// <param name="session"></param>
        /// <returns></returns>
        private bool IsInMem(Session.ISession session)
        {

            string strSecName;

            strSecName = "DOC_SEC_MEM_" + objDocument.Id + "_" + objDocument.mp_IDDoc + "_" + Id;

            //'-- verifica se la sezione ha delle aree di memoria in sessione
            if (!string.IsNullOrEmpty(session[strSecName]))
            {
                return true;
            }
            else
            {
                return false;
            }

        }

        public void RemoveMem(Session.ISession session)
        {
            string strSecName;

            strSecName = "DOC_SEC_MEM_" + objDocument.Id + "_" + objDocument.mp_IDDoc + "_" + Id;

            if (UCase(GetParam(param, "SAVE_MODEL")) == "YES")
            {
                BasicDocument.FreeModelMemDoc(session, strModelName, objDocument.mp_IDDoc);
            }

            session[strSecName] = null;
            session[$"{strSecName}_Value"] = null;
            session[$"{strSecName}_CRYPT"] = null;

        }

        private void ReadFrom(Session.ISession session, string param)
        {

            try
            {

                string strSql;
                TSRecordSet rs;
                string view;
                string strCon;

                string strFrom;
                string idFrom;
                string[] v;
                string[] v2;
                bool bVerticalRead;
                bVerticalRead = false;

                v = Strings.Split(param, ",");
                strFrom = v[0];
                idFrom = v[1];
                idFrom = Replace(idFrom, "<ID_USER>", CStr(session[Session.SessionProperty.SESSION_USER]));

                //'-- verifico se la vista di partenza � in verticale
                if (strFrom.Contains("~", StringComparison.Ordinal))
                {
                    v2 = Strings.Split(strFrom, "~");
                    strFrom = v2[0];
                    if (v2[1] == "V")
                    {
                        bVerticalRead = true;
                    }
                }



                //'-- prendo la lista dai parametri della sezione
                view = GetParam(this.param, "VIEW_FROM") + "_" + strFrom;

                //'-- controllo se il paramentro composto sia formalmente corretto
                isValidErr(view, 1);
                //'-- controllo che il from sia corretto
                isValidErr(idFrom, 4);

                //'-- prendo il recordset legato alla tabella principale del documento
                strSql = "select * from " + view + " where ID_FROM in(  " + idFrom + " )";
                if (!string.IsNullOrEmpty(GetParam(this.param, "FROM_USER_FIELD")))
                {
                    strSql = strSql + " and " + GetParam(this.param, "FROM_USER_FIELD") + " =  " + mp_User;
                }

                //Set objDB = CreateObject("ctldb.clsTabManage")
                CommonDbFunctions cdb = new CommonDbFunctions();
                rs = cdb.GetRSReadFromQuery_(strSql, mp_strConnectionString);

                bool bEditable;
                bEditable = true;

                //'-- recupero il nome del modello dinamicamente se previsto
                if (GetParam(param, "DYNAMIC_MODEL") == "yes")
                {
                    //On Error Resume Next
                    string strModel;
                    try
                    {
                        strModel = CStr(rs["MOD_Name"]);
                        strModelName = strModel;
                        if (objDocument.ReadOnly || !mp_editable)
                        {
                            bEditable = false;
                        }
                        LibDbModelExt objDB2 = new LibDbModelExt();
                        mp_Mod = objDB2.GetFilteredModelCTL(strModelName, mp_suffix, mp_User, session, 0, mp_strConnectionString, IIF(objDocument.PrintMode, false, bEditable));

                        //'-- mette l'owner del documento
                        if (!string.IsNullOrEmpty(GetParam(param, "FIELD_OWNER")))
                        {
                            mp_Mod.SetFieldValue(GetParam(param, "FIELD_OWNER"), mp_User);
                        }
                    }
                    catch { }

                }

                //'-- altrimenti salvo il Modello in memoria
                if (UCase(GetParam(param, "SAVE_MODEL")) == "YES")
                {
                    if (string.IsNullOrEmpty(session["CTL_MODEL_" + strModelName + "_" + mp_idDoc]))
                    {

                        LibDbModelExt objDB2 = new LibDbModelExt();

                        objDB2.SaveModelInCache(session, "CTL_MODEL_" + strModelName + "_" + mp_idDoc, mp_Mod.Fields, mp_Mod.PropFields, mp_suffix, mp_User, CInt(0), mp_strConnectionString, session, bEditable, mp_Mod.Template, mp_Mod.param, mp_idDoc);

                    }
                }



                if (rs != null)
                {
                    if (rs.RecordCount > 0)
                    {

                        if (bVerticalRead)
                        {
                            if (!rs.EOF)
                            {
                                rs.MoveFirst();
                                while (!rs.EOF)
                                {
                                    mp_Mod.SetFieldValue(CStr(rs["DZT_Name"]), rs["Value"]);
                                    rs.MoveNext();
                                }
                            }
                        }
                        else
                        {

                            rs.MoveFirst();
                            mp_Mod.SetFieldsValue(rs.Fields);

                        }
                    }
                }
                SaveInMem(session);

            }
            catch (Exception ex)
            {
                throw new Exception(" CtlDocument.Sec_Caption.Read()" + ex.Message, ex);
            }

        }

        public void AddRecord(Session.ISession session, int fromRow = -1, bool bCount = true)
        {
            throw new NotImplementedException();
        }

        public void UpdRecord(Session.ISession session)
        {
            throw new NotImplementedException();
        }

        public int GetIndexColumn(string strAttrib)
        {
            throw new NotImplementedException();
        }
    }

    public class Sec_Dettagli : ISectionDocument
    {
        public string Id { get; set; }
        public string Caption { get; set; }
        public string strTable { get; set; }
        public string strFieldId { get; set; }
        public string strFieldIdRow { get; set; }
        public string strTableFilter { get; set; }
        public string strModelName { get; set; }
        public long PosPermission { get; set; }
        public string mp_idDoc { get; set; }
        public Toolbar ObjToolbar { get; set; }
        public string strHelp { get; set; }
        public CTLDOCOBJ.Document objDocument { get; set; }
        public string param { get; set; }
        public string TypeSection { get; set; }
        public Model mp_Mod { get; set; }

        //'---------------------------------------------------------------------------
        //'-- Elementi personali della sezione
        //'---------------------------------------------------------------------------

        private long mp_User;//'-- identificativo dell'utente che ha caricato il documento
        private string mp_suffix;
        private string mp_strConnectionString;
        private string mp_Permission;
        private string Request_QueryString;
        private IFormCollection? Request_Form;



        //'-- colonne da visualizzare nella griglia dei dettagli
        private string mp_strModelGrid;
        public Dictionary<string, Field> mp_Columns { get; set; }
        private Dictionary<string, Grid_ColumnsProperty> mp_ColumnsProperty;
        private Grid mp_objGrid;


        public dynamic[,] mp_Matrix { get; set; } //'-- contiene la matrice dei valori da visualizzare come da modello 'strModelName'
                                                  //'-- con l'aggiunta di una colonna per gli attributi aggiuntivi
                                                  //'-- il cui contenuto � una supecollezione
                                                  //'-- l'ultima colonna rappresenta l'indice della riga se presa dal DB, -1 se la riga � nuova


        private double[] mp_VetTotRow;//'-- contiene i totali delle singole righe
        public double mp_Total;//'-- contiene il totale di tutta la sezione

        private long[] mp_VetOriginalRow; //'-- contiene i valori delle righe caricate originariamente nel documento

        public int mp_numRec { get; set; }//'-- contiene il numero di righe della matrice


        public Dictionary<string, Field> mp_ColumnsC { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public Dictionary<string, Field> mp_ColumnsS { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public TSRecordSet mp_rsCicle { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public TSRecordSet mp_rsCicleStep { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }

        private Model mp_ModAdd;
        private Model mp_ModAddDetail;



        private Form mp_objForm;
        private ButtonBar mp_ObjButtonBar;
        private Fld_Label mp_objCaption;


        private string mp_strcause;
        private string mp_ErrMsg;
        private string mp_SummaryField;
        private long mp_NumeroPagina;

        public string strFormula;//'-- formula per calcolare il totale della sezione

        private string mp_FieldNameNotEditable;//'-- campo contenente il nome della colonna che contiene il nome degli attributi non editabili sulla riga
        private int mp_indexFieldNotEditable;//'-- indice del campo precedente nella matrice dei valori

        private long mp_CounterValue;//'-- valore massimo attualmente utilizzato
        private string mp_CounterName;//'-- nome della colonna contatore
        private long mp_StartCounterRow;//'-- valore iniziale del contatore se non ci sono righe
        private string mp_SelectSQLStartCounterRow;//'-- Query per il valore iniziale del contatore sui documenti salvati
        private long mp_StepCounterRow;//'-- step di incremento del contatore
        private long mp_PosCounter;//'-- indice del contatore che deve essere presente come colonna nella griglia, eventualmente nascosta

        private bool mp_editable;//'-- viene settato a false al caricamento se il doc � in sola lettura
                                 //'-- e serve per controllarne la coerenza sul nuovo caricamento
        private int mp_PosNoDuplicati;//'-- posizione della colonna nella matrice per il campo che non deve avere duplicati

        private bool model_editable;//'-- conservo lo stato del modello tra editabile o meno per buttarlo giu nel caso in cui mi ritrovo la sezione incoerente

        private readonly EprocResponse _response;
        private readonly HttpContext _context;
        private readonly Session.ISession _session;

        public Sec_Dettagli(HttpContext context, Session.ISession session, EprocResponse response)
        {
            TypeSection = "DETTAGLI";
            mp_NumeroPagina = 1;
            mp_indexFieldNotEditable = -1;
            mp_editable = true;
            model_editable = true;
            //this._accessor = accessor;
            this._context = context;
            this._session = session;
            _response = response;
        }


        public bool CanSave(Session.ISession session)
        {
            return true;
        }

        public void Excel(EprocResponse response, Session.ISession OBJSESSION)
        {
            //'-- apro la div della sezione
            response.Write($@"<div class=""detail"" id=""" + Id + @""" name=""" + Id + @"""  >");

            mp_objGrid.SetMatrix(mp_Matrix, mp_VetOriginalRow);

            if (mp_ColumnsProperty.ContainsKey("FNZ_UPD"))
            {
                mp_ColumnsProperty["FNZ_UPD"].Hide = true;
            }

            if (mp_ColumnsProperty.ContainsKey("FNZ_DEL"))
            {
                mp_ColumnsProperty["FNZ_DEL"].Hide = true;
            }

            if (mp_ColumnsProperty.ContainsKey("FNZ_COPY"))
            {
                mp_ColumnsProperty["FNZ_COPY"].Hide = true;
            }

            //'-- disegno la griglia con le righe di dettaglio
            if (!string.IsNullOrEmpty(GetParam("CAPTIONGRID", param)))
            {
                mp_objGrid.Caption = ApplicationCommon.CNV(GetParam("CAPTIONGRID", param), OBJSESSION);
            }

            mp_objGrid.Excel(response);


            response.Write("<br/>");


            //'-- chiudo la div
            response.Write("</div>");
        }

        public void Html(EprocResponse response, Session.ISession OBJSESSION)
        {
            string strJSOnLoad;

            //'-- setto il percorso immagini corretto per la toolbar (per evitare il doppio ctl_library di default)
            if (ObjToolbar != null)
            {
                ObjToolbar.strPath = "../images/toolbar/";
            }

            //'--centro il tutto se richiesto
            if (UCase(GetParam(param, "CENTER")) == "YES")
            {
                response.Write($@"<center>");
            }

            //'-- apro la div della sezione
            response.Write($@"<div class=""detail"" id=""" + Id + @""" name=""" + Id + @"""  >");

            //'--Inserire i parametri obbligatori prima dell'inserimento
            HTML_HiddenField(response, "MSG_OBBLIG_FOR_ADD", HtmlEncode(ApplicationCommon.CNV("Inserire i parametri obbligatori prima del comando di aggiungi articolo", OBJSESSION)));


            //'-- se si possono inserire righe disegno gli attributi per l'inserimento
            if (GetParam(param, "AREA_ADD") == "yes" && objDocument.ReadOnly == false && mp_editable == true)
            {

                Window win = new Window();
                win.Path = "../images/window/style";
                win.Init("AddNew", "", true, Window.Label);//'Group
                win.width = "100%";
                win.PositionAbsolute = false;
                win.Height = GetParam(param, "HEIGHT_ADD");

                win.Html(response, HTML_iframe(Id + "_ADD_" + mp_idDoc, "Sec_Dettagli.asp?MODE=ADD&IDDOC=" + mp_idDoc + "&" + param + "&DOCUMENT=" + GetParamURL(Request_QueryString.ToString(), "DOCUMENT") + "&SECTION=" + Id));
                //Set win = Nothing
                //'-- aggiungo un if (rame per l'area di add / upd

            }

            HTML_HiddenField(response, "DETTAGLI_AREA_ADD", Id + "_ADD_" + mp_idDoc);
            HTML_HiddenField(response, "DETTAGLI_AREA_ADD_URL_UPD", "Sec_Dettagli.asp?MODE=UPD&IDDOC=" + mp_idDoc + "&" + param + "&DOCUMENT=" + GetParamURL(Request_QueryString.ToString(), "DOCUMENT") + "&SECTION=" + Id);
            HTML_HiddenField(response, Id + "Grid_SECTION_DETTAGLI_NAME", Id);

            //'-- disegno la griglia con le righe di dettaglio
            Grid objGrid;

            //'-- per ogni colonna setto l path dei JS
            int i;

            if (UCase(GetParam(param, "NO_PATH")) == "NO" || string.IsNullOrEmpty(GetParam(param, "NO_PATH")))
            {
                for (i = 0; i < mp_Columns.Count; i++)
                {
                    mp_Columns.ElementAt(i).Value.Path = "../../";
                }
            }

            //'-- in caso di documento in sola lettura si tolgono le colonne delle funzioni
            //On Error Resume Next
            if (objDocument.ReadOnly || !mp_editable)
            {

                if (mp_Columns.ContainsKey("FNZ_UPD"))
                {
                    mp_Columns.Remove("FNZ_UPD");
                }

                if (mp_Columns.ContainsKey("FNZ_DEL"))
                {
                    mp_Columns.Remove("FNZ_DEL");
                }

                if (mp_Columns.ContainsKey("FNZ_COPY"))
                {
                    mp_Columns.Remove("FNZ_COPY");
                }

            }
            else
            {
                //'-- imposto per queste colonne la format perchè viene persa
                if (mp_Columns.ContainsKey("FNZ_UPD"))
                {
                    mp_Columns["FNZ_UPD"].Value = "";
                }

                if (mp_Columns.ContainsKey("FNZ_DEL"))
                {
                    mp_Columns["FNZ_DEL"].Value = "";
                }

                if (mp_Columns.ContainsKey("FNZ_COPY"))
                {
                    mp_Columns["FNZ_COPY"].Value = "";
                }


                //'-- se il modello è editabile ed è stato passato il parametro di cif (cifratura degli allegati sulla sezione)
                if (Strings.Left(GetParam(param, "CRYPT"), 3) == "YES")
                {

                    for (i = 1; i <= mp_Columns.Count; i++)
                    {

                        //'-- se è un allegato
                        if (mp_Columns.ElementAt(i - 1).Value.getType() == 18)
                        {

                            if (Trim(CStr(mp_Columns.ElementAt(i - 1).Value.strFormat)) == "")
                            {
                                mp_Columns.ElementAt(i - 1).Value.strFormat = "INTC";
                            }
                            else
                            {
                                mp_Columns.ElementAt(i - 1).Value.strFormat = mp_Columns.ElementAt(i - 1).Value.strFormat + "C";
                            }

                        }

                    }

                }

            }


            //'-- inizializzo la griglia
            objGrid = new Grid();

            mp_strcause = "inizializzo la griglia dei dettagli html";
            objGrid.Columns = mp_Columns;
            objGrid.ColumnsProperty = mp_ColumnsProperty;
            objGrid.SetMatrixDisposition(false);// '-- imposta la matrice in colonna riga

            if ((LCase(GetParam(param, "WRITE_VERTICAL")) == "yes"))
            {
                objGrid.SetMatrix(mp_Matrix);
            }
            else
            {
                objGrid.SetMatrix(mp_Matrix, mp_VetOriginalRow);
            }

            objGrid.id = Id + "Grid";
            if (UCase(GetParam(param, "SEC_FIELD")) == "YES")
            {
                objGrid.UseNameGridOnField = 1;
            }
            objGrid.width = "100%";

            //'-- se � presente la colonna che riepiloga attributi opzionali allora si imposta il disegno custom
            if (!string.IsNullOrEmpty(mp_SummaryField) || mp_indexFieldNotEditable > -1)
            {
                objGrid.SetCustomDrawer(this);
            }

            //'-- se la sezione non � in sola lettura allora inserisco la toolbar se presente
            //'-- a meno che non � passato il parametro SHOW_TOOLBAR_ON_READONLY sulla sezione, in tal caso
            //'-- la toolbar viene comunque visualizzata


            //'-- recupero la SYS SHOW_NUMBER_ROW_SEC_DETTAGLI in sessione
            string strSHOW_NUMBER_ROW = CStr(ApplicationCommon.Application["SHOW_NUMBER_ROW_SEC_DETTAGLI"]);

            //'--se esiste il parametro valorizzato sulla sezione vince
            if (!string.IsNullOrEmpty(GetParam(param, "SHOW_NUMBER_ROW")))
            {

                strSHOW_NUMBER_ROW = GetParam(param, "SHOW_NUMBER_ROW");

            }

            //'--se vuota la imposto a NO
            if (string.IsNullOrEmpty(strSHOW_NUMBER_ROW))
            {
                strSHOW_NUMBER_ROW = "NO";
            }

            strSHOW_NUMBER_ROW = UCase(strSHOW_NUMBER_ROW);

            //'--YES � come SI
            if (strSHOW_NUMBER_ROW == "YES")
            {
                strSHOW_NUMBER_ROW = "SI";
            }

            EprocResponse toolbarHtml = new EprocResponse();

            if (UCase(GetParam(param, "SHOW_TOOLBAR_ON_READONLY")) == "YES" && ObjToolbar != null)
            {

                if (ObjToolbar.Buttons.Count > 0)
                {
                    if ((IsMasterPageNew()))
                    {
                        ObjToolbar.Html(toolbarHtml);
                    }
                    else
                    {
                        ObjToolbar.Html(response);
                    }
                }

            }
            else
            {

                if (!objDocument.ReadOnly && mp_editable && ObjToolbar != null)
                {

                    if (ObjToolbar.Buttons.Count > 0)
                    {
                        if ((IsMasterPageNew()))
                        {
                            ObjToolbar.Html(toolbarHtml);
                        }
                        else
                        {
                            ObjToolbar.Html(response);
                        }
                    }
                }

            }
            
            

            if (UCase(GetParam(param, "EDITABLE")) == "YES" && !objDocument.ReadOnly && mp_editable)
            {
                objGrid.Editable = true;
            }
            else
            {
                objGrid.Editable = false;
            }

            objGrid.SetLockedInfo(0, 0);
            objGrid.width = "100%";



            //'-- verif (ica se � necessario paginare la griglia
            long nRow;
            nRow = CLng("0" + GetParam(param, "numRowForPag"));

            if (nRow > 0)
            {

                //'-- inserisce lo script per il salto pagina relativo alla sezione
                response.Write($@"<script type=""text/javascript"" language=""javascript"" >" + Environment.NewLine);
                response.Write($@"function DettagliGoPage" + Id + "(strPage, target)" + Environment.NewLine);
                response.Write($@"{{" + Environment.NewLine);
                response.Write($@"    var sec = getObj( '" + Id + "Grid_SECTION_DETTAGLI_NAME' ).value;" + Environment.NewLine);
                response.Write($@"    ExecDocCommand( sec + '#PAGINAZIONE#saltopagina=ok' + strPage);" + Environment.NewLine);
                response.Write($@"    ShowLoading( sec );" + Environment.NewLine);
                response.Write($@"}}" + Environment.NewLine);
                response.Write($@"</script>" + Environment.NewLine);


                objGrid.SetPage(mp_NumeroPagina, nRow);

                string strQ;

                string RQS = GetQueryStringFromContext(_context.Request.QueryString);

                strQ = CStr(RQS);
                if (!strQ.Contains("numRowForPag", StringComparison.Ordinal))
                {
                    strQ = strQ + "&numRowForPag=" + nRow;
                    strQ = strQ + "&nPag=" + mp_NumeroPagina;
                    strQ = strQ + "&COMMAND=" + Id + ".PAGINAZIONE";
                }


                ScrollPage grSP = new ScrollPage();
                grSP.Id = "SP_" + Id;
                grSP.SetScrollPage("document.asp", strQ, CLng(mp_numRec), GetParamURL(RQS, "DOCUMENT") + "_Command_" + objDocument.mp_IDDoc);
                grSP.GotoPageFunc = "DettagliGoPage" + Id;
                grSP.strPath = "../images/ScrollPage/";

                grSP.Html(response);

            }

            //'--setto le prop per visualizzare il numero righe se richiesto
            if (strSHOW_NUMBER_ROW == "SI")
            {
                objGrid.mp_Show_NumRow = true;
                objGrid.mp_str_Label_NumRow = ApplicationCommon.CNV("Numero Righe Viewer", OBJSESSION);
            }

            if (!string.IsNullOrEmpty(GetParam(param, "CAPTIONGRID")))
            {
                objGrid.Caption = ApplicationCommon.CNV(GetParam(param, "CAPTIONGRID"), OBJSESSION);

            }

            if (!string.IsNullOrEmpty(GetParam(param, "ACTIVESEL")))
            {
                objGrid.ActiveSelection = CInt(GetParam(param, "ACTIVESEL"));
            }

            objGrid.Html(response, toolbarHtml);

            response.Write($@"<br/>");


            //'-- inserisco lo scipt per inizializzare i totali di riga
            if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_FIELD")) && objDocument.ReadOnly == false && mp_editable == true)
            {

                HTML_HiddenField(response, Id + "_TOTAL_FIELD", GetParam(param, "TOTAL_FIELD"));
                HTML_HiddenField(response, Id + "_TOTAL_EXPRESSION", GetParam(param, "TOTAL_EXPRESSION"));

                response.Write($@"<script type=""text/javascript"" language=""javascript"" >" + Environment.NewLine);
                response.Write($@"       try {{ var ");
                response.Write($@"    " + Id + "_TotRow = new Array( ");
                int R;
                for (R = 1; R <= mp_numRec; R++)
                {// To mp_numRec
                 //'response.Write mp_VetTotRow(r - 1) & " , "
                    response.Write(Replace(CStr(mp_VetTotRow[R - 1]), ",", ".") + " , ");
                }
                //'-- chiusura dell'array

                response.Write($@" 0 );      }}catch( e ) {{ }}; " + Environment.NewLine);

                //'-- scrivo nel campo preposto il totale


                response.Write($@"  try {{  SetNumericValue( '" + GetParam(param, "TOTAL_FIELD") + "' , " + Replace(CStr(mp_Total), ",", ".") + $@" ); }} catch( e ) {{;}}; " + Environment.NewLine);

                response.Write($@"</script>");

            }


            strJSOnLoad = GetParam(param, "JSOnLoad");
            if (LCase(strJSOnLoad) == "yes")
            {

                response.Write($@"<script type=""text/javascript"" language=""javascript"" >" + Environment.NewLine);
                response.Write($@" try {{" + this.Id + $@"_OnLoad(); }}catch(e){{}}");
                response.Write($@"</script>");

            }

            objGrid.SetCustomDrawer(null);

            //'-- chiudo la div
            response.Write($@"</div>");

            //'--centro il tutto se richiesto
            if (UCase(GetParam(param, "CENTER")) == "YES")
            {
                response.Write($@"</center>");
            }
        }

        /// <summary>
        /// '-- funzione di inizializzazione della sezione --
        /// '-- questa funzione � indispensabile al corretto funzionamento e viene invocata da CTL_DB al caricamento del docuemnto
        ///
        /// </summary>
        /// <param name="pId"></param>
        /// <param name="model"></param>
        /// <param name="pCaption"></param>
        /// <param name="pTable"></param>
        /// <param name="pstrFieldId"></param>
        /// <param name="pFieldIdRow"></param>
        /// <param name="pTableFilter"></param>
        /// <param name="strToolbar"></param>
        /// <param name="help"></param>
        /// <param name="session"></param>
        /// <exception cref="NotImplementedException"></exception>
        public void Init(string pId, string model, string pCaption, string pTable, string pstrFieldId, string pFieldIdRow, string pTableFilter, string strToolbar, string help, Session.ISession session)
        {
            Id = pId;
            strTable = pTable;
            Caption = pCaption;
            strFieldId = pstrFieldId;
            strHelp = help;
            strFieldIdRow = pFieldIdRow;

            if (string.IsNullOrEmpty(strFieldIdRow))
            {
                strFieldIdRow = strFieldId;
            }
            strTableFilter = pTableFilter;

            mp_strModelGrid = model;
            mp_SummaryField = GetParam(param, "SUMMARY");

            mp_PosCounter = -1;
            mp_CounterValue = 0;
            string strC;

            //'-- PROGR_ROW = nome della colonna che contiene il progressivo di riga separato da virgola per determinare lo step
            strC = GetParam(param, "PROGR_ROW");
            if (!string.IsNullOrEmpty(strC))
            {
                string[] v;
                v = Strings.Split(strC, "~");
                mp_CounterName = v[0];
                mp_StepCounterRow = CLng(v[1]);
                if ((v.Length - 1) > 1)
                {
                    mp_SelectSQLStartCounterRow = v[2];
                }
            }

        }

        private void initCryptKey(Session.ISession session)
        {
            //Se è richiesta la cifratura dei dati in sessione e la cifratura di questa sezione
            if (session.EncryptData() && Strings.Left(GetParam(param, "CRYPT"), 3) == "YES")
            {
                //Se la chiave di cifratura non è stata già recuperata
                if (string.IsNullOrEmpty(objDocument.cryptoKey))
                {
                    string Fieldkey;
                    int idDocCrypt = CInt(mp_idDoc);
                    string[] v_C = GetParam(param, "CRYPT").Split('~');

                    //Se il parametro CRYPT contiene almeno 3 valori, recuperiamo il nome della colonna utile a dirci l'id della ctl_doc
                    //  per le sezioni caption, normalmente, questo 3o parametro non è mai usato, il campo ReferenceKey contiene già l'id della CTL_DOC
                    if (v_C.Length > 2)
                    {
                        Fieldkey = v_C[2];

                        string strFilterRow = GetParam(param, "FILTER_ROW");
                        strFilterRow = strFilterRow.Replace("<ID_USER>", CStr(mp_User));

                        string view = GetParam(param, "VIEW");
                        if (string.IsNullOrEmpty(view))
                        {
                            view = strTable;
                        }

                        //'-- carica i dettagli
                        string strSql = $"Select top 1 {Fieldkey} as idDocKey from {view} with(nolock) where {strFieldId} = {mp_idDoc}" + IIF(!string.IsNullOrEmpty(strFilterRow), " and " + strFilterRow, "");

                        //'-- in caso in cui il salvataggio è verticale
                        bool bWRITE_VERTICAL = (GetParam(param, "WRITE_VERTICAL").ToLower() == "yes");
                        if (bWRITE_VERTICAL)
                        {
                            strSql += $" and DSE_ID = '{Id}'";
                        }

                        CommonDbFunctions cdb = new();
                        TSRecordSet rsCrypt = cdb.GetRSReadFromQuery_(strSql, mp_strConnectionString);

                        if (rsCrypt is null || rsCrypt.RecordCount == 0)
                        {
                            throw new DataEncryptionException("rsCrypt null or empty");
                        }

                        //Recupero l'id della ctl_doc
                        rsCrypt.MoveFirst();
                        idDocCrypt = CInt(rsCrypt["idDocKey"]!);
                    }

                    //Se sono nel caso di "new" passo come chiave il session id ( ma per la cifratura ci sarà sempre il documento creato )
                    if (IsNumeric(mp_idDoc))
                        objDocument.setCryptoKey(idCtlDoc: idDocCrypt);
                    else
                        objDocument.setCryptoKey(session.SessionID);
                }
            }
        }

        /// <summary>
        /// '-- inizializza la nuova sezione prelevando alcune informazioni da altri contesti
        /// </summary>
        /// <param name="OBJSESSION"></param>
        /// <param name="idDoc"></param>
        /// <exception cref="NotImplementedException"></exception>
        public void InitializeFrom(Session.ISession OBJSESSION, string param)
        {
            mp_editable = !BasicDocument.isReadOnlySection(param, mp_idDoc, CStr(mp_User), mp_strConnectionString);

            if (!IsInMem(OBJSESSION))
            {

                TSRecordSet rs;
                string strFrom;
                string idFrom;
                string[] v;
                string[] v2;
                string view;
                bool bVerticalRead;
                bVerticalRead = false;
                int R;
                int c = 0;

                v = Strings.Split(param, ",");
                strFrom = v[0];
                idFrom = v[1];
                idFrom = Replace(idFrom, "<ID_USER>", CStr(mp_User));

                if (string.IsNullOrEmpty(GetParam(this.param, "VIEW_FROM")))
                {
                    return;
                }


                //'-- verifico se la vista di partenza � in verticale
                if (strFrom.Contains('~', StringComparison.Ordinal))
                {
                    v2 = Strings.Split(strFrom, "~");
                    strFrom = v2[0];
                    if (v2[1] == "V")
                    {
                        bVerticalRead = true;
                    }
                }

                //'-- prendo la lista dai parametri della sezione
                view = GetParam(this.param, "VIEW_FROM") + "_" + strFrom;

                //'-- controllo se il paramentro composto sia formalmente corretto
                isValidErr(view, 1);
                //'-- controllo che il from sia corretto
                isValidErr(idFrom, 4);


                //'-- prendo il recordset legato alla tabella principale del documento
                string strSql;
                strSql = "select * from " + view + " where ID_FROM in(  " + idFrom + " )";
                if (!string.IsNullOrEmpty(GetParam(this.param, "FROM_USER_FIELD")))
                {
                    strSql = strSql + " and " + GetParam(this.param, "FROM_USER_FIELD") + " =  " + mp_User;
                }

                if (!string.IsNullOrEmpty(GetParam(this.param, "ORDERBY")))
                {
                    strSql = strSql + " order by " + GetParam(this.param, "ORDERBY");
                }

                CommonDbFunctions cdb = new();
                rs = cdb.GetRSReadFromQuery_(strSql, mp_strConnectionString);

                if (rs is not null)
                {
                    if (rs.RecordCount > 0)
                    {

                        if (bVerticalRead)
                        {
                            int numCol;

                            //'-- popola la matrice
                            numCol = mp_Columns.Count;
                            mp_numRec = rs.RecordCount;
                            if (mp_numRec > 0)
                            {
                                mp_Matrix = new dynamic[numCol + 4, mp_numRec];//ReDim mp_Matrix(numCol +3, mp_numRec - 1) As Variant
                            }
                            mp_VetOriginalRow = new long[mp_numRec + 1];//ReDim mp_VetOriginalRow(mp_numRec) As Long
                            mp_VetTotRow = new double[mp_numRec + 1];//ReDim mp_VetTotRow(mp_numRec) As Double

                            //On Error Resume Next

                            rs.MoveFirst();
                            long maxR;
                            maxR = 0;
                            while (!rs.EOF)
                            {
                                try
                                {
                                    R = CInt(rs["Row"]!);
                                }
                                catch
                                {
                                    R = 0;
                                }
                                if (maxR < R)
                                {
                                    maxR = R;
                                }
                                try
                                {
                                    c = GetIndexColumn(CStr(rs["DZT_Name"])) - 1;
                                }
                                catch { }
                                try
                                {
                                    if (c >= 0)
                                    {

                                        mp_Matrix[c, R] = GetValueFromRS(rs.Fields["Value"]);
                                    }
                                }
                                catch { }
                                rs.MoveNext();
                            }
                            mp_numRec = CInt(maxR);

                            mp_Matrix = ResizeArray(mp_Matrix, mp_Columns.Count + 3, mp_numRec);//ReDim Preserve mp_Matrix(mp_Columns.count + 3, mp_numRec) As Variant
                            Array.Resize(ref mp_VetTotRow, mp_numRec + 1);//ReDim Preserve mp_VetTotRow(mp_numRec) As Double
                            mp_numRec = mp_numRec + 1;


                        }
                        else
                        {

                            R = 0;
                            rs.MoveFirst();
                            while (!rs.EOF)
                            {

                                //'-- aggiunge una riga alla matrice
                                AddRecord(OBJSESSION, -1, false);

                                UpdRecordFromRS(OBJSESSION, rs, R);


                                R = R + 1;
                                rs.MoveNext();

                            }


                        }


                        AggiornaContatore();


                    }
                }

                SaveInMem(OBJSESSION);

                mp_objGrid.SetMatrix(mp_Matrix, mp_VetOriginalRow);

            }
        }
        /// <summary>
        /// '-- metodo pubblico per linizializzazione della sezione su un oggetto nuovo
        /// </summary>
        /// <param name="OBJSESSION"></param>
        /// <param name="idDoc"></param>
        /// <exception cref="NotImplementedException"></exception>
        public void InitializeNew(Session.ISession session, string idDoc)
        {
            try
            {

                //Dim objDB As Object
                int i;
                string strC;

                mp_idDoc = idDoc;
                InitLocal(session);

                mp_editable = !BasicDocument.isReadOnlySection(param, mp_idDoc, CStr(mp_User), mp_strConnectionString);


                ////'-- recupero la collezione di colonne da visualizzare in griglia
                mp_strcause = "recupero la collezione di colonne da visualizzare";

                ////'-- elimino la matrice precedentemente avvalorata
                EraseMem();

                ////'-- se la griglia non � coerente con il documento
                ////'-- il docuemento � editabile ma la griglia � stata caricata non editabile
                ////'-- allora la rimuove per ricaricarla


                if (mp_Columns != null)
                {

                    //'-- se la sezione era stata caricata come non editabile
                    //'-- ed il documento ora � editabile e la sezione non ha configurato il readonly
                    //'-- allora occorre ricaricarla per aggiornare i domini
                    if ((!objDocument.ReadOnly && !model_editable && mp_editable) || GetParam(param, "DYNAMIC_MODEL") == "yes")
                    {
                        mp_Columns = null;
                        mp_ColumnsProperty = null;
                    }

                }


                //'-- se la griglia non � presente la creo
                if (mp_Columns == null)
                {

                    LibDbModelExt objDB = new LibDbModelExt();
                    bool bEditable;
                    if (objDocument.ReadOnly || !mp_editable)
                    {
                        bEditable = false;
                    }
                    else
                    {
                        bEditable = true;
                    }

                    model_editable = bEditable;

                    string strModel;
                    strModel = mp_strModelGrid;

                    //'-- recupero il nome del modello dinamicamente se previsto
                    if (GetParam(param, "DYNAMIC_MODEL") == "yes" && UCase(Strings.Left(mp_idDoc, 3)) != "NEW")
                    {
                        TSRecordSet rsMod;
                        CommonDbFunctions objSQL = new CommonDbFunctions();
                        Dictionary<string, object?> sqlP = new();
                        sqlP.Add("@mp_idDoc", CInt(mp_idDoc));
                        sqlP.Add("@Id", Id);

                        rsMod = objSQL.GetRSReadFromQuery_("select MOD_Name from CTL_DOC_SECTION_MODEL with(nolock) where DSE_ID = @Id and IdHeader = @mp_idDoc", mp_strConnectionString, parCollection: sqlP);

                        if (rsMod.RecordCount > 0)
                        {
                            rsMod.MoveFirst();
                            strModel = CStr(rsMod["MOD_Name"]);
                        }

                    }

                    strModelName = strModel;

                    Dictionary<string, Field> tempMp_Columns = new Dictionary<string, Field>();
                    Dictionary<string, Grid_ColumnsProperty> tempMp_ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();

                    if (UCase(GetParam(param, "SAVE_MODEL")) == "YES")
                    {
                        objDB.GetFilteredFieldsCTL(strModel, ref tempMp_Columns, ref tempMp_ColumnsProperty, mp_suffix, mp_User, 0, mp_strConnectionString, session, IIF(objDocument.PrintMode, false, bEditable), mp_idDoc);
                    }
                    else
                    {
                        objDB.GetFilteredFieldsCTL(strModel, ref tempMp_Columns, ref tempMp_ColumnsProperty, mp_suffix, mp_User, 0, mp_strConnectionString, session, IIF(objDocument.PrintMode, false, bEditable), "");
                    }

                    this.mp_Columns = tempMp_Columns;
                    this.mp_ColumnsProperty = tempMp_ColumnsProperty;

                    if (!IsEmpty(mp_Matrix))
                    {
                        int colCount;
                        colCount = mp_Matrix.GetUpperBound(1);//UBound(mp_Matrix, 1)
                        if (colCount != mp_Columns.Count + 3 && mp_numRec > 0)
                        {
                            mp_Matrix = ResizeArray(mp_Matrix, mp_Columns.Count + 3, mp_numRec - 1);
                            //ReDim Preserve mp_Matrix(mp_Columns.count + 3, mp_numRec - 1) As Variant
                        }
                    }


                    //'-- in caso di documento in sola lettura si tolgono le colonne delle funzioni
                    if (objDocument.ReadOnly || !mp_editable)
                    {

                        if (mp_Columns.ContainsKey("FNZ_UPD"))
                        {
                            mp_Columns.Remove("FNZ_UPD");
                        }

                        if (mp_Columns.ContainsKey("FNZ_DEL"))
                        {
                            mp_Columns.Remove("FNZ_DEL");
                        }

                        if (mp_Columns.ContainsKey("FNZ_COPY"))
                        {
                            mp_Columns.Remove("FNZ_COPY");
                        }
                    }

                    mp_FieldNameNotEditable = UCase(GetParam(param, "COLUMN_NOT_EDITABLE"));

                    //'-- se è stato indicato il campo dei non editabili determina in che posizione della matrice si trova
                    if (!string.IsNullOrEmpty(mp_FieldNameNotEditable))
                    {
                        for (i = 1; i <= mp_Columns.Count; i++)
                        {//  To mp_Columns.count
                            if (UCase(mp_Columns.ElementAt(i - 1).Value.Name) == mp_FieldNameNotEditable)
                            {
                                mp_indexFieldNotEditable = i - 1;
                                break;
                            }
                        }
                    }


                    //'-- inizializzo le aree di memoria per il corretto funzionamento dell'oggetto
                    mp_objGrid = new Grid();

                    //'-- creo le aree di memoria vuote
                    mp_VetOriginalRow = new long[0 + 1];
                    mp_VetTotRow = new double[0 + 1];
                    mp_Total = 0;

                    //'-- recupero il modello di attributi
                    mp_strcause = "inizializzo la griglia dei dettagli";
                    mp_objGrid.Columns = mp_Columns;
                    mp_objGrid.ColumnsProperty = mp_ColumnsProperty;
                    mp_objGrid.SetMatrixDisposition(false); //'-- imposta la matrice in colonna riga
                    mp_objGrid.SetMatrix(mp_Matrix, mp_VetOriginalRow);
                    mp_objGrid.id = Id + "Grid";
                    mp_objGrid.width = "100%";
                    mp_SummaryField = GetParam(param, "SUMMARY");

                }

                //'-- PROGR_ROW = nome della colonna che contiene il progressivo di riga separato da virgola per determinare lo step
                strC = GetParam(param, "PROGR_ROW");
                if (!string.IsNullOrEmpty(strC))
                {
                    string[] v;
                    v = Strings.Split(strC, "~");
                    mp_CounterName = v[0];
                    mp_StepCounterRow = CLng(v[1]);
                    if ((v.Length - 1) > 1)
                    {
                        mp_SelectSQLStartCounterRow = v[2];
                    }

                    //'-- cerca la posizione del contatore
                    for (i = 1; i <= mp_Columns.Count; i++)
                    { //To mp_Columns.count
                        if (UCase(mp_Columns.ElementAt(i - 1).Value.Name) == UCase(mp_CounterName))
                        {
                            mp_PosCounter = i - 1;
                            break;
                        }
                    }

                }

                string strNODUPLICATI;
                strNODUPLICATI = Trim(GetParam(param, "NODUPLICATI"));
                //'-- cerca la posizione della colonna che non deve contenere duplicati
                mp_PosNoDuplicati = -1;
                if (!string.IsNullOrEmpty(strNODUPLICATI))
                {
                    //'-- cerca la posizione del contatore
                    for (i = 1; i <= mp_Columns.Count; i++)
                    {// To mp_Columns.count
                        if (UCase(mp_Columns.ElementAt(i - 1).Value.Name) == UCase(strNODUPLICATI))
                        {
                            mp_PosNoDuplicati = i - 1;
                            break;
                        }
                    }

                }

                //'-- recupero dalla memoria la matrice
                LoadFromMem(session);

                //'-- determino la posizione del contatore nella matrice ed il suo valore massimo
                if (!string.IsNullOrEmpty(mp_CounterName))
                {
                    AggiornaContatore();
                }

                //'-- elimino il modello per gli attributi opzionali
                mp_ModAddDetail = null;
            }
            catch (Exception ex)
            {
                throw new Exception("Errore inizializzazione sezione " + Id + " - " + ex.Message, ex);
            }
        }

        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library")
        {
            //On Error Resume Next
            if (mp_objGrid != null)
            {
                mp_objGrid.JScript(JS, Path);
            }
            if (mp_ModAdd != null)
            {
                mp_ModAdd.JScript(JS, Path);
            }
            if (mp_ModAddDetail != null)
            {
                mp_ModAddDetail.JScript(JS, Path);
            }
            if (!JS.ContainsKey("SEC_dettagli"))
            {
                JS.Add("SEC_dettagli", @"<script src=""" + Path + @"jscript/DOCUMENT/SEC_dettagli.js"" ></script>");
            }
            if (!JS.ContainsKey("ShowGroup"))
            {
                JS.Add("ShowGroup", @"<script src=""" + Path + @"jscript/ShowGroup.js"" ></script>");
            }
            if (!JS.ContainsKey("getObj"))
            {
                JS.Add("getObj", @"<script src=""" + Path + @"jscript/getObj.js"" ></script>");
            }
            if (!JS.ContainsKey("GetPosition"))
            {
                JS.Add("GetPosition", @"<script src=""" + Path + @"jscript/GetPosition.js"" ></script>");
            }
            if (!JS.ContainsKey("setVisibility"))
            {
                JS.Add("setVisibility", @"<script src=""" + Path + @"jscript/setVisibility.js"" ></script>");
            }
            if (!JS.ContainsKey("setClassName"))
            {
                JS.Add("setClassName", @"<script src=""" + Path + @"jscript/setClassName.js"" ></script>");
            }
            if (!JS.ContainsKey("JSTrim"))
            {
                JS.Add("JSTrim", @"<script src=""" + Path + @"jscript/JSTrim.js"" ></script>");
            }
            if (!JS.ContainsKey("ScrollPage"))
            {
                JS.Add("ScrollPage", @"<script src=""" + Path + @"jscript/ScrollPage/ScrollPage.js"" ></script>");
            }
        }

        public void Load(Session.ISession session, string idDoc, SqlConnection? prevConn = null)
        {
            //'-- prima si inizializzano le aree di memoria di base
            InitializeNew(session, idDoc);

            bool bEditable;
            bEditable = true;
            //RIMOSSO PER BLOCCO PIATTAFORMA AGGIUNTA PRODOTTI
            //long NumRowForPage;
            ////'-- recupera l'informazione delle righe per pagina se presente
            //NumRowForPage = CLng("0" + GetParam(param, "numRowForPag"));

            if (objDocument.ReadOnly || !mp_editable)
            {
                bEditable = false;
            }

            //'-- carico la matrice dal DB se non sono in memoria
            if (!IsInMem(session) || !bEditable)
            {

                //'-- sul primo caricamento determina il valore iniziale del contatore se necessario
                if (!string.IsNullOrEmpty(mp_SelectSQLStartCounterRow))
                {
                    TSRecordSet rs;
                    CommonDbFunctions cdb = new CommonDbFunctions();
                    mp_SelectSQLStartCounterRow = Strings.Replace(mp_SelectSQLStartCounterRow, "<ID_DOC>", idDoc);
                    rs = cdb.GetRSReadFromQuery_(mp_SelectSQLStartCounterRow, mp_strConnectionString, conn:prevConn);
                    if (rs.RecordCount > 0)
                    {
                        rs.MoveFirst();
                        mp_CounterValue = CLng(rs.Fields[0]);
                    }
                }

                ReadDettagli(prevConn);

                SaveInMem(session);

                mp_objGrid.SetMatrix(mp_Matrix, mp_VetOriginalRow);

            }
            else
            {

                //'-- recupero le variabili di memoria se presenti
                LoadFromMem(session);

            }

			//'--Controllo aggiiunto per settare la sezione dettalgi alla pagina massima nel caso in cui la pagina attuale superi la pagina massima BVEP-5920
			//'-- salto alla pagina corretta
			//RIMOSSO PER BLOCCO PIATTAFORMA AGGIUNTA PRODOTTI
			//if (NumRowForPage > 0)
			//{
			//    if (mp_NumeroPagina > Fix(CDbl(mp_numRec) / CDbl(NumRowForPage)) + IIF(mp_numRec % NumRowForPage > 0, 1, 0))
			//    {
			//        mp_NumeroPagina = CLng(Fix(CDbl(mp_numRec) / CDbl(NumRowForPage)) + IIF(mp_numRec % NumRowForPage > 0, 1, 0));
			//    }
			//}


		}

		public bool Save(Session.ISession session, ref string ReferenceKey, Dictionary<dynamic, dynamic> mpMEM, SqlConnection conn, SqlTransaction trans)
        {
            bool boolToReturn = true;
            string strCause = "";

            try
            {
                if (!mp_editable)
                {
                    boolToReturn = true;
                    return boolToReturn;
                }


                //'-- nel caso di record nuovo
                if (LCase(Strings.Left(mp_idDoc, 3)) == "new" || LCase(GetParam(param, "WRITE_VERTICAL")) == "yes")
                {

                    strCause = "chiamo Add";
                    Add(session, ReferenceKey, mpMEM, conn, trans);

                }
                else
                {

                    //'-- nel caso di salvataggio
                    strCause = "chiamo Upd";
                    Upd(session, ReferenceKey, mpMEM, conn, trans);

                }

                //'-- salvo i dati del modello se richiesto
                if (UCase(GetParam(param, "SAVE_MODEL")) == "YES")
                {
                    LibDbModelExt objDB = new LibDbModelExt();
                    strCause = "chiamo SaveDocModel";
                    objDB.SaveDocModel(strModelName, session, conn, mp_idDoc, ReferenceKey); //'mp_idSectionTable
                                                                                             //Set objDB = Nothing

                }

                string[] v_C;

                ////'-------------------
                ////'-- CRYPT ----------
                ////'-------------------
                ////'-- nel caso della cifratura dopo il salvataggio si richiede la cifratura dei dati
                if (Strings.Left(GetParam(param, "CRYPT"), 3) == "YES")
                {

                    string attreccezzioni;
                    string strFilter;

                    v_C = Strings.Split(GetParam(param, "CRYPT"), "~");

                    if ((v_C.Length - 1) >= 1)
                    {
                        attreccezzioni = v_C[1];
                    }
                    else
                    {
                        attreccezzioni = "";
                    }

                    if (LCase(GetParam(param, "WRITE_VERTICAL")) == "yes")
                    {
                        if (Trim(GetParam(param, "FILTER_ROW")) != "")
                        {
                            strFilter = Replace(GetParam(param, "FILTER_ROW") + " and DSE_ID = '" + Id + "' ", "'", "''");
                        }
                        else
                        {
                            strFilter = " DSE_ID = ''" + Id + "'' ";
                        }
                    }
                    else
                    {
                        strFilter = Replace(GetParam(param, "FILTER_ROW"), "'", "''");
                    }

                    strCause = "chiamo AFS_CRYPT_DATI '" + strTable + "' , '" + strFieldId + "' , '" + ReferenceKey + "' , '" + strModelName + "', '" + attreccezzioni + "' , '" + strFilter + "'";

                    CommonDbFunctions cdb = new();
                    var sqlParams = new Dictionary<string, object?>();
                    sqlParams.Add("@strTable", strTable);
                    sqlParams.Add("@strFieldId", strFieldId);
                    sqlParams.Add("@ReferenceKey", ReferenceKey);
                    sqlParams.Add("@strModel", strModelName);
                    sqlParams.Add("@attreccezzioni", attreccezzioni);
                    //sqlParams.Add("@strFilter", strFilter);
                    cdb.ExecuteWithTransaction($"exec AFS_CRYPT_DATI @strTable, @strFieldId, @ReferenceKey, @strModel, @attreccezzioni, '{strFilter}'", ApplicationCommon.Application.ConnectionString, conn, trans, parCollection: sqlParams);

                }


                //'-- azzero i valori delle colonne per le funzioni
                if (mp_Columns.ContainsKey("FNZ_UPD"))
                {
                    mp_Columns["FNZ_UPD"].Value = null;
                }

                if (mp_Columns.ContainsKey("FNZ_DEL"))
                {
                    mp_Columns["FNZ_DEL"].Value = null;
                }

                if (mp_Columns.ContainsKey("FNZ_COPY"))
                {
                    mp_Columns["FNZ_COPY"].Value = null;
                }

                return boolToReturn;

            }
            catch (Exception ex)
            {

                boolToReturn = false;

                string DescError;
                DescError = ex.Message;

                if (LCase(CStr(ApplicationCommon.Application["dettaglio-errori"])) == "yes")
                {

                    objDocument.Msg = strCause + " - Errore nel salvataggio - " + Caption + " - " + DescError;

                    TraceErr(ex, ApplicationCommon.Application.ConnectionString, "Sec_Dettagli.save()" + strCause + " - " + "Caption" + " - " + ex.ToString());

                }
                else
                {
                    objDocument.Msg = ApplicationCommon.CNV("INFO_UTENTE_ERRORE_PROCESSO", session) + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
                    TraceErr(ex, ApplicationCommon.Application.ConnectionString, "Sec_Dettagli.save()" + " Caption " + " - " + strCause + " - " + ex.ToString());
                }

                //'--aggiungo raiserror per far risalire anche la strcause
                throw new Exception("CtlDocument.Sec_Dettagli.Save( ) - " + strCause, ex);
            }
        }

        public void ToPrint(EprocResponse response, Session.ISession OBJSESSION)
        {
            string strJSOnLoad;
            int numCol;
            int c;
            int numRow;

            //'--centro il tutto se richiesto
            if (UCase(GetParam(param, "CENTER")) == "YES")
            {
                response.Write($@"<center>");
            }

            //'-- apro la div della sezione
            response.Write($@"<div class=""detail"" id=""" + Id + @""" name=""" + Id + @"""  >");


            //'-- se si possono inserire righe disegno gli attributi per l'inserimento

            HTML_HiddenField(response, "DETTAGLI_AREA_ADD", Id + "_ADD_" + mp_idDoc);
            HTML_HiddenField(response, "DETTAGLI_AREA_ADD_URL_UPD", "Sec_Dettagli.asp?MODE=UPD&IDDOC=" + mp_idDoc + "&" + param + "&DOCUMENT=" + GetParamURL(Request_QueryString.ToString(), "DOCUMENT") + "&SECTION=" + Id);
            HTML_HiddenField(response, Id + "Grid_SECTION_DETTAGLI_NAME", Id);

            //'-- disegno la griglia con le righe di dettaglio
            Grid objGrid;


            //'-- per ogni colonna setto l path dei JS
            int i;
            for (i = 0; i < mp_Columns.Count; i++)
            {
                mp_Columns.ElementAt(i).Value.Path = "../../";
            }

            //'-- in caso di documento in sola lettura si tolgono le colonne delle funzioni
            if (objDocument.ReadOnly || !mp_editable)
            {
                if (mp_Columns.ContainsKey("FNZ_UPD"))
                {
                    mp_Columns.Remove("FNZ_UPD");
                }

                if (mp_Columns.ContainsKey("FNZ_DEL"))
                {
                    mp_Columns.Remove("FNZ_DEL");
                }

                if (mp_Columns.ContainsKey("FNZ_COPY"))
                {
                    mp_Columns.Remove("FNZ_COPY");
                }
            }
            else
            {
                //'-- imposto per queste colonne la format perch� viene persa
                if (mp_Columns.ContainsKey("FNZ_UPD"))
                {
                    mp_Columns["FNZ_UPD"].Value = "";
                }

                if (mp_Columns.ContainsKey("FNZ_DEL"))
                {
                    mp_Columns["FNZ_DEL"].Value = "";
                }

                if (mp_Columns.ContainsKey("FNZ_COPY"))
                {
                    mp_Columns["FNZ_COPY"].Value = "";
                }
            }

            //'-- imposto per queste colonne la format perch� viene persa
            if (mp_Columns.ContainsKey("FNZ_UPD"))
            {
                mp_ColumnsProperty["FNZ_UPD"].Hide = true;
            }

            if (mp_Columns.ContainsKey("FNZ_DEL"))
            {
                mp_ColumnsProperty["FNZ_DEL"].Hide = true;
            }

            if (mp_Columns.ContainsKey("FNZ_COPY"))
            {
                mp_ColumnsProperty["FNZ_COPY"].Hide = true;
            }

            //'-- inizializzo la griglia
            objGrid = new Grid();

            mp_strcause = "inizializzo la griglia dei dettagli html";
            objGrid.Columns = mp_Columns;
            objGrid.ColumnsProperty = mp_ColumnsProperty;
            objGrid.SetMatrixDisposition(false); //'-- imposta la matrice in colonna riga
            objGrid.SetMatrix(mp_Matrix);
            objGrid.SetMatrix(mp_Matrix, mp_VetOriginalRow);
            objGrid.id = Id + "Grid";
            objGrid.width = "100%";

            if (UCase(GetParam(param, "SEC_FIELD")) == "YES")
            {
                objGrid.UseNameGridOnField = 1;
            }

            //'-- se � presente la colonna che riepiloga attributi opzionali allora si imposta il disegno custom
            if (!string.IsNullOrEmpty(mp_SummaryField) || mp_indexFieldNotEditable > -1)
            {
                objGrid.SetCustomDrawer(this);
            }

            objGrid.Editable = false;
            objGrid.PrintMode = true;
            objGrid.width = "100%";

            //'-- verifica se è necessario paginare la griglia
            if (!string.IsNullOrEmpty(GetParam(param, "CAPTIONGRID")))
            {
                objGrid.Caption = ApplicationCommon.CNV(GetParam(param, "CAPTIONGRID"), OBJSESSION);
            }


            objGrid.Html(response);



            strJSOnLoad = GetParam(param, "JSOnLoad");
            if (LCase(strJSOnLoad) == "yes")
            {

                response.Write($@"<script type=""text/javascript"" language=""javascript"" >" + Environment.NewLine);
                response.Write($@" try {{" + this.Id + $@"_OnLoad(); }}catch(e){{}}");
                response.Write($@"</script>");

            }

            objGrid.SetCustomDrawer(null);
            //Set objGrid = Nothing

            //'-- chiudo la div
            response.Write($@"</div>");


            //'--centro il tutto se richiesto
            if (UCase(GetParam(param, "CENTER")) == "YES")
            {
                response.Write($@"</center>");
            }

            //'DebugMem
        }

        public void toPrintExtraContent(EprocResponse response, Session.ISession OBJSESSION, string _params = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {
            long R;
            //Dim fld As Variant
            int c;
            Grid objGrid;
            int numCol;
            long numRow;

            //On Error Resume Next

            response.Write("<br/>");

            //'-- inizializzo la griglia
            objGrid = new Grid();

            objGrid.Columns = mp_Columns;
            objGrid.ColumnsProperty = mp_ColumnsProperty;
            objGrid.SetMatrixDisposition(false); //'-- imposta la matrice in colonna riga
            objGrid.SetMatrix(mp_Matrix);
            objGrid.id = Id + "Grid";

            numCol = objGrid.Columns.Count - 1;
            numRow = objGrid.getNumRow();


            for (R = 0; R <= numRow; R++)
            { //To numRow

                for (c = 0; c <= numCol; c++)
                {// To numCol
                    Field fld = objGrid.Columns.ElementAt(c).Value;
                    fld.Value = mp_Matrix[c, R];
                    fld.SetRow(R);
                    fld.toPrintExtraContent(response, OBJSESSION, _params, startPage, strHtmlHeader, strHtmlFooter, contaPagine);
                }

            }

            //err.Clear

            //On Error GoTo 0
        }

        public void UpdateContentInMem(Session.ISession session, IFormCollection? Request_Form = null)
        {
            //'--recupero tutti i campi editabili della griglia e li inserisco nella matrice
            int c;
            int R;
            int colCount;
            string UseNameGridOnField;
            long StartRow;
            long EndRow;
            long NumRowForPage;

            //Dim sessionASP As Object
            //Set sessionASP = session(OBJSESSION)


            UseNameGridOnField = "";

            //On Error Resume Next
            if (UCase(GetParam(param, "SEC_FIELD")) == "YES")
            {
                UseNameGridOnField = Id + "Grid" + "_";
            }

            Request_Form = _context.Request.HasFormContentType ? _context.Request.Form : null; //session(RequestForm)

            int numRow;

            //'INIZIALIZZO PER CICLARE SU TUTTE LE RIGHE
            StartRow = 0;
            EndRow = mp_numRec - 1;

            //'-- recupera l'informazione delle righe per pagina se presente
            if (!string.IsNullOrEmpty(GetParam(param, "numRowForPag")))
            {
                NumRowForPage = CLng("0" + GetParam(param, "numRowForPag"));
                //'-- recupera la pagina corrente
                long mp_NumeroPagina;
                string strSecName;

                strSecName = "DOC_SEC_MEM_" + objDocument.Id + "_" + objDocument.mp_IDDoc + "_" + Id;

                //'Se trova il numero di pagina in sessione, altrimenti cicla su tutte le righe
                if (!string.IsNullOrEmpty(CStr(session[strSecName + "_NumeroPagina"])))
                {
                    mp_NumeroPagina = CLng(session[strSecName + "_NumeroPagina"]);
                    StartRow = (mp_NumeroPagina - 1) * NumRowForPage;
                    EndRow = StartRow + NumRowForPage - 1;
                    if (EndRow > mp_numRec - 1)
                    {
                        EndRow = mp_numRec - 1;
                    }
                }
            }


            if (!IsEmpty(mp_Matrix))
            {
                colCount = mp_Columns.Count;

                if (Request_Form != null && Request_Form.Count > 0)
                {
                    //'For r = 0 To mp_numRec - 1
                    for (R = CInt(StartRow); R <= EndRow; R++)
                    { //To EndRow
                        for (c = 1; c <= colCount; c++)
                        { //To colCount
                            if (Request_Form.ContainsKey("R" + UseNameGridOnField + R + "_" + mp_Columns.ElementAt(c - 1).Value.Name))
                            {
                                mp_Matrix[c - 1, R] = GetValueFromForm(Request_Form, "R" + UseNameGridOnField + R + "_" + mp_Columns.ElementAt(c - 1).Value.Name);
                            }
                            else
                            {
                                //'-- solo per il checkbox si fa eccezione
                                if (mp_Columns.ElementAt(c - 1).Value.getType() == 9)
                                {
                                    mp_Matrix[c - 1, R] = "";
                                }
                            }
                        }
                    }
                }

                //'-- calcola il totale della sezione
                MakeTotalSection();

            }

            //'-- conservo le aree di memoria aggiornate
            SaveInMem(session);
        }

        public void xml(EprocResponse ScopeLayer)
        {
            mp_objGrid.Columns = mp_Columns;
            mp_objGrid.ColumnsProperty = mp_ColumnsProperty;
            mp_objGrid.SetMatrix(mp_Matrix);

            addXmlSection(Id, TypeSection, ScopeLayer);

            mp_objGrid.xml(ScopeLayer, "GRID");

            closeXmlSection(Id, ScopeLayer);
        }

        /// <summary>
        /// //'-- il metodo Command di una sezione norlmamente � invocato direttamente da una pagina per eseguire
        /// //'-- un comando il cui scopo � influenzare la sezione di pertinenza di provenienza
        /// //'-- ad esempio l'aggiunta di un record in una griglia
        /// </summary>
        public void Command(Session.ISession session, EprocResponse response)
        {
            InitLocal(session);

            string[] vcommand;
            string CommParam;
            string strTable;
            string indRow;
            long NumRowForPage;
            long CurRow;

            //'-- recupera l'informazione delle righe per pagina se presente
            NumRowForPage = CLng("0" + GetParam(param, "numRowForPag"));

            //'-- recupera il comando da eseguire
            vcommand = Strings.Split(CStr(GetParamURL(Request_QueryString.ToString(), "COMMAND")), ".");

            switch (UCase(vcommand[1]))
            {
                case "PAGINAZIONE":

                    //'-- recupera la pagina corrente
                    mp_NumeroPagina = CLng(GetParamURL(Request_QueryString.ToString(), "nPag"));

                    CurRow = (mp_NumeroPagina - 1) * NumRowForPage + 1;

                    //'-- aggiorna il contenuto della griglia da eventuali cambiamenti fatti a video
                    UpdateContentInMem(session, Request_Form);


                    //'-- disegna la griglia
                    //'mp_objGrid.Html response
                    Html(response, session);

                    //'-- inserisce il comando per sostituirla nel documento
                    response.Write($@"<script type=""text/javascript"" language=""javascript"" >;");
                    response.Write($@"       try {{ parent.getObj( 'div_" + Id + "Grid' ).innerHTML = ");
                    response.Write($@"       getObj( 'div_" + Id + $@"Grid' ).innerHTML; }} catch( e ) {{ }};");
                    response.Write($@"       ");

                    //'-- svuoto l'area di lavoro
                    response.Write($@"       try {{ ");
                    response.Write($@"       getObj( 'div_" + Id + $@"Grid' ).innerHTML=''; }} catch( e ) {{ }};");

                    //'-- aggiorno la paginazione
                    response.Write($@"       parent.SP_Refresh_SP_" + Id + "( " + mp_NumeroPagina + " );");

                    if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_SECTION")))
                    {
                        response.Write($@"      try {{  parent.MakeTotal_Section( '" + GetParam(param, "TOTAL_SECTION") + $@"' );}} catch( e ) {{ }}; ");
                    }

                    //'-- AGGIORNO IL TOTALE DELLA sezione
                    if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_FIELD")))
                    {
                        response.Write($@"  try {{  parent.SetNumericValue( '" + GetParam(param, "TOTAL_FIELD") + "' , " + Replace(CStr(mp_Total), ",", ".") + $@" ); }} catch( e ) {{;}}; " + Environment.NewLine);
                        response.Write($@"  try {{  parent." + Id + "_TotRow = " + Id + "_TotRow; } catch( e ) {;}; " + Environment.NewLine);
                    }

                    response.Write($@"</script>" + Environment.NewLine);
                    break;


                case "DELETE_ROW":

                    //'-- aggiorna il contenuto della griglia da eventuali cambiamenti fatti a video
                    UpdateContentInMem(session, Request_Form);

                    //'-- cancella dalla matrice il record nella posizione di 'IDROW'
                    DelRecord(session);

                    //'-- salto alla pagina corretta
                    if (NumRowForPage > 0)
                    {
                        if (mp_NumeroPagina > Fix(CDbl(mp_numRec) / CDbl(NumRowForPage)) + IIF(mp_numRec % NumRowForPage > 0, 1, 0))
                        {
                            mp_NumeroPagina = CLng(Fix(CDbl(mp_numRec) / CDbl(NumRowForPage)) + IIF(mp_numRec % NumRowForPage > 0, 1, 0));
                        }
                    }

                    //'-- disegna la griglia
                    //'mp_objGrid.Html response
                    Html(response, session);

                    //'-- inserisce il comando per sostituirla nel documento
                    response.Write($@"<script type=""text/javascript"" language=""javascript"" >;");
                    response.Write($@"       try {{ parent.getObj( 'div_" + Id + "Grid' ).innerHTML = ");
                    response.Write($@"       getObj( 'div_" + Id + $@"Grid' ).innerHTML; }} catch( e ) {{ }};");
                    response.Write($@"       ");
                    //'-- svuoto l'area di lavoro
                    response.Write($@"       try {{ ");
                    response.Write($@"       getObj( 'div_" + Id + $@"Grid' ).innerHTML=''; }} catch( e ) {{ }};");
                    
                    //'-- aggiusto la paginazione se presente
                    if (NumRowForPage > 0)
                    {
                        response.Write($@"       try {{ ");
                        //'Response.Write "           parent.SP_NumTotRow = SP_NumTotRow;"

                        response.Write($@"           parent.SP_Refresh_SP_" + Id + "( " + mp_NumeroPagina + " );");
                        response.Write($@"       }} catch( e ) {{ }};");
                    }


                    if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_SECTION")))
                    {
                        response.Write($@"      try {{  parent.MakeTotal_Section( '" + GetParam(param, "TOTAL_SECTION") + $@"' );}} catch( e ) {{ }}; ");
                    }

                    //'-- AGGIORNO IL TOTALE DELLA sezione
                    if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_FIELD")))
                    {
                        MakeTotalSection();
                        response.Write($@"  try {{  parent.SetNumericValue( '" + GetParam(param, "TOTAL_FIELD") + "' , " + Replace(CStr(mp_Total), ",", ".") + $@" ); }} catch( e ) {{;}}; " + Environment.NewLine);
                        response.Write($@"  try {{  parent." + Id + "_TotRow = " + Id + "_TotRow; } catch( e ) {;}; " + Environment.NewLine);
                    }



                    response.Write($@"</script>" + Environment.NewLine);

                    break;
                case "ADDNEW":

                    //'-- aggiorna il contenuto della griglia da eventuali cambiamenti fatti a video
                    UpdateContentInMem(session, Request_Form);

                    //'-- aggiunge una riga alla matrice
                    AddRecord(session);

                    //'-- salto alla pagina in coda
                    if (NumRowForPage > 0)
                    {
                        mp_NumeroPagina = CLng(Fix(CDbl(mp_numRec) / CDbl(NumRowForPage)) + IIF(mp_numRec % NumRowForPage > 0, 1, 0));
                    }

                    //'-- disegna la griglia
                    //'mp_objGrid.Html response
                    Html(response, session);


                    //'-- inserisce il comando per sostituirla nel documento
                    response.Write($@"<script type=""text/javascript"" language=""javascript"" >;");
                    response.Write($@"       try {{ parent.getObj( 'div_" + Id + "Grid' ).innerHTML = ");
                    response.Write($@"       getObj( 'div_" + Id + $@"Grid' ).innerHTML; }} catch( e ) {{ }};");
                    response.Write($@"       ");
                    //'-- svuoto l'area di lavoro
                    response.Write($@"       try {{ ");
                    response.Write($@"       getObj( 'div_" + Id + $@"Grid' ).innerHTML=''; }} catch( e ) {{ }};");

                    if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_SECTION")))
                    {
                        response.Write($@"      try {{  parent.MakeTotal_Section( '" + GetParam(param, "TOTAL_SECTION") + "' );}} catch( e ) {{ }}; ");
                    }

                    //'-- AGGIORNO IL TOTALE DELLA sezione
                    if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_FIELD")))
                    {
                        MakeTotalSection();
                        response.Write($@"  try {{  parent.SetNumericValue( '" + GetParam(param, "TOTAL_FIELD") + "' , " + Replace(CStr(mp_Total), ",", ".") + $@" ); }} catch( e ) {{;}}; " + Environment.NewLine);
                        response.Write($@"  try {{  parent." + Id + "_TotRow = " + Id + $@"_TotRow; }} catch( e ) {{;}}; " + Environment.NewLine);
                    }

                    //'-- aggiusto la paginazione se presente
                    if (NumRowForPage > 0)
                    {
                        response.Write($@"       try {{ ");
                        //'Response.Write "           parent.SP_NumTotRow = SP_NumTotRow;"
                        response.Write($@"           parent.SP_NumTotRow_SP_" + Id + " = " + mp_numRec + " ;");
                        response.Write($@"           parent.SP_Refresh_SP_" + Id + "( " + mp_NumeroPagina + " );");
                        response.Write($@"       }} catch( e ) {{ }};");
                    }

                    //'response.Write($@"       self.location = '' ;"


                    response.Write($@"</script>" + Environment.NewLine);
                    break;

                case "ADDFROM":

                    //On Error Resume Next

                    //Dim objDB As Object
                    TSRecordSet rs;
                    long R;
                    string strNODUPLICATI;
                    string RESPONSE_ESITO;
                    bool insertRecord;
                    string strSql;
                    string strMulti_Record;

                    strMulti_Record = "";

                    //'-- aggiorna il contenuto della griglia da eventuali cambiamenti fatti a video
                    UpdateContentInMem(session, Request_Form);


                    indRow = GetParamURL(Request_QueryString.ToString(), "IDROW");

                    strNODUPLICATI = Trim(GetParam(param, "NODUPLICATI"));
                    RESPONSE_ESITO = UCase(Trim(GetParamURL(Request_QueryString.ToString(), "RESPONSE_ESITO")));

                    strMulti_Record = UCase(Trim(GetParamURL(Request_QueryString.ToString(), "MULTI_RECORD")));

                    string[] aInfo;
                    int nRow;
                    int i;
                    aInfo = Strings.Split(indRow, "~~~");
                    nRow = (aInfo.Length - 1);

                    bool bContinue;

                    strTable = GetParamURL(Request_QueryString.ToString(), "TABLEFROMADD");

                    string strFilter;

                    strFilter = CStr(GetParamURL(Request_QueryString.ToString(), "Filter"));
                    int errorNumber = 0;
                    try
                    {
                        //'--gestiamo un nuovo parametro FILTER:  se passato applico questo e non ragiono per indrow sulla tabella sorgente
                        if (string.IsNullOrEmpty(strFilter))
                        {

                            for (i = 0; i <= nRow; i++)
                            {// To nRow

                                bContinue = true;

                                //'-- recupera i valori del record per metterli nella matrice
                                if (UCase(Strings.Left(strTable, 3)) == "SP_")
                                {

                                    //'--si tratta di una stored con i parametri user,iddoc
                                    strSql = "exec " + strTable + " " + CStr(mp_User) + "," + " '" + mp_idDoc + "'";

                                    if (IsNumeric(aInfo[i]))
                                    {
                                        strSql = strSql + ", " + CLng(aInfo[i]);
                                    }
                                    else
                                    {
                                        strSql = strSql + ", '" + Strings.Replace(aInfo[i], "'", "''") + "'";
                                    }

                                }
                                else
                                {


                                    if (IsNumeric(aInfo[i]))
                                    {
                                        strSql = "Select * from " + strTable + " where indRow  = " + CLng(aInfo[i]);
                                    }
                                    else
                                    {
                                        strSql = "Select * from " + strTable + " where indRow  = '" + Replace(aInfo[i], "'", "''") + "'";
                                    }

                                }



                                //Set objDB = CreateObject("ctldb.clsTabManage")
                                CommonDbFunctions cdb = new CommonDbFunctions();
                                rs = cdb.GetRSReadFromQuery_(strSql, mp_strConnectionString);

                                if (rs.RecordCount > 0)
                                {

                                    rs.MoveFirst();

                                    while (!rs.EOF && bContinue)
                                    {

                                        insertRecord = true;

                                        //'--if (rs.RecordCount > 0 And strNODUPLICATI <> "" ) {
                                        if (!string.IsNullOrEmpty(strNODUPLICATI))
                                        {
                                            //'-- prima di inserire il record verifico che non sia presente

                                            if (ValueExist(rs.Fields[strNODUPLICATI]))
                                            {
                                                insertRecord = false;
                                            }

                                        }


                                        if (insertRecord)
                                        {

                                            //'-- aggiunge una riga alla matrice
                                            AddRecord(session);

                                            //'    numCol = mp_Columns.Count
                                            R = mp_numRec - 1;

                                            //'--se passato il parametro della riga in cui inserire lo considero
                                            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), "ID_ADDROW")))
                                            {
                                                R = CInt(GetParamURL(Request_QueryString.ToString(), "ID_ADDROW"));
                                            }


                                            UpdRecordFromRS(session, rs, CInt(R));

                                        }

                                        if (strMulti_Record != "YES")
                                        {
                                            bContinue = false;
                                        }
                                        else
                                        {
                                            rs.MoveNext();
                                        }

                                    }

                                }
                                else
                                {

                                    //'--aggiungo una riga vuota per preservare il comportamento precedente dove nn era controllato che rs era pieno
                                    AddRecord(session);

                                }

                            }

                        }
                        else
                        {


                            //'--applico il filtro passato per determinare i record da aggiungere
                            strSql = "Select * from " + strTable + " where " + strFilter;

                            //Set objDB = CreateObject("ctldb.clsTabManage")
                            CommonDbFunctions cdb = new CommonDbFunctions();
                            rs = cdb.GetRSReadFromQuery_(strSql, mp_strConnectionString);
                            //Set objDB = Nothing

                            if (rs.RecordCount > 0)
                            {

                                //'ReDim mp_Matrix(mp_Columns.count + 3, rs.RecordCount) As Variant
                                //'ReDim VetTotRow(rs.RecordCount) As Double

                                rs.MoveFirst();

                                while (!rs.EOF)
                                {

                                    insertRecord = true;

                                    //'--if (rs.RecordCount > 0 And strNODUPLICATI <> "" ) {
                                    if (!string.IsNullOrEmpty(strNODUPLICATI))
                                    {

                                        //'-- prima di inserire il record verifico che non sia presente
                                        if (ValueExist(rs.Fields[strNODUPLICATI]))
                                        {
                                            insertRecord = false;
                                        }

                                    }


                                    if (insertRecord)
                                    {

                                        //'-- aggiunge una riga alla matrice
                                        AddRecord(session);

                                        //'    numCol = mp_Columns.Count
                                        R = mp_numRec - 1;

                                        //'--se passato il parametro della riga in cui inserire lo considero
                                        if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), "ID_ADDROW")))
                                        {
                                            R = CInt(GetParamURL(Request_QueryString.ToString(), "ID_ADDROW"));
                                        }


                                        UpdRecordFromRS(session, rs, CInt(R));

                                    }

                                    //'--if (strMulti_Record <> "YES" ) {
                                    //'--    bContinue = False
                                    //'--} else {
                                    rs.MoveNext();
                                    //'-- }

                                }

                            }

                        }
                    }
                    catch
                    {
                        errorNumber = 1;
                    }

                    if (RESPONSE_ESITO == "YES")
                    {

                        if (errorNumber != 0)
                        {

                            //err.Clear
                            //On Error GoTo 0

                            response.Write(ShowMessageBoxModale(ApplicationCommon.CNV("Righe non inserire correttamente.", session), "Errore", "../", MSG_ERR, "PARENT"));
                            response.Write($@"<script type=""text/javascript"" >" + Environment.NewLine);
                            response.Write($@"self.close();" + Environment.NewLine);
                            response.Write($@"</script>" + Environment.NewLine);

                        }
                        else
                        {
                            //err.Clear
                            //On Error GoTo 0
                            response.Write(ShowMessageBoxModale(ApplicationCommon.CNV("Righe inserire correttamente.", session), "Informazione", "../", MSG_INFO, "PARENT"));
                            response.Write($@"<script type=""text/javascript"" >" + Environment.NewLine);
                            response.Write($@"self.close();" + Environment.NewLine);
                            response.Write($@"</script>" + Environment.NewLine);

                        }


                    }
                    else
                    {

                        //err.Clear
                        //On Error GoTo 0
                        //'-- salto alla pagina in coda
                        if (NumRowForPage > 0)
                        {
                            mp_NumeroPagina = CLng(Fix(CDbl(mp_numRec) / CDbl(NumRowForPage)) + IIF(mp_numRec % NumRowForPage > 0, 1, 0));
                        }

                        //'-- disegna la griglia
                        //'mp_objGrid.Html response
                        Html(response, session);

                        //'-- inserisce il comando per sostituirla nel documento
                        response.Write($@"<script type=""text/javascript"" language=""javascript"" >;");
                        response.Write($@"       try {{ parent.getObj( 'div_" + Id + "Grid' ).innerHTML = ");
                        response.Write($@"       getObj( 'div_" + Id + $@"Grid' ).innerHTML; }} catch( e ) {{ }};");
                        response.Write($@"       ");
                        //'-- svuoto l'area di lavoro
                        response.Write($@"       try {{ ");
                        response.Write($@"       getObj( 'div_" + Id + $@"Grid' ).innerHTML=''; }} catch( e ) {{ }};");

                        if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_SECTION")))
                        {
                            response.Write($@"      try {{  parent.MakeTotal_Section( '" + GetParam(param, "TOTAL_SECTION") + $@"' );}} catch( e ) {{ }}; ");
                        }

                        //'-- AGGIORNO IL TOTALE DELLA sezione
                        if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_FIELD")))
                        {
                            MakeTotalSection();
                            response.Write($@"  try {{  parent.SetNumericValue( '" + GetParam(param, "TOTAL_FIELD") + "' , " + Replace(CStr(mp_Total), ",", ".") + $@" ); }} catch( e ) {{;}}; " + Environment.NewLine);
                            response.Write($@"  try {{  parent." + Id + "_TotRow = " + Id + $@"_TotRow; }} catch( e ) {{;}}; " + Environment.NewLine);
                        }


                        //'-- aggiusto la paginazione se presente
                        if (CLng("0" + GetParam(param, "numRowForPag")) > 0)
                        {
                            response.Write($@"       try {{ ");
                            //'Response.Write "           parent.SP_NumTotRow = SP_NumTotRow;"
                            response.Write($@"           parent.SP_NumTotRow_SP_" + Id + " = " + mp_numRec + " ;");
                            response.Write($@"           parent.SP_Refresh_SP_" + Id + "( " + mp_NumeroPagina + " );");
                            response.Write($@"       }} catch( e ) {{ }};");
                        }

                        response.Write($@"</script>" + Environment.NewLine);

                    }

                    break;
                case "COPY_ROW":


                    //'-- aggiorna il contenuto della griglia da eventuali cambiamenti fatti a video
                    UpdateContentInMem(session, Request_Form);

                    //'-- recupera l'indice del record per copiarlo nella matrice
                    indRow = GetParamURL(Request_QueryString.ToString(), "IDROW");

                    //'-- aggiunge una riga alla matrice
                    AddRecord(session, CInt(indRow));


                    //'-- salto alla pagina in coda
                    if (NumRowForPage > 0)
                    {
                        mp_NumeroPagina = CLng(Fix(CDbl(mp_numRec) / CDbl(NumRowForPage)) + IIF(mp_numRec % NumRowForPage > 0, 1, 0));
                    }

                    //'-- disegna la griglia
                    Html(response, session);

                    //'-- inserisce il comando per sostituirla nel documento
                    response.Write($@"<script type=""text/javascript"" language=""javascript"" >;");
                    response.Write($@"       try {{ parent.getObj( 'div_" + Id + $@"Grid' ).innerHTML = ");
                    response.Write($@"       getObj( 'div_" + Id + $@"Grid' ).innerHTML; }} catch( e ) {{ }};");
                    response.Write($@"       ");
                    //'-- svuoto l'area di lavoro
                    response.Write($@"       try {{ ");
                    response.Write($@"       getObj( 'div_" + Id + $@"Grid' ).innerHTML=''; }} catch( e ) {{ }};");

                    if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_SECTION")))
                    {
                        response.Write($@"      try {{  parent.MakeTotal_Section( '" + GetParam(param, "TOTAL_SECTION") + $@"' );}} catch( e ) {{ }}; ");
                    }

                    //'-- AGGIORNO IL TOTALE DELLA sezione
                    if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_FIELD")))
                    {
                        MakeTotalSection();
                        response.Write($@"  try {{  parent.SetNumericValue( '" + GetParam(param, "TOTAL_FIELD") + "' , " + Replace(CStr(mp_Total), ",", ".") + $@" ); }} catch( e ) {{;}}; " + Environment.NewLine);
                        response.Write($@"  try {{  parent." + Id + "_TotRow = " + Id + $@"_TotRow; }} catch( e ) {{;}}; " + Environment.NewLine);
                    }

                    //'-- aggiusto la paginazione se presente
                    if (CLng("0" + GetParam(param, "numRowForPag")) > 0)
                    {
                        response.Write($@"       try {{ ");
                        //'Response.Write "           parent.SP_NumTotRow = SP_NumTotRow;"
                        response.Write($@"           parent.SP_NumTotRow_SP_" + Id + " = " + mp_numRec + " ;");
                        response.Write($@"           parent.SP_Refresh_SP_" + Id + "( " + mp_NumeroPagina + " );");
                        response.Write($@"       }} catch( e ) {{ }};");
                    }




                    response.Write($@"</script>" + Environment.NewLine);
                    break;

                case "RELOAD":

                    bool toolbar_ok;
                    toolbar_ok = false;

                    RemoveMem(session);
                    Load(session, mp_idDoc);


                    if (NumRowForPage > 0)
                    {


                        //'--se passata setto una pagina
                        if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), "nPag")))
                        {

                            if (UCase(Trim(GetParamURL(Request_QueryString.ToString(), "nPag"))) == "LAST_PAGE")
                            {

                                //'-- salto alla pagina in coda
                                mp_NumeroPagina = CLng(Fix(mp_numRec / NumRowForPage) + IIF(mp_numRec % NumRowForPage > 0, 1, 0));

                            }
                            else
                            {

                                if (IsNumeric(Trim(GetParamURL(Request_QueryString.ToString(), "nPag"))))
                                {
                                    mp_NumeroPagina = CLng(Trim(GetParamURL(Request_QueryString.ToString(), "nPag")));
                                }

                            }

                        }

                    }

                    //'--se richiesto non disegna l'output
                    if (GetParamURL(Request_QueryString.ToString(), "OUTPUT") != "NO")
                    {

                        //'--se presente la toolbar la disegno

                        //'-- se la sezione non � in sola lettura allora inserisco la toolbar se presente
                        //'-- a meno che non � passato il parametro SHOW_TOOLBAR_ON_READONLY sulla sezione, in tal caso
                        //'-- la toolbar viene comunque visualizzata

                        //'-- setto il percorso immagini corretto per la toolbar (per evitare il doppio ctl_library di default)
                        if (ObjToolbar != null)
                        {
                            ObjToolbar.strPath = "../images/toolbar/";
                        }

                        if (UCase(GetParam(param, "SHOW_TOOLBAR_ON_READONLY")) == "YES" && ObjToolbar != null)
                        {

                            if (ObjToolbar.Buttons.Count > 0)
                            {
                                ObjToolbar.Html(response);
                                toolbar_ok = true;
                            }

                        }
                        else
                        {

                            if (objDocument.ReadOnly == false && mp_editable == true && ObjToolbar != null)
                            {
                                if (ObjToolbar.Buttons.Count > 0)
                                {
                                    ObjToolbar.Html(response);
                                    toolbar_ok = true;
                                }
                            }

                        }

                        //'-- disegna la griglia
                        Html(response, session);

                        //'-- inserisce il comando per sostituirla nel documento
                        response.Write($@"<script type=""text/javascript"" language=""javascript"" >;");
                        response.Write($@"       try {{ parent.getObj( 'div_" + Id + $@"Grid' ).innerHTML = ");
                        response.Write($@"       getObj( 'div_" + Id + $@"Grid' ).innerHTML; }} catch( e ) {{ }};");
                        response.Write($@"       ");

                        //'-- svuoto l'area di lavoro della griglia
                        response.Write($@"       try {{ ");
                        response.Write($@"       getObj( 'div_" + Id + $@"Grid' ).innerHTML=''; }} catch( e ) {{ }};");

                        //'-- inserisce il comando per sostituire la toolbar della sezione
                        if (toolbar_ok == true)
                        {
                            response.Write($@"       try {{ parent.getObj( '" + ObjToolbar.id + $@"' ).innerHTML = ");
                            response.Write($@"       getObj( '" + ObjToolbar.id + $@"' ).innerHTML; }} catch( e ) {{ }};");
                            response.Write($@"       ");

                            //'-- svuoto l'area di lavoro della toolbar
                            response.Write($@"       try {{ ");
                            response.Write($@"       getObj( '" + ObjToolbar.id + $@"' ).innerHTML=''; }} catch( e ) {{ }};");
                        }

                        if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_SECTION")))
                        {
                            response.Write($@"      try {{  parent.MakeTotal_Section( '" + GetParam(param, "TOTAL_SECTION") + $@"' );}} catch( e ) {{ }}; ");
                        }

                        //'-- AGGIORNO IL TOTALE DELLA sezione
                        if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_FIELD")))
                        {
                            MakeTotalSection();
                            response.Write($@"  try {{  parent.SetNumericValue( '" + GetParam(param, "TOTAL_FIELD") + "' , " + Replace(CStr(mp_Total), ",", ".") + $@" ); }} catch( e ) {{;}}; " + Environment.NewLine);
                            response.Write($@"  try {{  parent." + Id + "_TotRow = " + Id + "_TotRow; } catch( e ) {;}; " + Environment.NewLine);
                        }

                        //'-- aggiusto la paginazione se presente
                        if (CLng("0" + GetParam(param, "numRowForPag")) > 0)
                        {
                            response.Write($@"       try {{ ");
                            //'response.Write($@"           parent.SP_NumTotRow = SP_NumTotRow;"
                            response.Write($@"           parent.SP_NumTotRow_SP_" + Id + " = " + mp_numRec + " ;");
                            response.Write($@"           parent.SP_Refresh_SP_" + Id + "( " + mp_NumeroPagina + " );");
                            response.Write($@"       }} catch( e ) {{ }};");
                        }

                        response.Write($@"</script>" + Environment.NewLine);

                    }
                    break;
                case "DELETE_ALL":

                    //'--cancella tutta la griglia
                    DeleteAll();

                    //'-- salto alla pagina corretta
                    if (NumRowForPage > 0)
                    {
                        if (mp_NumeroPagina > Fix(CDbl(mp_numRec / NumRowForPage)) + IIF(mp_numRec % NumRowForPage > 0, 1, 0))
                        {
                            mp_NumeroPagina = CLng(Fix(CDbl(mp_numRec / NumRowForPage)) + IIF(mp_numRec % NumRowForPage > 0, 1, 0));
                        }
                    }

                    //'-- disegna la griglia
                    Html(response, session);

                    //'-- inserisce il comando per sostituirla nel documento
                    response.Write($@"<script type=""text/javascript"" language=""javascript"" >;");
                    response.Write($@"       try {{ parent.getObj( 'div_" + Id + "Grid' ).innerHTML = ");
                    response.Write($@"       getObj( 'div_" + Id + $@"Grid' ).innerHTML; }} catch( e ) {{ }};");
                    response.Write($@"       ");
                    //'-- svuoto l'area di lavoro
                    response.Write($@"       try {{ ");
                    response.Write($@"       getObj( 'div_" + Id + $@"Grid' ).innerHTML=''; }} catch( e ) {{ }};");

                    //'-- aggiusto la paginazione se presente
                    if (NumRowForPage > 0)
                    {
                        response.Write($@"       try {{ ");
                        //'Response.Write "           parent.SP_NumTotRow = SP_NumTotRow;"
                        response.Write($@"           parent.SP_NumTotRow_SP_" + Id + " = " + mp_numRec + " ;");
                        response.Write($@"           parent.SP_Refresh_SP_" + Id + "( " + mp_NumeroPagina + " );");
                        response.Write($@"       }} catch( e ) {{ }};");
                    }


                    if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_SECTION")))
                    {
                        response.Write($@"      try {{  parent.MakeTotal_Section( '" + GetParam(param, "TOTAL_SECTION") + $@"' );}} catch( e ) {{ }}; ");
                    }

                    //'-- AGGIORNO IL TOTALE DELLA sezione
                    if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_FIELD")))
                    {
                        MakeTotalSection();
                        response.Write($@"  try {{  parent.SetNumericValue( '" + GetParam(param, "TOTAL_FIELD") + "' , " + Replace(CStr(mp_Total), ",", ".") + $@" ); }} catch( e ) {{;}}; " + Environment.NewLine);
                        response.Write($@"  try {{  parent." + Id + "_TotRow = " + Id + $@"_TotRow; }} catch( e ) {{;}}; " + Environment.NewLine);
                    }

                    response.Write($@"</script>" + Environment.NewLine);
                    break;
                default:
                    break;

            }

            response.Write($@"<script type=""text/javascript"" language=""javascript"" >;");
            response.Write($@"       try {{ ");
            response.Write($@"       parent." + Id + "_AFTER_COMMAND( '" + UCase(vcommand[1]) + $@"' ); }} catch( e ) {{ }};");

            //'--innesco funzione javascript DOCUMENT_AFTER_COMMAND
            response.Write($@"       try {{ ");
            response.Write($@"       parent.DOCUMENT_AFTER_COMMAND( '" + UCase(vcommand[1]) + "' , '" + Id + $@"' ,'SEC_DETTAGLI'); }} catch( e ) {{ }};");


            response.Write($@"</script>" + Environment.NewLine);

            SaveInMem(session);
        }

        /// <summary>
        /// '-- pulisce la matrice con le aree collegate
        /// </summary>
        public void EraseMem()
        {
            int colCount;
            //On Error Resume Next


            //'If mp_numRec = 0 Then
            //'    Exit Function
            //'End If
            int numRow;

            if (!IsEmpty(mp_Matrix))
            {
                numRow = mp_Matrix.GetUpperBound(1);
                colCount = mp_Columns.Count;

                //for (i = 0; i <= numRow; i++){// To numRow
                //    colAtt = mp_Matrix[colCount, i];
                //    if(colAtt != null){
                //        while ((colAtt.Count) > 0)
                //            colAtt.Remove(1);
                //        }
                //    }
                //    mp_Matrix[colCount, i] = null;
                //}

                //Erase(mp_Matrix);
                mp_Matrix = new dynamic[0, 0];
            }
            if (mp_objGrid != null)
                mp_objGrid.SetMatrix(mp_Matrix, mp_VetOriginalRow);

            //Erase(mp_VetOriginalRow);
            //Erase(mp_VetTotRow);
            mp_VetOriginalRow = new long[0];
            mp_VetTotRow = new double[0];

            mp_numRec = 0;
        }

        private void ReadDettagli(SqlConnection? prevConn)
        {
            TSRecordSet rsDett = new TSRecordSet();
            TSRecordSet rsAtt = new TSRecordSet();
            string strSql;
            int R;
            int i;
            int c;
            int numCol;
            string strAttribTable;
            string strAttribTableField;
            string strAttribTableValue;
            string strRELACTION;
            Dictionary<dynamic, dynamic> ObjColAtt;
            string strFieldClass;
            string strFilterRow;
            bool bWRITE_VERTICAL;
            string lstrSTORED;

            try
            {
                CommonDbFunctions cdb = new();
                //'-- recupera i parametri di configurazione
                strAttribTable = GetParam(param, "ATTRIB_TABLE");
                strAttribTableField = GetParam(param, "ATTRIB_TABLE_FIELD");
                strAttribTableValue = GetParam(param, "ATTRIB_TABLE_VALUE");
                strRELACTION = GetParam(param, "ATTRIB_RELACTION");
                strFieldClass = GetParam(param, "FIELD_CLASS");
                strFilterRow = GetParam(param, "FILTER_ROW");

                strFilterRow = Strings.Replace(strFilterRow, "<ID_USER>", CStr(mp_User));

                string view;
                view = GetParam(param, "VIEW");
                if (string.IsNullOrEmpty(view))
                {
                    view = strTable;
                }

                //'-------------------
                //'-- CRYPT ----------
                //'-------------------
                string[] v_C;
                v_C = Strings.Split(GetParam(param, "CRYPT"), "~");
                string PresenteCifratura;
                PresenteCifratura = "no";

                //'-- carica i dettagli
                strSql = "Select * from " + view + " where " + strFieldId + " = " + mp_idDoc + IIF(!string.IsNullOrEmpty(strFilterRow), " and " + strFilterRow, "");

                //'-- in caso in cui il salvataggio è verticale
                bWRITE_VERTICAL = (LCase(GetParam(param, "WRITE_VERTICAL")) == "yes");
                if (bWRITE_VERTICAL)
                {
                    strSql = strSql + " and DSE_ID ='" + Id + "' order by row";
                }
                else
                {
                    if (!string.IsNullOrEmpty(GetParam(this.param, "ORDERBY")))
                    {
                        strSql = strSql + " order by " + GetParam(this.param, "ORDERBY");
                    }
                    else
                    {
                        strSql = strSql + " order by " + strFieldIdRow;
                    }
                }

                //'-------------------
                //'-- CRYPT ----------
                //'-------------------
                //'-- nel caso della cifratura aggiunge la colonna che decifra i dati
                string Fieldkey = "";
                if (Strings.Left(GetParam(param, "CRYPT"), 3) == "YES")
                {
                    PresenteCifratura = "YES";

                    if ((v_C.Length - 1) == 2)
                    {
                        Fieldkey = v_C[2];
                    }
                    else
                    {
                        Fieldkey = strFieldId;
                    }
                }

                //'-- se è presente la stored per recuperare i dati viene sfruttata quest'ultima per effettuare decifratura o lettura in verticale
                lstrSTORED = GetParam(param, "STORED");
                if (!string.IsNullOrEmpty(lstrSTORED))
                {
                    strSql = "Exec " + lstrSTORED + " '" + objDocument.Id + "' ,  '" + Id + " ' , '" + mp_idDoc + "' , '" + mp_User + "'";
                    rsDett = cdb.GetRSReadFromQuery_(strSql, mp_strConnectionString, conn: prevConn);
                }
                else
                {
                    if (PresenteCifratura == "YES")
                    {
                        rsDett = cdb.GetRSReadFromQuery_("exec AFS_DECRYPT '" + CStr(mp_User) + "' , '" + Id + "', '" + Fieldkey + "', '" + Replace(strSql, "'", "''") + "' , '" + strTable + "', '" + strFieldIdRow + "'", mp_strConnectionString, conn: prevConn);
                    }
                    else
                    {
                        rsDett = cdb.GetRSReadFromQuery_(strSql, mp_strConnectionString, conn: prevConn);
                    }
                }

                //'-- carica gli attributi dei dettagli
                if (!string.IsNullOrEmpty(strAttribTable))
                {
                    strSql = "Select * from " + strAttribTable + ", " + strTable + " where " + strFieldId + " = " + mp_idDoc + " and " + strTableFilter;
                    //TODO: Federico, utilizzare un metodo GetRSReadFromQueryAsync così da ottenere un task e far andare avanti il codice
                    //          fino al punto dove effettivamente serve rsAtt, lì aggiungere una wait
                    rsAtt = cdb.GetRSReadFromQuery_(strSql, mp_strConnectionString, conn: prevConn);
                }

                //'-- in caso di documento in sola lettura si tolgono le colonne delle funzioni
                if (objDocument.ReadOnly || !mp_editable)
                {
                    //On Error Resume Next
                    try
                    {
                        mp_Columns.Remove("FNZ_UPD");
                    }
                    catch { }
                    try
                    {
                        mp_Columns.Remove("FNZ_DEL");
                    }
                    catch { }
                    try
                    {
                        mp_Columns.Remove("FNZ_COPY");
                    }
                    catch { }
                    //'-- in questo caso si deve ricalcolare la posizione del contatore
                    if (!string.IsNullOrEmpty(mp_CounterName))
                    {
                        for (i = 1; i <= mp_Columns.Count; i++)
                        {// To mp_Columns.Count
                            if (UCase(mp_Columns.ElementAt(i - 1).Value.Name) == UCase(mp_CounterName))
                            {
                                mp_PosCounter = i - 1;
                                break;
                            }
                        }
                    }

                    //On Error GoTo 0
                }


                //'-- popola la matrice
                numCol = mp_Columns.Count;
                mp_numRec = rsDett.RecordCount;
                if (mp_numRec > 0)
                {
                    mp_Matrix = new dynamic[numCol + 3 + 1, mp_numRec - 1 + 1];//ReDim mp_Matrix(numCol + 3, mp_numRec - 1) As Variant
                }
                mp_VetOriginalRow = new long[mp_numRec + 1];//ReDim mp_VetOriginalRow(mp_numRec) As Long
                mp_VetTotRow = new double[mp_numRec + 1];//ReDim mp_VetTotRow(mp_numRec) As Double


                XmlDocument objXML = new XmlDocument();
                XmlNodeList objNodeList;// = new XmlNodeList();

                //On Error Resume Next

                objXML.PreserveWhitespace = true;

                if (rsDett.RecordCount > 0)
                {
                    rsDett.MoveFirst();
                    if (bWRITE_VERTICAL == true)
                    {
                        long maxR;
                        maxR = 0;
                        while (!rsDett.EOF)
                        {
                            R = CInt(rsDett.Fields["Row"]);

                            if (maxR < R)
                            {
                                maxR = R;
                            }
                            c = GetIndexColumn(CStr(rsDett["DZT_Name"])) - 1;
                            if (c >= 0)
                            {
                                mp_Matrix[c, R] = GetValueFromRS(rsDett.Fields["Value"]);
                            }

                            //'-------------------
                            //'-- CRYPT ----------
                            //'-------------------
                            if (PresenteCifratura == "YES" && IsNull(mp_Matrix[c, R]) && c >= 0)
                            {
                                //'-- se il valore restituito è null allora verifichiamo se è nei dati cifrati

                                objXML.LoadXml(CStr(rsDett.Fields["AFS_DATI_DECIFRATI"]));

                                //'Set objNodeList = objXML.getElementsByTagName(rsDett.Fields("DZT_Name").Value)
                                objNodeList = objXML.GetElementsByTagName("Value");
                                if (objNodeList.Count - 1 >= 0)
                                {
                                    mp_Matrix[c, R] = objNodeList[0].InnerText;// .nodeTypedValue
                                }

                            }

                            rsDett.MoveNext();
                        }
                        mp_numRec = CInt(maxR);

                        mp_Matrix = ResizeArray(mp_Matrix, mp_Columns.Count + 3, mp_numRec);//ReDim Preserve mp_Matrix(mp_Columns.count + 3, mp_numRec) As Variant
                        Array.Resize(ref mp_VetTotRow, mp_numRec + 1);//ReDim Preserve mp_VetTotRow(mp_numRec) As Double

                        mp_numRec = mp_numRec + 1;
                        int ix;
                        for (ix = 0; ix <= mp_numRec - 1; ix++)
                        {// To mp_numRec - 1
                            mp_Matrix[numCol, ix] = null;
                        }

                    }
                    else
                    {
                        for (R = 0; R <= mp_numRec - 1; R++)
                        { //To mp_numRec - 1


                            //On Error Resume Next

                            for (c = 1; c <= numCol; c++)
                            {  //To numCol

                                //'-- il campo potrebbe non essere in tabella
                                if (rsDett.ColumnExists(mp_Columns.ElementAt(c - 1).Value.Name))
                                {
                                    mp_Matrix[c - 1, R] = GetValueFromRS(rsDett.Fields[mp_Columns.ElementAt(c - 1).Value.Name]);
                                }

                            }


                            //'-------------------
                            //'-- CRYPT ----------
                            //'-------------------
                            //'-- se richiesta la cifratura e ci sono dati cifrati allora si cerca di recuperare i dati dalla
                            if (PresenteCifratura == "YES")
                            {

                                if (IsNull(rsDett.Fields["AFS_DATI_DECIFRATI"]) == false && IsDbNull(rsDett.Fields["AFS_DATI_DECIFRATI"]) == false)
                                {
                                    try
                                    {
                                        objXML.LoadXml(CStr(rsDett.Fields["AFS_DATI_DECIFRATI"]));
                                    }
                                    catch { }


                                    for (c = 1; c <= numCol; c++)
                                    {//To numCol
                                        //'--mp_Matrix(c - 1, r) = rsDett.Fields(mp_Columns(c).Name)
                                        if (IsNull(mp_Matrix[c - 1, R]))
                                        {
                                            objNodeList = objXML.GetElementsByTagName(mp_Columns.ElementAt(c - 1).Value.Name);
                                            if (objNodeList.Count - 1 >= 0)
                                            {
                                                mp_Matrix[c - 1, R] = objNodeList[0].InnerText; //.nodeTypedValue 'text
                                            }
                                        }
                                    }


                                }
                            }



                            //On Error GoTo Herr

                            //'-- aggiunge gli attributi di riferimento sulla matrice
                            mp_Matrix[numCol + 1, R] = GetValueFromRS(rsDett.Fields[strFieldIdRow]);
                            mp_VetOriginalRow[R] = CLng(rsDett.Fields[strFieldIdRow]);
                            if (!string.IsNullOrEmpty(strFieldClass))
                            {
                                mp_Matrix[numCol + 2, R] = GetValueFromRS(rsDett.Fields[strFieldClass]);
                            }

                            mp_Matrix[numCol, R] = null;
                            //'-- se ci sono attributi opzionali li carico nella supercollezione
                            if (rsAtt != null && rsAtt.RecordCount != 0)
                            {
                                //'-- prendo tutti gli attributi relativi alla riga
                                rsAtt.Filter(strRELACTION + "=" + rsDett.Fields[strFieldIdRow]);

                                if (rsAtt.RecordCount > 0)
                                {
                                    ObjColAtt = new Dictionary<dynamic, dynamic>();
                                    rsAtt.MoveFirst();
                                    for (i = 1; i <= rsAtt.RecordCount; i++)
                                    {// To rsAtt.RecordCount
                                        ObjColAtt.Add(CStr(rsAtt.Fields[strAttribTableValue]), CStr(rsAtt.Fields[strAttribTableField]));
                                        rsAtt.MoveNext();
                                    }
                                    mp_Matrix[numCol, R] = ObjColAtt;
                                    ObjColAtt = null;
                                }

                            }

                            //'-- determino il contatore massimo
                            if (mp_PosCounter >= 0)
                            {
                                if (CInt(mp_Matrix[mp_PosCounter, R]) > CInt(mp_CounterValue))
                                {
                                    mp_CounterValue = CLng(mp_Matrix[mp_PosCounter, R]);
                                }
                            }

                            rsDett.MoveNext();

                        }
                    }
                }

                //'-- calcola il totale della sezione
                MakeTotalSection();


            }
            catch (Exception ex)
            {
                throw new Exception("CtlDocument.Sec_Dettagli.ReadDettagli", ex);
            }
        }

        /// <summary>
        /// '-- in caso di primo inseriemento
        /// </summary>
        /// <param name="session"></param>
        /// <param name="ReferenceKey"></param>
        /// <param name="mpMEM"></param>
        /// <param name="conn"></param>
        /// <param name="trans"></param>
        /// <returns></returns>
        private void Add(Session.ISession session, string ReferenceKey, Dictionary<dynamic, dynamic> mpMEM, SqlConnection conn, SqlTransaction trans)
        {
            //'-- aggiunge tutti i record presenti nella matrice
            string strCause = "";
            SqlConnection cnLocal = new SqlConnection(mp_strConnectionString);
            try
            {
                int numRec;
                int R;
                string strSql;
                TSRecordSet rs = new TSRecordSet();
                TSRecordSet rsAtt = new TSRecordSet();

                //Dim objDB As Object
                //'Dim Columns As Collection
                //'Dim ColumnsProperty As Collection
                Field objField;
                int i;
                int nc;
                Dictionary<dynamic, dynamic> objAttOpt;
                string strRELACTION;
                string strAttribTableField;
                string strAttribTableValue;
                string strAttribTable;
                string strFieldClass;

                bool bWRITE_VERTICAL;

                bWRITE_VERTICAL = (LCase(GetParam(param, "WRITE_VERTICAL")) == "yes");

                strCause = "recupero parametri";
                strAttribTable = GetParam(param, "ATTRIB_TABLE");
                strRELACTION = GetParam(param, "ATTRIB_RELACTION");
                strAttribTableField = GetParam(param, "ATTRIB_TABLE_FIELD");
                strAttribTableValue = GetParam(param, "ATTRIB_TABLE_VALUE");
                strFieldClass = GetParam(param, "FIELD_CLASS");

                //'if (Not IsEmpty(mp_Matrix) ) {
                //'    numRec = UBound(mp_Matrix, 2)
                //'}

                if (mp_numRec <= 0 && bWRITE_VERTICAL == false)
                {
                    return;
                }
                //'-- apro la connessione
                if (conn == null)
                {
                    cnLocal = new SqlConnection(mp_strConnectionString);
                    //'cnLocal.ConnectionTimeout = lTimeout
                    cnLocal.Open();
                    trans = cnLocal.BeginTransaction();
                }
                else
                {
                    cnLocal = conn;
                }


                string Columns;
                Columns = Trim(GetParam(param, "FIELD_TO_UPD"));

                if (bWRITE_VERTICAL && LCase(Strings.Left(mp_idDoc, 3)) != "new" && !string.IsNullOrEmpty(mp_idDoc))
                {

                    if (!string.IsNullOrEmpty(Columns))
                    {
                        if (Strings.Left(Columns, 1) == ",")
                        {
                            Columns = Strings.Mid(Columns, 2);
                        }
                        if (Strings.Right(Columns, 1) == ",")
                        {
                            Columns = Strings.Left(Columns, Len(Columns) - 1);
                        }
                        Columns = "'" + Strings.Replace(Columns, ",", "','") + "'";
                    }

                    strCause = "tabella " + strTable + " - cancello le colonne=" + Columns + " - idheader = " + ReferenceKey + " - DSE_ID=" + Id +
                    " [ DELETE from " + strTable + " where idHeader = " + ReferenceKey + " and DSE_ID = '" + Id + "'" + IIF(!string.IsNullOrEmpty(Columns), " and dzt_name in ( " + Columns + " ) ", "") + " ] ";
                    CommonDbFunctions cdb = new CommonDbFunctions();

                    var sqlParams = new Dictionary<string, object?>();
                    sqlParams.Add("@ReferenceKey", CLng(ReferenceKey));
                    sqlParams.Add("@Id", Id);

                    cdb.ExecuteWithTransaction($"DELETE from {strTable} where idHeader = @ReferenceKey and DSE_ID = @Id " + IIF(!string.IsNullOrEmpty(Columns), " and dzt_name in ( " + Columns + " ) ", ""), ApplicationCommon.Application.ConnectionString, cnLocal, trans, parCollection: sqlParams);
                }


                //'-- prendo il recordset dei clienti
                strSql = "select * from " + strTable + " where " + strFieldIdRow + " = -1 ";

                rs.Open(strSql, ApplicationCommon.Application.ConnectionString, connection: conn, transaction: trans);

                if (!string.IsNullOrEmpty(strAttribTable))
                {
                    strSql = "select * from " + strAttribTable + " where " + strRELACTION + " = -1 ";
                    rsAtt.Open(strSql, ApplicationCommon.Application.ConnectionString, connection: conn, transaction: trans);
                }

                nc = mp_Columns.Count;


                if (bWRITE_VERTICAL)
                {

                    strCause = "write vertical ";

                    //'-- aqzzero le colonne da non aggiornare sul primo salvataggio
                    if (LCase(Strings.Left(mp_idDoc, 3)) == "new" || string.IsNullOrEmpty(mp_idDoc))
                    {
                        Columns = "";
                    }

                    //'-- per ogni riga della matrice
                    for (R = 0; R <= mp_numRec - 1; R++)
                    {// To mp_numRec - 1

                        //'-- per ogni campo del modello prelevo il valore dal form e lo memorizzo nel RS
                        for (i = 1; i <= nc; i++)
                        {// To nc

                            objField = mp_Columns.ElementAt(i - 1).Value;

                            //'-- se il campo � da aggiornare
                            if (Columns.Contains("," + objField.Name + ",", StringComparison.Ordinal) || string.IsNullOrEmpty(Columns))
                            {

                                mp_Columns.ElementAt(i - 1).Value.Value = mp_Matrix[i - 1, R];

                                //On Error Resume Next
                                strCause = "write vertical idheader=" + ReferenceKey + " - dse_id=" + Id + " - Row = " + R + " - dzt_name = " + objField.Name + " - " + IIF(IsNull(mp_Columns.ElementAt(i - 1).Value.TechnicalValue()), "", mp_Columns.ElementAt(i - 1).Value.TechnicalValue());

                                DataRow dr = rs.AddNew();

                                dr["IdHeader"] = ReferenceKey;
                                dr["DSE_ID"] = Id;
                                dr["Row"] = R;
                                dr["DZT_Name"] = objField.Name;
                                dr["Value"] = mp_Columns.ElementAt(i - 1).Value.TechnicalValue();

                                strSql = "select * from " + strTable + " where " + strFieldIdRow + " = -1 ";
                                rs.Open(strSql, ApplicationCommon.Application.ConnectionString, connection: conn, transaction: trans);

                                if (!string.IsNullOrEmpty(strAttribTable))
                                {
                                    strCause = "prima di rs.Update 1";
                                    rs.Update(dr, strRELACTION, strAttribTable);
                                    strCause = "dopo rs.Update 1";
                                }
                                else
                                {
                                    strCause = "prima di rs.Update 2";
                                    rs.Update(dr, strFieldIdRow, strTable);
                                    strCause = "dopo rs.Update 2";
                                }


                            }

                        }
                    }

                }
                else
                {

                    strCause = "write NON vertical ";

                    //'-- per ogni riga della matrice inserisco un record
                    for (R = 0; R <= mp_numRec - 1; R++)
                    { //To mp_numRec - 1

                        //'-- se il record nella matrice � nuovo lo inserisco
                        if (mp_Matrix != null && CInt(mp_Matrix[nc + 1, R]) == 0)
                        {

                            DataRow dr2 = rs.AddNew();

                            //'-- per ogni campo del modello prelevo il valore dal form e lo memorizzo nel RS
                            for (i = 1; i <= nc; i++)
                            {// To nc

                                objField = mp_Columns.ElementAt(i - 1).Value;

                                strCause = "colonna " + i + " - attributo = " + CStr(objField.Name) + " - valore = " + (mp_Matrix != null ? CStr(mp_Matrix[i - 1, R]) : "nessun valore") + Environment.NewLine;
                                mp_Columns.ElementAt(i - 1).Value.Value = mp_Matrix[i - 1, R];

                                //On Error Resume Next
                                try
                                {
                                    dr2[objField.Name] = mp_Columns.ElementAt(i - 1).Value.RSValue();
                                }
                                catch { }
                                //On Error GoTo Herr

                            }

                            //'-- inserisce il valore per la relazione al documento
                            if (!IsNull(ReferenceKey))
                            {
                                strCause = "inserisce il valore per la relazione al documento strFiled=" + strFieldId + " - ReferenceKey=" + ReferenceKey;
                            }
                            else
                            {
                                strCause = "inserisce il valore per la relazione al documento strFiled=" + strFieldId + " - ReferenceKey=NULL";
                            }

                            dr2[strFieldId] = ReferenceKey;

                            if (!string.IsNullOrEmpty(strFieldClass))
                            {
                                strCause = "strFieldClass = " + strFieldClass;
                                dr2[strFieldClass] = mp_Matrix[nc + 2, R];
                            }

                            strCause = "prima di rs.Update";
                            if (!string.IsNullOrEmpty(strAttribTable))
                            {
                                rs.Update(dr2, strFieldIdRow, strAttribTable);
                            }
                            else
                            {
                                rs.Update(dr2, strFieldIdRow, strTable);
                            }


                            strCause = "dopo rs.Update";

                            //'-- per la riga appena inserita si aggiungono tutte gli attributi opzionali
                            if (!string.IsNullOrEmpty(strAttribTable))
                            {

                                strCause = "per la riga appena inserita si aggiungono tutte gli attributi opzionali";

                                if (mp_Matrix[nc, R] != null && !string.IsNullOrEmpty(strAttribTable))
                                {

                                    objAttOpt = mp_Matrix[nc, R];
                                    if (objAttOpt.Count > 0)
                                    {

                                        for (i = 1; i <= objAttOpt.Count; i++)
                                        {//To objAttOpt.count

                                            DataRow dr3 = rsAtt.AddNew();

                                            dr3[strRELACTION] = rs.Fields[strFieldIdRow];
                                            dr3[strAttribTableField] = objAttOpt.ElementAt(i - 1).Key;
                                            dr3[strAttribTableValue] = objAttOpt.ElementAt(i - 1).Value;

                                            rsAtt.Update(dr3, strFieldId, strTable);

                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                //'-- chiudo ed esco
                //rs.Close
                if (!string.IsNullOrEmpty(strAttribTable))
                {
                    //rsAtt.Close
                }
                if (conn == null)
                {
                    trans.Commit();
                    cnLocal.Close();
                }
                //if (conn Is Nothing ) { 
                //    cnLocal.CommitTrans
                //if (conn Is Nothing ) { 
                //    cnLocal.Close

                //Set rs = Nothing
                //Set rsAtt = Nothing
                //Set cnLocal = Nothing

                //return boolToReturn;

            }
            catch (Exception ex)
            {

                trans.Rollback();
                cnLocal.Close();

                throw new Exception(" CtlDocument.Sec_Dettagli.Add( ) - " + strCause, ex);
            }
        }

        private void Upd(Session.ISession session, string ReferenceKey, Dictionary<dynamic, dynamic> mpMEM, SqlConnection conn, SqlTransaction trans)
        {

            SqlConnection cnLocal = new SqlConnection(mp_strConnectionString);
            string strCause = "";
            try
            {
                string strSql;
                TSRecordSet rs = new TSRecordSet();
                TSRecordSet rsAtt = new TSRecordSet();

                string Columns;
                //'Dim ColumnsProperty As Collection
                Field objField;
                int i;
                int nc;
                Dictionary<dynamic, dynamic> objAttOpt;
                string strRELACTION;
                string strAttribTableField;
                string strAttribTableValue;
                string strAttribTable;
                string strFilterRow;
                strCause = "";

                strAttribTable = GetParam(param, "ATTRIB_TABLE");
                strRELACTION = GetParam(param, "ATTRIB_RELACTION");
                strAttribTableField = GetParam(param, "ATTRIB_TABLE_FIELD");
                strAttribTableValue = GetParam(param, "ATTRIB_TABLE_VALUE");
                strFilterRow = GetParam(param, "FILTER_ROW");

                strFilterRow = Replace(strFilterRow, "<ID_USER>", CStr(mp_User));

                //'-- recupero gli attributi di cui fare l'update
                Columns = GetParam(param, "FIELD_TO_UPD");


                //'-- apro la connessione
                strCause = "apro la connessione";
                if (conn == null)
                {
                    cnLocal = new SqlConnection(mp_strConnectionString);
                    //cnLocal.connectionString = mp_strConnectionString
                    //'cnLocal.ConnectionTimeout = lTimeout
                    cnLocal.Open();
                    trans = cnLocal.BeginTransaction();
                }
                else
                {
                    cnLocal = conn;
                }

                //rs.CursorLocation = CursorLocationEnum.adUseClient
                //rs.CursorType = adOpenKeyset
                //rs.LockType = adLockPessimistic
                //Set rs.ActiveConnection = cnLocal


                //rsAtt.CursorLocation = CursorLocationEnum.adUseClient
                //rsAtt.CursorType = adOpenKeyset
                //rsAtt.LockType = adLockPessimistic
                //Set rsAtt.ActiveConnection = cnLocal

                //if (conn Is Nothing ) { cnLocal.BeginTrans



                //'-- si cancellano tutti gli attributi opzionali della griglia, perch� verranno reinseriti successivamente
                if (!string.IsNullOrEmpty(strAttribTable))
                {
                    strSql = "delete * from " + strAttribTable + " where " + strRELACTION + " in ( select " + strFieldIdRow + " from " +
                             strTable + " where " + strFieldId + " = " + CLng(ReferenceKey) + IIF(!string.IsNullOrEmpty(strFilterRow), " and " + strFilterRow, "") + "  ) ";
                    CommonDbFunctions cdb = new CommonDbFunctions();
                    strCause = "si cancellano tutti gli attributi opzionali della griglia, perch� verranno reinseriti successivamente" +
                    " [ " + strSql + " ] ";
                    cdb.ExecuteWithTransaction(strSql, ApplicationCommon.Application.ConnectionString, cnLocal, trans);
                    //cnLocal.Execute strSql
                }

                //'-- prendo il recordset delle righe
                strCause = "prendo il recordset delle righe table=" + strTable + "fieldid=" + strFieldId + " - valore id = " + ReferenceKey;
                strSql = "select * from " + strTable + " where " + strFieldId + " = " + CLng(ReferenceKey) + IIF(!string.IsNullOrEmpty(strFilterRow), " and " + strFilterRow, "");
                rs.Open(strSql, ApplicationCommon.Application.ConnectionString, connection: cnLocal, transaction: trans);

                //'-- prendo il recordset degli attributi opzionali
                if (!string.IsNullOrEmpty(strAttribTable))
                {
                    strSql = "select * from " + strAttribTable + " where " + strRELACTION + " = -1 ";
                    rsAtt.Open(strSql, ApplicationCommon.Application.ConnectionString, connection: cnLocal, transaction: trans);
                }
                else
                {
                    rsAtt = null;
                }

                nc = mp_Columns.Count;
                int indR;

                //'-- per ogni record del databasse si cerca la posizione nella matrice, se non presente si elimina
                strCause = "per ogni record del database si cerca la posizione nella matrice, se non presente si elimina";
                if (rs.RecordCount > 0)
                {
                    rs.MoveFirst();
                    while (!rs.EOF)
                    {

                        //'-- cerco l'indice di riga del record
                        indR = GetRowIndex(GetValueFromRS(rs.Fields[strFieldIdRow]));

                        if (indR == -1)
                        {
                            CommonDbFunctions cdb = new();
                            string strSql2 = "DELETE FROM " + strTable + " WHERE " + strFieldIdRow + " = " + rs.Fields[strFieldIdRow];
                            //cdb.Execute(strSql2, ApplicationCommon.Application.ConnectionString)
                            cdb.ExecuteWithTransaction(strSql2, ApplicationCommon.Application.ConnectionString, cnLocal, trans);
                        }
                        else
                        {
                            //'-- aggiorna il record corrente
                            strCause = "aggiorna il record corrente riga=" + indR;
                            int currentPositionRS = rs.position;
                            UpdateRec(indR, rs, Columns, rsAtt);
                            rs.position = currentPositionRS;
                        }
                        rs.MoveNext();
                    }

                }


                //'-- chiudo

                //rs.Close
                //if (strAttribTable <> "" ) {
                //    rsAtt.Close
                //}
                if (conn == null)
                {
                    trans.Commit();
                    cnLocal.Close();
                }
                //if (conn Is Nothing ) { cnLocal.CommitTrans
                //if (conn Is Nothing ) { cnLocal.Close


                //Set rs = Nothing
                //Set rsAtt = Nothing
                //Set cnLocal = Nothing

                //'-- aggiungo tutti i record nuovi
                Add(session, ReferenceKey, mpMEM, cnLocal, trans);


                //Exit Function

            }
            catch (Exception ex)
            {
                trans.Rollback();
                cnLocal.Close();

                throw new Exception(" CtlDocument.Sec_Dettagli.Upd( )" + strCause, ex);

            }
        }

        private int GetRowIndex(dynamic Id)
        {
            //int numRec;
            //int R;
            int m;
            int c;
            bool bFound;
            c = mp_Columns.Count;
            //'-- verifica ogni indice se � presente nella matrice
            //numRec = (mp_VetOriginalRow.Length - 1) - 1;
            if (mp_Matrix == null)
            {
                return -1;
            }

            bFound = false;
            for (m = 0; m <= mp_numRec - 1; m++)
            {// To mp_numRec -1
                if (mp_Matrix[c + 1, m] == Id)
                {
                    bFound = true;
                    break;
                }
            }

            if (bFound == false)
            {
                return -1;
            }
            else
            {
                return m;
            }
        }

        /// <summary>
        /// '-- in caso di primo inseriemento
        /// </summary>
        private void UpdateRec(int indR, TSRecordSet rs, string ColumnsToUpd, TSRecordSet rsAtt)
        {
            string strCause = "";
            string strAttribValore = "";
            try
            {
                int numRec;
                int R;
                string strSql;

                Field objField;
                int i;
                int nc;
                Dictionary<dynamic, dynamic> objAttOpt;
                string strRELACTION;
                string strAttribTableField;
                string strAttribTableValue;
                string strAttribTable;
                string strFieldClass;


                dynamic strTemp;

                //On Error GoTo Herr

                strCause = "";
                strAttribValore = "";

                strFieldClass = GetParam(param, "FIELD_CLASS");
                strRELACTION = GetParam(param, "ATTRIB_RELACTION");
                strAttribTableField = GetParam(param, "ATTRIB_TABLE_FIELD");
                strAttribTableValue = GetParam(param, "ATTRIB_TABLE_VALUE");
                strAttribTable = GetParam(param, "ATTRIB_TABLE");

                nc = mp_Columns.Count;

                R = indR;
                DataRow? dr = null;
                dr = rs.Fields;
                Dictionary<string, dynamic?> parCollection = new Dictionary<string, dynamic?>();

                //'-- per ogni campo del modello prelevo il valore dal form e lo memorizzo nel RS
                strCause = "per ogni campo del modello prelevo il valore dal form e lo memorizzo nel RS";
                for (i = 1; i <= nc; i++)
                {
                    objField = mp_Columns.ElementAt(i - 1).Value;

                    //'-- se il campo è da aggiornare
                    if (ColumnsToUpd.Contains("," + objField.Name + ",", StringComparison.Ordinal) || string.IsNullOrEmpty(UCase(ColumnsToUpd)))
                    {
                        strCause = "se il campo è da aggiornare";
                        mp_Columns.ElementAt(i - 1).Value.Value = mp_Matrix[i - 1, R];
                        //On Error Resume Next
                        try
                        {
                            strTemp = mp_Columns.ElementAt(i - 1).Value.RSValue();

                            //Non serve più aggiornare l'oggetto DataRow ( variabile dr ) perchè l'update del TSRecordSet lavora con i parametri sql ( parCollection )
                            //  l'unico dato che prende dal datarow è il valore della chiave primaria, già presente perchè sopra facciamo dr = rs.Fields

                            if (rs.ColumnExists(objField.Name))
                            {
                                parCollection.TryAdd(objField.Name, strTemp);
                            }

                            //'--costruisco sctrcause attributo - valore
                            //'--se ho errore aggiungo [errore]
                            if (IsNull(strTemp))
                            {
                                strTemp = "(NULL)";
                            }

                            strAttribValore = $"{strAttribValore}  [ {objField.Name} = {strTemp}]{Environment.NewLine}";


                        }
                        catch (Exception ex)
                        {
                            strAttribValore = $"{strAttribValore} : descrizione errore = {ex.ToString()}{Environment.NewLine}";
                        }
                        //On Error GoTo Herr

                        if (!string.IsNullOrEmpty(strFieldClass))
                        {
                            dr[strFieldClass] = mp_Matrix[nc + 2, R];
                            parCollection.TryAdd(strFieldClass, mp_Matrix[nc + 2, R]);
                        }

                    }

                }

                if (dr != null && parCollection.Count != 0)
                {
                    strCause = "update rs";
                    rs.Update(dr, strFieldIdRow, strTable, parCollection);
                }

                //'-- per la riga appena aggiornata si aggiungono tutte gli attributi opzionali
                if (mp_Matrix[nc, R] != null && !string.IsNullOrEmpty(strAttribTable))
                {

                    strCause = "per la riga appena aggiornata si aggiungono tutte gli attributi opzionali";
                    strAttribValore = "";

                    objAttOpt = mp_Matrix[nc, R];
                    if (objAttOpt.Count > 0)
                    {

                        for (i = 1; i <= objAttOpt.Count; i++)
                        {// To objAttOpt.count


                            DataRow dr2 = rsAtt.AddNew();

                            dr2[strRELACTION] = rs.Fields[strFieldIdRow];
                            dr2[strAttribTableField] = objAttOpt.ElementAt(i - 1).Key;
                            dr2[strAttribTableValue] = objAttOpt.ElementAt(i - 1).Value;

                            rsAtt.Update(dr2, "", strTable);

                        }

                    }
                }




            }
            catch (Exception ex)
            {
                throw new Exception("UpdateRec - " + strCause + " - " + strAttribValore, ex);
                //RaiseError "UpdateRec"  
            }
        }

        public void InitLocal(Session.ISession session)
        {

            mp_suffix = CStr(session[Session.SessionProperty.SESSION_SUFFIX]);
            if (string.IsNullOrEmpty(mp_suffix))
            {
                mp_suffix = "I";
            }

            mp_strConnectionString = ApplicationCommon.Application.ConnectionString;
            Request_QueryString = GetQueryStringFromContext(_context.Request.QueryString);
            Request_Form = _context.Request.HasFormContentType ? _context.Request.Form : null;

            mp_User = CLng(session[Session.SessionProperty.SESSION_USER]);
            mp_Permission = CStr(session[Session.SessionProperty.SESSION_PERMISSION]);

        }

        public void run(Session.ISession session, EprocResponse response)
        {

            //'-- recupero variabili di sessione
            InitLocal(session);

            InitGUIObject(session);

            ExecuteAction(session, response);

            Draw(session, response);
        }


        public void Draw(Session.ISession session, EprocResponse response)
        {

            Dictionary<string, string> JS = new Dictionary<string, string>();
            string RQS;
            string fc;
            string strJSOnLoad;

            try
            {



                if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), "COMMAND")) && string.IsNullOrEmpty(mp_ErrMsg))
                {

                    //'----------------------------------
                    //'-- avvia la scrittura della pagina
                    //'----------------------------------
                    if (!JS.ContainsKey("getObj"))
                    {
                        JS.Add("getObj", @"<script src=""../jscript/getObj.js"" ></script>");
                    }
                    response.Write(JavaScript(JS));

                    response.Write($@"</head><body>" + Environment.NewLine);

                    //'-- disegna la nuova griglia
                    objDocument.Sections[GetParamURL(Request_QueryString.ToString(), "SECTION")].Html(response, session);

                    //'-- esegue script per sostituire la griglia nel documento
                    response.Write($@"<script type=""text/javascript"" language=""javascript"" >");
                    response.Write($@"       try {{ parent.getObj( '" + GetParamURL(Request_QueryString.ToString(), "SECTION") + "' ).innerHTML = ");
                    response.Write($@"       getObj( '" + GetParamURL(Request_QueryString.ToString(), "SECTION") + $@"' ).innerHTML; }} catch( e ) {{}};");

                    if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), "TOTAL_SECTION")))
                    {
                        response.Write($@"       parent.MakeTotal_Section( '" + GetParamURL(Request_QueryString.ToString(), "TOTAL_SECTION") + "' ); ");
                    }

                    response.Write($@"</script>" + Environment.NewLine);

                    objDocument = null;

                }
                else
                {


                    //'----------------------------------
                    //'-- avvia la scrittura della pagina
                    //'----------------------------------

                    //'-- recupera i javascript necessari dagli oggetti dell'interfaccia
                    mp_strcause = "recupera i javascript necessari dagli oggetti dell'interfaccia";
                    if (!JS.ContainsKey("ExecFunction"))
                    {
                        JS.Add("ExecFunction", @"<script src=""../jscript/ExecFunction.js"" ></script>");
                    }

                    mp_objForm.JScript(JS, "../");
                    mp_ModAdd.JScript(JS, "../");
                    if (mp_ModAddDetail != null)
                    {
                        mp_ModAddDetail.JScript(JS, "../");
                    }
                    mp_ObjButtonBar.JScript(JS, "../");


                    JScript(JS, "../");


                    //'-- inserisce i java script necessari
                    mp_strcause = "inserisce i java script necessari";
                    response.Write(JavaScript(JS));


                    response.Write($@"</head><body>" + Environment.NewLine);


                    //'-- inserisce gli script per l'aggiornamento del titolo
                    response.Write($@"<script type=""text/javascript"" language=""javascript"" >");
                    if (GetParamURL(Request_QueryString.ToString(), "MODE") == "UPD")
                    {
                        response.Write($@"       getObjPage( 'AddNew', 'parent' )[0].innerText = '" + ApplicationCommon.CNV("Aggiorna", session) + "';");
                        response.Write($@"       getObjPage( 'AddNew', 'parent' )[1].innerText = '" + ApplicationCommon.CNV("Aggiorna", session) + "';");
                        response.Write($@"       parent.ShowGroup( 'AddNew' , 0 );");

                    }
                    else
                    {
                        response.Write($@"       getObjPage( 'AddNew', 'parent' )[0].innerText = '" + ApplicationCommon.CNV("Inserisci", session) + "';");
                        response.Write($@"       getObjPage( 'AddNew', 'parent' )[1].innerText = '" + ApplicationCommon.CNV("Inserisci", session) + "';");
                    }
                    response.Write($@"</script>" + Environment.NewLine);


                    if (!string.IsNullOrEmpty(mp_ErrMsg))
                    {
                        response.Write(ShowMessageBox(mp_ErrMsg, ApplicationCommon.CNV("Attenzione", session), "../"));
                    }

                    Id = GetParamURL(Request_QueryString.ToString(), "SECTION");
                    mp_idDoc = GetParamURL(Request_QueryString.ToString(), "IDDOC");

                    response.Write($@"<div id=""" + Id + @"_DIV_ADD_" + mp_idDoc + @""" name=""" + Id + @"_DIV_ADD_" + mp_idDoc + @""" >");


                    fc = GetParamURL(Request_QueryString.ToString(), "FIELD_CLASS");
                    RQS = CStr(Request_QueryString);
                    string v;
                    v = GetParamURL(Request_QueryString.ToString(), fc);

                    RQS = Replace(RQS, "&" + fc + "=" + v, "");
                    RQS = Replace(RQS, fc + "=" + v, "");

                    //'-- togliere  - COMMAND  -
                    v = GetParamURL(Request_QueryString.ToString(), "COMMAND");
                    RQS = MyReplace(RQS, "&COMMAND=" + v, "");
                    RQS = MyReplace(RQS, "COMMAND=" + v, "");
                    if (Strings.Left(RQS, 1) == "&")
                    {
                        RQS = Strings.Mid(RQS, 2);
                    }

                    HTML_HiddenField(response, "RQS", RQS);
                    HTML_HiddenField(response, "FIELD_CLASS", fc);


                    response.Write($@"<table width=""100%"" height=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0""><tr><td>");

                    //'-- apre il form di ricerca
                    response.Write(mp_objForm.OpenForm());

                    response.Write($@"<table width=""100%"" height=""100%""  border=""0"" cellspacing=""0"" cellpadding=""0"">");


                    //'-- aggiungo la caption all'area di nuovo record o aggiornamento
                    //'-- e la toolbar
                    //'        response.Write($@"<tr><td >"
                    //'        mp_objCaption.Html response
                    //'        response.Write($@"</td></tr>" + Environment.NewLine


                    //'-- disegna il modello di ricerca
                    mp_strcause = "disegna il modello di base";
                    response.Write($@"<tr><td width=""100%"" >");
                    mp_ModAdd.Html(response);
                    response.Write($@"</td></tr>");

                    if (mp_ModAddDetail != null)
                    {
                        mp_strcause = "disegna il modello opzionale";
                        response.Write($@"<tr><td width=""100%"" >");
                        mp_ModAddDetail.Html(response);
                        response.Write($@"</td></tr>");
                    }

                    //'-- disegna i bottoni del form
                    mp_strcause = "disegna i bottoni del form";
                    response.Write($@"<tr><td width=""100%"" >");
                    mp_ObjButtonBar.Html(response);
                    response.Write($@"</td></tr>");


                    response.Write($@"</table>");

                    //'-- chiude il form di ricerca
                    response.Write(mp_objForm.CloseForm());

                    response.Write($@"</td></tr><tr><td height=""100%""></td></tr></table>");

                    //'-- setto il fuoco sul primo campo del form
                    //'Set objDocument = session(OBJSESSION)("DOC_" & Request_QueryString("DOCUMENT") & "_" & Request_QueryString("IDDOC"))


                    response.Write($@"<script>" + Environment.NewLine);

                    response.Write($@"</script>" + Environment.NewLine);

                    response.Write($@"</div>");


                    //'-- in caso di un comando con errore ricopia la pagina nel frame di add
                    if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), "COMMAND")) && !string.IsNullOrEmpty(mp_ErrMsg))
                    {


                        //'-- esegue script per sostituire la griglia nel documento
                        response.Write($@"<script type=""text/javascript"" language=""javascript"" >");
                        response.Write($@"       try {{ parent.getObjPage( '" + Id + "_DIV_ADD_" + mp_idDoc + "' , '" + Id + "_ADD_" + mp_idDoc + "' ).innerHTML = ");
                        response.Write($@"       getObj( '" + Id + "_DIV_ADD_" + mp_idDoc + $@"' ).innerHTML; }} catch( e ) {{}};");


                        response.Write($@"</script>" + Environment.NewLine);

                    }

                }


            }
            catch (Exception ex)
            {
                throw new Exception(mp_strcause, ex);
            }
        }

        /// <summary>
        /// '-- inizializzo gli oggetti dell'interfaccia
        /// </summary>
        /// <param name="session"></param>
        private void InitGUIObject(Session.ISession session)
        {

            mp_objForm = new Form();
            mp_ObjButtonBar = new ButtonBar();

            string strQueryString;

            strQueryString = CStr(Request_QueryString);


            DomElem el;

            //'-- tolgo il comando dalla querystring
            strQueryString = MyReplace(strQueryString, "&COMMAND=" + GetParamURL(Request_QueryString.ToString(), "COMMAND"), "");
            strQueryString = MyReplace(strQueryString, "COMMAND=" + GetParamURL(Request_QueryString.ToString(), "COMMAND"), "");
            if (Strings.Left(strQueryString, 1) == "&")
            {
                strQueryString = Strings.Mid(strQueryString, 2);
            }

            //'-- inizializzo il form
            mp_objForm.id = "FormAdd";
            mp_objForm.Action = "sec_dettagli.asp?COMMAND=" + GetParamURL(Request_QueryString.ToString(), "MODE") + "&" + strQueryString;
            mp_objForm.Target = GetParamURL(Request_QueryString.ToString(), "DOCUMENT") + "_Command_" + GetParamURL(Request_QueryString.ToString(), "IDDOC");

            //'-- barra dei bottoni
            mp_ObjButtonBar.CaptionSubmit = ApplicationCommon.CNV("Aggiungi", session);
            mp_ObjButtonBar.CaptionReset = ApplicationCommon.CNV("Pulisci", session);

            //'mp_ObjButtonBar.OnReset = "self.location='" & "ViewerAddNew.asp?MODE=ADD&Table=" & mp_strTable & Replace(mp_queryString, "'", "\'") & "';"
            //'mp_ObjButtonBar.OnSubmit = "document.forms[0].elements[0].focus();" '& IIf(GetParamURL(Request_QueryString.ToString(), "ClearNew") = "1", "document.forms[0].reset();", "")

            //'-- inizializzo la caption
            mp_strcause = "inizializzo la caption";
            mp_objCaption = new Fld_Label();
            mp_objCaption.PathImage = "../images/";
            mp_objCaption.Style = "SinteticHelp";



            //'-- recupero il modello di ricerca
            mp_strcause = "recupero il modello di ricerca";
            LibDbModelExt objDB = new LibDbModelExt();//CreateObject("ctldb.lib_dbmodel")
            mp_ModAdd = objDB.GetFilteredModel(GetParamURL(Request_QueryString.ToString(), "MODEL_ADD"), mp_suffix, mp_User, 0, mp_strConnectionString);


            //'-- recupera il modello degli attributi opzionali
            string strValModello;
            strValModello = GetParamURL(Request_QueryString.ToString(), "FIELD_CLASS");


            //'-- nel caso sia indicato un record preciso carico i campi del modello con quel record
            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), "IDROW")))
            {
                int R;
                R = CInt(GetParamURL(Request_QueryString.ToString(), "IDROW"));
                //'-- recupero il documento dalla memoria che contiene i valori
                objDocument = session["DOC_" + GetParamURL(Request_QueryString.ToString(), "DOCUMENT") + "_" + GetParamURL(Request_QueryString.ToString(), "IDDOC")];
                if (objDocument != null)
                {

                    string strFieldClass;
                    mp_Columns = objDocument.Sections[GetParamURL(Request_QueryString.ToString(), "SECTION")].mp_Columns;
                    mp_Matrix = objDocument.Sections[GetParamURL(Request_QueryString.ToString(), "SECTION")].mp_Matrix;
                    param = objDocument.Sections[GetParamURL(Request_QueryString.ToString(), "SECTION")].param;
                    //'-- modifico i campi del modello con i valori del RS
                    //'-- per ogni campo del modello della griglia avvalora se esiste il corrispettivo di upd
                    //On Error Resume Next
                    int i;
                    for (i = 1; i <= mp_Columns.Count; i++)
                    {// To mp_Columns.Count
                        try
                        {
                            mp_ModAdd.Fields[mp_Columns.ElementAt(i - 1).Value.Name].Value = mp_Matrix[i, R];
                        }
                        catch { }
                        //err.Clear
                    }

                    //'-- recupera la merceologia sulla quale ricavare il modello
                    string selectedMerc;
                    selectedMerc = GetParamURL(Request_QueryString.ToString(), strValModello);
                    if (string.IsNullOrEmpty(selectedMerc))
                    {
                        if (!(CStr(Request_QueryString).Contains(strValModello + "=", StringComparison.Ordinal)))
                        {
                            selectedMerc = mp_Matrix[mp_Columns.Count + 2, R];
                        }
                    }
                    //'-- prendo il modello associato alla merceologia
                    mp_ModAddDetail = null;

                    if (!string.IsNullOrEmpty(selectedMerc))
                    {

                        el = mp_ModAdd.Fields[strValModello].Domain.Elem[selectedMerc];
                        mp_ModAddDetail = objDB.GetFilteredModel(el.CodExt, mp_suffix, mp_User, 0, mp_strConnectionString);

                        Dictionary<dynamic, dynamic> sCol;
                        mp_ModAdd.Fields[strValModello].Value = selectedMerc;
                        sCol = mp_Matrix[mp_Columns.Count, R];
                        mp_ModAddDetail.SetFieldsValue(sCol);

                    }

                    mp_Matrix = null;
                    mp_Columns = null;
                    objDocument = null;

                }
            }
            else
            {

                if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), strValModello)))
                {

                    el = mp_ModAdd.Fields[strValModello].Domain.Elem[GetParamURL(Request_QueryString.ToString(), strValModello)];
                    mp_ModAddDetail = objDB.GetFilteredModel(el.CodExt, mp_suffix, mp_User, 0, mp_strConnectionString);
                    mp_ModAdd.Fields[strValModello].Value = GetParamURL(Request_QueryString.ToString(), strValModello);
                }
                else
                {
                    mp_ModAddDetail = null;
                }

            }

            //Set objDB = Nothing


            //'-- nel caso si tratta di un update modifico l'azionde del form per eseguire l'aggiornamento del record
            if (GetParamURL(Request_QueryString.ToString(), "MODE") == "UPD")
            {

                //'-- cambio la toolbar
                mp_ObjButtonBar.CaptionSubmit = ApplicationCommon.CNV("Aggiorna", session);
                //'mp_ObjButtonBar.ShowButtons = CtlHtml.SubmitButton


                //'-- setto la caption per la modifica
                mp_objCaption.Value = ApplicationCommon.CNV(GetParamURL(Request_QueryString.ToString(), "CaptionUpd"), session);
                mp_objCaption.Image = "update.gif";


            }
            else
            {

                //'-- setto la caption per l'inserimento
                mp_objCaption.Value = ApplicationCommon.CNV(GetParamURL(Request_QueryString.ToString(), "CaptionAdd"), session);
                mp_objCaption.Image = "Create.gif";


            }
        }

        /// <summary>
        /// '-- esegue l'azione in memoria di aggiunta di un record o variazione di quello corrente
        /// '-- in caso di variazione ricarica il form con l'inserimento
        /// </summary>
        /// <param name="session"></param>
        /// <param name="response"></param>
        private void ExecuteAction(Session.ISession session, EprocResponse response)
        {
            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), "COMMAND")))
            {

                //'-- controlla che i dati pasasti siano corretti
                mp_ModAdd.SetFieldsValue(Request_Form);
                if (mp_ModAdd.CheckObblig())
                {
                    mp_ErrMsg = ApplicationCommon.CNV("Alcuni dati obbligatori non sono presenti", session);
                    return;
                }

                if (mp_ModAddDetail != null)
                {
                    mp_ModAddDetail.SetFieldsValue(Request_Form);
                    if (mp_ModAddDetail.CheckObblig())
                    {
                        mp_ErrMsg = ApplicationCommon.CNV("Alcuni dati obbligatori non sono presenti", session);
                        return;
                    }
                }

                //'-- recupera il documento dalla memoria
                objDocument = session["DOC_" + GetParamURL(Request_QueryString.ToString(), "DOCUMENT") + "_" + GetParamURL(Request_QueryString.ToString(), "IDDOC")];
                if (objDocument != null)
                {

                    if (GetParamURL(Request_QueryString.ToString(), "COMMAND") == "ADD")
                    {
                        objDocument.Sections[GetParamURL(Request_QueryString.ToString(), "SECTION")].AddRecord(session);
                    }
                    else
                    {
                        objDocument.Sections[GetParamURL(Request_QueryString.ToString(), "SECTION")].UpdRecord(session);
                    }

                }
            }
        }

        public void UpdRecord(Session.ISession session)
        {
            string strFieldClass;
            int numCol;
            ClsDomain dom;
            //Dim objDB As Object
            int R;
            int i;
            long indRow;
            Dictionary<string, Field> Columns = new Dictionary<string, Field>();
            Dictionary<string, Grid_ColumnsProperty> ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();

            InitLocal(session);

            indRow = CLng(GetParamURL(Request_QueryString.ToString(), "IDROW"));
            numCol = mp_Columns.Count;
            R = CInt(indRow);

            //'-- carica i valori del modello della griglia nella matrice
            for (i = 1; i <= numCol; i++)
            {// To numCol
                mp_Matrix[i - 1, indRow] = GetValueFromForm(Request_Form, mp_Columns.ElementAt(i - 1).Value.Name);
            }

            strFieldClass = GetParam(param, "FIELD_CLASS");

            //'mp_Matrix(numCol + 1, r) = 0 '-- idRow 0 per nuovo
            mp_Matrix[numCol, R] = null;//'-- eleimina la collezione di attributi
            if (!string.IsNullOrEmpty(strFieldClass))
            {

                mp_Matrix[numCol + 2, R] = "";
                mp_Matrix[numCol + 2, R] = GetValueFromForm(Request_Form, strFieldClass);
                mp_Matrix[numCol, R] = null;
                if (!string.IsNullOrEmpty(mp_Matrix[numCol + 2, R]))
                {

                    Dictionary<dynamic, dynamic> sCollAtt;
                    sCollAtt = new Dictionary<dynamic, dynamic>();

                    //'-- prendo il dominio
                    //'Request_Form (strFieldClass)

                    LibDbDictionary ldbd = new LibDbDictionary();
                    //Set objDB = CreateObject("ctldb.lib_dbDictionary")
                    dom = ldbd.GetDomOfAttrSC(strFieldClass, mp_suffix, 0, mp_strConnectionString);
                    //Set objDB = Nothing

                    //'-- recupera il modello di attributi opzionali
                    //Set objDB = CreateObject("ctldb.lib_dbModel")
                    LibDbModelExt ldme = new LibDbModelExt();
                    ldme.GetFilteredFields(dom.Elem[GetValueFromForm(Request_Form, strFieldClass)].CodExt, ref Columns, ref ColumnsProperty, "I", 0, 0, mp_strConnectionString, session, false);
                    //Set objDB = Nothing


                    //'-- carica i valori del modello in una supercollezione
                    for (i = 1; i <= Columns.Count; i++)
                    {// To Columns.count
                        sCollAtt.Add(Columns.ElementAt(i - 1).Value.Name, GetValueFromForm(Request_Form, Columns.ElementAt(i - 1).Value.Name));
                    }

                    //'-- inserisco la collezione nella matrice
                    mp_Matrix[numCol, R] = sCollAtt;

                    //ReleaseCollection Columns
                    //ReleaseCollection ColumnsProperty
                    //Set Columns = Nothing
                    //Set ColumnsProperty = Nothing

                    //Set dom = Nothing
                    //Set sCollAtt = Nothing
                }


            }

            //'-- aggiorno la matrice nella griglia
            mp_objGrid.SetMatrix(mp_Matrix, mp_VetOriginalRow);


        }

        public void UpdRecordFromTable(Session.ISession session, dynamic indRow, string strTable)
        {

            string strFieldClass;
            int numCol;
            ClsDomain dom;
            //Dim objDB As Object
            int R;
            int i;
            //'Dim indRow As Integer
            Dictionary<string, Field> Columns = new Dictionary<string, Field>();
            Dictionary<string, Grid_ColumnsProperty> ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();
            //Dim val As Variant
            string strSql;


            TSRecordSet rs;

            if (IsNumeric(indRow))
            {
                strSql = "Select * from " + strTable + " where indRow  = " + CLng(indRow);
            }
            else
            {
                strSql = "Select * from " + strTable + " where indRow  = '" + indRow.Replace("'", "''") + "'";
            }


            //Set objDB = CreateObject("ctldb.clsTabManage")
            CommonDbFunctions cdb = new CommonDbFunctions();
            rs = cdb.GetRSReadFromQuery_(strSql, mp_strConnectionString);

            R = mp_numRec - 1;

            UpdRecordFromRS(session, rs, R);


        }

        /// <summary>
        /// 'bCount = true indica che incrementa il contatore, false invece no
        /// </summary>
        public void AddRecord(Session.ISession session, int fromRow = -1, bool bCount = true)
        {



            string strFieldClass;
            int numCol;
            ClsDomain dom;
            //Dim objDB As Object
            int R;
            int i;

            Dictionary<string, Field> Columns = new Dictionary<string, Field>();// As Collection
            Dictionary<string, Grid_ColumnsProperty> ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>();// As Collection
            int j;

            InitLocal(session);
            numCol = mp_Columns.Count;
            R = mp_numRec;

            //'-- aggiunge un record alla matrice
            //'--if ( bRedimMatrix ) {

            if (mp_numRec != 0)
            {
                mp_Matrix = ResizeArray(mp_Matrix, mp_Columns.Count + 3, mp_numRec);
                Array.Resize(ref mp_VetTotRow, mp_numRec + 1);
                //ReDim Preserve mp_Matrix(mp_Columns.count + 3, mp_numRec) As Variant
                //ReDim Preserve mp_VetTotRow(mp_numRec) As Double

            }
            else
            {
                mp_Matrix = new dynamic[mp_Columns.Count + 3 + 1, 0 + 1];

                mp_VetTotRow = new double[0 + 1];
                //ReDim mp_Matrix(mp_Columns.count + 3, 0) As Variant
                //ReDim mp_VetTotRow(0) As Double
            }
            //'--}

            int nPosNewRow;
            nPosNewRow = mp_numRec;

            //'--recupero posizione diriga in cui inserie la nuova riga
            if (!string.IsNullOrEmpty(GetParamURL(Request_QueryString.ToString(), "ID_ADDROW")))
            {
                nPosNewRow = CInt(GetParamURL(Request_QueryString.ToString(), "ID_ADDROW"));
            }

            //'--se voglio inserire in mezzo sposto in gi� le righe per fare posto alla nuova riga in posizione nPosNewRow
            if (nPosNewRow < mp_numRec && nPosNewRow >= 0)
            {

                Shift_Down_Row_Matrix(mp_Matrix, mp_numRec, nPosNewRow, numCol);

            }

            //'-- carica i valori del modello della griglia nella matrice
            if (fromRow == -1)
            {
                if (GetParam(param, "NO_DEF_ROW") != "yes")
                {
                    for (i = 1; i <= numCol; i++)
                    {// To numCol
                        //'mp_Matrix(i - 1, mp_numRec) = Request_Form(mp_Columns(i).Name)
                        mp_Matrix[i - 1, nPosNewRow] = GetValueFromForm(Request_Form, mp_Columns.ElementAt(i - 1).Value.Name);
                    }
                }
            }
            else
            {
                //'-- altrimenti li ricopio da una riga indicata
                for (i = 1; i <= numCol; i++)
                {// To numCol
                    //'mp_Matrix(i - 1, mp_numRec) = mp_Matrix(i - 1, fromRow)
                    mp_Matrix[i - 1, nPosNewRow] = mp_Matrix[i - 1, fromRow];
                }
            }

            strFieldClass = GetParam(param, "FIELD_CLASS");



            R = nPosNewRow;

            if (IsEmpty(mp_Matrix[numCol + 1, R]))
            {
                mp_Matrix[numCol + 1, R] = 0; //'-- idRow 0 per nuovo
            }
            mp_Matrix[numCol, R] = null;
            mp_Matrix[numCol + 2, R] = "";

            if (!string.IsNullOrEmpty(strFieldClass))
            {

                mp_Matrix[numCol + 2, R] = "";
                mp_Matrix[numCol + 2, R] = GetValueFromForm(Request_Form, strFieldClass);
                mp_Matrix[numCol, R] = null;
                if (!string.IsNullOrEmpty(mp_Matrix[numCol + 2, R]))
                {

                    //Dim sCollAtt As superCollection
                    //Set sCollAtt = New superCollection
                    Dictionary<dynamic, dynamic> sCollAtt = new Dictionary<dynamic, dynamic>();
                    //'-- prendo il dominio
                    //'Request_Form (strFieldClass)
                    //objDB = CreateObject("ctldb.lib_dbDictionary")
                    LibDbDictionary objDB = new LibDbDictionary();
                    dom = objDB.GetDomOfAttrSC(strFieldClass, mp_suffix, 0, mp_strConnectionString);
                    //objDB = Nothing

                    //'-- recupera il modello di attributi opzionali
                    //Set objDB = CreateObject("ctldb.lib_dbModel")
                    LibDbModelExt ldme = new LibDbModelExt();
                    ldme.GetFilteredFields(dom.Elem[GetValueFromForm(Request_Form, strFieldClass)].CodExt, ref Columns, ref ColumnsProperty, "I", 0, 0, mp_strConnectionString, session, false);
                    //Set objDB = Nothing


                    //'-- carica i valori del modello in una supercollezione
                    if (fromRow == -1)
                    {
                        for (i = 1; i <= Columns.Count; i++)
                        {//To Columns.count
                            sCollAtt.Add(Columns.ElementAt(i).Value.Name, GetValueFromForm(Request_Form, Columns.ElementAt(i).Value.Name));
                        }
                    }
                    else
                    {
                        //'-- ricopio i valori della riga
                        if (mp_Matrix[numCol, fromRow] != null)
                        {
                            Dictionary<dynamic, dynamic> ColSource;
                            ColSource = mp_Matrix[numCol, fromRow];

                            for (i = 1; i <= Columns.Count; i++)
                            {//To Columns.count
                                sCollAtt.Add(ColSource[Columns.ElementAt(i).Value.Name], Columns.ElementAt(i).Value.Name);
                            }
                            //Set ColSource = Nothing
                        }
                    }

                    //'-- inserisco la collezione nella matrice
                    mp_Matrix[numCol, R] = sCollAtt;

                    //ReleaseCollection Columns
                    //ReleaseCollection ColumnsProperty
                    //Set Columns = Nothing
                    //Set ColumnsProperty = Nothing

                    //Set dom = Nothing
                    //Set sCollAtt = Nothing
                }


            }

            //'-- determino il valore per la colonna contatore
            if (mp_PosCounter >= 0 && bCount)
            {
                mp_CounterValue = mp_CounterValue + mp_StepCounterRow;
                mp_Matrix[mp_PosCounter, R] = mp_CounterValue;
            }

            //'-- aggiorno la matrice nella griglia
            mp_objGrid.SetMatrix(mp_Matrix, mp_VetOriginalRow);

            mp_numRec = mp_numRec + 1;


        }


        public void DelRecord(Session.ISession session)
        {

            string[] aInfoRow;
            long[] vetIndRow;


            int i;


            aInfoRow = Strings.Split(GetParamURL(Request_QueryString.ToString(), "IDROW"), ",");


            vetIndRow = new long[aInfoRow.Length - 1 + 1];//(UBound(aInfoRow))


            //'--copio in un vettore di long
            for (i = 0; i <= aInfoRow.Length - 1; i++)
            {// To UBound(aInfoRow)
                vetIndRow[i] = CLng(aInfoRow[i]);
            }


            //'--ordino in modo decrescente per cancellare prima le righe con indice pi� grande
            SelSortL(0, (vetIndRow.Length - 1), vetIndRow);

            for (i = (vetIndRow.Length - 1); i >= 0; i--)
            {// To 0 Step - 1


                DelRowRecord(session, CInt(vetIndRow[i]));


            }


            //'--DelRowRecord session, Request_QueryString("IDROW")


            //'    Dim strFieldClass  As String
            //'    Dim numCol As Integer
            //'    Dim dom As clsDomain
            //'    Dim objDB As Object
            //'    Dim r As Integer
            //'    Dim i As Integer
            //'    Dim indRow As Long
            //'    Dim Columns As Collection
            //'    Dim ColumnsProperty As Collection
            //'    Dim newMatrix As Variant
            //'
            //'
            //'    InitLocal session
            //'
            //'    indRow = Request_QueryString("IDROW")
            //'    numCol = mp_Columns.Count
            //'    r = indRow
            //'
            //'    '-- elimino la collezione di attributi opzionali
            //'    Set mp_Matrix(numCol, r) = Nothing '-- eleimina la collezione di attributi
            //'
            //'
            //'    '-- tiro su tutte le righe sottostanti
            //'    For r = indRow To mp_numRec - 2
            //'        For i = 0 To numCol - 1
            //'            mp_Matrix(i, r) = mp_Matrix(i, r + 1)
            //'        Next
            //'        Set mp_Matrix(numCol, r) = mp_Matrix(numCol, r + 1)
            //'        mp_Matrix(numCol + 1, r) = mp_Matrix(numCol + 1, r + 1)
            //'        mp_Matrix(numCol + 2, r) = mp_Matrix(numCol + 2, r + 1)
            //'    Next
            //'
            //'    '-- ridimensiono la griglia
            //'    mp_numRec = mp_numRec - 1
            //'    If mp_numRec = 0 Then
            //'        Erase mp_Matrix
            //'        mp_Matrix = Empty
            //'    Else
            //'        ReDim newMatrix(mp_Columns.Count + 3, mp_numRec - 1) As Variant
            //'        ReDim Preserve mp_VetTotRow(mp_numRec) As Double
            //'
            //'        '-- copia la vecchia matrice
            //'        For r = 0 To mp_numRec - 1
            //'            For i = 0 To numCol - 1
            //'                newMatrix(i, r) = mp_Matrix(i, r)
            //'            Next
            //'            Set newMatrix(numCol, r) = mp_Matrix(numCol, r)
            //'            Set mp_Matrix(numCol, r) = Nothing
            //'            newMatrix(numCol + 1, r) = mp_Matrix(numCol + 1, r)
            //'            newMatrix(numCol + 2, r) = mp_Matrix(numCol + 2, r)
            //'        Next
            //'        Erase mp_Matrix
            //'        mp_Matrix = newMatrix
            //'        newMatrix = Empty
            //'
            //'    End If
            //'
            //'    '-- aggiorno la matrice nella griglia
            //'    mp_objGrid.SetMatrix mp_Matrix



        }

        /// <summary>
        /// '-- funzione per personalizzare la visualizzazione della griglia usata per il regalo a piacere
        /// </summary>
        /// <param name="Grid"></param>
        /// <param name="Context"></param>
        /// <param name="field"></param>
        /// <param name="R"></param>
        /// <param name="c"></param>
        /// <param name="strCellProperty"></param>
        /// <param name="objResp"></param>
        /// <returns></returns>
        public bool Grid_DrawCell(Grid Grid, int Context, Field field, long R, long c, string strCellProperty, IEprocResponse objResp)
        {
            bool boolToReturn;
            boolToReturn = false;

            //'If UCase(left(field.name, 3)) = "FNZ" Then
            //'    field.GetPrimitiveObject().Value = ""
            //'End If

            //'-- se � attivo il meccanismo per rendere le celle non editabili
            if (mp_indexFieldNotEditable > -1)
            {
                //'-- controllo se la cella � non editabile, cio� se il campo � presente nella collezione dei non editabili
                if (UCase(CStr(mp_Matrix[mp_indexFieldNotEditable, R])).Contains(" " + UCase(CStr(field.Name)) + " ", StringComparison.Ordinal))
                {

                    //'-- il campo � non editabile
                    objResp.Write($@"<td id=""" + Grid.id + "_r" + R + "_c" + c + $@""" " + strCellProperty + " >");

                    //'-- scrivo il valore
                    field.umValueHtml(objResp, false);
                    field.ValueHtml(objResp, false);


                    //'-- chiudo la cella
                    objResp.Write("</td>" + Environment.NewLine);


                    boolToReturn = true;

                }


            }


            //'-- verifico se la cella � riferita alla riga del regalo di iniziativa
            if (field.Name == mp_SummaryField && mp_Matrix[mp_Columns.Count, R] != null)
            {

                string v;
                Dictionary<dynamic, dynamic> col;
                int i;
                string selectedMerc;
                Model ModAddDetail;
                DomElem el;
                //Dim objDB As Object
                ClsDomain dom;

                string strValModello;
                strValModello = GetParam(param, "FIELD_CLASS");

                v = field.Value;
                col = mp_Matrix[mp_Columns.Count, R];

                //'-- recupera il modello per visualizzare correttamente i dati
                selectedMerc = mp_Matrix[mp_Columns.Count + 2, R];

                //Set objDB = CreateObject("ctldb.lib_dbDictionary")
                LibDbDictionary objDB = new LibDbDictionary();
                dom = objDB.GetDomOfAttrSC(strValModello, mp_suffix, 0, mp_strConnectionString);
                //Set objDB = Nothing

                el = dom.Elem[selectedMerc];
                //Set objDB = CreateObject("ctldb.lib_dbModel")
                LibDbModelExt ldme = new LibDbModelExt();
                ModAddDetail = ldme.GetFilteredModel(el.CodExt, mp_suffix, mp_User, 0, mp_strConnectionString);
                ModAddDetail.SetFieldsValue(col);


                for (i = 1; i <= col.Count; i++)
                {// To col.count
                    if (!string.IsNullOrEmpty(ModAddDetail.Fields[col.ElementAt(i - 1).Key].TxtValue))
                    {
                        v = v + ", " + ModAddDetail.Fields[col.ElementAt(i - 1).Key].Caption + " " + ModAddDetail.Fields[col.ElementAt(i - 1).Key].TxtValue;
                    }
                }


                field.Value = v;
                //Set dom = Nothing
                //Set objDB = Nothing
                //Set ModAddDetail = Nothing
                //Set el = Nothing
                //Set col = Nothing
                //Set ModAddDetail = Nothing

            }
            return boolToReturn;
        }

        public int GetIndexColumn(string strAttrib)
        {
            int intToReturn;
            //On Error Resume Next

            int i;
            //Dim obj As Variant
            Field obj;
            int numCol;

            numCol = mp_Columns.Count;
            intToReturn = 0;

            for (i = 1; i <= numCol; i++)
            {// To numCol

                obj = mp_Columns.ElementAt(i - 1).Value;

                if (LCase(obj.Name) == LCase(strAttrib))
                {
                    intToReturn = i;
                    break;
                }

            }

            //err.Clear
            return intToReturn;



        }

        /// <summary>
        /// '-- effettua il calcolo dei totali di riga e quello complessivo di sezione
        /// </summary>
        private void MakeTotalSection()
        {
            int R;
            try
            {

                string strFormula;
                int i;
                string[] vVetAttrib;
                string strAttrib;
                int numAtt;
                long[] vIndexAtt;
                string strEspressione;
                //Dim scpript As Object //'New ScriptControl
                string valApp;

                if (objDocument.ReadOnly == true || mp_editable == false)
                {
                    return;
                }
                //Set scpript = CreateObject("ScriptControl")


                //'-- prende l'espressione configurata
                strFormula = GetParam(param, "TOTAL_EXPRESSION");
                mp_Total = 0;

                //'-- se non � presente si esce
                if (string.IsNullOrEmpty(strFormula))
                {
                    return;
                }

                //'-- determina tuti gli attributi presenti
                strAttrib = strFormula.Replace(@" ", @"");
                strAttrib = strAttrib.Replace(@"-", @"*");
                strAttrib = strAttrib.Replace(@"+", @"*");
                strAttrib = strAttrib.Replace(@"/", @"*");
                strAttrib = strAttrib.Replace(@"(", @"*");
                strAttrib = strAttrib.Replace(@")", @"*");
                strAttrib = strAttrib.Replace(@"**", @"*");

                vVetAttrib = Strings.Split(strAttrib, "*");
                numAtt = (vVetAttrib.Length - 1);

                //'-- per ogni attributo si calcola gli indice nella matrice
                vIndexAtt = new long[numAtt + 1];//ReDim vIndexAtt(numAtt) As Long
                for (i = 0; i <= numAtt; i++)
                {// To numAtt
                    if (!string.IsNullOrEmpty(vVetAttrib[i]))
                    {
                        vIndexAtt[i] = GetIndexColumn(vVetAttrib[i]);
                    }
                    else
                    {
                        vIndexAtt[i] = 0;
                    }

                }
                //'--determina il separatore dei decimali
                string sep;
                if (Strings.InStr(1, CStr(0.5), ",") > 0)
                {
                    sep = ",";
                }
                else
                {
                    sep = ".";
                }


                //'-- per ogni riga calcola il suo totale
                for (R = 1; R <= mp_numRec; R++)
                {// To mp_numRec

                    strEspressione = strFormula;

                    //'-- recupera per ogni attributo il valore dalla matrice
                    for (i = 0; i <= numAtt; i++)
                    {// To numAtt
                        if (!string.IsNullOrEmpty(vVetAttrib[i]) && vIndexAtt[i] > 0)
                        {
                            //'-- lo sostituisce nella formula

                            //'mp_Columns(vVetAttrib(i)).Value = mp_Matrix(vIndexAtt(i) - 1, r - 1)
                            valApp = "0";
                            //On Error Resume Next
                            try
                            {
                                valApp = CStr(mp_Matrix[vIndexAtt[i] - 1, R - 1]);
                            }
                            catch { }
                            //err.Clear
                            //'If sep = "," Then
                            //'    valApp = Replace(valApp, ".", ",")
                            //'Else
                            valApp = valApp.Replace(",", ".");
                            //'End If


                            //'strEspressione = Replace(strEspressione, vVetAttrib(i), mp_Matrix(vIndexAtt(i) - 1, r - 1))
                            //'strEspressione = Replace(strEspressione, vVetAttrib(i), mp_Columns(vVetAttrib(i)).RSValue())
                            strEspressione = strEspressione.Replace(vVetAttrib[i], valApp);
                        }
                    }

                    //'-- esegue il calcolo e conserva il parziale
                    //scpript.Language = "VBscript";
                    //On Error Resume Next
                    try
                    {
                        mp_VetTotRow[R - 1] = CDbl(CommonModule.Basic.ComputeEval(strEspressione));//scpript.Eval(strEspressione)

                    }
                    catch
                    {
                        mp_VetTotRow[R - 1] = 0;
                    }
                    //If err.Number Then
                    //    mp_VetTotRow(R - 1) = 0
                    //    err.Clear
                    //End If


                    //'-- lo somma al totale
                    mp_Total = mp_Total + mp_VetTotRow[R - 1];

                }


                //Erase vIndexAtt
                //Set scpript = Nothing

                //Exit Sub

            }
            catch (Exception ex)
            {

                //'-- in caso di errore si svuotano i totali
                for (R = 1; R <= mp_numRec; R++)
                {// To mp_numRec
                    mp_VetTotRow[R - 1] = 0;
                }
                mp_Total = 0;
                //Erase vIndexAtt
                //Set scpript = Nothing    
            }
        }
        /// <summary>
        /// '-- recupera dalla sessione di lavoro ASP le variabili per gestire la griglia paginata
        /// </summary>
        /// <param name="session"></param>
        private void LoadFromMem(Session.ISession session)
        {
            string strSecName = "DOC_SEC_MEM_" + objDocument.Id + "_" + objDocument.mp_IDDoc + "_" + Id;

            if (objDocument.ReadOnly || !mp_editable)
            {

                if (!string.IsNullOrEmpty(CStr(session[strSecName + "_NumeroPagina"])))
                {
                    mp_NumeroPagina = CLng(session[strSecName + "_NumeroPagina"]);
                }

                return;
            }

            //'-- verifica se la sezione ha delle aree di memoria in sessione
            if (!string.IsNullOrEmpty(session[strSecName]))
            {

                if (!string.IsNullOrEmpty(session[$"{strSecName}_CRYPT"]))
                {
                    initCryptKey(session);
                    var encryptedData = (byte[]?)session[strSecName + "_MATRIX"];
                    mp_Matrix = Cifratura.DecryptGenericData<dynamic[,]>(encryptedData, objDocument.cryptoKey)!;
                }
                else
                {
                    mp_Matrix = session[strSecName + "_MATRIX"]!;
                }

                if (mp_objGrid != null)
                {
                    mp_objGrid.SetMatrix(mp_Matrix, mp_VetOriginalRow);
                }

                mp_VetTotRow = session[strSecName + "_VetTotRow"]!;
                mp_Total = CDbl(session[strSecName + "_Total"]);
                mp_VetOriginalRow = session[strSecName + "_VetOriginalRow"]!;

                mp_numRec = CInt(session[strSecName + "_numRec"]);
                mp_CounterValue = CLng(session[strSecName + "_CounterValue"]);

                mp_NumeroPagina = CLng(session[strSecName + "_NumeroPagina"]);

            }
        }

        /// <summary>
        /// '-- salva inella sessione di lavoro ASP le variabili per gestire la griglia paginata
        /// </summary>
        /// <param name="session"></param>
        private void SaveInMem(Session.ISession session)
        {
            string strSecName;

            strSecName = "DOC_SEC_MEM_" + objDocument.Id + "_" + objDocument.mp_IDDoc + "_" + Id;

            if (objDocument.ReadOnly || !mp_editable)
            {
                //'--salvo solo il numero di pagina per poterlo recuperare correttamente anche quando la sezione non è editabile
                session[strSecName + "_NumeroPagina"] = mp_NumeroPagina;
                return;
            }

            //Se in configurazione è attiva la cifratura della sessione e SE per questa sezione è richiesta la cifratura
            bool crypt = (Strings.Left(GetParam(param, "CRYPT"), 3) == "YES" && session.EncryptData());

            session[strSecName] = "yes";

            if (crypt)
            {
                initCryptKey(session);

                session[$"{strSecName}_CRYPT"] = "yes"; //evidenziamo con una chiave dedicata che i dati in sessione sono cifrati
                session[strSecName + "_MATRIX"] = Cifratura.EncryptGenericData(mp_Matrix, objDocument.cryptoKey);
            }
            else
            {
                session[strSecName + "_MATRIX"] = mp_Matrix;
            }

            session[strSecName + "_VetTotRow"] = mp_VetTotRow;
            session[strSecName + "_Total"] = mp_Total;
            session[strSecName + "_VetOriginalRow"] = mp_VetOriginalRow;
            session[strSecName + "_numRec"] = mp_numRec;
            session[strSecName + "_CounterValue"] = mp_CounterValue;
            session[strSecName + "_NumeroPagina"] = mp_NumeroPagina;

        }

        /// <summary>
        /// '-- recupera dalla sessione di lavoro ASP le variabili per gestire la griglia paginata
        /// </summary>
        /// <param name="session"></param>
        /// <returns></returns>
        private bool IsInMem(Session.ISession session)
        {
            string strSecName;

            strSecName = "DOC_SEC_MEM_" + objDocument.Id + "_" + objDocument.mp_IDDoc + "_" + Id;

            //'-- verifica se la sezione ha delle aree di memoria in sessione
            if (!string.IsNullOrEmpty(session[strSecName]))
            {
                return true;
            }
            else
            {
                return false;
            }

        }

        public void RemoveMem(Session.ISession session)
        {
            string strSecName;

            strSecName = "DOC_SEC_MEM_" + objDocument.Id + "_" + objDocument.mp_IDDoc + "_" + Id;

            if (UCase(GetParam(param, "SAVE_MODEL")) == "YES")
            {
                BasicDocument.FreeModelMemDoc(session, strModelName, objDocument.mp_IDDoc);
            }

            session[strSecName] = null;
            session[strSecName + "_CRYPT"] = null;
            session[strSecName + "_MATRIX"] = null;
            session[strSecName + "_VetTotRow"] = null;
            session[strSecName + "_Total"] = 0;
            session[strSecName + "_VetOriginalRow"] = null;
            session[strSecName + "_numRec"] = 0;
            session[strSecName + "_CounterValue"] = 0;
        }

        private void UpdRecordFromRS(Session.ISession session, TSRecordSet rs, int R)
        {

            string strFieldClass;
            int numCol;
            ClsDomain dom;
            int i;
            Dictionary<string, Field> Columns = new Dictionary<string, Field>(); //As Collection
            Dictionary<string, Grid_ColumnsProperty> ColumnsProperty = new Dictionary<string, Grid_ColumnsProperty>(); // As Collection
            dynamic? val;

            numCol = mp_Columns.Count;
            //'r = mp_numRec - 1

            //'-- carica i valori del modello della griglia nella matrice
            //On Error Resume Next
            for (i = 1; i <= numCol; i++)
            { //To numCol   
                try
                {
                    val = GetValueFromRS(rs.Fields[mp_Columns.ElementAt(i - 1).Value.Name]);
                }
                catch
                {
                    val = null;

                }
                //'-- la colonna contatore non deve essere sovrascritta con empty
                if (mp_PosCounter != (i - 1))
                {
                    mp_Matrix[i - 1, R] = val;
                }
                else
                {
                    if (!IsEmpty(val))
                    {
                        mp_Matrix[i - 1, R] = val;
                    }
                }
            }
            //On Error GoTo 0

            strFieldClass = GetParam(param, "FIELD_CLASS");

            //'mp_Matrix(numCol + 1, r) = 0 '-- idRow 0 per nuovo
            mp_Matrix[numCol, R] = null;//'-- eleimina la collezione di attributi
            if (!string.IsNullOrEmpty(strFieldClass))
            {

                mp_Matrix[numCol + 2, R] = "";
                mp_Matrix[numCol + 2, R] = GetValueFromForm(Request_Form, strFieldClass);
                mp_Matrix[numCol, R] = null;
                if (!string.IsNullOrEmpty(mp_Matrix[numCol + 2, R]))
                {

                    Dictionary<dynamic, dynamic> sCollAtt = new Dictionary<dynamic, dynamic>();
                    //Set sCollAtt = New superCollection

                    //'-- prendo il dominio
                    //'Request_Form (strFieldClass)
                    //Set objDB = CreateObject("ctldb.lib_dbDictionary")
                    LibDbDictionary ldd = new LibDbDictionary();
                    dom = ldd.GetDomOfAttrSC(strFieldClass, mp_suffix, 0, mp_strConnectionString);
                    //Set objDB = Nothing

                    //'-- recupera il modello di attributi opzionali
                    //Set objDB = CreateObject("ctldb.lib_dbModel")
                    LibDbModelExt ldme = new LibDbModelExt();
                    ldme.GetFilteredFields(dom.Elem[GetValueFromForm(Request_Form, strFieldClass)].CodExt, ref Columns, ref ColumnsProperty, "I", 0, 0, mp_strConnectionString, session, false);
                    //Set objDB = Nothing


                    //'-- carica i valori del modello in una supercollezione
                    //On Error Resume Next
                    for (i = 1; i <= Columns.Count; i++)
                    {// To Columns.count
                        try
                        {
                            val = GetValueFromRS(rs.Fields[Columns.ElementAt(i - 1).Value.Name]);
                        }
                        catch
                        {
                            val = "";
                        }
                        //If err.Number <> 0 Then
                        //    err.Clear
                        //End If
                        sCollAtt.Add(Columns.ElementAt(i - 1).Value.Name, val);

                    }
                    //On Error GoTo 0

                    //'-- inserisco la collezione nella matrice
                    mp_Matrix[numCol, R] = sCollAtt;

                    //ReleaseCollection Columns
                    //ReleaseCollection ColumnsProperty
                    //Set Columns = Nothing
                    //Set ColumnsProperty = Nothing

                    //Set dom = Nothing
                    //Set sCollAtt = Nothing
                }


            }

            //'-- aggiorno la matrice nella griglia
            mp_objGrid.SetMatrix(mp_Matrix, mp_VetOriginalRow);


        }

        public void DeleteAll()
        {
            //'

            //'InitLocal session

            //'EraseMem


            string strFieldClass;
            int numCol;
            ClsDomain dom;
            //Dim objDB As Object
            int R;
            int i;
            long indRow;
            Dictionary<string, Field> Columns;// As Collection
            Dictionary<string, Grid_ColumnsProperty> ColumnsProperty; //As Collection
            //Dim newMatrix As Variant


            //'InitLocal session

            //'indRow = Request_QueryString("IDROW")
            numCol = mp_Columns.Count;
            //'r = indRow


            //'-- tiro su tutte le righe sottostanti
            for (R = 0; R <= mp_numRec - 1; R++)
            {// To mp_numRec - 1
                mp_Matrix[numCol, R] = null; //'-- eleimina la collezione di attributi
            }

            //'-- ridimensiono la griglia
            mp_numRec = 0;
            if (mp_numRec == 0)
            {
                if (!IsEmpty(mp_Matrix))
                {
                    //Erase mp_Matrix
                }
                mp_Matrix = null;
            }

            //'-- aggiorno la matrice nella griglia
            mp_objGrid.SetMatrix(mp_Matrix, mp_VetOriginalRow);



        }

        public void SetMatrixValue(long R, long c, dynamic Valore)
        {
            mp_Matrix[c, R] = Valore;
        }

        public void UpdateHtml(Session.ISession session, EprocResponse response)
        {

            Html(response, session);

            //'-- inserisce il comando per sostituirla nel documento
            response.Write($@"<script type=""text/javascript"" language=""javascript"" >;");
            response.Write($@"       try {{ parent.getObj( 'div_" + Id + "Grid' ).innerHTML = ");
            response.Write($@"       getObj( 'div_" + Id + $@"Grid' ).innerHTML; }} catch( e ) {{ }};");
            response.Write($@"       ");

            //'-- svuoto l'area di lavoro
            response.Write($@"       try {{ ");
            response.Write($@"       getObj( 'div_" + Id + $@"Grid' ).innerHTML=''; }} catch( e ) {{ }};");

            //'-- aggiorno la paginazione
            response.Write($@"       try {{parent.SP_Refresh_SP_" + Id + "( " + mp_NumeroPagina + $@" );}} catch( e ) {{ }}");

            if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_SECTION")))
            {
                response.Write($@"      try {{  parent.MakeTotal_Section( '" + GetParam(param, "TOTAL_SECTION") + "' );}} catch( e ) {{ }}; ");
            }


            //'-- AGGIORNO IL TOTALE DELLA sezione
            if (!string.IsNullOrEmpty(GetParam(param, "TOTAL_FIELD")))
            {
                MakeTotalSection();
                response.Write($@"  try {{  parent.SetNumericValue( '" + GetParam(param, "TOTAL_FIELD") + "' , " + Replace(CStr(mp_Total), ",", ".") + $@" ); }} catch( e ) {{;}}; " + Environment.NewLine);
                response.Write($@"  try {{  parent." + Id + "_TotRow = " + Id + "_TotRow; } catch( e ) {;}; " + Environment.NewLine);
            }


            response.Write($@"</script>" + Environment.NewLine);

        }

        private void AggiornaContatore()
        {


            long numRow;
            long i;


            //'-- calcola il valore massimo corrente
            if (mp_PosCounter >= 0)
            {

                //'-- determina il valore iniziale del contatore
                mp_CounterValue = 0;

                if (!IsEmpty(mp_Matrix))
                {

                    numRow = mp_Matrix.GetUpperBound(1);

                    for (i = 0; i <= numRow; i++)
                    {// To numRow
                        if (CLng(mp_Matrix[mp_PosCounter, i]) > mp_CounterValue)
                        {//Then
                            mp_CounterValue = CLng(mp_Matrix[mp_PosCounter, i]);
                        }
                    }

                }

            }



        }

        private bool ValueExist(dynamic v)
        {
            bool boolToReturn;
            long numRow;
            long i;

            if (mp_PosNoDuplicati >= 0)
            {


                if (!IsEmpty(mp_Matrix))
                {

                    numRow = mp_Matrix.GetUpperBound(1);

                    for (i = 0; i <= numRow; i++)
                    {// To numRow
                        if (CStr(mp_Matrix[mp_PosNoDuplicati, i]) == CStr(v))
                        {
                            boolToReturn = true;
                            return boolToReturn;
                        }
                    }

                }

            }
            boolToReturn = false;
            return boolToReturn;

        }

        public void DelRowRecord(Session.ISession session, int indRow)
        {


            string strFieldClass;
            int numCol;
            ClsDomain dom;
            //Dim objDB As Object
            int R;
            int i;
            //'Dim indRow As Long
            //Dim Columns As Collection
            //Dim ColumnsProperty As Collection
            dynamic[,] newMatrix;


            InitLocal(session);

            //'indRow = Request_QueryString("IDROW")
            numCol = mp_Columns.Count;
            R = indRow;

            //'-- elimino la collezione di attributi opzionali
            mp_Matrix[numCol, R] = null;//'-- eleimina la collezione di attributi


            //'-- tiro su tutte le righe sottostanti
            for (R = indRow; R <= mp_numRec - 2; R++)
            {// To mp_numRec - 2
                for (i = 0; i <= numCol - 1; i++)
                {// To numCol - 1
                    mp_Matrix[i, R] = mp_Matrix[i, R + 1];
                }
                //On Error Resume Next
                try
                {
                    mp_Matrix[numCol, R] = mp_Matrix[numCol, R + 1];
                }
                catch { }
                try
                {
                    mp_Matrix[numCol + 1, R] = mp_Matrix[numCol + 1, R + 1];
                }
                catch { }
                try
                {
                    mp_Matrix[numCol + 2, R] = mp_Matrix[numCol + 2, R + 1];
                }
                catch { }
                //On Error GoTo 0
            }

            //'-- ridimensiono la griglia
            mp_numRec = mp_numRec - 1;
            if (mp_numRec == 0)
            {
                //Erase mp_Matrix
                mp_Matrix = null;
            }
            else
            {
                newMatrix = new dynamic[mp_Columns.Count + 4, mp_numRec - 1 + 1];
                //ReDim newMatrix(mp_Columns.count + 3, mp_numRec - 1) As Variant
                Array.Resize(ref mp_VetTotRow, mp_numRec + 1);
                //ReDim Preserve mp_VetTotRow(mp_numRec) As Double

                //'-- copia la vecchia matrice
                for (R = 0; R <= mp_numRec - 1; R++)
                {// To mp_numRec - 1
                    for (i = 0; i <= numCol - 1; i++)
                    {// To numCol - 1
                        newMatrix[i, R] = mp_Matrix[i, R];
                    }
                    newMatrix[numCol, R] = mp_Matrix[numCol, R];
                    mp_Matrix[numCol, R] = null;
                    newMatrix[numCol + 1, R] = mp_Matrix[numCol + 1, R];
                    newMatrix[numCol + 2, R] = mp_Matrix[numCol + 2, R];
                }
                //Erase mp_Matrix
                mp_Matrix = newMatrix;
                //newMatrix = null;

            }

            //'aggiunta la chiamata per ridare il valore corretto quando cancello una riga da una griglia
            //'con la configurazione del PROG_ROW, evita di lasciare buchi
            AggiornaContatore();

            //'-- aggiorno la matrice nella griglia
            mp_objGrid.SetMatrix(mp_Matrix, mp_VetOriginalRow);




        }

        public void SaveSectionInMem(Session.ISession session)
        {
            SaveInMem(session);
        }

        /// <summary>
        /// '--libera la riga in posizione nPosNewRow di un amatrice
        /// </summary>
        /// <param name="mp_Matrix"></param>
        /// <param name="nNumRow"></param>
        /// <param name="nPosNewRow"></param>
        /// <param name="numCol"></param>
        private void Shift_Down_Row_Matrix(dynamic[,] mp_Matrix, int nNumRow, int nPosNewRow, int numCol)
        {

            int j;
            int i;

            for (j = mp_numRec; j >= nPosNewRow + 1; j--)
            {// To nPosNewRow +1 Step - 1


                for (i = 1; i <= numCol; i++)
                {// To numCol
                    mp_Matrix[i - 1, j] = mp_Matrix[i - 1, j - 1];
                }

                //On Error Resume Next
                try
                {
                    mp_Matrix[numCol, j] = mp_Matrix[numCol, j - 1];
                }
                catch { }
                try
                {
                    mp_Matrix[numCol + 2, j] = mp_Matrix[numCol + 2, j - 1];
                }
                catch { }
                //'mp_Matrix(numCol + 1, j) = mp_Matrix(numCol + 1, j - 1)
                //On Error GoTo 0


            }

            //'--svuoto la nuova riga
            for (i = 1; i <= numCol; i++)
            {// To numCol
                mp_Matrix[i - 1, nPosNewRow] = "";
            }


        }



    }

    public class Sec_Static : ISectionDocument
    {
        public string Id { get; set; }
        public string Caption { get; set; }
        public string strTable { get; set; }
        public string strFieldId { get; set; }
        public string strFieldIdRow { get; set; }
        public string strTableFilter { get; set; }
        public string strModelName { get; set; }
        public long PosPermission { get; set; }
        public string mp_idDoc { get; set; }
        public Toolbar ObjToolbar { get; set; }
        public string strHelp { get; set; }
        public CTLDOCOBJ.Document objDocument { get; set; }
        public string param { get; set; }
        public string TypeSection { get; set; }
        public Model mp_Mod { get; set; }
        public Dictionary<string, Field> mp_Columns { get; set; }
        public dynamic[,] mp_Matrix { get; set; }


        public Dictionary<string, Field> mp_ColumnsC { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public Dictionary<string, Field> mp_ColumnsS { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public TSRecordSet mp_rsCicle { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public TSRecordSet mp_rsCicleStep { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public int mp_numRec { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }

        private EprocResponse _response;
        //private IHttpContextAccessor _accessor;
        private HttpContext _context;
        private Session.ISession _session;

        public Sec_Static(HttpContext context, Session.ISession session, EprocResponse response)
        {
            TypeSection = "STATIC";
            //this._accessor = accessor;
            this._context = context;
            this._session = session;
            _response = response;
        }


        public void AddRecord(Session.ISession session, int fromRow = -1, bool bCount = true)
        {
            throw new NotImplementedException();
        }

        public bool CanSave(Session.ISession session)
        {
            return true;
        }

        public void Excel(EprocResponse response, Session.ISession OBJSESSION)
        {

        }

        public void Html(EprocResponse response, Session.ISession OBJSESSION)
        {
            string URL;
            string h;
            string strJSOnLoad;

            if (!string.IsNullOrEmpty(GetParam(param, "CAPTION")) && string.IsNullOrEmpty(GetParam(param, "NOCAPTION")))
            {

                Fld_Label objlabel = new Fld_Label();
                objlabel.Value = ApplicationCommon.CNV(GetParam(param, "CAPTION"), OBJSESSION);
                objlabel.Html(response);
                objlabel = null;

            }


            if (strTable == "ASP")
            {
                URL = param;
            }
            else
            {
                URL = GetParamURL(param, "URL");
            }

            h = GetParam(param, "HEIGHT");

            URL = MyReplace(URL, "<ID_DOC>", this.mp_idDoc);
            URL = MyReplace(URL, "<ID_USER>", CStr(OBJSESSION[Session.SessionProperty.SESSION_USER]));

            response.Write(HTML_iframe(Id, URL, 0, @"scrolling=""no""", h));

            //'--esegue jscript onload
            response.Write("<script>" + Environment.NewLine);
            strJSOnLoad = GetParam(param, "JSOnLoad");
            if (LCase(strJSOnLoad) == "yes")
            {

                response.Write(this.Id + "_OnLoad(); ");

            }
            response.Write("</script>" + Environment.NewLine);
        }

        /// <summary>
        /// '-- funzione di inizializzazione della sezione --
        /// '-- questa funzione � indispensabile al corretto funzionamento e viene invocata da CTL_DB al caricamento del docuemnto
        /// </summary>
        /// <param name="pId"></param>
        /// <param name="model"></param>
        /// <param name="pCaption"></param>
        /// <param name="pTable"></param>
        /// <param name="pstrFieldId"></param>
        /// <param name="pFieldIdRow"></param>
        /// <param name="pTableFilter"></param>
        /// <param name="strToolbar"></param>
        /// <param name="help"></param>
        /// <param name="session"></param>
        public void Init(string pId, string model, string pCaption, string pTable, string pstrFieldId, string pFieldIdRow, string pTableFilter, string strToolbar, string help, Session.ISession session)
        {
            Id = pId;
            strTable = pTable;
            Caption = ApplicationCommon.CNV(pCaption, session);
            strFieldId = pstrFieldId;
            //'Set ObjToolbar = Nothing
            strHelp = help;
            strFieldIdRow = pFieldIdRow;

            if (string.IsNullOrEmpty(strFieldIdRow))
            {
                strFieldIdRow = strFieldId;
            }
            strTableFilter = pTableFilter;


            //'-- carica il modello associato
            strModelName = model;

            //'mp_User = session(SESSION_USER)
        }

        public void InitializeFrom(Session.ISession OBJSESSION, string idDoc)
        {

        }

        public void InitializeNew(Session.ISession OBJSESSION, string idDoc)
        {

        }

        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library")
        {

        }

        public void Load(Session.ISession session, string idDoc, SqlConnection? prevConn = null)
        {
            mp_idDoc = idDoc;
        }

        public void RemoveMem(Session.ISession session)
        {

        }

        public bool Save(Session.ISession session, ref string ReferenceKey, Dictionary<dynamic, dynamic> mpMEM, SqlConnection conn, SqlTransaction trans)
        {
            return true;
        }

        public void ToPrint(EprocResponse response, Session.ISession OBJSESSION)
        {
            string URL;
            string h;
            string strJSOnLoad;

            if (!string.IsNullOrEmpty(GetParam(param, "CAPTION")) && string.IsNullOrEmpty(GetParam(param, "NOCAPTION")))
            {

                Fld_Label objlabel = new Fld_Label();
                objlabel.Value = ApplicationCommon.CNV(GetParam(param, "CAPTION"), OBJSESSION);
                objlabel.Html(response);
                //Set objlabel = Nothing

            }


            if (strTable == "ASP")
            {
                URL = param;
            }
            else
            {
                URL = GetParam(param, "URL");
            }

            h = GetParam(param, "HEIGHT");

            URL = MyReplace(URL, "<ID_DOC>", this.mp_idDoc);
            URL = MyReplace(URL, "<ID_USER>", CStr(OBJSESSION[Session.SessionProperty.SESSION_USER]));

            response.Write(HTML_iframe(Id, URL, 0, @"scrolling=""no""", h));

            //'--esegue jscript onload
            response.Write("<script>" + Environment.NewLine);
            strJSOnLoad = GetParam(param, "JSOnLoad");
            if (LCase(strJSOnLoad) == "yes")
            {

                response.Write(this.Id + "_OnLoad(); ");

            }
            response.Write("</script>" + Environment.NewLine);
        }

        public void toPrintExtraContent(EprocResponse response, Session.ISession OBJSESSION, string _params = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {

        }

        public void UpdateContentInMem(Session.ISession session, IFormCollection? Request_Form = null)
        {

        }

        public void UpdRecord(Session.ISession session)
        {
            throw new NotImplementedException();
        }

        public void xml(EprocResponse ScopeLayer)
        {
            addXmlSection(Id, TypeSection, ScopeLayer);

            closeXmlSection(Id, ScopeLayer);
        }

        public void Command(Session.ISession session, EprocResponse response)
        {

        }

        public int GetIndexColumn(string strAttrib)
        {
            throw new NotImplementedException();
        }
    }

    public class Sec_Total : ISectionDocument
    {
        public string Id { get; set; }
        public string Caption { get; set; }
        public string strTable { get; set; }
        public string strFieldId { get; set; }
        public string strFieldIdRow { get; set; }
        public string strTableFilter { get; set; }
        public string strModelName { get; set; }
        public long PosPermission { get; set; }
        public string mp_idDoc { get; set; }
        public Toolbar ObjToolbar { get; set; }
        public string strHelp { get; set; }
        public CTLDOCOBJ.Document objDocument { get; set; }
        public string param { get; set; }
        public string TypeSection { get; set; }
        public Model mp_Mod { get; set; }
        public Dictionary<string, Field> mp_Columns { get; set; }
        public dynamic[,] mp_Matrix { get; set; }

        public Dictionary<string, Field> mp_ColumnsC { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public Dictionary<string, Field> mp_ColumnsS { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public TSRecordSet mp_rsCicle { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public TSRecordSet mp_rsCicleStep { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public int mp_numRec { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }

        private long mp_User; //'-- identificativo dell'utente che ha caricato il documento
        private string mp_suffix;
        private string mp_strConnectionString;
        private string mp_Permission;


        //'-- la sezione total possiede un modello per la visualizzazione delle informazioni
        //public Model mp_Mod;

        private EprocResponse _response;
        //private IHttpContextAccessor _accessor;
        private HttpContext _context;
        private Session.ISession _session;

        public Sec_Total(HttpContext context, Session.ISession session, EprocResponse response)
        {
            TypeSection = "TOTAL";
            //this._accessor = accessor;
            this._context = context;
            this._session = session;
            _response = response;
        }

        public void AddRecord(Session.ISession session, int fromRow = -1, bool bCount = true)
        {
            throw new NotImplementedException();
        }

        public bool CanSave(Session.ISession session)
        {
            //'-- controlla che i campi obbligatori siano stati inseriti
            if (mp_Mod.CheckObblig())
            {
                return false;
            }
            else
            {
                return true;
            }
        }

        public void Excel(EprocResponse response, Session.ISession OBJSESSION)
        {
            response.Write($@"<div class=""Total"" id=""" + Id + @""" name=""" + Id + @"""  >");

            //'-- disegno il modello
            if (mp_Mod != null)
            {//Then

                mp_Mod.Excel(response);

            }

            //'-- chiudo la div
            response.Write("</div>");
        }

        public void Html(EprocResponse response, Session.ISession OBJSESSION)
        {
            //'-- apro la div
            response.Write(@"<div class=""Total"" id=""" + Id + @""" name=""" + Id + @"""  >");


            HTML_HiddenField(response, Id + "_EXPRESSION", GetParam(param, "EXPRESSION"));
            HTML_HiddenField(response, Id + "_F_TOT_RIGHE", GetParam(param, "F_TOT_RIGHE"));
            HTML_HiddenField(response, Id + "_F_TOT", GetParam(param, "F_TOT"));
            HTML_HiddenField(response, Id + "_F_TRASPORTO", GetParam(param, "F_TRASPORTO"));
            HTML_HiddenField(response, Id + "_F_SCONTO", GetParam(param, "F_SCONTO"));
            HTML_HiddenField(response, Id + "_F_TOTALESCONTATO", GetParam(param, "F_TOTALESCONTATO"));
            HTML_HiddenField(response, Id + "_F_ACCONTO", GetParam(param, "F_ACCONTO"));
            HTML_HiddenField(response, Id + "_F_RESTO", GetParam(param, "F_RESTO"));
            HTML_HiddenField(response, Id + "_SECTION_DETAIL", GetParam(param, "SECTION_DETAIL"));

            //'-- disegno il modello
            if (mp_Mod != null)
            {//Then

                if (objDocument.ReadOnly == true || UCase(GetParam(param, "READONLY")) == "YES")
                {
                    mp_Mod.Editable = false;
                }

                mp_Mod.Html(response);
            }
            else
            {
                response.Write("Il modello [" + Id + "] dei totali non è stato avvalorato");
            }


            //'-- invoca l'aggiornamento dei totali
            response.Write($@"<script type=""text/javascript"" language=""javascript"" >");
            response.Write($@"       try {{ MakeTotal_Section( '" + Id + $@"');  }} catch( e ) {{}};");
            response.Write($@"</script>" + Environment.NewLine);


            //'-- chiudo la div
            response.Write("</div>");
        }

        public void Init(string pId, string model, string pCaption, string pTable, string pstrFieldId, string pFieldIdRow, string pTableFilter, string strToolbar, string help, Session.ISession session)
        {
            Id = pId;
            strTable = pTable;
            Caption = pCaption;
            strFieldId = pstrFieldId;
            //'Set ObjToolbar = Nothing
            strHelp = help;
            strFieldIdRow = pFieldIdRow;

            if (string.IsNullOrEmpty(strFieldIdRow))
            {
                strFieldIdRow = strFieldId;
            }
            strTableFilter = pTableFilter;


            mp_suffix = CStr(session[Session.SessionProperty.SESSION_SUFFIX]);
            if (string.IsNullOrEmpty(mp_suffix))
            {
                mp_suffix = "I";
            }
            mp_strConnectionString = ApplicationCommon.Application.ConnectionString;
            mp_User = CLng(session[Session.SessionProperty.SESSION_USER]);
            mp_Permission = CStr(session[Session.SessionProperty.SESSION_PERMISSION]);


            //'-- carica il modello associato alla caption
            //Dim objDB As Object //'New CTLDB.Lib_dbModelExt
            //Set objDB = CreateObject("ctldb.lib_dbModelext")
            LibDbModelExt ldme = new LibDbModelExt();
            mp_Mod = ldme.GetFilteredModel(model, mp_suffix, mp_User, 0, mp_strConnectionString, true, session);
            //'-- per ogni campo dei totali imposto la funzione per l'aggiornamento dei campi

            for (int i = 1; i <= mp_Mod.Fields.Count; i++)
            { //To mp_Mod.Fields.count
                mp_Mod.Fields.ElementAt(i - 1).Value.setOnChange("SetTotalField('" + Id + "');");
            }

            //Set objDB = Nothing
        }

        public void InitializeFrom(Session.ISession OBJSESSION, string idDoc)
        {
            //'mp_idDoc = idDoc
        }

        public void InitializeNew(Session.ISession OBJSESSION, string idDoc)
        {
            //'-- per la copertina non � necessario effettuare operazioni ( almeno per il momento POI??? )
            mp_idDoc = idDoc;
        }

        public void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library")
        {
            //On Error Resume Next

            if (mp_Mod != null)
            {//Then
                mp_Mod.JScript(JS, Path);
            }
            if (!JS.ContainsKey("SEC_Total"))
            {
                JS.Add("SEC_Total", $@"<script src=""" + Path + $@"jscript/DOCUMENT/SEC_Total.js"" ></script>");
            }
        }

        public void Load(Session.ISession session, string idDoc, SqlConnection? prevConn = null)
        {
            mp_idDoc = idDoc;
            Read();
        }

        public void RemoveMem(Session.ISession session)
        {

        }

        public bool Save(Session.ISession session, ref string ReferenceKey, Dictionary<dynamic, dynamic> mpMEM, SqlConnection conn, SqlTransaction trans)
        {
            try
            {
                return true;

                //Exit Function

            }
            catch (Exception ex)
            {

                objDocument.Msg = ApplicationCommon.CNV("Errore nel salvataggio " + Caption + " - " + ex.Message, session);
                return false;

            }
        }

        public void ToPrint(EprocResponse response, Session.ISession OBJSESSION)
        {
            Html(response, OBJSESSION);
        }

        public void toPrintExtraContent(EprocResponse response, Session.ISession OBJSESSION, string _params = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false)
        {

        }

        public void UpdateContentInMem(Session.ISession session, IFormCollection? Request_Form = null)
        {
            mp_Mod.UpdFieldsValue(Request_Form);
        }

        public void UpdRecord(Session.ISession session)
        {
        }

        public void xml(EprocResponse ScopeLayer)
        {
            addXmlSection(Id, TypeSection, ScopeLayer);

            mp_Mod.xml(ScopeLayer);

            closeXmlSection(Id, ScopeLayer);
        }

        public void Command(Session.ISession session, EprocResponse response)
        {

        }

        public void Read()
        {

            try
            {

                string strSql;
                TSRecordSet rs;
                //Dim objDB As Object

                string view;


                //'-- prendo la lista dai parametri della sezione
                view = GetParam(param, "VIEW");
                if (string.IsNullOrEmpty(view))
                {
                    view = strTable;
                }

                //'-- prendo il recordset legato alla tabella principale del documento
                strSql = "select * from " + view + " where " + strFieldId + " = " + mp_idDoc;

                //Set objDB = CreateObject("ctldb.clsTabManage")
                CommonDbFunctions cdb = new CommonDbFunctions();
                rs = cdb.GetRSReadFromQuery_(strSql, mp_strConnectionString);
                //Set objDB = Nothing


                //'--avvaloro il modello
                mp_Mod.SetFieldsValue(rs.Fields);


                //'-- chiudo ed esco
                //rs.Close

                //Set rs = Nothing

                //Exit Function

            }
            catch (Exception ex)
            {
                //If Not rs Is Nothing Then rs.Close

                //Set rs = Nothing
                throw new Exception(" CtlDocument.Sec_Total.Read( )", ex);
                //RaiseError " CtlDocument.Sec_Total.Read( )"
            }

        }

        public int GetIndexColumn(string strAttrib)
        {
            throw new NotImplementedException();
        }
    }



}