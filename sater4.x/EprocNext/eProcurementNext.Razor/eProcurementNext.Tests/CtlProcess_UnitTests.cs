using DocumentFormat.OpenXml.InkML;
using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using Microsoft.Extensions.Configuration;
using Microsoft.VisualBasic;
using Microsoft.VisualBasic.FileIO;
using ParixClient;
using MongoDB.Driver.Core.Configuration;
using System.Data;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.Const;
using eProcurementNext.Core.XMLValidation;
using DocumentFormat.OpenXml;

namespace eProcurementNext.CtlProcess.Test
{
    [TestClass]
    public class ElabTest
    {
        const string ConnectionStringsKey = "ConnectionStrings";

        private IConfiguration _configuration;

        private string GetConfigPath()
        {
            string configPath = "";

            var t = Path.GetFullPath(@"..\..\", Directory.GetCurrentDirectory());
            if (Path.GetDirectoryName(t).EndsWith("x64"))
            {
                configPath = Path.GetFullPath(@"..\..\..\..\..\..\eProcurementNext.Razor\eProcurementNext.Razor", Directory.GetCurrentDirectory());
            }
            else
            {
                configPath = Path.GetFullPath(@"..\..\..\..\..\eProcurementNext.Razor\eProcurementNext.Razor", Directory.GetCurrentDirectory());
            }

            return configPath;
        }

        public ElabTest()
        {
            var configPath = GetConfigPath();
            var exists = Directory.Exists(configPath);

            _configuration = new ConfigurationBuilder()
                .SetBasePath(configPath)
                .AddJsonFile("appsettings.json", false, false)
                //.AddEnvironmentVariables()
                .Build();

            ApplicationCommon.Configuration = _configuration;
            ConfigurationServices._configuration = _configuration;
        }

        private ELAB_RET_CODE TestElaborate(string strProcessName, string strDocType, ref string strDescrRetCode, dynamic strDocKey = null, long lIdPfu = -20)
        {
            string vConnectionString = "";

            var connectionStringsCfg = _configuration.GetSection(ConnectionStringsKey);
            var kvPairs = connectionStringsCfg.AsEnumerable().ToList();

            //vConnectionString = _configuration.GetConnectionString("DefaultConnection")
            //vConnectionString = "Server=10.0.1.5;Database=AFLink_EmPULIA_New;User ID=tssuser;Password=Ge^X+W9#MhY[6DZ3;Persist Security Info=True;";  PUGLIA
            //vConnectionString = "Password=QPpEUU^Cv!5kqWV-;Persist Security Info=True;User ID=tssuser;Initial Catalog=AFLink_RL;Data Source=SV-VM-01333";  //LAZIO
            vConnectionString = "Password=QPpEUU^Cv!5kqWV-;Persist Security Info=True;User ID=tssuser;Database=AFLink_PA_Dev;Server=SV-VM-01333;Persist Security Info=True;"; //046


            if (strDocKey == null)
                strDocKey = -1;
            dynamic? vIdMp = 1;

            ClsElab elab = new ClsElab();

            return elab.Elaborate(strProcessName, strDocType, strDocKey, lIdPfu, ref strDescrRetCode, vIdMp, vConnectionString);
        }

        [TestMethod]
        public void TestExecute()
        {
            var sqlParams = new Dictionary<string, object?>();
			sqlParams.Add("@cod_operation", "prova senza errore");
			sqlParams.Add("@IdPfu", 1000);
			sqlParams.Add("@strParams", "params");
			string strSql = "INSERT INTO CTL_LOG_PROC " +
						"(DOC_NAME,PROC_NAME,id_Doc,idPfu,Parametri) VALUES " +
						"('DOCUMENT','REFRESH.ASP',@cod_operation,@IdPfu,@strParams)";

			CommonDbFunctions cdf = new();
            try
            {
                cdf.Execute(strSql, "Server=SV-VM-01483;Server=10.0.1.5;Database=AFLink_EmPULIA_New;User ID=tssuser;Password=Ge^X+W9#MhY[6DZ3;Persist Security Info=True;", parCollection: sqlParams);
            }
            catch (Exception ex)
            {
                string err = ex.ToString();
            }
        }

        [TestMethod]
        public void TestXMLValidation()
        {
            try
            {
                string basePath = Path.GetFullPath(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "..", "..", "..", "..", "eProcurementNext.Razor", "wwwroot", "eForms", "XSD", "schemas", "maindoc"));
               
                XMLValidation xMLValidation = new XMLValidation(basePath,true);

                string Xml =  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<urn:ContractNotice xmlns:cac=\"urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2\"\r\n                     xmlns:cbc=\"urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2\"\r\n                     xmlns:efac=\"http://data.europa.eu/p27/eforms-ubl-extension-aggregate-components/1\"\r\n                     xmlns:efbc=\"http://data.europa.eu/p27/eforms-ubl-extension-basic-components/1\"\r\n                     xmlns:efext=\"http://data.europa.eu/p27/eforms-ubl-extensions/1\"\r\n                     xmlns:ext=\"urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2\"\r\n                     xmlns:urn=\"urn:oasis:names:specification:ubl:schema:xsd:ContractNotice-2\">\r\n   <ext:UBLExtensions>\r\n      <ext:UBLExtension>\r\n         <ext:ExtensionContent>\r\n            <efext:EformsExtension>\r\n               <efac:NoticeSubType>\r\n                  <cbc:SubTypeCode listName=\"notice-subtype\">16</cbc:SubTypeCode>\r\n               </efac:NoticeSubType>\r\n               <efac:Organizations>\r\n                  <efac:Organization>\r\n                     <efac:Company>\r\n                        <cac:PartyIdentification>\r\n                           <cbc:ID>ORG-0001</cbc:ID>\r\n                        </cac:PartyIdentification>\r\n                        <cac:PartyName>\r\n                           <cbc:Name languageID=\"ITA\">Organizzazione name</cbc:Name>\r\n                        </cac:PartyName>\r\n                        <cac:PostalAddress>\r\n                           <cbc:CityName>Napoli</cbc:CityName>\r\n                           <cac:Country>\r\n                              <cbc:IdentificationCode listName=\"country\">ITA</cbc:IdentificationCode>\r\n                           </cac:Country>\r\n                        </cac:PostalAddress>\r\n                        <cac:PartyLegalEntity>\r\n                           <cbc:CompanyID>34534543535</cbc:CompanyID>\r\n                        </cac:PartyLegalEntity>\r\n                        <cac:Contact>\r\n                           <cbc:Telephone>2342211456</cbc:Telephone>\r\n                           <cbc:ElectronicMail>email@referente.it</cbc:ElectronicMail>\r\n                        </cac:Contact>\r\n                     </efac:Company>\r\n                  </efac:Organization>\r\n               </efac:Organizations>\r\n            </efext:EformsExtension>\r\n         </ext:ExtensionContent>\r\n      </ext:UBLExtension>\r\n   </ext:UBLExtensions>\r\n   <cbc:UBLVersionID>2.3</cbc:UBLVersionID>\r\n   <cbc:CustomizationID>eforms-sdk-1.8</cbc:CustomizationID>\r\n   <cbc:ID schemeName=\"notice-id\">bf5b362d-0764-4257-8071-fb352d45fb78</cbc:ID>\r\n   <cbc:ContractFolderID>ac8cbfb2-dcdc-4c25-861e-06ad1f79ef9e</cbc:ContractFolderID>\r\n   <cbc:IssueDate>2023-09-04Z</cbc:IssueDate>\r\n   <cbc:IssueTime>11:20:51Z</cbc:IssueTime>\r\n   <cbc:VersionID>01</cbc:VersionID>\r\n   <cbc:RegulatoryDomain>32014L0024</cbc:RegulatoryDomain>\r\n   <cbc:NoticeTypeCode listName=\"competition\">cn-standard</cbc:NoticeTypeCode>\r\n   <cbc:NoticeLanguageCode listName=\"language\">ITA</cbc:NoticeLanguageCode>\r\n   <cac:ContractingParty>\r\n      <cac:ContractingPartyType>\r\n         <cbc:PartyTypeCode listName=\"buyer-legal-type\">body-pl-cga</cbc:PartyTypeCode>\r\n      </cac:ContractingPartyType>\r\n      <cac:ContractingActivity>\r\n         <cbc:ActivityTypeCode listName=\"authority-activity\">defence</cbc:ActivityTypeCode>\r\n      </cac:ContractingActivity>\r\n      <cac:Party>\r\n         <cac:PartyIdentification>\r\n            <cbc:ID>ORG-0001</cbc:ID>\r\n         </cac:PartyIdentification>\r\n      </cac:Party>\r\n   </cac:ContractingParty>\r\n   <cac:TenderingTerms>\r\n      <cac:TendererQualificationRequest>\r\n         <cac:SpecificTendererRequirement>\r\n            <cbc:TendererRequirementTypeCode listName=\"exclusion-ground\">corruption</cbc:TendererRequirementTypeCode>\r\n            <cbc:Description languageID=\"ITA\">descrizione di corruzione</cbc:Description>\r\n         </cac:SpecificTendererRequirement>\r\n      </cac:TendererQualificationRequest>\r\n   </cac:TenderingTerms>\r\n   <cac:TenderingProcess>\r\n      <ext:UBLExtensions>\r\n         <ext:UBLExtension>\r\n            <ext:ExtensionContent>\r\n               <efext:EformsExtension>\r\n                  <efbc:ProcedureRelaunchIndicator>false</efbc:ProcedureRelaunchIndicator>\r\n               </efext:EformsExtension>\r\n            </ext:ExtensionContent>\r\n         </ext:UBLExtension>\r\n      </ext:UBLExtensions>\r\n      <cbc:ProcedureCode listName=\"procurement-procedure-type\">open</cbc:ProcedureCode>\r\n      <cac:ProcessJustification>\r\n         <cbc:ProcessReasonCode listName=\"accelerated-procedure\">false</cbc:ProcessReasonCode>\r\n      </cac:ProcessJustification>\r\n   </cac:TenderingProcess>\r\n   <cac:ProcurementProject>\r\n      <cbc:Name languagdaeID=\"ITA\">Titolo della procedura</cbc:Name>\r\n      <cbc:Description languageeID=\"ITA\">Descrizione della procedura</cbc:Description>\r\n      <cbc:ProcurementTypeCode listName=\"contract-nature\">services</cbc:ProcurementTypeCode>\r\n      <cac:MainCommodityClassification>\r\n         <cbc:ItemClassificationCode listName=\"cpv\">64110000</cbc:ItemClassificationCode>\r\n      </cac:MainCommodityClassification>\r\n   </cac:ProcurementProject>\r\n   <cac:ProcurementProjectLot>\r\n      <cbc:ID schemedaName=\"Lot\">LOT-0001</cbc:ID>\r\n      <cac:TenderingTerms>\r\n         <ext:UBLExtensions>\r\n            <ext:UBLExtension>\r\n               <ext:ExtensionContent>\r\n                  <efext:EformsExtension>\r\n                     <efac:SelectionCriteria>\r\n                        <cbc:CriterionTypeCode listName=\"selection-criterion\">tp-abil</cbc:CriterionTypeCode>\r\n                     </efac:SelectionCriteria>\r\n                     <efac:SelectionCriteria>\r\n                        <cbc:CriterionTypeCode listName=\"selection-criterion\">ef-stand</cbc:CriterionTypeCode>\r\n                     </efac:SelectionCriteria>\r\n                  </efext:EformsExtension>\r\n               </ext:ExtensionContent>\r\n            </ext:UBLExtension>\r\n         </ext:UBLExtensions>\r\n         <cbc:FundingProgramCode listName=\"eu-funded\">eu-funds</cbc:FundingProgramCode>\r\n         <cac:CallForTendersDocumentReference>\r\n            <cbc:ID>_DEFAULT_VALUE_CHANGE_ME_</cbc:ID>\r\n            <cbc:DocumentType>non-restricted-document</cbc:DocumentType>\r\n            <cac:Attachment>\r\n               <cac:ExternalReference>\r\n                  <cbc:URI>https://enotices2.preview.ted.europa.eu/</cbc:URI>\r\n               </cac:ExternalReference>\r\n            </cac:Attachment>\r\n         </cac:CallForTendersDocumentReference>\r\n         <cac:TendererQualificationRequest>\r\n            <cac:SpecificTendererRequirement>\r\n               <cbc:TendererRequirementTypeCode listName=\"reserved-procurement\">none</cbc:TendererRequirementTypeCode>\r\n            </cac:SpecificTendererRequirement>\r\n         </cac:TendererQualificationRequest>\r\n         <cac:ContractExecutionRequirement>\r\n            <cbc:ExecutionRequirementCode listName=\"reserved-execution\">no</cbc:ExecutionRequirementCode>\r\n         </cac:ContractExecutionRequirement>\r\n         <cac:ContractExecutionRequirement>\r\n            <cbc:ExecutionRequirementCode listName=\"einvoicing\">required</cbc:ExecutionRequirementCode>\r\n         </cac:ContractExecutionRequirement>\r\n         <cac:ContractExecutionRequirement>\r\n            <cbc:ExecutionRequirementCode listName=\"conditions\">performance</cbc:ExecutionRequirementCode>\r\n            <cbc:Description languageID=\"ITA\">grtgertretr</cbc:Description>\r\n         </cac:ContractExecutionRequirement>\r\n         <cac:ContractExecutionRequirement>\r\n            <cbc:ExecutionRequirementCode listName=\"ecatalog-submission\">required</cbc:ExecutionRequirementCode>\r\n         </cac:ContractExecutionRequirement>\r\n         <cac:AppealTerms>\r\n            <cac:AppealReceiverParty>\r\n               <cac:PartyIdentification>\r\n                  <cbc:ID>ORG-0001</cbc:ID>\r\n               </cac:PartyIdentification>\r\n            </cac:AppealReceiverParty>\r\n         </cac:AppealTerms>\r\n         <cac:Language>\r\n            <cbc:ID>ITA</cbc:ID>\r\n         </cac:Language>\r\n         <cac:PostAwardProcess>\r\n            <cbc:ElectronicOrderUsageIndicator>true</cbc:ElectronicOrderUsageIndicator>\r\n            <cbc:ElectronicPaymentUsageIndicator>true</cbc:ElectronicPaymentUsageIndicator>\r\n         </cac:PostAwardProcess>\r\n      </cac:TenderingTerms>\r\n      <cac:TenderingProcess>\r\n         <cbc:SubmissionMethodCode listName=\"esubmission\">required</cbc:SubmissionMethodCode>\r\n         <cbc:GovernmentAgreementConstraintIndicator>false</cbc:GovernmentAgreementConstraintIndicator>\r\n         <cac:TenderSubmissionDeadlinePeriod>\r\n            <cbc:EndDate>2023-09-29+02:00</cbc:EndDate>\r\n            <cbc:EndTime>12:00:00+02:00</cbc:EndTime>\r\n         </cac:TenderSubmissionDeadlinePeriod>\r\n         <cac:AuctionTerms>\r\n            <cbc:AuctionConstraintIndicator>false</cbc:AuctionConstraintIndicator>\r\n         </cac:AuctionTerms>\r\n         <cac:ContractingSystem>\r\n            <cbc:ContractingSystemTypeCode listName=\"framework-agreement\">none</cbc:ContractingSystemTypeCode>\r\n         </cac:ContractingSystem>\r\n         <cac:ContractingSystem>\r\n            <cbc:ContractingSystemTypeCode listName=\"dps-usage\">none</cbc:ContractingSystemTypeCode>\r\n         </cac:ContractingSystem>\r\n      </cac:TenderingProcess>\r\n      <cac:ProcurementProject>\r\n         <cbc:ID>1</cbc:ID>\r\n         <cbc:Name languageID=\"ITA\">Lotto</cbc:Name>\r\n         <cbc:Description languageID=\"ITA\">Descrizione del lotto</cbc:Description>\r\n         <cbc:ProcurementTypeCode listName=\"contract-nature\">services</cbc:ProcurementTypeCode>\r\n         <cac:MainCommodityClassification>\r\n            <cbc:ItemClassificationCode listName=\"cpv\">98111000</cbc:ItemClassificationCode>\r\n         </cac:MainCommodityClassification>\r\n      </cac:ProcurementProject>\r\n   </cac:ProcurementProjectLot>\r\n</urn:ContractNotice>\r\n";
                string Xsd = "UBL-ContractNotice-2.3.xsd";
                bool isXmlPath = false;
                bool isXsdPath = true;

                xMLValidation.ValidateXML(Xml, Xsd, isXmlPath, isXsdPath);
            }
            catch (Exception ex)
            {
                string err = ex.ToString();
            }
        }

