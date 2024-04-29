using eProcurementNext.Application;
using eProcurementNext.CommonModule.Exceptions;
using Microsoft.AspNetCore.Http;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Bson.Serialization.Attributes;
using MongoDB.Driver;

namespace eProcurementNext.Session
{
    public partial class Session : ISession
    {
        private string _id = ""; //Chiave primaria

        private readonly Dictionary<string, object?> _properties;
        private readonly Dictionary<string, object?> _toUpdateProperties;

        private readonly IMongoCollection<BsonDocument> _collection;

        /// <summary>
        /// settata a true 
        /// </summary>
        public bool AutoSave { get; set; } = true;

        /// <summary>
        /// il default è false. settata a true questa proprietà farà si che per la durata dell'oggetto session ( durata pari ad una request ) il valore richiesto dovrà sempre essere recuperato da mongo e mai dalla cache locale
        /// </summary>
        public bool DisableCache { get; set; } = false;

        //public bool Crypt { get; set; } = false;

        public Session(string connectionString = "")
        {
            MongoClient client;
            if (string.IsNullOrEmpty(connectionString))
            {
                connectionString = SessionCommon.MongoDbConnectionString;
            }

            //Nome della collection dei dati di sessione
            var collectionName = SessionCommon.CollectionName;

            _properties = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
            _toUpdateProperties = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);

            string databaseName;
            if (string.IsNullOrEmpty(connectionString))
            {
                databaseName = "local";
                client = new MongoClient();
            }
            else
            {
                databaseName = MongoUrl.Create(connectionString).DatabaseName;
                client = new MongoClient(connectionString);
            }

            var database = client.GetDatabase(databaseName);

            //var filterList = new BsonDocument("name", collectionName);
            //var options = new ListCollectionNamesOptions { Filter = filterList };

            //var collectionExists = database.ListCollectionNames(options).Any();

            //if (!collectionExists)
            //{
            //    database.CreateCollection(collectionName, new CreateCollectionOptions { });
            //}

            _collection = database.GetCollection<BsonDocument>(collectionName);
        }

        public void Init(string id)
        {
            this._id = id;
            this.Timeout = SessionCommon.SessionTimeout;
            this.LastUpdate = DateTime.UtcNow;
        }

        private void UpdateExpires()
        {
            this.LastUpdate = DateTime.UtcNow;
            this.Save();
        }


        public void Load(string? id)
        {
            this._id = id ?? throw new SessionMongoDbException($"Cannot Load \"null\" session id");

            var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, this._id);
            var loadKey = new List<string> { SessionProperty.Timeout, SessionProperty.LastUpdate };

            var sb = new System.Text.StringBuilder("{");
            foreach (var key in loadKey)
            {
                sb.Append(key);
                sb.Append(":1,");
            }
            sb.Append('}');

            var partOfDoc = this._collection
                .Find(filter)
                .Project(sb.ToString())
                .FirstOrDefault();

            // salva internamete all'oggetto
            if (partOfDoc == null)
                throw new SessionMongoDbException($"session ${this._id} not found");

