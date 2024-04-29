using AutoMapper;
using eProcurementNext.Application;
using eProcurementNext.Authentication;
using eProcurementNext.BizDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Handler;
using eProcurementNext.HTML;
using eProcurementNext.Session;
using eProcurementNext.WebAPI.Model;
using Microsoft.AspNetCore.Mvc;
using Microsoft.VisualBasic;
using MongoDB.Bson;
using MongoDB.Driver;
using System.Text.Json;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.WebAPI.Controllers
{
    [Route("api/v1/[controller]")]     //Questa route contiene il place holder [controller], così facendo la rotta risponderà al nome 'Layout'
    [ApiController]                 //mette una serie di comportamenti di default ai nostri controller. ad es. ci permette l'uso delle rotte
    public class LayoutController : TsControllerBase
    {
        private readonly ILogger<ProcessController> _logger;
        private readonly IConfiguration _configuration;
        private readonly IMapper _mapper;
        private readonly IAuthHandlerCustom _authHandler;
        private readonly ILogHandler _logHandler;
        private readonly eProcurementNext.Session.ISession _session;
        public MongoClient _client;
        public IMongoDatabase _database;

        private readonly int idpfu;


        public LayoutController(
            ILogger<ProcessController> logger,
            IConfiguration configuration,
            IMapper mapper,
            eProcurementNext.Session.ISession session,
            IAuthHandlerCustom authHandler,
            ILogHandler logHandler
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
            _logHandler = logHandler;


            //todo controlla validità (expire) token
            //se token ok refresh (DateTime!)
            //se non ok 

            //TODO attiva cleaner ogni tot tempo (tieni traccia dell'ultimo cleaning fatto)
            //asincrono

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

            if (!CBool(_session["SessionIsAuth"]))
            {
                throw new AuthorizedException();
            }
        }

        /// <summary>
        /// GET: /api/v1/Layout/Groups
        /// </summary>
        /// <param></param>
        /// <returns></returns>
        [HttpGet("Groups")]
        [ProducesResponseType(typeof(List<LightGroup>), StatusCodes.Status200OK)]
        public async Task<IActionResult> Groups()
        {
            #region calcolo Menu Groups

            Lib_dbFunctions libFunc = new Lib_dbFunctions(ConfigurationServices.GetKey("ConnectionStrings:DefaultConnection"));
            List<LightGroup> mp_objGroupsLight = libFunc.GetGroups(_session);

            #endregion

            var result = new { status = "OK", result = JsonSerializer.Serialize(mp_objGroupsLight) };
            return Ok(result);

        }

        /// <summary>
        /// GET: /api/v1/Layout/ToolbarButtons
        /// </summary>
        /// <param></param>
        /// <returns></returns>
        [HttpGet("ToolbarButtons")]
        [ProducesResponseType(typeof(List<ToolbarButtonModel>), StatusCodes.Status200OK)]
        public async Task<IActionResult> ToolbarButtons()
        {
            Toolbar tb = Lib_dbFunctions.GetHtmlToolbar("TOOLBAR_HOMELIGHT", CommonModule.Basic.CStr(_session["Funzionalita"]), CommonModule.Basic.CStr(_session["strSuffLing"]), ApplicationCommon.Application.ConnectionString, _session);
            List<ToolbarButtonModel> toolbarButtons = new();

            foreach (var btn in tb.Buttons)
            {
                var Button = btn.Value;

                var Id = $"{tb.id}_{Button.Id}";
                var OnClick = "";
                var Url = "";
                var Title = "";
                var Enabled = Button.Enabled;
                var Value = "";

                if (Button.Enabled)
                {

                    if (!String.IsNullOrEmpty(Button.OnClick))
                    {
                        OnClick = $@"Javascript:try{{ CloseAllSub( '{tb.id}' ); }}catch(e){{}};{Button.OnClick}( '{Button.paramTarget}');return false;";
                    }
                    else
                    {
                        OnClick = $@"Javascript:try{{ CloseAllSub( '{tb.id}' ); }}catch(e){{}}; ExecFunction('{Button.URL}','{Button.Target}' ,'{Button.paramTarget}');return false;";
                    }

                    if (!String.IsNullOrEmpty(Button.URL))
                    {
                        Url = $"{CommonModule.Basic.htmlEncodeValue(CommonModule.Basic.CStr(Button.URL))}";
                    }
                    else
                    {
                        Url = "#";
                    }

                }

                var nMaxLengthDesc = 40;
                //var Caption = Strings.Split(Button.Text, @"\")[levelDraw];
                var Caption = Button.Text;
                var CaptionControl = Caption;
                Value = CommonModule.Basic.CStr(CaptionControl);

                if (!String.IsNullOrEmpty(Button.Text))
                {

                    if (CaptionControl.Length > nMaxLengthDesc)
                    {
                        CaptionControl = $@"{Strings.Left(CaptionControl, nMaxLengthDesc - 3)}...";
                    }
                }


                if (!String.IsNullOrEmpty(CommonModule.Basic.CStr(Button.ToolTip)))
                {
                    Title = CommonModule.Basic.htmlEncodeValue(CommonModule.Basic.CStr(Button.ToolTip));
                }
                else
                {
                    Title = CommonModule.Basic.htmlEncodeValue(CommonModule.Basic.CStr(CaptionControl));
                }
            
                toolbarButtons.Add(new ToolbarButtonModel(Id, OnClick, Title, Url, Enabled, Value));
            }

            var result = new { status = "OK", result = toolbarButtons };
            return Ok(result);

        }

        /// <summary>
        /// POST: /api/v1/Layout/AddWidgetGroup
        /// </summary>
        /// <param name="group"></param>
        /// <returns></returns>
        /// <exception cref="Exception"></exception>
        [HttpPost("AddWidgetGroup")]
        public async Task<IActionResult> AddWidgetGroup(LightGroup lightGroup)
        {
            var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, idpfu);
            var update = Builders<BsonDocument>.Update.Set(SessionProperty.Id, idpfu);

            BsonArray barray = new();

            var _userHistoryCollection = _database.GetCollection<BsonDocument>(UserHistoryController.collectionNameMongoDBUserHistory);

            var found = _userHistoryCollection.FindSync(filter).FirstOrDefault();
            if (found != null && found.Contains("dashboardGrups"))
            {
                barray.AddRange(found["dashboardGrups"].AsBsonArray);
            }
            bool mustAdd = true;
            try
            {
                mustAdd = barray.ToList().FindIndex(item => { return item["Id"] == lightGroup.id; }) == -1;
            }
            catch
            {
                mustAdd = true;
            }
            if (mustAdd)
            {
                barray.Add(
                    new Dictionary<string, object>
                    {
                        { "Id", lightGroup.id },
                        { "Title", lightGroup.title },
                        { "subGroupList", lightGroup.subGroupList }
                    }.ToBsonDocument()
                );
            }



            update = update.Set("dashboardGrups", barray);
            var res = _userHistoryCollection.UpdateOne(filter, update);

            if (res.ModifiedCount == 0 && res.MatchedCount == 0)
            {
                var bsonDoc = new BsonDocument() {
                        { SessionProperty.Id, idpfu },
                    };

                _userHistoryCollection.InsertOne(bsonDoc);
                res = _userHistoryCollection.UpdateOne(filter, update);
            }
            if (res.ModifiedCount > 0 || res.MatchedCount > 0)
            {
                var result = new { status = "OK" };
                return Ok(result);
            }
            else
            {
                throw new Exception("cannot save");
            }

        }

        /// <summary>
        /// POST: /api/v1/Layout/DeleteWidgetGroup
        /// </summary>
        /// <param name="group"></param>
        /// <returns></returns>
        /// <exception cref="Exception"></exception>
        [HttpDelete("DeleteWidgetGroup")]
        public async Task<IActionResult> DeleteWidgetGroup(LightGroup lg)
        {
            var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, idpfu);
            var update = Builders<BsonDocument>.Update.Set(SessionProperty.Id, idpfu);

            BsonArray barray = new();

            var _userHistoryCollection = _database.GetCollection<BsonDocument>(UserHistoryController.collectionNameMongoDBUserHistory);

            var collFound = _userHistoryCollection.FindSync(filter).FirstOrDefault();
            if (collFound != null && collFound.Contains("dashboardGrups"))
            {
                barray.AddRange(collFound["dashboardGrups"].AsBsonArray);
            }
            else
            {
                var result = new { status = "NOT OK", result = "user history collection not found" };
                return Ok(result);
            }
            int indexOfFound = -1;
            try
            {
                indexOfFound = barray.ToList().FindIndex(item => { return item["Id"] == lg.id; });
            }
            catch
            {
                indexOfFound = -1;
            }
            if (indexOfFound != -1)
            {
                barray.RemoveAt(indexOfFound);
            }
            else
            {
                var result = new { status = "OK", result = "group id not found in user history collection" };
                return Ok(result);
            }

            update = update.Set("dashboardGrups", barray);
            var res = _userHistoryCollection.UpdateOne(filter, update);

            if (res.ModifiedCount == 0 && res.MatchedCount == 0)
            {
                var bsonDoc = new BsonDocument() {
                        { SessionProperty.Id, idpfu },
                    };

                _userHistoryCollection.InsertOne(bsonDoc);
                res = _userHistoryCollection.UpdateOne(filter, update);
            }
            if (res.ModifiedCount > 0 || res.MatchedCount > 0)
            {
                var result = new { status = "OK", result = $"Group {lg.id} removed from user history collection" };
                return Ok(result);
            }
            else
            {
                throw new Exception("cannot save");
            }

        }



    }
}
