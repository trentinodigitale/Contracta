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
    public class CodiceAUSAController : TsControllerBase
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

        public CodiceAUSAController(ILogger<ProcessController> logger, IConfiguration configuration, IMapper mapper, eProcurementNext.Session.ISession session, IAuthHandlerCustom authHandler)
        {
            //Proprietà recuperate con la dependency injection
            _logger = logger;
            _configuration = configuration;
            _mapper = mapper;
            _session = session;
            //_authHandler = authHandler;
            //string csMongoDB = ConfigurationServices.GetKey("ConnectionStrings:MongoDbConnection")!;
            //_client = new MongoClient(csMongoDB);
            //_database = _client.GetDatabase(MongoUrl.Create(csMongoDB).DatabaseName);
            //_collection = _database.GetCollection<BsonDocument>(collectionNameMongoDBWidget);

            //try
            //{
            //    _session.Load(_authHandler.Token!);
            //}
            //catch
            //{
            //    throw new AuthorizedException();
            //}

            //idpfu = CInt(_session["idpfu"]);

            //if (idpfu <= 0)
            //{
            //    throw new AuthorizedException();
            //}

            //if (!_session["SessionIsAuth"])
            //{
            //    throw new AuthorizedException();
            //}
        }

        [HttpGet]
        [ProducesResponseType(typeof(List<WidgetViewModel>), StatusCodes.Status200OK)]
        public async Task<IActionResult> recuperaCentroDiCosto(string cfStazioneAppaltante)
        {
            WebAPI.Utils.PDNDService ps = new Utils.PDNDService();

            string url = "https://apigw-test.anticorruzione.it/modi/rest/AUSA/v1/api/ausa/getBy";
            string  ausa = await Task.Run(() => ps.recuperaCentroDiCosto(cfStazioneAppaltante, url));
            return Ok(ausa);
        }

    }

}

