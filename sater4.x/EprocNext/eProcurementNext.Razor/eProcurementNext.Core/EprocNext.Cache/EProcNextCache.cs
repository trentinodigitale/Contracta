using eProcurementNext.CommonDB;
using eProcurementNext.HTML;
using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Caching.Redis;
using StackExchange.Redis;
using System.Reflection;
using System.Text;
using System.Text.Json;

namespace eProcurementNext.Cache
{
    public partial class EProcNextCache : IEprocNextCache
    {
        public static string RedisConnectionString;

        public static string RedisDBNameCache;

        public static string RedisDBNameML;

        public static bool RedisDBEnabled = false;

        private Dictionary<string, object?> _properties;
        private Dictionary<string, object?> _toUpdateProperties;

        private readonly IDistributedCache _cache;

        public readonly IDistributedCache _cacheML;

        // Setting up the cache options
        DistributedCacheEntryOptions redisOptions = new DistributedCacheEntryOptions();

        public EProcNextCache(string connectionString = "", string collectionName = "", IDistributedCache cache = null)
        {
            if (RedisDBEnabled)
            {
                RedisCacheOptions cacheOptions = new RedisCacheOptions();

                cacheOptions.Configuration = RedisConnectionString;
                cacheOptions.InstanceName = RedisDBNameCache;

                _cache = new RedisCache(cacheOptions);

                RedisCacheOptions cacheOptionsML = new RedisCacheOptions();

                cacheOptionsML.Configuration = RedisConnectionString;
                cacheOptionsML.InstanceName = RedisDBNameML;

                _cacheML = new RedisCache(cacheOptionsML);
            }

            _properties = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
            _toUpdateProperties = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
        }

        public string? GetML(string key)
        {
            RedisValue value;
            lock (_cacheML)
            {
                value = _cacheML.GetString(key);

            }
            if (value.HasValue)
            {
                return value.ToString();

            }
            else
            {
                return null;
            }
        }

        public void SetML(string key, string value)
        {
            _cacheML.SetStringAsync(key.ToUpper(), value);
        }

        public byte[] ObjectToByteArray(string key, object obj)
        {
            //salvo il tipo della variabile
            string type = obj.GetType().Name;
            CommonDbFunctions cdf = new CommonDbFunctions();
            if (type == "Dictionary`2")
            {
                type = $@"Dictionary<{obj.GetType().GenericTypeArguments[0].Name},{obj.GetType().GenericTypeArguments[1].Name}>";
                if (type == "Dictionary<String,Field>")
                {
                    Dictionary<string, Field> dictObj = (Dictionary<string, Field>)obj;
                    foreach (var el in dictObj)
                    {
                        if (el.Value.Domain != null)
                        {
                            el.Value.Domain.RsElemBackup = el.Value.Domain.RsElem != null ? cdf.getSerializedTS(el.Value.Domain.RsElem) : "";
                        }
                        if (el.Value.umDomain != null)
                        {
                            el.Value.umDomain.RsElemBackup = el.Value.umDomain.RsElem != null ? cdf.getSerializedTS(el.Value.umDomain.RsElem) : "";
                        }
                    }
                    Field[] tempArrayOfField = dictObj.Values.ToArray();
                    string[] _ArrayOfTypes = new string[tempArrayOfField.Length];
                    for (int i = 0; i < tempArrayOfField.Length; i++)
                    {
                        _ArrayOfTypes[i] = tempArrayOfField[i].GetType().Name;
                    }
                    string serialized = JsonSerializer.Serialize(_ArrayOfTypes);
                    _cache.Set(key + $@"_ArrayOfTypes", Encoding.UTF8.GetBytes(serialized), redisOptions);
                    _cache.Set(key + $@"_Type", Encoding.UTF8.GetBytes(type), redisOptions);

                    // Serializing the data
                    string cachedDataStringTemp = JsonSerializer.Serialize(dictObj);
                    return Encoding.UTF8.GetBytes(cachedDataStringTemp);
                }
            }
            else if (type == "Object[]")
            {
                type = "Object[]";
            }
            else if (type == "TSRecordSet")
            {
                _cache.Set(key + $@"_Type", Encoding.UTF8.GetBytes(type), redisOptions);
                return Encoding.UTF8.GetBytes(cdf.getSerializedTS((TSRecordSet)obj));
            }
            _cache.Set(key + $@"_Type", Encoding.UTF8.GetBytes(type), redisOptions);

            // Serializing the data
            string cachedDataString = JsonSerializer.Serialize(obj);
            return Encoding.UTF8.GetBytes(cachedDataString);
        }