            lock (this._properties)
            {
                foreach (var bson in partOfDoc)
                {
                    if (bson.Name == SessionProperty.Id) continue;
                    var value = GetValue(bson.Value);
                    this._properties[bson.Name] = value;
                }
            }
        }


        public void Save()
        {
            var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, this._id);

            var update = Builders<BsonDocument>.Update.Set(SessionProperty.Id, this._id);

            Dictionary<string, object> tempDict = new();
            foreach (var bson in this._toUpdateProperties)
            {
                if (bson.Value != null && bson.Value.GetType() == typeof(DateTime))
                {
                    DateTime tempDT = DateTime.SpecifyKind(((DateTime)bson.Value), DateTimeKind.Utc);
                    tempDict.Add(bson.Key, tempDT);
                }
                else if(bson.Value != null && bson.Value.GetType() == typeof(Dictionary<string, object>)){
                    Dictionary<string, object> tempDictSub = new();
                    foreach (var elem in (Dictionary<string, object>)bson.Value)
                    {
                        if (elem.Value != null && elem.Value.GetType() == typeof(DateTime))
                        {
                            DateTime tempDT = DateTime.SpecifyKind(((DateTime)elem.Value), DateTimeKind.Utc);
                            tempDictSub.Add(elem.Key, tempDT);

                        }
                    }
                    foreach(var elem in tempDictSub)
                    {
                        ((Dictionary<string, object>)bson.Value).Remove(elem.Key);
                        ((Dictionary<string, object>)bson.Value).Add(elem.Key, elem.Value);
                    }
                }
            }
            foreach(var elem in tempDict)
            {
                this._toUpdateProperties.Remove(elem.Key);
                this._toUpdateProperties.Add(elem.Key, elem.Value);
            }

            foreach (var bson in this._toUpdateProperties)
            {
                update = update.Set(bson.Key, bson.Value);
            }

            //Se non ho nulla da aggiornare esco
            if (update == null) return;

            _collection.UpdateOne(filter, update, new UpdateOptions { IsUpsert = true }); //con l'opzione IsUpsert = true se il document non esiste viene creato. il default è false

            //Svuoto gli aggiornamenti pending
            _toUpdateProperties.Clear();
        }

        public bool Delete()
        {
            var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, _id);
            _id = "";   // rendo la sessione non più valida

            // pulizia
            lock (this._properties)
            {
                _properties.Clear();
            }
            _toUpdateProperties.Clear();

            var res = _collection.DeleteOne(filter);
            return res.DeletedCount > 0;
        }

        public bool IsExpired()
        {
            var check = this.LastUpdate.AddMinutes(this.Timeout) < DateTime.UtcNow;

            return check;
        }

        public bool IsActive(string token)
        {
            var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, token);
            var sb = new System.Text.StringBuilder("{");
            var loadKey = new List<string> { SessionProperty.Timeout, SessionProperty.LastUpdate };

            foreach (var key in loadKey)
            {
                sb.Append(key);
                sb.Append(":1,");
            }
            sb.Append('}');
            var partOfDoc = this._collection
                .Find(filter)
                .Project(sb.ToString())
                .FirstOrDefault();

            return partOfDoc != null;
        }
        public bool IsLogged(HttpContext ctx, string cookieAuthName)
        {
            return ctx.Request.Cookies.TryGetValue(cookieAuthName, out var tokenAuth) && this._id == tokenAuth && IsActive(tokenAuth);
        }

        public long NumeroUtentiCollegati()
        {
            return _collection.EstimatedDocumentCountAsync().Result;
        }

        public bool Refresh()
        {
            if (this.IsExpired())
            {
                return false;
            }
            else
            {
                this.UpdateExpires();
            }
            return true;
        }

        public static IEnumerable<string> GetOldSessionsIds()
        {
            var now = DateTime.UtcNow;
            var lastUpdateDate = now.Subtract(new TimeSpan(0, SessionCommon.SessionTimeout, 0));

            var connectionString = SessionCommon.MongoDbConnectionString;
            var collectionName = SessionCommon.CollectionName;

            MongoClient client;

            string databaseName;
            if (string.IsNullOrEmpty(connectionString))
            {
                databaseName = "local";
                connectionString = "";
                client = new MongoClient();
            }
            else
            {
                databaseName = MongoUrl.Create(connectionString).DatabaseName;
                client = new MongoClient(connectionString);
            }

            var database = client.GetDatabase(databaseName);

            var filterList = new BsonDocument("name", collectionName);
            var options = new ListCollectionNamesOptions { Filter = filterList };

            var collectionExists = database.ListCollectionNames(options).Any();

            if (!collectionExists)
            {
                database.CreateCollection(collectionName, new CreateCollectionOptions { });
            }

            var collection = database.GetCollection<BsonDocument>(collectionName);

            var filter = Builders<BsonDocument>.Filter.Lte(SessionProperty.LastUpdate.ToLower(), lastUpdateDate);
            var expired = collection.Find(filter).ToList();
            var ids = expired.Select(e => e[SessionProperty.Id].AsString).ToList();

            return ids;
        }

        private static dynamic? GetValue(BsonValue bsonValue)
        {
            object? value;

            if (bsonValue.GetType() == typeof(BsonDocument))
            {
                try
                {
                    value = BsonSerializer.Deserialize<object>(bsonValue.AsBsonDocument);
                    //value = BsonTypeMapper.MapToDotNetValue(bsonValue);
                }
                catch (Exception ex) when (ex is BsonSerializationException)
                {
                    if (!(ex.Message.ToLower().Contains("dbnull", StringComparison.Ordinal)))
                    {
                        throw;
                    }
                    else
                    {
                        value = null;
                    }
                }
            }
            else
            {
                try
                {
                    value = bsonValue.IsInt32 ? bsonValue.AsInt32 :
                            bsonValue.IsInt64 ? bsonValue.AsInt64 :
                            bsonValue.IsDouble ? bsonValue.AsDouble :
                            bsonValue.IsDecimal128 ? bsonValue.AsDecimal128 :
                            bsonValue.IsBoolean ? bsonValue.AsBoolean :
                            bsonValue.IsString ? bsonValue.AsString :
                            bsonValue.IsValidDateTime ? bsonValue.ToUniversalTime() :
                            null;

                    //value = BsonSerializer.Deserialize<object>(bsonValue.ToBsonDocument());
                }
                catch (Exception ex)
                {
                    eProcurementNext.CommonDB.Basic.TraceErr(ex, ApplicationCommon.Application.ConnectionString);
                    value = null;
                }
            }

            return value;
        }

        [BsonElement("properties")]
        public dynamic? this[string propertyName]
        {
            get
            {
                propertyName = propertyName.ToLowerInvariant();

                //Se l'oggetto session corrente ha già recuperato il dato richiesto nel suo ciclo di vita, non lo richiede nuovamente a mongo ma lo prendo dalla memoria locale ( NON STATICA! ) 
                if (this._properties.ContainsKey(propertyName))
                {
                    return this._properties[propertyName];
                }
                else
                {
                    // altrimenti la recupero e la salvo localmente
                    var filter = Builders<BsonDocument>.Filter.Eq(SessionProperty.Id, this._id);
                    var partOfDoc = _collection
                        .Find(filter)
                        .Project("{" + propertyName + ":1}")
                        .FirstOrDefault();

                    dynamic? propValue;

                    //Se non è stato trovato il document o la proprietà
                    if (partOfDoc == null || !partOfDoc.Contains(propertyName))
                    {
                        return null;
                    }

                    try
                    {
                        var value = partOfDoc[propertyName];
                        propValue = GetValue(value);

                        // ho ottenuto il valore per la proprietà
                        // quindi salvo internamente all'oggetto
                        lock (this._properties)
                        {
                            this._properties[propertyName] = propValue;
                        }
                    }
                    catch (KeyNotFoundException)
                    {
                        propValue = null;
                    }

                    return propValue;
                }
            }

            set
            {
                if (string.IsNullOrEmpty(propertyName))
                {
                    return;
                }

                // forzo il case a lower
                propertyName = propertyName.ToLowerInvariant();

                //default
                lock (this._properties)
                {
                    this._properties[propertyName] = value;
                }
                lock (this._toUpdateProperties)
                {
                    this._toUpdateProperties[propertyName] = value;
                }

                //Se è richiesto il salvataggio automatico per ogni modifica di session, altrimenti ci aspettiamo una chiamata esplicita al metodo Save() dal chiamante
                if (AutoSave && propertyName != SessionProperty.LastUpdate.ToLower())
                {
                    this.Save();
                }
            }
        }

        public bool EncryptData()
        {
            return SessionCommon.EncryptData;
        }


        /*
        private dynamic ConvertArray(BsonArray bsonArray)
        {
            var typeName = bsonArray.GetType().Name;
            var bArr = bsonArray.ToArray();
            dynamic arr = new dynamic[bArr.Length];
            for (var i = 0; i < bArr.Length; i++)
            {
                if (bArr[i] != null)
                {
                    if (bArr[i].GetType() == typeof(BsonArray))
                    {
                        try
                        {
                            arr[i] = ConvertArray(bArr[i].AsBsonArray);
                        }
                        catch (Exception ex)
                        {

                        }
                    }
                    else
                    {
                        arr[i] = ConvertBsonValue(bArr[i]);
                    }
                }
            }
            return arr;
        }

        private dynamic ConvertBsonValue(BsonValue value)
        {
            var v = value.GetType() == typeof(BsonDocument) ? value[vkey] : value;
            dynamic rv;
            switch (v.GetType().Name)
            {
                case "BsonInt32":
                    rv = Convert.ToInt32(v);
                    break;
                case "BsonInt64":
                    rv = Convert.ToInt64(v);
                    break;
                case "BsonDouble":
                    rv = Convert.ToDouble(v);
                    break;
                case "BsonDecimal128":
                    rv = Convert.ToDecimal(v);
                    break;
                case "BsonBoolean":
                    rv = Convert.ToBoolean(v);
                    break;
                case "BsonString":
                    rv = Convert.ToString(v);
                    break;
                case "BsonDateTime":
                    rv = Convert.ToDateTime(v);
                    break;
                case "BsonArray":
                    rv = ConvertArray(v.AsBsonArray);
                    break;
                case "BsonNull":
                    rv = null;
                    break;
                case "BsonUndefined":
                    rv = null;
                    break;

                //case "BsonTimestamp":
                default:
                    rv = null;
                    break;
            }
            return rv;
        }*/

        /*
        public async Task<T> GetValueAsync<T>(string sessionId, string key)
        {
	        var filter = Builders<BsonDocument>.Filter.Eq("_id", sessionId);
	        var projection = Builders<BsonDocument>.Projection.Include(key).Exclude("_id");
	        var document = await _collection.Find(filter).Project(projection).FirstOrDefaultAsync();

	        if (document == null || !document.Contains(key))
	        {
		        return default;
	        }

	        var value = document[key];

	        return BsonTypeMapper.MapToDotNetValue<T>(value);
        }

        public async Task SetValueAsync<T>(string sessionId, string key, T value)
        {
	        var filter = Builders<BsonDocument>.Filter.Eq("_id", sessionId);
	        var update = Builders<BsonDocument>.Update.Set(key, BsonTypeMapper.MapToBsonValue(value));
	        await _collection.UpdateOneAsync(filter, update, new UpdateOptions { IsUpsert = true });
        }

        public async Task RemoveKeyAsync(string sessionId, string key)
        {
	        var filter = Builders<BsonDocument>.Filter.Eq("_id", sessionId);
	        var update = Builders<BsonDocument>.Update.Unset(key);
	        await _collection.UpdateOneAsync(filter, update);
        }*/


    }
}