        [TestMethod]
        public void TestRequestSimog()
        {
            ELAB_RET_CODE retCode = TestElaborate("RUN", "EXEC_PROCESS_DEFERRED", 1644683, 45094);
        }

        [TestMethod]
        public void TestTraceEventViewer()
        {
            string connection = "Password=QPpEUU^Cv!5kqWV-;Persist Security Info=True;User ID=tssuser;Initial Catalog=AFLink_RL;Data Source=SV-VM-01333";
            string source = "CTLSERVICES";
            string descrizione = "CTLSERVICES error x- ExecuteProcess(REQUEST,INTEGRATION , 3 , -20) - [] - err.description:System.Exception: Step: Invoco il connettore specifico in base all'integrazione richiesta - Creazione oggetto CtlProcess.ClsInvokeService - System.Exception: Invoco l'url del servizio remoto - Richiesta invokeUrl(http://10.147.6.82/application/INIPEC/CaricaPec.asp?ID=3&OPERATION=CaricaPec) fallita. Exception: ResponseStatusCode: NotFound - Output: <h1>Page /WebApiFramework/api/CaricaPec Not Found</h1>   - FUNZIONE : CtlProcess.ClsInvokeService.Elaborate   ---> System.Exception: Richiesta invokeUrl(http://10.147.6.82/application/INIPEC/CaricaPec.asp?ID=3&OPERATION=CaricaPec) fallita. Exception: ResponseStatusCode: NotFound - Output: <h1>Page /WebApiFramework/api/CaricaPec Not Found</h1>     ---> System.Exception: ResponseStatusCode: NotFound - Output: <h1>Page /WebApiFramework/api/CaricaPec Not Found</h1>       at eProcurementNext.CommonModule.Basic.invokeUrl(String url, Int32 timeoutMilliseconds) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\EprocNext.CommonModule\\Basic.cs:line 641     --- End of inner exception stack trace ---     at eProcurementNext.CommonModule.Basic.invokeUrl(String url, Int32 timeoutMilliseconds) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\EprocNext.CommonModule\\Basic.cs:line 641     at eProcurementNext.CtlProcess.ClsInvokeService.Elaborate(String strDocType, Object strDocKey, Int64 lIdPfu, String strParam, String& strDescrRetCode, Object vIdMp, Object connection, SqlTransaction transaction, Int32 timeout) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\eProcurementNext.Core\\CtlProcess\\Lib\\clsInvokeService.cs:line 283     --- End of inner exception stack trace ---     at eProcurementNext.CtlProcess.ClsInvokeService.Elaborate(String strDocType, Object strDocKey, Int64 lIdPfu, String strParam, String& strDescrRetCode, Object vIdMp, Object connection, SqlTransaction transaction, Int32 timeout) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\eProcurementNext.Core\\CtlProcess\\Lib\\clsInvokeService.cs:line 392     at CallSite.Target(Closure , CallSite , IProcess , String , Object , Int64 , String , String& , Object , SqlConnection , SqlTransaction , Int32 )     at eProcurementNext.CtlProcess.Basic.ExecActionsProcess(CommonDbFunctions cdf, SqlConnection& cnLocal, TSRecordSet rsActions, String strDocType, Object strDocKey, Int64 lIdPfu, String& strDescrRetCode, String& strCause, Object vParam1, Object vParam2, Int32 timeOut, SqlTransaction transaction) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\eProcurementNext.Core\\CtlProcess\\Basic.cs:line 71 - FUNZIONE : Basic.ExecActionsProcess  - FUNZIONE : CtlProcess.clsElab.Elaborate   ---> System.Exception: System.Exception: Invoco l'url del servizio remoto - Richiesta invokeUrl(http://10.147.6.82/application/INIPEC/CaricaPec.asp?ID=3&OPERATION=CaricaPec) fallita. Exception: ResponseStatusCode: NotFound - Output: <h1>Page /WebApiFramework/api/CaricaPec Not Found</h1>   - FUNZIONE : CtlProcess.ClsInvokeService.Elaborate   ---> System.Exception: Richiesta invokeUrl(http://10.147.6.82/application/INIPEC/CaricaPec.asp?ID=3&OPERATION=CaricaPec) fallita. Exception: ResponseStatusCode: NotFound - Output: <h1>Page /WebApiFramework/api/CaricaPec Not Found</h1>     ---> System.Exception: ResponseStatusCode: NotFound - Output: <h1>Page /WebApiFramework/api/CaricaPec Not Found</h1>       at eProcurementNext.CommonModule.Basic.invokeUrl(String url, Int32 timeoutMilliseconds) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\EprocNext.CommonModule\\Basic.cs:line 641     --- End of inner exception stack trace ---     at eProcurementNext.CommonModule.Basic.invokeUrl(String url, Int32 timeoutMilliseconds) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\EprocNext.CommonModule\\Basic.cs:line 641     at eProcurementNext.CtlProcess.ClsInvokeService.Elaborate(String strDocType, Object strDocKey, Int64 lIdPfu, String strParam, String& strDescrRetCode, Object vIdMp, Object connection, SqlTransaction transaction, Int32 timeout) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\eProcurementNext.Core\\CtlProcess\\Lib\\clsInvokeService.cs:line 283     --- End of inner exception stack trace ---     at eProcurementNext.CtlProcess.ClsInvokeService.Elaborate(String strDocType, Object strDocKey, Int64 lIdPfu, String strParam, String& strDescrRetCode, Object vIdMp, Object connection, SqlTransaction transaction, Int32 timeout) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\eProcurementNext.Core\\CtlProcess\\Lib\\clsInvokeService.cs:line 392     at CallSite.Target(Closure , CallSite , IProcess , String , Object , Int64 , String , String& , Object , SqlConnection , SqlTransaction , Int32 )     at eProcurementNext.CtlProcess.Basic.ExecActionsProcess(CommonDbFunctions cdf, SqlConnection& cnLocal, TSRecordSet rsActions, String strDocType, Object strDocKey, Int64 lIdPfu, String& strDescrRetCode, String& strCause, Object vParam1, Object vParam2, Int32 timeOut, SqlTransaction transaction) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\eProcurementNext.Core\\CtlProcess\\Basic.cs:line 71 - FUNZIONE : Basic.ExecActionsProcess   ---> System.Exception: Invoco l'url del servizio remoto - Richiesta invokeUrl(http://10.147.6.82/application/INIPEC/CaricaPec.asp?ID=3&OPERATION=CaricaPec) fallita. Exception: ResponseStatusCode: NotFound - Output: <h1>Page /WebApiFramework/api/CaricaPec Not Found</h1>   - FUNZIONE : CtlProcess.ClsInvokeService.Elaborate   ---> System.Exception: Richiesta invokeUrl(http://10.147.6.82/application/INIPEC/CaricaPec.asp?ID=3&OPERATION=CaricaPec) fallita. Exception: ResponseStatusCode: NotFound - Output: <h1>Page /WebApiFramework/api/CaricaPec Not Found</h1>     ---> System.Exception: ResponseStatusCode: NotFound - Output: <h1>Page /WebApiFramework/api/CaricaPec Not Found</h1>       at eProcurementNext.CommonModule.Basic.invokeUrl(String url, Int32 timeoutMilliseconds) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\EprocNext.CommonModule\\Basic.cs:line 641     --- End of inner exception stack trace ---     at eProcurementNext.CommonModule.Basic.invokeUrl(String url, Int32 timeoutMilliseconds) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\EprocNext.CommonModule\\Basic.cs:line 641     at eProcurementNext.CtlProcess.ClsInvokeService.Elaborate(String strDocType, Object strDocKey, Int64 lIdPfu, String strParam, String& strDescrRetCode, Object vIdMp, Object connection, SqlTransaction transaction, Int32 timeout) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\eProcurementNext.Core\\CtlProcess\\Lib\\clsInvokeService.cs:line 283     --- End of inner exception stack trace ---     at eProcurementNext.CtlProcess.ClsInvokeService.Elaborate(String strDocType, Object strDocKey, Int64 lIdPfu, String strParam, String& strDescrRetCode, Object vIdMp, Object connection, SqlTransaction transaction, Int32 timeout) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\eProcurementNext.Core\\CtlProcess\\Lib\\clsInvokeService.cs:line 392     at CallSite.Target(Closure , CallSite , IProcess , String , Object , Int64 , String , String& , Object , SqlConnection , SqlTransaction , Int32 )     at eProcurementNext.CtlProcess.Basic.ExecActionsProcess(CommonDbFunctions cdf, SqlConnection& cnLocal, TSRecordSet rsActions, String strDocType, Object strDocKey, Int64 lIdPfu, String& strDescrRetCode, String& strCause, Object vParam1, Object vParam2, Int32 timeOut, SqlTransaction transaction) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\eProcurementNext.Core\\CtlProcess\\Basic.cs:line 71     --- End of inner exception stack trace ---     at eProcurementNext.CtlProcess.Basic.ExecActionsProcess(CommonDbFunctions cdf, SqlConnection& cnLocal, TSRecordSet rsActions, String strDocType, Object strDocKey, Int64 lIdPfu, String& strDescrRetCode, String& strCause, Object vParam1, Object vParam2, Int32 timeOut, SqlTransaction transaction) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\eProcurementNext.Core\\CtlProcess\\Basic.cs:line 150     at CallSite.Target(Closure , CallSite , Type , CommonDbFunctions , SqlConnection& , TSRecordSet , String , Object , Int64 , String& , String& , Object , Object , Int32 , SqlTransaction )     at eProcurementNext.CtlProcess.ClsElab.Elaborate(String strProcessName, String strDocType, Object strDocKey, Int64 lIdPfu, String& strDescrRetCode, Object vIdMp, Object vConnectionString, Int32 timeout) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\eProcurementNext.Core\\CtlProcess\\Lib\\clsElab.cs:line 212     --- End of inner exception stack trace ---     at eProcurementNext.CtlProcess.ClsElab.Elaborate(String strProcessName, String strDocType, Object strDocKey, Int64 lIdPfu, String& strDescrRetCode, Object vIdMp, Object vConnectionString, Int32 timeout) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\eProcurementNext.Core\\CtlProcess\\Lib\\clsElab.cs:line 212     at CallSite.Target(Closure , CallSite , ClsElab , String , String , Object , Object , String& , Int32 , String )     at eProcurementNext.Services.Service.ExecuteProcess_new(String strProcessName, String strDocType, String strSql, String strConnectionString, Dictionary`2 params_, SqlConnection connection) in C:\\Users\\f.dangelo\\OneDrive - TeamSystem S.p.A\\FILE_LAVORO_TS\\SORGENTI_VISUAL\\E_PROC_NEXT\\eProcurementNext.Razor\\EprocNext.Services\\Service.cs:line 698";
            var dbEV = new DbEventViewer();
            dbEV.traceEventInDBConnString(0, source, descrizione, connection);
        }