        public object ByteArrayToObject(string key, byte[]? arrBytes)
        {
            if (arrBytes == null)
            {
                return "";
            }
            var cachedDataString = Encoding.UTF8.GetString(arrBytes);
            string type = Encoding.UTF8.GetString(_cache.Get(key + $@"_Type"));
            switch (type)
            {
                case "String":
                    return JsonSerializer.Deserialize<string>(cachedDataString);
                case "DateTime":
                    return JsonSerializer.Deserialize<DateTime>(cachedDataString);
                case "Int32":
                case "Number":
                    return JsonSerializer.Deserialize<int>(cachedDataString);
                case "Object[]":
                    JsonElement[] temp = JsonSerializer.Deserialize<JsonElement[]>(cachedDataString);
                    dynamic[] arr = new dynamic[temp.Length];
                    for (int i = 0; i < temp.Length; i++)
                    {
                        switch (temp[i].ValueKind.ToString())
                        {
                            case "String":
                                arr[i] = temp[i].Deserialize(typeof(String));
                                break;
                            case "Array":
                                JsonElement[] temp2 = JsonSerializer.Deserialize<JsonElement[]>(temp[i]);
                                dynamic[] arr2 = new dynamic[temp2.Length];
                                for (int k = 0; k < temp2.Length; k++)
                                {
                                    switch (temp2[k].ValueKind.ToString())
                                    {
                                        case "String":
                                            arr2[k] = temp2[k].Deserialize(typeof(String));
                                            break;
                                        case "Array":
                                            arr2[k] = temp2[k].Deserialize(typeof(dynamic[]));
                                            break;
                                        case "True":
                                            arr2[k] = true;
                                            break;
                                        case "False":
                                            arr2[k] = false;
                                            break;
                                        case "Null":
                                            arr2[k] = null;
                                            break;
                                        case "DateTime":
                                            arr2[k] = JsonSerializer.Deserialize<DateTime>(temp2[k]);
                                            break;
                                        case "Number":
                                        case "Int32":
                                            arr2[k] = JsonSerializer.Deserialize<int>(temp2[k]);
                                            break;
                                        default:
                                            arr2[k] = JsonSerializer.Deserialize<object>(temp2[k]);
                                            break;
                                    }
                                }
                                arr[i] = arr2;
                                break;
                            //arr[i] = temp[i].Deserialize(typeof(dynamic[]));
                            //break;
                            case "True":
                                arr[i] = true;
                                break;
                            case "False":
                                arr[i] = false;
                                break;
                            case "Null":
                                arr[i] = null;
                                break;
                            case "DateTime":
                                arr[i] = JsonSerializer.Deserialize<DateTime>(temp[i]);
                                break;
                            case "Number":
                                arr[i] = JsonSerializer.Deserialize<int>(temp[i]);
                                break;
                            default:
                                arr[i] = JsonSerializer.Deserialize<object>(temp[i]);
                                break;
                        }
                    }
                    return arr;
                case "Dictionary<String,Field>":
                    Dictionary<string, dynamic> tempDict = JsonSerializer.Deserialize<Dictionary<string, dynamic>>(cachedDataString);
                    Dictionary<string, Field> tempDict2 = new();
                    string[] _ArrayOfTypes = JsonSerializer.Deserialize<string[]>(Encoding.UTF8.GetString(_cache.Get(key + $@"_ArrayOfTypes")));
                    for (int j = 0; j < _ArrayOfTypes.Length; j++)
                    {
                        switch (_ArrayOfTypes[j])
                        {
                            case "Fld_Attach":
                                tempDict2.Add(tempDict.ElementAt(j).Key, JsonSerializer.Deserialize<Fld_Attach>(tempDict.ElementAt(j).Value));
                                break;
                            case "Fld_CheckBox":
                                tempDict2.Add(tempDict.ElementAt(j).Key, JsonSerializer.Deserialize<Fld_CheckBox>(tempDict.ElementAt(j).Value));
                                break;
                            case "Fld_Date":
                                tempDict2.Add(tempDict.ElementAt(j).Key, JsonSerializer.Deserialize<Fld_Date>(tempDict.ElementAt(j).Value));
                                break;
                            case "Fld_Domain":
                                tempDict2.Add(tempDict.ElementAt(j).Key, JsonSerializer.Deserialize<Fld_Domain>(tempDict.ElementAt(j).Value));
                                break;
                            case "Fld_ExtendedDomain":
                                tempDict2.Add(tempDict.ElementAt(j).Key, JsonSerializer.Deserialize<Fld_ExtendedDomain>(tempDict.ElementAt(j).Value));
                                break;
                            case "Fld_Hierarchy":
                                tempDict2.Add(tempDict.ElementAt(j).Key, JsonSerializer.Deserialize<Fld_Hierarchy>(tempDict.ElementAt(j).Value));
                                break;
                            case "Fld_HR":
                                tempDict2.Add(tempDict.ElementAt(j).Key, JsonSerializer.Deserialize<Fld_HR>(tempDict.ElementAt(j).Value));
                                break;
                            case "Fld_Label":
                                tempDict2.Add(tempDict.ElementAt(j).Key, JsonSerializer.Deserialize<Fld_Label>(tempDict.ElementAt(j).Value));
                                break;
                            case "Fld_Mail":
                                tempDict2.Add(tempDict.ElementAt(j).Key, JsonSerializer.Deserialize<Fld_Mail>(tempDict.ElementAt(j).Value));
                                break;
                            case "Fld_Number":
                                tempDict2.Add(tempDict.ElementAt(j).Key, JsonSerializer.Deserialize<Fld_Number>(tempDict.ElementAt(j).Value));
                                break;
                            case "Fld_PubLeg":
                                tempDict2.Add(tempDict.ElementAt(j).Key, JsonSerializer.Deserialize<Fld_PubLeg>(tempDict.ElementAt(j).Value));
                                break;
                            case "Fld_RadioButton":
                                tempDict2.Add(tempDict.ElementAt(j).Key, JsonSerializer.Deserialize<Fld_RadioButton>(tempDict.ElementAt(j).Value));
                                break;
                            case "Fld_Static":
                                tempDict2.Add(tempDict.ElementAt(j).Key, JsonSerializer.Deserialize<Fld_Static>(tempDict.ElementAt(j).Value));
                                break;
                            case "Fld_Text":
                                tempDict2.Add(tempDict.ElementAt(j).Key, JsonSerializer.Deserialize<Fld_Text>(tempDict.ElementAt(j).Value));
                                break;
                            case "Fld_TextArea":
                                tempDict2.Add(tempDict.ElementAt(j).Key, JsonSerializer.Deserialize<Fld_TextArea>(tempDict.ElementAt(j).Value));
                                break;
                            case "Fld_Url":
                                tempDict2.Add(tempDict.ElementAt(j).Key, JsonSerializer.Deserialize<Fld_Url>(tempDict.ElementAt(j).Value));
                                break;
                            default:
                                tempDict2.Add(tempDict.ElementAt(j).Key, tempDict.ElementAt(j).Value);
                                break;
                        }
                    }
                    return elaborateDictionaryStringField(tempDict2);
                case "TSRecordSet":
                    CommonDbFunctions cdf = new CommonDbFunctions();
                    return cdf.getDeserializedTS(cachedDataString);
                default:
                    return JsonSerializer.Deserialize<object>(cachedDataString);
            }
        }

