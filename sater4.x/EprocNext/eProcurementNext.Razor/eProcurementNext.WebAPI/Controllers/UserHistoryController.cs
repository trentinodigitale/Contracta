using AutoMapper;
using eProcurementNext.Application;
using eProcurementNext.Authentication;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Session;
using eProcurementNext.WebAPI.Model;
using Microsoft.AspNetCore.Mvc;
using MongoDB.Bson;
using MongoDB.Driver;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.WebAPI.Controllers
{
    [Route("api/v1/[controller]")]     //Questa route contiene il place holder [controller], così facendo la rotta risponderà al nome 'UserHistory'
    [ApiController]                 //mette una serie di comportamenti di default ai nostri controller. ad es. ci permette l'uso delle rotte
    public class UserHistoryController : TsControllerBase
    {
        private readonly ILogger<ProcessController> _logger;
        private readonly IConfiguration _configuration;
        private readonly IMapper _mapper;
        private readonly IAuthHandlerCustom _authHandler;
        private readonly eProcurementNext.Session.ISession _session;

        public static string collectionNameMongoDBUserHistory = "eProcNextUserHistory";

        public MongoClient _client;
        public IMongoDatabase _database;
        public IMongoCollection<BsonDocument> _collection;

        private readonly int idpfu;


        public UserHistoryController(
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
            string csMongoDB = ConfigurationServices.GetKey("ConnectionStrings:MongoDbConnection");
            _client = new MongoClient(csMongoDB);
            _database = _client.GetDatabase(MongoUrl.Create(csMongoDB).DatabaseName);
            _collection = _database.GetCollection<BsonDocument>(collectionNameMongoDBUserHistory);

            try
            {
                _session.Load(_authHandler.Token);
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

            if (!_session["SessionIsAuth"])
            {
                throw new AuthorizedException();
            }
        }

        /// <summary>
        /// POST: /api/v1/UserHistory/Add
        /// </summary>
        /// <param name="userHistory"></param>
        /// <returns></returns>
        /// <exception cref="Exception"></exception>
        [HttpPost("Add")]
        public async Task<IActionResult> Add(UserHistoryModel userHistory)
        {
            var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, idpfu);
            var update = Builders<BsonDocument>.Update.Set(SessionProperty.Id, idpfu);

            BsonArray barray = new();

            var found = _collection.FindSync(filter).FirstOrDefault();
            if (found != null && found.Contains("links"))
            {
                barray.AddRange(found["links"].AsBsonArray);
            }

            bool recordAlreadyAdded = false;
            string? newId = null;
            string? oldId = null;
             
            foreach (BsonValue? item in barray)
            {
                if (
                    userHistory.Link == item["Link"].AsString &&
                    userHistory.Title == item["Title"].AsString &&
                    userHistory.Breadcrumb == item["Breadcrumb"].AsString
                )
                {
                    recordAlreadyAdded = true;
                    newId = DateTime.Now.ToString("yyMMddHHmmssff");
                    oldId = item["Id"].AsString;
					item["Id"] = newId;
                    item["Date"] = DateTime.Now.ToString("G");
                    break;
                }
            }

			if (!recordAlreadyAdded)
			{
				barray.Add(
					new Dictionary<string, object>
					{
						{ "Id", DateTime.Now.ToString("yyMMddHHmmssff") },
						{ "Link", userHistory.Link },
						{ "Title", userHistory.Title },
						{ "Breadcrumb", userHistory.Breadcrumb },
						{ "Date", DateTime.Now.ToString("G") },
						{ "IsFavorite", userHistory.IsFavorite }
					}.ToBsonDocument()
				);
            }
            else
            {
                //check if exists Bookmark, if exists must update his prop OriginalId
                foreach (var item in barray)
                {
                    if (
                        item.AsBsonDocument.ToDictionary().ContainsKey("OriginalId")
                        &&
                        item["OriginalId"].AsString == oldId
					)
                    {
                        item["OriginalId"] = newId;
					}
				}
            }
			
				
			update = update.Set("links", barray);
			var res = _collection.UpdateOne(filter, update);

            if (res.ModifiedCount == 0 && res.MatchedCount == 0)
            {
                var bsonDoc = new BsonDocument() {
                        { SessionProperty.Id, idpfu },
                    };

                _collection.InsertOne(bsonDoc);
                res = _collection.UpdateOne(filter, update);
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
        /// Get: /api/v1/UserHistory
        /// </summary>
        /// <returns>List<UserHistoryViewModel></returns>
        [HttpGet]
		[ProducesResponseType(typeof(List<UserHistoryViewModel>), StatusCodes.Status200OK)]
		public async Task<IActionResult> Get()
		{
			var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, idpfu);
			var found = _collection.FindSync(filter).FirstOrDefault();
			BsonArray barray = new();
			if (found != null)
			{
				barray.AddRange(found["links"].AsBsonArray);
			}
			List<UserHistoryViewModel> listOfUserHistory = new();
			foreach(var link in barray)
			{
                if (
                    link.AsBsonDocument.ToDictionary().ContainsKey("IsBookmark")
                    &&
                    link["IsBookmark"].AsBoolean == true
                )
                {
					continue;
				}

				UserHistoryViewModel fav = new()
				{
					Id = link[0].AsString,
					Link = link[1].AsString,
					Title = link[2].AsString,
					Breadcrumb = link[3].AsString,
					Date = link[4].AsString,
					IsFavorite = link[5].AsBoolean
				};

                listOfUserHistory.Add(fav);
            }

            var result = new { status = "OK", result = listOfUserHistory.OrderByDescending(elem => elem.Id).ToList<UserHistoryViewModel>() };
            return Ok(result);

		}

        /// <summary>
        /// POST: /api/v1/UserHistory/AddFavorite
        /// </summary>
        /// <param name="userHistory"></param>
        /// <returns></returns>
        /// <exception cref="Exception"></exception>
        [HttpPost("AddFavorite")]
        public async Task<IActionResult> AddFavorite(UserHistoryViewModel userHistory)
        {
            var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, idpfu);
            var update = Builders<BsonDocument>.Update.Set(SessionProperty.Id, idpfu);

            BsonArray barray = new();

            var found = _collection.FindSync(filter).FirstOrDefault();
            if (found != null)
            {
                barray.AddRange(found["links"].AsBsonArray);
            }

            BsonValue? bsonValueFound = null;
            BsonValue? bsonValueFoundToDelete = null;
            //Cerco il record e lo setto come "favorite"
            foreach (BsonValue? item in barray)
            {
				if (
					item.AsBsonDocument.ToDictionary().ContainsKey("OriginalId") && userHistory.Id == item["OriginalId"].AsString
				)
				{
					bsonValueFoundToDelete = item;

				}
				if (
                    userHistory.Id == item["Id"].AsString
                )
                {
					bsonValueFound = item;
					item["IsFavorite"] = userHistory.IsFavorite;
                }
                
            }

            if (userHistory.IsFavorite == true && bsonValueFound != null)
            {
                //Duplico il record "favorite" e lo setto come "IsBookmark"
                barray.Add(
				    new Dictionary<string, object>
				    {
					    { "Id", DateTime.Now.ToString("yyMMddHHmmssff")  },
					    { "Link", bsonValueFound["Link"].AsString },
					    { "Title", bsonValueFound["Title"].AsString },
					    { "Breadcrumb", bsonValueFound["Breadcrumb"].AsString },
					    { "Date", bsonValueFound["Date"].AsString },
					    { "IsFavorite", bsonValueFound["IsFavorite"].AsBoolean },
                        { "IsBookmark", true },
                        { "OriginalId", bsonValueFound["Id"].AsString }
					}.ToBsonDocument()
			    );
            }
            else if(userHistory.IsFavorite == false && bsonValueFoundToDelete != null)
            {
                barray.Remove(bsonValueFoundToDelete);
            }


			update = update.Set("links", barray);
            var res = _collection.UpdateOne(filter, update);

            if (res.ModifiedCount == 0 && res.MatchedCount == 0)
            {
                var bsonDoc = new BsonDocument() {
                        { SessionProperty.Id, idpfu },
                    };

                _collection.InsertOne(bsonDoc);
                res = _collection.UpdateOne(filter, update);
            }
            if (res.ModifiedCount > 0 || res.MatchedCount > 0)
            {
                var result = new { status = "OK", userHistory };
                return Ok(result);
            }
            else
            {
                throw new Exception("cannot save");
            }

        }

        /// <summary>
        /// Get: /api/v1/UserHistory/Favorites
        /// </summary>
        /// <returns>List<UserHistoryViewModel></returns>
        [HttpGet("Favorites")]
        [ProducesResponseType(typeof(List<UserHistoryViewModel>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetFavorites()
        {
            var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, idpfu);
            var found = _collection.FindSync(filter).FirstOrDefault();
            BsonArray barray = new();
            if (found != null)
            {
                barray.AddRange(found["links"].AsBsonArray);
            }
            List<UserHistoryViewModel> listOfUserHistory = new();
            foreach (var link in barray)
            {
                UserHistoryViewModel userHistoryViewModel = new()
                {
                    Id = link[0].AsString,
                    Link = link[1].AsString,
                    Title = link[2].AsString,
                    Breadcrumb = link[3].AsString,
                    Date = link[4].AsString,
                    IsFavorite = link[5].AsBoolean,
                    IsBookmark = link.AsBsonDocument.ToDictionary().ContainsKey("IsBookmark") && link["IsBookmark"].AsBoolean == true
				};
				if (userHistoryViewModel.IsFavorite && userHistoryViewModel.IsBookmark)
				{
					listOfUserHistory.Add(userHistoryViewModel);
				}
            }

            var result = new { status = "OK", result = listOfUserHistory.OrderByDescending(elem => elem.Id).ToList<UserHistoryViewModel>() };
            return Ok(result);

        }

        /// <summary>
        /// Delete: /api/v1/UserHistory/DeleteFavorite
        /// </summary>
        /// <returns>DeletedCount</returns>
        [HttpDelete("DeleteFavorite")]
        [ProducesResponseType(typeof(List<UserHistoryViewModel>), StatusCodes.Status200OK)]
        public async Task<IActionResult> DeleteFavorite(UserHistoryViewModel itemToDelete)
        {
            var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, idpfu);
            var update = Builders<BsonDocument>.Update.Set(SessionProperty.Id, idpfu);

            BsonArray barray = new();
            var found = _collection.FindSync(filter).FirstOrDefault();
            if (found != null)
            {
                barray.AddRange(found["links"].AsBsonArray);
            }
            BsonValue? bsonValueToDelete = null;
            BsonValue? bsonValueToUpdate = null;
            string? OriginalId = null;
            foreach (BsonValue? item in barray)
            {
                if(item["Id"].AsString == itemToDelete.Id)
                {
                    bsonValueToDelete = item;
                    if (item.AsBsonDocument.ToDictionary().ContainsKey("OriginalId"))
                    {
                        OriginalId = item["OriginalId"].AsString;
                    }
                }
            }

			foreach (BsonValue? item in barray)
			{
				if (item["Id"].AsString == OriginalId)
				{
                    item["IsFavorite"] = false;
				}
			}

			if (bsonValueToDelete != null )
            {
                barray.Remove(bsonValueToDelete);
            }

            update = update.Set("links", barray);
            var res = _collection.UpdateOne(filter, update);

            if (res.ModifiedCount == 0 && res.MatchedCount == 0)
            {
                var bsonDoc = new BsonDocument() {
                        { SessionProperty.Id, idpfu },
                    };

                _collection.InsertOne(bsonDoc);
                res = _collection.UpdateOne(filter, update);
            }
            if (res.ModifiedCount > 0 || res.MatchedCount > 0)
            {
                var result = new { status = "OK", result = $"Deleted: {itemToDelete.Id}" };
                return Ok(result);
            }
            else
            {
                throw new Exception("cannot save");
            }
        }


		/// <summary>
		/// Delete: /api/v1/UserHistory/Favorites
		/// </summary>
		/// <returns>DeletedCount</returns>
		[HttpDelete("Favorites")]
		[ProducesResponseType(typeof(List<UserHistoryViewModel>), StatusCodes.Status200OK)]
		public async Task<IActionResult> DeleteFavorites()
		{
			var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, idpfu);
			var update = Builders<BsonDocument>.Update.Set(SessionProperty.Id, idpfu);

			BsonArray barray = new();
            var found = _collection.FindSync(filter).FirstOrDefault();
			if (found != null)
			{
				barray.AddRange(found["links"].AsBsonArray);
			}
			BsonArray barrayToDelete = new();
            List<string> barrayToUpdate = new();
			foreach (BsonValue? item in barray)
			{
				if (item.AsBsonDocument.ToDictionary().ContainsKey("IsBookmark") && item["IsBookmark"].AsBoolean)
				{
                    barrayToDelete.Add(item);
                    if (item.AsBsonDocument.ToDictionary().ContainsKey("OriginalId"))
                    {
                        barrayToUpdate.Add(item["OriginalId"].AsString);
                    }
				}
			}

            foreach (BsonValue? item in barrayToDelete)
            {
                barray.Remove(item);
            }

			foreach (BsonValue? item in barray)
			{
				item["IsFavorite"] = false;
			}

			update = update.Set("links", barray);
			var res = _collection.UpdateOne(filter, update);

			if (res.ModifiedCount == 0 && res.MatchedCount == 0)
			{
				var bsonDoc = new BsonDocument() {
						{ SessionProperty.Id, idpfu },
					};

				_collection.InsertOne(bsonDoc);
				res = _collection.UpdateOne(filter, update);
			}
			if (res.ModifiedCount > 0 || res.MatchedCount > 0)
			{
				var result = new { status = "OK", result= $"DeletedCount: {res.ModifiedCount}" };
				return Ok(result);
			}
			else
			{
				throw new Exception("cannot save");
			}

		}

		/// <summary>
		/// Delete: /api/v1/UserHistory
		/// </summary>
		/// <returns>DeletedCount</returns>
		[HttpDelete]
		public async Task<IActionResult> DeleteUserHistory()
		{
			var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, idpfu);
            var update = Builders<BsonDocument>.Update.Set(SessionProperty.Id, idpfu);

			BsonArray barray = new();
			var found = _collection.FindSync(filter).FirstOrDefault();
			if (found != null)
			{
				barray.AddRange(found["links"].AsBsonArray);
			}
			BsonArray barrayToDelete = new();

			foreach (var item in barray)
            {
                if (
					item.AsBsonDocument.ToDictionary().ContainsKey("IsBookmark") == false
					||
                    item.AsBsonDocument.ToDictionary().ContainsKey("IsBookmark") && item["IsBookmark"] == false)
                {
                    barrayToDelete.Add(item);
                }
            }

            foreach (var item in barrayToDelete)
            {
                barray.Remove(item);
            }

			try
            {
                update = update.Set("links", barray);
                var res = _collection.UpdateOne(filter, update);
                var result = new { status = "OK", result = "Deleted UserHistory" };
			    return Ok(result);
            }
            catch (Exception ex) 
            {
                var result = new { status = "NotOK", result = "Error Deleting UserHistory: " + ex.Message };
                return Ok(result);
            }
		}

		/// <summary>
		/// Delete: /api/v1/UserHistory/UserHistoryItem
		/// </summary>
		/// <returns>Deleted Id</returns>
		[HttpDelete("UserHistoryItem")]
		public async Task<IActionResult> DeleteUserHistoryItem(UserHistoryItemModel userHistoryItem)
		{
			var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, idpfu);
			var update = Builders<BsonDocument>.Update.Set(SessionProperty.Id, idpfu);

			BsonArray barray = new();
			var found = _collection.FindSync(filter).FirstOrDefault();
			if (found != null)
			{
				barray.AddRange(found["links"].AsBsonArray);
			}
			foreach (BsonValue? item in barray)
			{
				if (item["Id"].AsString == userHistoryItem.id.ToString())
				{
                    barray.Remove(item);
                    break;
				}
			}

			update = update.Set("links", barray);
			var res = _collection.UpdateOne(filter, update);

			if (res.ModifiedCount > 0 || res.MatchedCount > 0)
			{
				var result = new { status = "OK", result = $"Id Deleted: {userHistoryItem.id}" };
				return Ok(result);
			}
			else
			{
				throw new Exception("cannot save");
			}
		}


		/// <summary>
		/// Get: /api/v1/UserHistory/Notify
		/// </summary>
		/// <returns>List<NotifyViewModel></returns>
		[HttpGet("Notify")]
		[ProducesResponseType(typeof(List<NotifyViewModel>), StatusCodes.Status200OK)]
		public async Task<IActionResult> GetNotify()
		{
            CommonDbFunctions cdb = new();

			var sqlParams = new Dictionary<string, object?>()
			{
				{ "@idpfu", idpfu }
			};
            //TODO: stored giusta per le notifiche? (drawer)
			string strSql = "exec DASHBOARD_SP_LISTA_ATTIVITA @idpfu , '' , '' , '' , '' , ''  , 0, 0";
			TSRecordSet? rs = cdb.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, sqlParams);

			List<NotifyViewModel> listOfNotify = new();
            if (rs != null && rs.RecordCount > 0)
            {
                while(!rs.EOF)
                {
					NotifyViewModel notifyViewModel = new() {
                        Id = CInt(rs["Id"]),
                        Oggetto = CStr(rs["Oggetto"]),
                        Data = CStr(rs["Data"]) != "" ? CDate(CStr(rs["Data"])).ToString() : "",
						Obbligatory = CStr(rs["ATV_Obbligatory"]),
                    };
					listOfNotify.Add(notifyViewModel);
					rs.MoveNext();
                }
            }
			
			var result = new { status = "OK", result = listOfNotify.OrderByDescending(elem => elem.Id).ToList<NotifyViewModel>() };
			return Ok(result);

		}


	}
}