        [TestMethod]
        public void TestGetRs()
        {
            const int MAX_LENGTH_ip = 97;
            const int MAX_LENGTH_paginaAttaccata = 294;
            const int MAX_LENGTH_motivoBlocco = 3994;

            CommonDbFunctions cdf = new();
            try
            {
                string strConnectionString = "Password=QPpEUU^Cv!5kqWV-;Persist Security Info=True;User ID=tssuser;Initial Catalog=AFLink_RL;Data Source=SV-VM-01333";
                string blocco = new string('x', 60000);

                var sqlParams = new Dictionary<string, object?>()
                {
                    { "@ip", TruncateMessage(blocco, MAX_LENGTH_ip)},
                    {"@paginaAttaccata", TruncateMessage(blocco, MAX_LENGTH_paginaAttaccata)},
                    {"@queryString", blocco},
                    {"@idpfu", -20},
                    { "@motivoBlocco",  TruncateMessage(blocco, MAX_LENGTH_motivoBlocco)}
                };
                string strsql = "INSERT INTO [CTL_blacklist] ([ip],[statoBlocco],[dataBlocco],[dataRefresh],[numeroRefresh],[paginaAttaccata],[queryString],[idPfu],[form],[motivoBlocco])";
                strsql = strsql + " VALUES (@ip, 'log-attack', getdate(), null, 0, @paginaAttaccata, @queryString, @idpfu, null, @motivoBlocco)";

                cdf.Execute(strsql, strConnectionString, parCollection: sqlParams);

                //TSRecordSet rs = cdf.GetRSReadFromQuery_("exec CHAT_ROOM_ADD_MSG 1,1, '11:01'", "Server=SV-VM-01483;Database=AFLink_PA_Dev;User ID=spaterno;Password=eProc9Manag!;Persist Security Info=True;");
                //TSRecordSet rs = cdf.GetRSReadFromQuery_("select PunteggioTEC_100 from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO where idlotto = 5362", "Server=SV-VM-01483;Database=AFLink_PA_Dev;User ID=spaterno;Password=eProc9Manag!;Persist Security Info=True;");
                //rs = cdf.GetRSReadFromQuery_("Declare @blocco int; Exec SP_CAN_INSERT_CLASSI_BANDO 99, 'pippo', @blocco output, 1", "Server=SV-VM-01483;Database=AFLink_PA_Dev;User ID=spaterno;Password=eProc9Manag!;Persist Security Info=True;");

                //bool pippo;
                //if (rs.RecordCount > 0)
                //{
                //    if (GetValueFromRS(rs["PunteggioTEC_100"]) != 0)
                //    {
                //        pippo = true;
                //    }
                //}
            }
            catch (Exception ex)
            {
                string mess = ex.ToString();
            }
        }