        public Dictionary<string, Field> elaborateDictionaryStringField(Dictionary<string, Field> tempDict)
        {
            CommonDbFunctions cdf = new CommonDbFunctions();
            Dictionary<string, Field> dict = new Dictionary<string, Field>();
            for (int i = 0; i < tempDict.Count; i++)
            {
                Field fld = tempDict.ElementAt(i).Value;
                string key = tempDict.ElementAt(i).Key;
                foreach (PropertyInfo propertyInfo in fld.GetType().GetProperties())
                {
                    string type = propertyInfo.GetValue(fld, null) != null ? propertyInfo.GetValue(fld, null).GetType().Name : "";
                    if (type == "JsonElement")
                    {
                        propertyInfo.SetValue(fld, ConvertJsonElement((JsonElement)propertyInfo.GetValue(fld, null)));

                    }
                    else if (type == "ClsDomain")
                    {
                        ClsDomain tempCls = (ClsDomain)propertyInfo.GetValue(fld, null);
                        tempCls.RsElem = cdf.getDeserializedTS(tempCls.RsElemBackup);
                    }
                    //if(type.ToLower() == "tsrecordset")
                    //{
                    //    propertyInfo.SetValue(fld, fld.Domain.RsElem.);
                    //}
                }
                dict.Add(key, fld);
            }

            return dict;
        }

