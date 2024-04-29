using AutoMapper;
using eProcurementNext.Application;
using eProcurementNext.Authentication;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.DashBoard;
using eProcurementNext.HTML;
using eProcurementNext.Session;
using eProcurementNext.WebAPI.Model;
using eProcurementNext.WebAPI.Utils;
using Microsoft.AspNetCore.Mvc;
using Microsoft.VisualBasic;
using MongoDB.Bson;
using MongoDB.Bson.IO;
using MongoDB.Driver;
using System.Data.SqlClient;
using System.Linq;
using System.Text.Json;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.WebAPI.Controllers
{
    [Route("api/v1/[controller]")]     //Questa route contiene il place holder [controller], così facendo la rotta risponderà al nome 'Widget'
    [ApiController]                 //mette una serie di comportamenti di default ai nostri controller. ad es. ci permette l'uso delle rotte
    public class WidgetController : TsControllerBase
    {
        private readonly ILogger<ProcessController> _logger;
        private readonly IConfiguration _configuration;
        private readonly IMapper _mapper;
        private readonly IAuthHandlerCustom _authHandler;
        private readonly eProcurementNext.Session.ISession _session;

        public static string collectionNameMongoDBWidget = "eProcNextWidget";

        public MongoClient _client;
        public IMongoDatabase _database;
        public IMongoCollection<BsonDocument> _collection;

        private readonly int idpfu;


        public WidgetController(
            ILogger<ProcessController> logger,
            IConfiguration configuration,
            IMapper mapper,
            eProcurementNext.Session.ISession session,
            IAuthHandlerCustom authHandler
            )
        {
            //Proprietà recuperate con la dependency injection
            _logger = logger;
            _configuration = configuration;
            _mapper = mapper;
            _session = session;
            _authHandler = authHandler;
            string csMongoDB = ConfigurationServices.GetKey("ConnectionStrings:MongoDbConnection")!;
            _client = new MongoClient(csMongoDB);
            _database = _client.GetDatabase(MongoUrl.Create(csMongoDB).DatabaseName);
            _collection = _database.GetCollection<BsonDocument>(collectionNameMongoDBWidget);

            try
            {
                _session.Load(_authHandler.Token!);
            }
            catch
            {
                throw new AuthorizedException();
            }

            idpfu = CInt(_session["idpfu"]);

            if (idpfu <= 0)
            {
                throw new AuthorizedException();
            }
        }

        /// <summary>
        /// Get: /api/v1/Widget
        /// </summary>
        /// <returns>List<WidgetViewModel></returns>
        [HttpGet]
        [ProducesResponseType(typeof(List<WidgetViewModel>), StatusCodes.Status200OK)]
        public async Task<IActionResult> Get()
        {
            //GET ALL WIDGETS
            List<BsonDocument> allWidgetsInColl = _collection.Find(_ => true).ToList();

            allWidgetsInColl = allWidgetsInColl.FindAll(item => item["_id"] != "idLastUpdate" );

			List<WidgetViewModel> listOfWidgets = new();

            string? permessi = _session[SessionProperty.Funzionalita] ?? throw new AuthorizedException();


            foreach (var item in allWidgetsInColl)
            {
                if (item == null) {
                    continue;
                }

                if (!item.Contains("Pos_permission") || IsEnabled(permessi, CInt(item["Pos_permission"])))
                {
                    WidgetViewModel toAdd = new();
                    toAdd.Id = item["Id"].AsInt32;
                    toAdd.Type = (WidgetViewModel.WidgetType)item["Type"].AsInt32;
                    toAdd.Code = new Guid(item["Code"].AsString);
                    toAdd.Title = item.Contains("Title") ? ApplicationCommon.CNV(CStr(item["Title"])) : "";

                    //toAdd.Params = item["Params"][1].AsBsonDocument.ToDictionary();
                    //toAdd.Pos_permission = item["Pos_permission"].AsString;
                    //toAdd.Deleted = item["Deleted"].AsString;
                    listOfWidgets.Add(toAdd);
                }
            }

            var result = new { status = "OK", result = listOfWidgets };
            return Ok(result);

        }

        /// <summary>
        /// Get: /api/v1/Widget/{Guid}
        /// </summary>
        /// <returns>List<WidgetViewModel></returns>
        [HttpGet("{guid}")]
        [ProducesResponseType(typeof(WidgetViewModel), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetSingleWidget(Guid guid)
        {
            var filter = Builders<BsonDocument>.Filter.Eq("Code", guid.ToString());
            var found = _collection.FindSync(filter).FirstOrDefault();
            var toReturn = new WidgetViewModel();

            if (found == null)
            {
                var result = new { status = "NotOK", result = "Guid not found" };
                return Ok(result);
            } else if ((found.Contains("Deleted") ? CStr(found["Deleted"]) : "") == "1") {
                var result = new { status = "NotOK", result = "Guid has been deleted" };
                return Ok(result);
            } else if (!IsEnabled(_session[SessionProperty.Funzionalita], found.Contains("Pos_permission") ? CInt(found["Pos_permission"]) : -1)) {
                var result = new { status = "NotOK", result = "User has not right permission" };
                return Ok(result);
            }
            else
            {
                toReturn.Id = found["Id"].AsInt32;
                toReturn.Type = (WidgetViewModel.WidgetType)found["Type"].AsInt32;
                toReturn.Code = guid;
                toReturn.Title = found.Contains("Title") ? ApplicationCommon.CNV(found["Title"].AsString) : "";

                Dictionary<string, object>? tempDict;
                try
                {
                    tempDict = found["Params"][1].AsBsonDocument.ToDictionary();
                }
                catch
                {
                    tempDict = new();
                }

                toReturn.Params = tempDict;
                toReturn.Pos_permission = found.Contains("Pos_permission") ? CInt(found["Pos_permission"]) : -1;
                toReturn.Deleted = found.Contains("Deleted") ? CStr(found["Deleted"]) : "";
                string stored;
                if (found.Contains("Stored") && found["Stored"] != null && found["Stored"] is not BsonNull)
                {

                    stored = found["Stored"].AsString;

                    Dictionary<string, object?> sqlP = new();
                    sqlP.Add("@idpfu", idpfu);
                    sqlP.Add("@CallerType", "WebAPI");
                    sqlP.Add("@WidgetType", toReturn.Type);
                    sqlP.Add("@Command", "init");//altri possibili parametri (reload, etc.)
                    sqlP.Add("@suffix", _session[SessionProperty.SESSION_SUFFIX]);//session suffix
                    sqlP.Add("@Context", _session["IdMP"]);//session context
                                                           //Example: exec stored 'idpfu', 'WebAPI', '0'
                    stored = $"exec {stored} @idpfu, @CallerType, @WidgetType, @Command, @suffix, @Context";
                    TSRecordSet? recordSet;
                    try
                    {
                        switch (toReturn.Type)
                        {
                            case WidgetViewModel.WidgetType.Base:
                                recordSet = new CommonDbFunctions().GetRSReadFromQuery_(stored, ApplicationCommon.Application.ConnectionString, sqlP);
                                if (recordSet != null)
                                {
                                    if (toReturn.Params.ContainsKey("body"))
                                    {
                                        toReturn.Params["body"] = CStr(recordSet["result"]);
                                    }
                                }
                                break;
                            case WidgetViewModel.WidgetType.List:
                                recordSet = new CommonDbFunctions().GetRSReadFromQuery_(stored, ApplicationCommon.Application.ConnectionString, sqlP);
                                if (recordSet != null)
                                {
                                    if (toReturn.Params.ContainsKey("body"))
                                    {
                                        List<Dictionary<string, object?>> listOfDictToStringify = new();
                                        recordSet.MoveFirst();
                                        while (!recordSet.EOF)
                                        {
                                            Dictionary<string, object?> dictToStringify = new();
                                            foreach (var item in recordSet.Columns)
                                            {
                                                var col = item.ToString();
                                                var key = col;
                                                var value = recordSet[col];
                                                dictToStringify.Add(key, value);
                                            }
                                            listOfDictToStringify.Add(dictToStringify);
                                            recordSet.MoveNext();
                                        }

                                        toReturn.Params["body"] = JsonSerializer.Serialize(listOfDictToStringify);
                                    }
                                }
                                break;
                            case WidgetViewModel.WidgetType.Chart:
                                break;
                            default:
                                break;
                        }

                    }
                    catch (Exception ex)
                    {
                        CommonDB.Basic.WriteToEventLog("Error executing stored (" + stored + ") for widget (" + toReturn != null ? toReturn.Title : "" + ") \n" + ex.ToString());
                    }

                }

                switch (toReturn.Type)
                {
                    case WidgetViewModel.WidgetType.Base:
                        toReturn.Params["title"] = toReturn.Title;
                        break;
                    case WidgetViewModel.WidgetType.List:
                        toReturn.Params["title"] = toReturn.Title;
                        break;
                    case WidgetViewModel.WidgetType.Group:
                        Lib_dbFunctions libFunc = new Lib_dbFunctions(ConfigurationServices.GetKey("ConnectionStrings:DefaultConnection"));
                        if (!found.Contains("Title"))
                        {
                            CommonDB.Basic.WriteToEventLog("Widget Group with no title specified, loading aborted, provide Title to fix");
                            break;
                        }
                        var objGroup = libFunc.LoadHtmlFunctionGroup(found["Title"].AsString, _session[SessionProperty.Funzionalita]);
                        if (toReturn.Params.ContainsKey("body"))
                        {
                            List<Dictionary<string, object?>> listOfDictToStringify = new();
                            foreach (var item in ((Group)objGroup).Rows)
                            {
                                GroupRow groupRow = (GroupRow)item;

                                Dictionary<string, object?> dictToStringify = new();
                                dictToStringify.Add("text", groupRow.Text);
                                var counter = GetParam(HtmlDecode(groupRow.ParamTarget), "counter");
                                if (counter != null && counter == "yes")
                                {
                                    dictToStringify.Add("counterInfo", $"{found["Title"].AsString}@@@{groupRow.Code}");
                                }
                                dictToStringify.Add("action", groupRow.Func);
                                listOfDictToStringify.Add(dictToStringify);
                            }

                            toReturn.Params["title"] = toReturn.Title;

                            toReturn.Params["body"] = JsonSerializer.Serialize(listOfDictToStringify);
                        }
                        break;
                    case WidgetViewModel.WidgetType.Chart:
                        break;
                    default:
                        break;
                }

                var result = new { status = "OK", result = toReturn };
                return Ok(result);

            }


        }

        /// <summary>
        /// Get: /api/v1/Widget/GroupsWidget
        /// </summary>
        /// <returns>List<WidgetViewModel></returns>
        [HttpGet("GroupsWidget")]
        [ProducesResponseType(typeof(List<LightGroup>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetGroupsWidget()
        {
            //Recupero i widget gruppi aggiunti manualmente dall'utente (con il drag&drop)
            var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, idpfu);

            BsonArray barray = new();

            var _userHistoryCollection = _database.GetCollection<BsonDocument>(UserHistoryController.collectionNameMongoDBUserHistory);

            var found = _userHistoryCollection.FindSync(filter).FirstOrDefault();
            if (found != null && found.Contains("dashboardGrups"))
            {
                barray.AddRange(found["dashboardGrups"].AsBsonArray);
            }

            List<LightGroup> listToReturn = new();
            foreach (var group in barray)
            {
                LightGroup lg = new();
                lg.subGroupList = new();

                lg.id = group["Id"].AsString;
                lg.title = group["Title"].AsString;
                foreach (var item in (BsonArray)group["subGroupList"][1]) {
                    var slg = new SubLightGroup();
                    slg.title = item["title"].AsString;
                    slg.link = item["link"].AsString;
                    lg.subGroupList.Add(slg);
                }
                listToReturn.Add(lg);
            }

            var result = new { status = "OK", result = listToReturn };
            return Ok(result);

        }

        /// <summary>
        /// Get: /api/v1/Widget/GroupRowCounter
        /// </summary>
        /// <returns>long</returns>
        [HttpGet("GroupRowCounter")]
        [ProducesResponseType(typeof(int), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetGroupRowCounter([FromQuery] string counterInfo)
        {
            //counterInfo is type mainGroup@@@subGroup
            long mp_numRec = -1;
            try
            {

                if (counterInfo != null)
                {
                    TSRecordSet? rs = new TSRecordSet();
                    Dictionary<string, object?> sqlP = new();
                    string sqlQ = string.Empty;
                    sqlP.Add("@mainGroup", counterInfo.Split("@@@")[0]);
                    sqlP.Add("@subGroup", counterInfo.Split("@@@")[1]);
                    sqlQ = "select LFN_paramTarget, LFN_PosPermission from LIB_Functions with(nolock) where LFN_GroupFunction = @mainGroup and LFN_id = @subGroup";
                    rs = new CommonDbFunctions().GetRSReadFromQuery_(sqlQ, ApplicationCommon.Application.ConnectionString, sqlP);
                    if(rs != null && !rs.EOF && IsEnabled(_session[SessionProperty.Funzionalita], CInt(rs["LFN_PosPermission"])))
                    {
                        rs.MoveFirst();
                        string pT = CStr(rs["LFN_paramTarget"]);
                        var qs = HtmlDecode(pT);
                        var hasCounterStored = !string.IsNullOrEmpty(GetParamURL(qs, "countersource"));
                        if (!hasCounterStored)
                        {
                            var mp_OWNER = GetParamURL(qs, "OWNER");
                            var mp_strTable = GetParamURL(qs, "Table");
                            var strGlobalFilter = "";
                            var mp_FilterHide = GetParamURL(qs, "FilterHide");
                            var mp_RSConnectionString = ApplicationCommon.Application.ConnectionString;
                            var mp_Top = "";
                            var strSort = "";
                            long mp_timeout = 0;
                            if (GetParamURL(qs, "TIMEOUT") != "")
                            {
                                mp_timeout = CLng(GetParamURL(qs, "TIMEOUT"));
                            }
                            var mp_strStoredSQL = GetParamURL(qs, "STORED_SQL");

                            string l_strStoredSQL;
                            l_strStoredSQL = mp_strStoredSQL;

                            //'-- nel caso la query non sia in una stored, passo il nome del modello, verr� utilizzato per limitare la select alle sole colonne utili al posto di *
                            if (mp_strStoredSQL != "yes")
                            {
                                var mp_ModGriglia = GetParamURL(qs, "ModGriglia");
                                if (string.IsNullOrEmpty(mp_ModGriglia))
                                {
                                    mp_ModGriglia = $"{mp_strTable}Griglia";
                                }
                                var mp_IDENTITY = GetParamURL(qs, "IDENTITY");

                                if (String.IsNullOrEmpty(mp_IDENTITY))
                                {
                                    mp_IDENTITY = "id";
                                }
                                l_strStoredSQL = $"MODELLO={mp_ModGriglia}&IDENTITY={mp_IDENTITY}";

                                //'--se non uso la stored recupero e aggiungo il parametro che mi dice se voglio tutte le colonne
                                //'--per gestire eccezioni o casi particolari
                                l_strStoredSQL = $"{l_strStoredSQL}&ALL_COLUMN={GetParamURL(qs, "ALL_COLUMN")}";

                                //'--aggiungo paraemtro ROWCONDITION per capire le altre colonne da aggiungere
                                l_strStoredSQL = $"{l_strStoredSQL}&ROWCONDITION={GetParamURL(qs, "ROWCONDITION")}";

                                //'--RS_PARAM  lista parametri aggiuntivi da recuperare dalla querystring e portare avanti
                                if (GetParamURL(qs, "RS_PARAM") != "")
                                {

                                    string strRs_Param;
                                    dynamic aInfo;
                                    //'Dim i As Integer

                                    strRs_Param = GetParamURL(qs, "RS_PARAM");

                                    if (strRs_Param != "")
                                    {

                                        aInfo = Strings.Split(strRs_Param, ",");

                                        for (int i = 0; i <= Information.UBound(aInfo); i++)
                                        {

                                            l_strStoredSQL = $"{l_strStoredSQL}&{aInfo[i]}={GetParamURL(qs, aInfo[i])}";

                                        }

                                    }


                                }


                            }

                            var Solo_Colonne_Usate = "";

                            DashBoardMod.GetRSGridCount(mp_OWNER, CLng(idpfu), mp_strTable, strGlobalFilter, mp_FilterHide, mp_RSConnectionString, ref mp_numRec, mp_Top, strSort, mp_timeout, l_strStoredSQL, Solo_Colonne_Usate);
                        }
                        else
                        {
                            var counterStored = GetParamURL(qs, "countersource");

                            Dictionary<string, object?> sqlParams = new();
                            sqlParams.Add("@idpfu", idpfu);
                            sqlParams.Add("@params", "?");//TODO params?

                            counterStored = $"exec {counterStored} @idpfu, @params";
                            TSRecordSet? recordSet = new CommonDbFunctions().GetRSReadFromQuery_(counterStored, ApplicationCommon.Application.ConnectionString, sqlParams);
                            if (recordSet != null)
                            {
                                mp_numRec = CInt(recordSet["result"]);
                            }
                        }

                    }


                }
            }
            catch
            {
                CommonDB.Basic.WriteToEventLog($"Error in WebAPI (/api/v1/Widget/GroupRowCounter): {counterInfo}");
                mp_numRec = -1;
			}


            var result = new { status = "OK", result = mp_numRec };
            return Ok(result);

        }

        

        /// <summary>
        /// Get: /api/v1/Widget/Refresh
        /// </summary>
        /// <returns></returns>
        [HttpGet("Refresh")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<IActionResult> GetRefresh()
        {
            try
            {
                WidgetUtils widgetUtils = new();
                widgetUtils.LoadWidgetFromJson(true);
                var result = new { status = "OK", result = "Widgets Refreshed" };
                return Ok(result);
            }
            catch(Exception ex) 
            {
                var result = new { status = "NotOK", result = ex.Message };
                return Ok(result);

            }


        }

    }
}