        private ELAB_RET_CODE TestElaborate(string strProcessName, string strDocType, dynamic? strDocKey = null, long lIdPfu = -20)
        {
            string strDescrRetCode = "";
            return TestElaborate(strProcessName, strDocType, ref strDescrRetCode, strDocKey, lIdPfu);
        }

		[TestMethod]
		public void Elaborate_UtenteCancellato()
		{
			string strDescrRetCode = "";

			ELAB_RET_CODE retCode = TestElaborate("RUN", "EXEC_PROCESS_DEFERRED", 1644683, 45094);
			Assert.IsTrue(string.IsNullOrEmpty(strDescrRetCode));
		}

		[TestMethod]
		public void TestEliminaZip()
		{
			string strDescrRetCode = "";

			ELAB_RET_CODE retCode = TestElaborate("ELIMINA_ZIP", "FASCICOLO_GARA", 476344, 1);
			Assert.IsTrue(string.IsNullOrEmpty(strDescrRetCode));
		}

		[TestMethod]
        public void Elaborate_clsSetValue()
        {
            TestElaborate("clsSetValue", "REFACTORING_UNITTEST");
        }

        [TestMethod]
        public void Elaborate_clsCheckAndUpd()
        {
            string strDescrRetCode = "";
            //TestElaborate(strProcessName, strDocType, ref strDescrRetCode);
            //Assert.IsNotNull(strDescrRetCode);

            ELAB_RET_CODE retCode = TestElaborate("clsCheckAndUpd", "REFACTORING_UNITTEST", ref strDescrRetCode);
            Assert.IsTrue(string.IsNullOrEmpty(strDescrRetCode));

            retCode = TestElaborate("clsCheckAndUpd_condfalse", "REFACTORING_UNITTEST", ref strDescrRetCode);
            Assert.IsTrue(!string.IsNullOrEmpty(strDescrRetCode));
        }
        