        public dynamic? ConvertJsonElement(JsonElement value)
        {
            switch (value.ValueKind.ToString())
            {
                case "String":
                    return JsonSerializer.Deserialize<string>(value);
                case "DateTime":
                    return JsonSerializer.Deserialize<DateTime>(value);
                case "Int32":
                case "Number":
                    return JsonSerializer.Deserialize<int>(value);
                case "True":
                    return true;
                case "False":
                    return false;
                case "Null":
                    return null;
                default:
                    return JsonSerializer.Deserialize<object>(value);

            }
        }

        public void Save()
        {
            if (!RedisDBEnabled)
            {
                return;
            }
            lock (this._toUpdateProperties)
            {
                foreach (var prop in this._toUpdateProperties)
                {
                    _cache.Set(prop.Key, ObjectToByteArray(prop.Key, prop.Value), redisOptions);
                }
            }
            lock (_toUpdateProperties)
            {
                _toUpdateProperties.Clear();

            }
            lock (_properties)
            {
                _properties.Clear();
            }

        }

        public bool Exists(string key)
        {
            bool boolToReturn = this._properties.ContainsKey(key);

            return boolToReturn;
        }

        public bool Remove(string key)
        {
            try
            {
                lock (this._properties)
                {
                    this._properties.Remove(key);
                }
                return true;
            }
            catch
            {
                return false;
            }
        }

        public void RemoveAll()
        {
            foreach (var x in this.Keys)
            {
                Remove(x);
            }
            lock (this._properties)
            {
                this._properties.Clear();
            }
            lock (this._toUpdateProperties)
            {
                this._toUpdateProperties.Clear();
            }
        }

        public IEnumerable<string> Keys
        {
            get
            {
                return this._properties.Keys;
            }
        }

        public dynamic? this[string propertyName]
        {
            get
            {
                // forzo il case a lower
                propertyName = propertyName.ToLowerInvariant();

                //const string IdKey = EProcNextCacheProperty.Id;

                if (this._properties.ContainsKey(propertyName))
                {
                    // se ho la variabile localmente la restituisco
                    return this._properties[propertyName];
                }
                else if (RedisDBEnabled)
                {
                    return ByteArrayToObject(propertyName, _cache.Get(propertyName));
                    //return ByteArrayToObject(propertyName, _cache.Get(propertyName));

                }
                else
                {
                    return "";
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

                if (propertyName != EProcNextCacheProperty.LastUpdate.ToLower())
                {
                    this.LastUpdate = DateTime.UtcNow;
                }

                lock (this._properties)
                {
                    this._properties[propertyName] = value;
                }
                lock (this._toUpdateProperties)
                {
                    this._toUpdateProperties[propertyName] = value;
                }

                this.Save();
            }
        }


    }
}