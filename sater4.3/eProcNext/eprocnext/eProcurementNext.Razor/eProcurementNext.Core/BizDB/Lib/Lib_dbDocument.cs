using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.HTML;
//using static EprocNext.BizDB.BasicFunction;
using eProcurementNext.Session;
using Microsoft.AspNetCore.Http;
using System.Data.SqlClient;
using System.Reflection;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.BizDB
{
    public interface ISectionDocument
    {
        //'-- elementi base di ogni sezione
        string Id { get; set; }//'-- identificativo della sezione come nome
        string Caption { get; set; }
        string strTable { get; set; }
        string strFieldId { get; set; }
        string strFieldIdRow { get; set; }
        string strTableFilter { get; set; }
        string strModelName { get; set; }
        long PosPermission { get; set; }
        string mp_idDoc { get; set; } //'-- identificativo del documento a cui la sezione fa riferimento
        Toolbar ObjToolbar { get; set; }//'-- toolbar associata al documento
        string strHelp { get; set; }//'-- indirizzo della pagina di help
        Document.CTLDOCOBJ.Document objDocument { get; set; } //' --  riferimento al documento che contiene questa sezione
        string param { get; set; }//'-- parametri passati sulla configurazione della sezione
        string TypeSection { get; set; }//' -- contiene la tipologia di sezione


        //attributi della classe aggiunti per risolvere errori in compilazione
        Model mp_Mod { get; set; }
        Dictionary<string, Field> mp_Columns { get; set; }
        public Dictionary<string, Field> mp_ColumnsC { get; set; }
        public Dictionary<string, Field> mp_ColumnsS { get; set; }
        public TSRecordSet mp_rsCicle { get; set; }
        public TSRecordSet mp_rsCicleStep { get; set; }
        public int mp_numRec { get; set; }//'-- contiene il numero di righe della matrice

        dynamic[,] mp_Matrix { get; set; }
        void AddRecord(Session.ISession session, int fromRow = -1, bool bCount = true);
        void UpdRecord(Session.ISession session);
        int GetIndexColumn(string strAttrib);




        void Init(string pId, string model, string pCaption, string pTable, string pstrFieldId, string pFieldIdRow, string pTableFilter, string strToolbar, string help, Session.ISession session);

        public void Command(Session.ISession session, EprocResponse response);
        void JScript(Dictionary<string, string> JS, string Path = "../CTL_Library");
        bool Save(Session.ISession session, ref string ReferenceKey, Dictionary<dynamic, dynamic> mpMEM, SqlConnection conn, SqlTransaction trans);
        bool CanSave(Session.ISession session);
        void RemoveMem(Session.ISession session);
        void ToPrint(EprocResponse response, Session.ISession OBJSESSION);

        void Excel(EprocResponse response, Session.ISession OBJSESSION);
        void UpdateContentInMem(Session.ISession session, IFormCollection? Request_Form = null);
        void InitializeNew(Session.ISession OBJSESSION, string idDoc);
        void InitializeFrom(Session.ISession OBJSESSION, string idDoc);
        void toPrintExtraContent(EprocResponse response, Session.ISession OBJSESSION, string _params = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false);

        void xml(EprocResponse ScopeLayer);
        void Load(Session.ISession session, string idDoc, SqlConnection? prevConn = null);
        void Html(EprocResponse response, Session.ISession OBJSESSION);
    }

    //DLL VB6 CTLDB/Lib_Document.cls
    public class Lib_dbDocument
    {

        private EprocResponse _response;
        //private IHttpContextAccessor _accessor;
        private HttpContext _context;
        private Session.ISession _session;

        public Lib_dbDocument(HttpContext context, Session.ISession session, EprocResponse response)
        {
            //this._accessor = accessor;
            this._context = context;
            this._session = session;
            _response = response;

        }

        /// <summary>
        /// '-- ritorna un oggetto di tipo documento prelevando tutta la configurazione dal DB
        /// </summary>
        public Document.CTLDOCOBJ.Document? GetDocument(string strDocName, string strPermission, string suffix, int Context, Session.ISession session, string strConnectionString)
        {


            Document.CTLDOCOBJ.Document objNewDoc;
            Lib_dbFunctions objDBFun = new Lib_dbFunctions();
            TSRecordSet rs;
            string strCause = "";
            CommonDbFunctions cdb = new CommonDbFunctions();

            try
            {

                strCause = "carico dalla lib_documents le sezioni del documento Doc_ID=[" + strDocName + "]";
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@DocName", strDocName);
                rs = cdb.GetRSReadFromQuery_("select * from lib_documents with(nolock) where Doc_ID = @DocName", strConnectionString, null, parCollection: sqlParams);

                //'-- Se il documento non � presente nella lib_documents provo nella CTL_documents
                if (rs.RecordCount == 0)
                {
                    //rs.Close
                    strCause = "carico dalla CTL_documents le sezioni del documento Doc_ID=[" + strDocName + "]";
                    sqlParams = new Dictionary<string, object?>();
                    sqlParams.Add("@DocName", strDocName);
                    rs = cdb.GetRSReadFromQuery_("select * from CTL_documents with(nolock) where Doc_ID = @DocName", strConnectionString, null, parCollection: sqlParams);
                }

                if (rs.RecordCount > 0)
                {

                    objNewDoc = new Document.CTLDOCOBJ.Document(_context, _session, _response);




                    rs.MoveFirst();
                    if (!string.IsNullOrEmpty(CStr(rs["DOC_LFN_GroupFunction"])))
                    {
                        //'-- carica la toolbar del documento
                        strCause = "carica la toolbar [" + rs.Fields["DOC_LFN_GroupFunction"] + "] del documento [" + strDocName + "]";
                        objNewDoc.ObjToolbar = Lib_dbFunctions.GetHtmlToolbar(CStr(rs.Fields["DOC_LFN_GroupFunction"]), strPermission, suffix, strConnectionString, session);
                    }

                    //'-- avvaloro le informazioni base del documento
                    strCause = "avvaloro le informazioni base del documento=[" + strDocName + "]";

                    objNewDoc.Caption = CStr(rs.Fields["DOC_DescML"]);

                    //if (!string.IsNullOrEmpty(CStr(rs.Fields["DOC_ProgIdCustomizer"]))){ 
                    //    objNewDoc.ObjCustomizer = CreateObject(rs.Fields("DOC_ProgIdCustomizer"));
                    //    //'-- do alla sezione il riferimento incrociato del documento
                    //    objNewDoc.ObjCustomizer.objDocument = objNewDoc;
                    //}

                    if (!IsNull(rs.Fields["DOC_Table"]))
                    {
                        objNewDoc.strTable = CStr(rs.Fields["DOC_Table"]);
                    }
                    if (!IsNull(rs.Fields["DOC_FieldID"]))
                    {
                        objNewDoc.strFieldId = CStr(rs.Fields["DOC_FieldID"]);
                    }
                    if (!IsNull(rs.Fields["DOC_Help"]))
                    {
                        objNewDoc.strHelp = CStr(rs.Fields["DOC_Help"]);
                    }
                    if (!IsNull(rs.Fields["DOC_Param"]))
                    {
                        objNewDoc.param = CStr(rs.Fields["DOC_Param"]);
                    }

                    objNewDoc.Id = strDocName;

                    if (objNewDoc.param.Contains("READONLY=yes", StringComparison.Ordinal))
                    {
                        objNewDoc.ReadOnly = true;
                    }

                    //Set rs = Nothing

                    //'-- carica le sezioni del documento
                    strCause = "carica le sezioni del documento documento=[" + strDocName + "]";
                    LoadSection(objNewDoc, objDBFun, strDocName, strPermission, suffix, Context, session, strConnectionString);

                    return objNewDoc;

                }

                return null;

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Source + " - FUNZIONE : Lib_dbDocument.GetDocument() - STRCAUSE=" + strCause, ex);
            }

        }

        //'-- carica tutte le sezioni sul documento
        private void LoadSection(Document.CTLDOCOBJ.Document objDoc, Lib_dbFunctions objDBFun, string strDocName, string strPermission, string suffix, int Context, Session.ISession session, string strConnectionString)
        {

            //HTML.Document objNewDoc;
            ISectionDocument newSec;
            TSRecordSet rs;
            int iTypeEnabled;
            string strCause = "";
            CommonDbFunctions cdb = new CommonDbFunctions();

            try
            {
                strCause = "carico dalla lib_documentSections le sezioni del documento DSE_Doc_ID=[" + strDocName + "]";
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@DocName", strDocName);
                rs = cdb.GetRSReadFromQuery_("select * from lib_documentSections with(nolock) where DSE_Doc_ID = @DocName order by DES_order asc", strConnectionString, null, parCollection: sqlParams);

                if (rs.RecordCount == 0)
                {
                    //rs.Close
                    strCause = "carico dalla CTL_documentSections le sezioni del documento DSE_Doc_ID=[" + strDocName + "]";
                    rs = cdb.GetRSReadFromQuery_("select * from CTL_documentSections with(nolock) where DSE_Doc_ID = @DocName order by DES_order asc", strConnectionString, null, parCollection: sqlParams);
                }

                //'-- carico le sezioni configurate
                if (rs.RecordCount > 0)
                {

                    objDoc.Sections = new Dictionary<string, ISectionDocument>();

                    while (!rs.EOF)
                    {

                        //'-- verifico che ci sia il permesso sulla sezione
                        //' 0 -- permesso negato
                        //' 1 -- modifica
                        //' 2 -- lettura
                        if (!IsNull(rs.Fields["DES_PosPermission"]) && !string.IsNullOrEmpty(strPermission)) 
                        {

                            //Federico: in data 25/05/2023 ho aggiunto <<&& !string.IsNullOrEmpty(strPermission)>> per rendere la gestione retrocompatibile con vb6.
                            // nella versione precedente la funzione TypeEnabled andava in errore quando strPermission era vuota e se DES_PosPermission era valorizzato ( ad es. a 3, come per la sezione TOTALI del doc OFFERTA )
                            // questa andava in eccezione e quindi iTypeEnabled restava valorizzato con il valore precedente. questo portava a visualizzare una sezione in vb6 lato backoffice mentre in c# no.
                            //  è ad esempio il caso dove nella stampa 'OFFERTA_PRODOTTI.asp' non portavamo a video il "VALORE DELL'OFFERTA ECONOMICA"

                            //On Error Resume Next
                            if (string.IsNullOrEmpty(CStr(rs.Fields["DES_PosPermission"]).Trim()))
                            {
                                iTypeEnabled = 1;
                            }
                            else
                            {
                                iTypeEnabled = TypeEnabled(strPermission, CInt(rs.Fields["DES_PosPermission"]));
                            }
                            //On Error GoTo eh
                        }
                        else
                        {
                            iTypeEnabled = 1;
                        }

                        if (iTypeEnabled > 0)
                        {

                            //'-- creo il nuovo controllo
                            strCause = "documento DSE_Doc_ID=[" + strDocName + "] - creo il nuovo controllo - DES_ProgID=[" + rs.Fields["DES_ProgID"] + "]";
                            string[] arrProgId = CStr(rs.Fields["DES_ProgID"]).Split(".");
                            string currentAssembly = "eProcurementNext.Core";
                            string nameSpace = "eProcurementNext.Document.";
                            Assembly asm = Assembly.Load(currentAssembly);//CtlDocument
                            string strProgId = "";
                            if (!IsNull(GetValueFromRS(rs.Fields["DES_ProgID"])))
                            {
                                strProgId = Trim(GetValueFromRS(rs.Fields["DES_ProgID"]));
                            }
                            if (asm != null)
                            {
                                Type? typeInstance = asm.GetType(nameSpace + strProgId);

                                if (typeInstance != null)
                                {

                                    ISectionDocument classInstance = Activator.CreateInstance(typeInstance, new object[] { _context, _session, _response }) as ISectionDocument;
                                    //strReturn = classInstance.Elaborate(strDocType, strDocKey, lIdPfu, strParam, ref strDescrRetCode, vParam1, cnLocal, transaction);
                                    newSec = classInstance;//CreateObject(CStr(rs.Fields("DES_ProgID")));

                                }
                                else
                                {
                                    strCause = "Impossibile creare l'istanza di " + strProgId;
                                    throw new Exception(strCause + " - FUNZIONE : Lib_dbDocument.GetDocument");//
                                }
                            }
                            else
                            {
                                strCause = "Impossibile trovare l'assembly " + nameSpace + arrProgId[0];
                                throw new Exception(strCause + " - FUNZIONE : Lib_dbDocument.GetDocument");//
                            }


                            if (newSec != null)
                            {

                                strCause = "DSE_Doc_ID=[" + strDocName + "] - toolbar=" + rs.Fields["DES_LFN_GroupFunction"];
                                //'-- carico la toolbar
                                if (!string.IsNullOrEmpty(CStr(rs.Fields["DES_LFN_GroupFunction"])))
                                {
                                    newSec.ObjToolbar = Lib_dbFunctions.GetHtmlToolbar(CStr(rs.Fields["DES_LFN_GroupFunction"]), strPermission, suffix, strConnectionString, session);
                                }
                                newSec.PosPermission = CLng(rs.Fields["DES_PosPermission"]);

                                //'-- carico eventuali propietà della sezione
                                //'-- da fare

                                //'-- carica le informazioni base della sezione
                                strCause = "DSE_Doc_ID=[" + strDocName + "] - carica le informazioni base della sezione=[" + rs.Fields["DSE_ID"] + "]";

                                if (!IsNull(rs.Fields["DSE_Param"]))
                                {
	                                newSec.param = CStr(rs.Fields["DSE_Param"]);
                                }

                                //Imposto sulla sezione il riferimento incrociato del documento
                                newSec.objDocument = objDoc;

								newSec.Init(CStr(rs.Fields["DSE_ID"]),
                                            IIF(IsNull(rs.Fields["DSE_MOD_ID"]), "", rs.Fields["DSE_MOD_ID"]),
                                            CStr(rs.Fields["DSE_DescML"]),
                                            CStr(rs.Fields["DES_Table"]),
                                            CStr(rs.Fields["DES_FieldIdDoc"]),
                                            IIF(IsNull(rs.Fields["DES_FieldIdRow"]), "", rs.Fields["DES_FieldIdRow"]),
                                            IIF(IsNull(rs.Fields["DES_TableFilter"]), "", rs.Fields["DES_TableFilter"]),
                                            IIF(IsNull(rs.Fields["DES_LFN_GroupFunction"]), "", rs.Fields["DES_LFN_GroupFunction"]),
                                            "", session);     //' -- help


                                //'-- nel caso il permesso indichi la sola lettura
                                if (iTypeEnabled == 2)
                                {
                                    strCause = "nel caso il permesso indichi la sola lettura";
                                    newSec.param = newSec.param.Replace("READONLY=", "EX_READONLY=");
                                    newSec.param += "&READONLY=YES";
                                }

                                //'-- inserisco la sezione all'interno del documento
                                strCause = "inserisco la sezione[" + newSec.Id + "] all'interno del documento[" + strDocName + "]";
                                objDoc.Sections.Add(newSec.Id, newSec);
                            }
                        }

                        rs.MoveNext();
                    }

                }

            }catch(Exception ex){

                throw new Exception(ex.Source + " - FUNZIONE : Lib_dbDocument.LoadSection() - STRCAUSE=" + strCause, ex);
    
            }
        }

        public Document.CTLDOCOBJ.Document? getDocumentFuoriSessione(string strDocName, string strPermission, string suffix, int Context, string strConnectionString)
        {

            Document.CTLDOCOBJ.Document? objNewDoc = null;

            Lib_dbFunctions objDBFun = new();
            TSRecordSet rs;
            string strCause = "";
            CommonDbFunctions cdb = new CommonDbFunctions();

            try
            {
                strCause = "carico dalla lib_documentSections le sezioni del documento DSE_Doc_ID=[" + strDocName + "]";
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@DocName", strDocName);
                rs = cdb.GetRSReadFromQuery_("select * from lib_documentSections with(nolock) where DSE_Doc_ID = @DocName order by DES_order asc", strConnectionString, null, parCollection: sqlParams);

                if (rs.RecordCount == 0)
                {
                    //rs.Close
                    strCause = "carico dalla CTL_documentSections le sezioni del documento DSE_Doc_ID=[" + strDocName + "]";
                    rs = cdb.GetRSReadFromQuery_("select * from CTL_documentSections with(nolock) where DSE_Doc_ID = @DocName order by DES_order asc", strConnectionString, null, parCollection: sqlParams);
                }

                if (rs.RecordCount > 0)
                {
                    strCause = "carica le informazioni base del documento=[" + strDocName + "]";

                    objNewDoc = new Document.CTLDOCOBJ.Document(_context, _session, _response);


                    if (!IsNull(rs.Fields["DOC_Table"]))
                    {
                        objNewDoc.strTable = CStr(rs.Fields["DOC_Table"]);
                    }
                    if (!IsNull(rs.Fields["DOC_FieldID"]))
                    {
                        objNewDoc.strFieldId = CStr(rs.Fields["DOC_FieldID"]);
                    }
                    if (!IsNull(rs.Fields["DOC_Help"]))
                    {
                        objNewDoc.strHelp = CStr(rs.Fields["DOC_Help"]);
                    }
                    if (!IsNull(rs.Fields["DOC_Param"]))
                    {
                        objNewDoc.param = CStr(rs.Fields["DOC_Param"]);
                    }

                    objNewDoc.Id = strDocName;
                    objNewDoc.ReadOnly = true;

                    //'-- carica le sezioni del documento
                    strCause = "carica le sezioni del documento=[" + strDocName + "]";
                    LoadSectionFuoriSessione(objNewDoc, objDBFun, strDocName, strPermission, suffix, Context, strConnectionString);

                }
  
                return objNewDoc;

            }
            catch(Exception ex)
            {
                throw new Exception(ex.Source + " - FUNZIONE : Lib_dbDocument.getDocumentFuoriSessione()- STRCAUSE=" + strCause, ex);
            }

        }

        //'-- carica tutte le sezioni sul documento
        private void LoadSectionFuoriSessione(Document.CTLDOCOBJ.Document? objDoc, Lib_dbFunctions objDBFun, string strDocName, string strPermission, string suffix, int Context, string strConnectionString)
        {

            Document.CTLDOCOBJ.Document? objNewDoc;
            ISectionDocument newSec;
            TSRecordSet rs;
            int iTypeEnabled;
            Session.Session sessionVuota = new Session.Session();
            Random rnd = new Random();
            sessionVuota.Init("tempSession" + rnd.Next(10) + rnd.Next(10) + rnd.Next(10) + rnd.Next(10));
            //Dictionary<int, dynamic> sessionVuota= new Dictionary<int, dynamic>();
            string strCause = "";
            CommonDbFunctions cdb = new CommonDbFunctions();

            try
            {

                sessionVuota[SessionProperty.SESSION_SUFFIX] = suffix;
                sessionVuota["ConnectionString"] = strConnectionString;
                sessionVuota[SessionProperty.SESSION_USER] = CInt(0);
                sessionVuota[SessionProperty.SESSION_PERMISSION] = "";

                //On Error GoTo eh
                strCause = "carico dalla lib_documentSections le sezioni del documento DSE_Doc_ID=[" + strDocName + "]";
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@DocName", strDocName);
                rs = cdb.GetRSReadFromQuery_("select * from lib_documentSections with(nolock) where DSE_Doc_ID = @DocName order by DES_order asc", strConnectionString, null, parCollection: sqlParams);

                if (rs.RecordCount == 0)
                {
                    //rs.Close
                    strCause = "carico dalla CTL_documentSections le sezioni del documento DSE_Doc_ID=[" + strDocName + "]";
                    rs = cdb.GetRSReadFromQuery_("select * from CTL_documentSections with(nolock) where DSE_Doc_ID = @DocName order by DES_order asc", strConnectionString, null, parCollection: sqlParams);
                }

                //'-- carico le sezioni configurate
                if (rs.RecordCount > 0)
                {

                    objDoc.Sections = new Dictionary<string, ISectionDocument>();

                    while (!rs.EOF)
                    {

                        //'-- creo il nuovo controllo
                        strCause = "documento DSE_Doc_ID=[" + strDocName + "] - creo il nuovo controllo - DES_ProgID=[" + rs.Fields["DES_ProgID"] + "]";
                        string[] arrProgId = CStr(rs.Fields["DES_ProgID"]).Split(".");
                        string nameSpace = "eProcurementNext.Document.";
                        Assembly asm = Assembly.Load(nameSpace + arrProgId[0]);//CtlDocument
                        string strProgId = "";
                        if (!IsNull(GetValueFromRS(rs.Fields["DES_ProgID"])))
                        {
                            strProgId = Trim(GetValueFromRS(rs.Fields["DES_ProgID"]));
                        }
                        if (asm != null)
                        {
                            Type? typeInstance = asm.GetType(nameSpace + strProgId);

                            if (typeInstance != null)
                            {
                                ISectionDocument classInstance = Activator.CreateInstance(typeInstance, new object[] { _context, _session, _response }) as ISectionDocument;
                                //strReturn = classInstance.Elaborate(strDocType, strDocKey, lIdPfu, strParam, ref strDescrRetCode, vParam1, cnLocal, transaction);
                                newSec = classInstance;//CreateObject(CStr(rs.Fields("DES_ProgID")));

                            }
                            else
                            {
                                strCause = "Impossibile creare l'istanza di " + strProgId;
                                throw new Exception(strCause + " - FUNZIONE : Lib_dbDocument.LoadSectionFuoriSessione");//
                            }
                        }
                        else
                        {
                            strCause = "Impossibile trovare l'assembly " + nameSpace + arrProgId[0];
                            throw new Exception(strCause + " - FUNZIONE : Lib_dbDocument.LoadSectionFuoriSessione");//
                        }

                        if (newSec != null)
                        {

                            //'-- carica le informazioni base della sezione
                            strCause = "DSE_Doc_ID=[" + strDocName + "] - carica le informazioni base della sezione=[" + rs.Fields["DSE_ID"] + "]";
                            newSec.Init(CStr(rs.Fields["DSE_ID"]),
                                        IIF(IsNull(rs.Fields["DSE_MOD_ID"]), "", rs.Fields["DSE_MOD_ID"]),
                                        CStr(rs.Fields["DSE_DescML"]),
                                        CStr(rs.Fields["DES_Table"]),
                                        CStr(rs.Fields["DES_FieldIdDoc"]),
                                        IIF(IsNull(rs.Fields["DES_FieldIdRow"]), "", rs.Fields["DES_FieldIdRow"]),
                                        IIF(IsNull(rs.Fields["DES_TableFilter"]), "", rs.Fields["DES_TableFilter"]),
                                        IIF(IsNull(rs.Fields["DES_LFN_GroupFunction"]), "", rs.Fields["DES_LFN_GroupFunction"]),
                                        "", sessionVuota);      //' -- help


                            //'-- do alla sezione il riferimento incrociato del documento
                            strCause = "do alla sezione il riferimento incrociato del documento";
                            newSec.objDocument = objDoc;

                            if (!IsNull(rs.Fields["DSE_Param"]))
                            {
                                newSec.param = CStr(rs.Fields["DSE_Param"]);
                            }

                            //'-- nel caso il permesso indichi la sola lettura
                            //if (iTypeEnabled == 2 ){
                            //    strCause = "nel caso il permesso indichi la sola lettura";
                            //    newSec.param = newSec.param.Replace("READONLY=", "EX_READONLY=");
                            //    newSec.param = newSec.param + "&READONLY=YES";

                            //}

                            //'-- inserisco la sezione all'interno del documento
                            strCause = "inserisco la sezione[" + newSec.Id + "] all'interno del documento[" + strDocName + "]";
                            objDoc.Sections.Add(newSec.Id, newSec);

                            //Set newSec = Nothing

                        }

                        rs.MoveNext();

                    }

                    //Set rs = Nothing

                }

                //Exit Sub
            }
            catch (Exception ex)
            {

                throw new Exception(ex.Source + " - FUNZIONE : Lib_dbDocument.LoadSectionFuoriSessione()- STRCAUSE=" + strCause);
                //AFLErrorControl.StoreErrWithSource err.Source & " - FUNZIONE : Lib_dbDocument.LoadSectionFuoriSessione()- STRCAUSE=" & strCause
                //On Error GoTo 0
                //AFLErrorControl.DecodeErr
            }


        }


    }
}