        [TestMethod]
        public void ProseguiListaAttivita()
        {
            string strDescrRetCode = string.Empty;
            ELAB_RET_CODE retCode = TestElaborate("PROSEGUI", "LISTA_ATTIVITA", ref strDescrRetCode, 1, 45406);
        }

        [TestMethod]
        public void Elaborate_clsSubProcess()
        {
            string strDescrRetCode = "";
            //ELAB_RET_CODE retCode = TestElaborate("clsSubProcess", "REFACTORING_UNITTEST", ref strDescrRetCode)
            //TestElaborate("RUN", "ELABORAZIONI_SCHEDULATE", 88303, 45406);
            TestElaborate("TESTSALVO", "ANAG_DOCUMENTAZIONE", 71278, 42727); 
        }

        [TestMethod]
        public void TestSendMailLevelUp()
        {
            TestElaborate("SEND_MAIL_LEVEL_UP", "REFACTORING", 423271);
        }

        [TestMethod]
        public void TestSendPec()
        {
            TestElaborate("SEND_MAIL_PEC", "REFACTORING", 423309);
        }
        [TestMethod]
        public void TestSendMail()
        {
            TestElaborate("EMAIL", "TEST_SYS", 88068);
        }

        [TestMethod]
        public void TestCTLMailsystem()
        {
            TestElaborate("RUN", "CTLMAILSYSTEM", 3612);
        }

