using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using eProcurementNext.WebAPI.Model;
using MongoDB.Bson;
using MongoDB.Driver;
using System.Text.Json;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.WebAPI.Utils
{
    public class WidgetUtils 
    {

        public static string collectionNameMongoDBWidget = "eProcNextWidget";
        public MongoClient _client;
        public IMongoDatabase _database;
        public IMongoCollection<BsonDocument> _collection;

        public WidgetUtils()
        {
            string csMongoDB = ConfigurationServices.GetKey("ConnectionStrings:MongoDbConnection")!;
            _client = new MongoClient(csMongoDB);
            _database = _client.GetDatabase(MongoUrl.Create(csMongoDB).DatabaseName);
            _collection = _database.GetCollection<BsonDocument>(collectionNameMongoDBWidget);

        }

        public void LoadWidgetFromJson(bool forceDeleteCollection = false, bool loadCustom = false, bool checkLastUpdate = false)
        {
            if (forceDeleteCollection)
            {
                _database.DropCollection(collectionNameMongoDBWidget);
            }

            string jsonName = $"widgets{(loadCustom ? "Custom" : "")}.json";
            string DefaultPath = Path.Combine(ConfigurationServices._contentRootPath, jsonName);
            string? pathJsonFile = ConfigurationServices.GetKey("pathJsonFile", DefaultPath);
            if (pathJsonFile == null || !CommonStorage.FileExists(pathJsonFile))
            {
                Console.WriteLine(" ------------ Widgets Json file (" + jsonName + ") not found ------------ ");

            }
            else
            {
                Console.WriteLine(" ------------ Loading " + jsonName + " ------------------- ");
                var json = File.ReadAllText(pathJsonFile);
                JsonSerializerOptions _options = new()
                {
                    PropertyNameCaseInsensitive = true
                };
                try
                {
                    WidgetsDTO? widgetsDTO = JsonSerializer.Deserialize<WidgetsDTO>(json, _options);
                    if(widgetsDTO != null && checkLastUpdate)
                    {
						var currentLastUpdateFound = _collection.Find(new BsonDocument("_id", "idLastUpdate")).ToList().Count != 0;
						if (
							currentLastUpdateFound &&
							_collection.Find(new BsonDocument("_id", "idLastUpdate")).ToList().FirstOrDefault() != null 
							)
						{
                            string valueFoundInColl;
                            try
                            {
								valueFoundInColl = _collection.Find(new BsonDocument("_id", "idLastUpdate")).ToList().FirstOrDefault().Values.ToList()[1].ToString();
                                if(valueFoundInColl == null)
                                {
									valueFoundInColl = DateTime.MinValue.ToString();
								}
                            }
                            catch
                            {
                                valueFoundInColl = DateTime.MinValue.ToString();
							}
							
                            if(DateTime.Compare(DateTime.Parse(valueFoundInColl), DateTime.Parse(widgetsDTO.lastupdate)) == 0)
                            {
                                return;
                            }
                            else
                            {
                                _database.DropCollection(collectionNameMongoDBWidget);
                            }

						}
						else
						{
							_database.DropCollection(collectionNameMongoDBWidget);
						}
						var newLastUpdate = new BsonDocument { { "_id", "idLastUpdate" }, { "lastupdate", widgetsDTO.lastupdate } };
						var result = _collection.ReplaceOne(
										filter: new BsonDocument("_id", "idLastUpdate"),
										options: new ReplaceOptions { IsUpsert = true },
										replacement: newLastUpdate);

					}

					if (widgetsDTO != null && widgetsDTO.widgets != null && widgetsDTO.widgets.Count > 0)
                    {
                        foreach (var widget in widgetsDTO.widgets)
                        {
                            var tempDictParams = new Dictionary<string, object?>();
                            foreach (var item in widget.Params)
                            {
                                if(((JsonElement)item.Value).ValueKind == JsonValueKind.Array)
                                {
                                    tempDictParams.Add(item.Key, JsonSerializer.Serialize(item.Value));
                                }
                                else
                                {
                                    tempDictParams.Add(item.Key, item.Value.ToString());
                                }
                            }
				            var widgetDoc = new Dictionary<string, object?>
				            {
					            { "Id", CInt(widget.Id) },
					            { "Code", widget.Code.ToString() },
                                { "Title", widget.Title != null ? CStr(widget.Title) : null },
					            { "Type", CInt(widget.Type) },
					            { "Stored", widget.Stored != null ? CStr(widget.Stored) : null },
					            { "Params", tempDictParams },
					            { "Pos_permission", CInt(widget.Pos_permission) },
					            { "Deleted", widget.Deleted != null ?  CStr(widget.Deleted) : null },
				            }.ToBsonDocument();


                            if (!loadCustom)
                            {
								_collection.InsertOne(widgetDoc);
                            }
                            else
                            {
                                var filter = Builders<BsonDocument>.Filter.Eq("Id", widget.Id);
                                var bsonFound = _collection.Find(filter).ToList();
                                if(bsonFound != null && bsonFound.Count != 0)
                                {
                                    _collection.FindOneAndReplace(Builders<BsonDocument>.Filter.Eq("Id", widget.Id), widgetDoc);
                                }
                                else
                                {
                                    _collection.InsertOne(widgetDoc);
                                }
                            }
							
                        }
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine(" ------------ Loading " + jsonName + " Failed: ----------- ");
                    Console.WriteLine(" ------------ " + ex.Message + "------------------- ");
                    CommonDB.Basic.WriteToEventLog(" ------------ Loading " + jsonName + " Failed: ----------- \n" + ex.ToString());
                }

            }

            if (!loadCustom)
            {
                LoadWidgetFromJson(false, true);
            }
        }
        
    }

    class WidgetsDTO
    {
        public string lastupdate { get; set; }

        public List<WidgetViewModel> widgets { get; set; }

    }
}