        [TestMethod]
        public void TEST_FASCICOLO_GARA()
        {
            TestElaborate("ELABORAZIONE", "FASCICOLO_GARA", 87536, 45406);
        }

        [TestMethod]
        public void TEST_ELIMINA_ZIP()
        {
            TestElaborate("ELIMINA_ZIP", "FASCICOLO_GARA", 88197, 1);
        }

        [TestMethod]
        public void TEST_DECIFRA_FILE()
        {
            TestElaborate("RUN", "EXEC_PROCESS_DEFERRED", 2821128, 71520);
        }

        //[TestMethod]
        //public void Elaborate_clsSetValue_()
        //{

        //    TestElaborate("XX", "XX");
        //}

        //[TestMethod]
        //public void _Elaborate_clsSetValue()
        //{
        //    TestElaborate("XX", "XX");
        //}

        //[TestMethod]
        //public void Elaborate_ServizieProcessi()
        //{
        //    TestElaborate("TEST_PROCESS_1", "REFACTORING");
        //}

        //[TestMethod]
        //public void Elaborate_clsSubProcess()
        //{
        //    TestElaborate("TEST_PROCESS_1", "REFACTORING");
        //}

        [TestMethod]
        public void Elaborate_clsDownloader()
        {
            TestElaborate("TEST_CLS_DOWNLOADER", "REFACTORING");
        }

        [TestMethod]
        public void Elaborate_clsGetProtocol()
        {
            TestElaborate("TEST_PROTOCOL", "NUOVA_CONVENZIONE", 42591);
        }

        //[TestMethod]
        //public async Task TestURLDownloadToFileAsync()
        //{
        //    await Basic.DownloadFileFromWebAsync(@"http://files.customersaas.com/files/34NQcSAEa9X8glBfsI9Z9XYk.pdf", @"E:\Downloads\Samsung.pdf");
        //}

        [TestMethod]
        public void TestSemaphore()
        {
            ClsSemaphore semaforo = new ClsSemaphore();
            semaforo.Dispose();
            //semaforo = null;
        }

        [TestMethod]
        public void TestTime()
        {
            string time = Convert.ToDateTime(DateTime.Now).ToString("yyyyMMddhhmmss");
        }

        [TestMethod]
        public void TestWriteFile()
        {
            CommonStorage.Write(@"E:\PortaleGareTelematiche\Allegati\pippo.txt", "ERRORE 2040!");
        }

        [TestMethod]
        public void UpdateTest2()
        {
            var connectionStringsCfg = _configuration.GetSection(ConnectionStringsKey);
            var kvPairs = connectionStringsCfg.AsEnumerable().ToList();

            string vConnectionString = _configuration.GetConnectionString("DefaultConnection");

            TSRecordSet rs = new TSRecordSet();

            var cdf = new CommonDbFunctions();
            var strSql = "select * from _Test WHERE id=1"; // 


            rs = rs.Open(strSql, vConnectionString); // cdf.GetRSReadFromQuery_(strSql, vConnectionString);

            //if (rs.RecordCount > 0)
            //{
            //    rs.Fields["id"] = 1;
            //    rs.Fields["Testo"] = "Pippo4";
            //    rs.Fields["Numero"] = 61;
            //    rs.Update(rs.Fields, "id", "_Test2");
            //}

            System.Data.DataRow dr = rs.AddNew();
            dr["Testo"] = "Nuovo Testo";
            dr["Numero"] = 92;
            rs.Update(dr, "id", "_Test2");
        }

        [TestMethod]
        public void TestParse()
        {
            try
            {
                string[] reqCookiesUser = "1,2,3,".Split(",");
                reqCookiesUser = reqCookiesUser.Except(new string[] { string.Empty }).ToArray();
                int[] intidpfu = Array.ConvertAll(reqCookiesUser, int.Parse);
            }
            catch (Exception ex)
            {
                string e = ex.ToString();
            }
        }

        [TestMethod]
        public void TestStringInterpolation()
        {
            string pippo = "io sono pippo";
            int nr = 99;
            string sign_lock = "L'Aquila";
            pippo = $"{pippo} {nr} volte su {++nr} e vengo da {sign_lock.Replace("'", "''")}";

            string strSql = $"declare @KeyCrypt varchar(200){Environment.NewLine}";
            strSql = $"{strSql}declare @KeyName varchar(200){Environment.NewLine}";
            strSql = $"{strSql}declare @SQLCrypt varchar(max){Environment.NewLine}";
            strSql = $"{strSql}declare @ID_DOC int{Environment.NewLine}";
            strSql = $"{strSql}declare @id int{Environment.NewLine}";
        }

        [TestMethod]
        public void TestGetTempName()
        {
            string filename = $"{Path.GetTempFileName()}";
            string file = Path.ChangeExtension(CStr(ApplicationCommon.Application["PathFolderAllegati"]) + CommonStorage.GetTempName(), ".xlsx");
            var stream = System.IO.File.Create(file);
        }
        
        [TestMethod]
        public void TestInstr()
        {
            DateTime start;
            TimeSpan time;
            start = DateTime.Now;
            string pippo = "0123 456 789PUprtpretdjgklvxcmvxcvxvj kkjsgdgfkjkjnjxmnv0000006y0g0gf9gg9g9g9dfg09gf0g09fd9g0fg90fg90f9g0fg90f9g0f90g90fg90df9g0dgfbnjgvkjekfdfcvvg89vhjukjdvoiwe90vghxdklvbhnjvkjxdvjhdjklhbgxklbnxbklxklbklhjsklghsklklsdgkldsgkjdsklgkljgkljskljsgkljskljgklskljgsdklgkjskgsdkjgkjsdgkjskjgklsdgklsgklsgkjsINDEXkvkfxvxklcvkxcklvxcvj";
            string find = "INDEX";
            int pluto = InStrVb6(1, pippo, find);
            time = DateTime.Now - start; 

            string diff = String.Format("{0}.{1}", time.Seconds, time.Milliseconds.ToString().PadLeft(3, '0'));

            byte p = 1;
            //int pluto = CInt(pippo);
        }

        [TestMethod]
        public void TestInstrVB6()
        {
            string timestamp = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss.fff", CultureInfo.InvariantCulture);
            string pippo = "0123 456 789Poprtpretdjgklvxcmvxcvxvj kkjsgdgfkjkjnjxmnv0000006y0g0gf9gg9g9g9dfg09gf0g09fd9g0fg90fg90f9g0fg90f9g0f90g90fg90df9g0dgfbnjgvkjekfdfcvvg89vhjukjdvoiwe90vghxdklvbhnjvkjxdvjhdjklhbgxklbnxbklxklbklhjsklghsklklsdgkldsgkjdsklgkljgkljskljsgkljskljgklskljgsdklgkjskgsdkjgkjsdgkjskjgklsdgklsgklsgkjsINDEXkvkfxvxklcvkxcklvxcvj";
            string find = "INDEX";
            int pluto = InStrVb6(1, pippo, find);
            string timestamp2 = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss.fff", CultureInfo.InvariantCulture);

            string diff = $"{timestamp} - {timestamp2}";

            byte p = 1;
            //int pluto = CInt(pippo);
        }

        [TestMethod]
        public void TestLeft()
        {
            string? pippo = null;
            pippo = Replace(pippo, "#0", "");


            string str = new string('e', 70000);
            //string pluto = pippo.ToLower();

            string  pluto = str.Substring(40000, 29000);
        }

        [TestMethod]
        public void TestCast()
        {
            float a = 320.88F;

            dynamic? str = null;

            string strSql = "?<ID_DOC>=123";
            strSql = Replace(strSql, "<ID_DOC>", str);

            double b = 10;
            int c = 85351;
            string d = CStr(c);
            long l = 1000;

            if (c == l)
            {
                d = "uguale";
            }
            else
            {
                d = "diverso";
            }

            b = b + a;

            long pippo = 10;
            int pluto = (int)pippo;

            string? cf = null;
            string cf2 = CStr(cf);

            //int b = CInt("");

            string paperino = "15,05245";
            double paperone = CDbl(paperino);

            paperino = "15.05245";
            paperone = CDbl(paperino);
        }

        [TestMethod]
        public bool TestDynamic()
        {
            bool uguale = false;

            string pippo = "pippo";
            dynamic pluto = "pippo";

            string strSql = "?<ID_DOC>=123";
            strSql = Replace(strSql, "<ID_DOC>", pluto);

            if (pippo == pluto)
            { 
                uguale = true;
			}

			return uguale;
        }

        [TestMethod]
        public void TestDBProfiler()
        {
            CommonDbFunctions cdf = new();
            DbProfiler dbProfiler = new(ApplicationCommon.Configuration);
            dbProfiler.startProfiler();
            try
            {
                TSRecordSet rs = cdf.GetRSReadFromQuery_("select * from Lib_DocumentProcess", "Server=SV-VM-01483;Database=AFLink_PA_Dev;User ID=spaterno;Password=eProc9Manag!;Persist Security Info=True;");
            }
            catch { }
            dbProfiler.endProfiler();
            dbProfiler.traceDbProfiler("pippo", "Server=SV-VM-01483;Database=AFLink_PA_Dev;User ID=spaterno;Password=eProc9Manag!;Persist Security Info=True;");

            dbProfiler.startProfiler();
            try
            {
                TSRecordSet rs = cdf.GetRSReadFromQuery_("select 1", "Server=SV-VM-01483;Database=AFLink_PA_Dev;User ID=spaterno;Password=eProc9Manag!;Persist Security Info=True;");
            }
            catch { }

            dbProfiler.endProfiler();
            dbProfiler.traceDbProfiler("pippo", "Server=SV-VM-01483;Database=AFLink_PA_Dev;User ID=spaterno;Password=eProc9Manag!;Persist Security Info=True;");
        }

        [TestMethod]
        public void TestStringBuilder()
        {
            //string? strNull = null;
            //var response = new StringBuilder();
            //response.Append(strNull);
            //string pippo = response.ToString();

            dynamic zField;
            double dField = 1455.554;
            zField = dField;
            if (CStr(0.5).Contains(","))
            {
                //zField = zField.Replace(".", ",");
                zField = Replace(CStr(zField), ".", ",");

                zField = Strings.FormatNumber(CDbl(zField), 2);
            }
        }
        [TestMethod]
        public void TestBasicCast()
        {
            float floatField = 509.46915F;
            double doubleField = 0;

            doubleField = CDbl(floatField);



            int totLotti = 30;
            int r = CInt(100 - CLng(100 / totLotti * CLng(totLotti - CInt("55"))));

            int a = 700;
            long b = 1000;
            double c = 125.4585;
            string d = "846";

            a = CIntTest(b);
            a = CIntTest(c);
            a = CIntTest(d);
            b = CLngTest(a);
            b = CLngTest(c);
            b = CLngTest(d);
            c = CDblTest(a);
            c = CDblTest(b);
            c = CDblTest(d);
            d = CStrTest(a);
            d = CStrTest(b);
            d = CStrTest(c);
        }


        [TestMethod]
        public static int CIntTest(dynamic str)
        {
            try
            {
                switch (str)
                {
                    case null:
                        return 0;
                    //Se è già del tipo utile all'output facciamo subito una return
                    case int:
                        return str;
                    case string when !string.IsNullOrEmpty(str):
                        return Convert.ToInt32(str);
                    case string:
                        return 0;
                    default:
                        try
                        {
                            return Convert.ToInt32(str);
                        }
                        catch
                        {
                            return 0;
                        }
                        break;
                }
            }
            catch
            {
                return 0;
            }
        }

        [TestMethod]
        public static string CStrTest(dynamic? str)
        {
            try
            {
                return str switch
                {
                    null => string.Empty,
                    string => str,
                    _ => Convert.ToString(str)
                };
            }
            catch
            {
                try
                {
                    return str is not null ? (string)str.ToString() : string.Empty;
                }
                catch
                {
                    return string.Empty;
                }
            }
        }

        [TestMethod]
        public static double CDblTest(dynamic? str)
        {
            switch (str)
            {
                case null:
                    return 0;
                //Se è già del tipo utile all'output facciamo subito una return
                case double:
                    return str;
                //Se la variabile di input è un int la scaliamo immediatamente ad Int64, non serve fare convert particolari
                case int:
                case long:
                    return (double)str;
                default:
                    try
                    {
                        return Convert.ToDouble(str);
                    }
                    catch
                    {
                        return 0;
                    }
                    break;
            }
        }
        [TestMethod]
        public static Int64 CLngTest(dynamic str)
        {
            switch (str)
            {
                case null:
                    return 0;
                //Se è già del tipo utile all'output facciamo subito una return
                case long:
                    return str;
                //Se la variabile di input è un int la scaliamo immediatamente ad Int64, non serve fare convert particolari
                case int:
                    return (Int64)str;
                case string when !string.IsNullOrEmpty(str):
                    return Convert.ToInt64(str);
                case string:
                    return 0;
                default:
                    try
                    {
                        return Convert.ToInt64(str);
                    }
                    catch
                    {
                        return 0;
                    }
                    break;
            }
        }

            [TestMethod]
        public static bool IsEmptyTest(dynamic value)
        {
            switch (value)
            {
                case null:
                case string when string.IsNullOrEmpty(value):
                    return true;
                default:
                    return false;
            }
        }

        [TestMethod]
        public void TestHashWithoutNumbers()
        {
            string hash = HashWithoutNumbers("oggi è giorno 23/07/ 2023 e il costo è 120€");
        }

        private string HashWithoutNumbers(string hash)
        {
            Regex regex = new Regex(@"\d+");
            string ret = regex.Replace(CStr(hash), "");
            return ret;
        }

        [TestMethod]
        public void TestTransazione()
        {
            CommonDbFunctions cdf = new CommonDbFunctions();
            int iCount = 0;

            var connectionStringsCfg = _configuration.GetSection(ConnectionStringsKey);
            var kvPairs = connectionStringsCfg.AsEnumerable().ToList();

            string vConnectionString = _configuration.GetConnectionString("DefaultConnection");

            System.Data.SqlClient.SqlConnection cnLocal = cdf.SetConnection(vConnectionString);
            cnLocal.Open();

            try
            {
                var sqlParams = new Dictionary<string, object?>();
                string[] reqCookiesUser = "2380, 2384, 2392".Split(","); // recupero un array di stringhe per quanti sono gli idpfu contenuti nel cookie
                int[] intidpfu = Array.ConvertAll(reqCookiesUser, int.Parse); // valorizzo un array di int contenente tutti gli idpfu contenuti in reqCookiesUser
                string[] paramNames = new string[intidpfu.Length]; // predispongo un array di stringhe che conterrà il nome dei parametri
                for (int x = 0; x < reqCookiesUser.Length; x++) // ciclo per valorizzare i parametri e prepara la stringa da inserire nella clausola IN
                {
                    string par = $"@param{x}";
                    paramNames[x] = par;
                    sqlParams.Add(par, intidpfu[x]);
                }
                string strJoin = string.Join(", ", paramNames); // concateno tutti i nomi dei parametri
                string strSql = $"select * from lib_dictionary with (nolock) where id in ({strJoin})";
                // QUERY SENZA TRANSAZIONE
                TSRecordSet rs = cdf.GetRSReadFromQuery_(strSql, vConnectionString, cnLocal, parCollection: sqlParams);
                iCount = rs.RecordCount;
            }
            catch { }

            //APERTURA TRANSAZIONE
            System.Data.SqlClient.SqlTransaction trans = cnLocal.BeginTransaction(System.Data.IsolationLevel.ReadCommitted);

            try
            {
                // QUERY SENZA TRANSAZIONE
                TSRecordSet? rs = cdf.GetRSReadFromQuery_("select dzt_valuedef from lib_dictionary with (nolock) where dzt_name = 'SYS_SERVIZIO'", vConnectionString, cnLocal);
                iCount = rs.RecordCount;
            }
            catch { }
            try
            {
                // QUERY CON TRANSAZIONE
                TSRecordSet? rs = cdf.GetRSReadFromQueryWithTransaction("select dzt_valuedef from lib_dictionary with (nolock) where dzt_name = 'SYS_SERVIZIO'", vConnectionString, cnLocal, trans);
                iCount = rs.RecordCount;
            }
            catch { }
        }
    }
}