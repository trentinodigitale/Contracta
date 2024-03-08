using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using MongoDB.Bson;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;

namespace EprocNext.WebApi.CheckInfrastructureControllers
{
    [ApiVersion("1.0")]
    [Route("api/v{v:apiVersion}/[controller]")]
    [ApiController]
    public class MicroserviceStatusController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public MicroserviceStatusController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        private static void Assert_NotEmpty(string value, string message)
        {
            if (string.IsNullOrEmpty(value)) throw new Exception(message);
        }

        [HttpGet]
        public ActionResult MicroservicesStatus()
        {
            try
            {
                Console.WriteLine("Starting check keyVault keys");
                Assert_NotEmpty(_configuration.GetConnectionString("SQL"), "Connection string SQL is empty");
                Assert_NotEmpty(_configuration.GetConnectionString("NOSQL"), "Connection string NOSQL is empty");
                Assert_NotEmpty(_configuration.GetConnectionString("Repository"), "Connection string Repository is empty");
                Assert_NotEmpty(_configuration.GetConnectionString("Redis"), "Connection string Redis is empty");

                Assert_NotEmpty(_configuration["MongoConnection:ConnectionString"], "MongoConnection:ConnectionString is empty");
                Assert_NotEmpty(_configuration["MongoConnection:Database"], "MongoConnection:Database is empty");
                Assert_NotEmpty(_configuration["MongoConnectionHangFire:ConnectionString"], "MongoConnectionHangFire:ConnectionString is empty");

                Assert_NotEmpty(_configuration["AppSettings:ISPAESKEY"], " is empty");
                Assert_NotEmpty(_configuration["AppSettings:ISPAESIV"], "AppSettings:ISPAESIV is empty");
                Assert_NotEmpty(_configuration["AppSettings:ISPAPPCODE"], "AppSettings:ISPAPPCODE is empty");
                Assert_NotEmpty(_configuration["AppSettings:APIBASEURL"], "AppSettings:APIBASEURL is empty");

                Assert_NotEmpty(_configuration["TsIdSettings:ISPAESKEY"], "TsIdSettings:ISPAESKEY is empty");
                Assert_NotEmpty(_configuration["TsIdSettings:ISPAESIV"], "TsIdSettings:ISPAESIV is empty");
                Assert_NotEmpty(_configuration["TsIdSettings:ISPAPPCODE"], "TsIdSettings:ISPAPPCODE is empty");
                Assert_NotEmpty(_configuration["TsIdSettings:APIBASEURL"], "TsIdSettings:APIBASEURL is empty");

                Assert_NotEmpty(_configuration["TsDigitalSettings:APIVERSION"], "TsDigitalSettings:APIVERSION is empty");
                Assert_NotEmpty(_configuration["TsDigitalSettings:APIBASEURL"], "TsDigitalSettings:APIBASEURL is empty");
                Assert_NotEmpty(_configuration["TsDigitalSettings:UserAgent"], "TsDigitalSettings:UserAgent is empty");
                Assert_NotEmpty(_configuration["TsDigitalSettings:XAppName"], "TsDigitalSettings:XAppName is empty");
                Assert_NotEmpty(_configuration["TsDigitalSettings:XAppVersion"], "TsDigitalSettings:XAppVersion is empty");
                Assert_NotEmpty(_configuration["TsDigitalSettings:APIBASEURLITEMS"], "TsDigitalSettings:APIBASEURLITEMS is empty");
                Assert_NotEmpty(_configuration["TsDigitalSettings:APIVERSIONITEMS"], "TsDigitalSettings:APIVERSIONITEMS is empty");
                Assert_NotEmpty(_configuration["TsDigitalSettings:NCSKEY"], "TsDigitalSettings:NCSKEY is empty");
                Assert_NotEmpty(_configuration["TsDigitalSettings:TECHNICALUSERID"], "TsDigitalSettings:TECHNICALUSERID is empty");
                Assert_NotEmpty(_configuration["TsDigitalSettings:NCSBASEURL"], "TsDigitalSettings:NCSBASEURL is empty");
                Assert_NotEmpty(_configuration["TsDigitalSettings:TechnicalUserId"], "TsDigitalSettings:TechnicalUserId is empty");
                Assert_NotEmpty(_configuration["TsDigitalSettings:TechnicalToken"], "TsDigitalSettings:TechnicalToken is empty");
                Assert_NotEmpty(_configuration["TsDigitalSettings:APIBASEUSERS"], "TsDigitalSettings:APIBASEUSERS is empty");

                Assert_NotEmpty(_configuration["JwtGenerationSettings:JwtBearer:ValidAudience"], "JwtGenerationSettings:JwtBearer:ValidAudience is empty");
                Assert_NotEmpty(_configuration["JwtGenerationSettings:JwtBearer:ValidIssuer"], "JwtGenerationSettings:JwtBearer:ValidIssuer is empty");
                Assert_NotEmpty(_configuration["JwtGenerationSettings:JwtTokenDuration"], "JwtGenerationSettings:JwtTokenDuration is empty");
                Assert_NotEmpty(_configuration["JwtGenerationSettings:RefreshTokenDuration"], "JwtGenerationSettings:RefreshTokenDuration is empty");
                Assert_NotEmpty(_configuration["JwtGenerationSettings:BypassRefreshTokenExpiration"], "JwtGenerationSettings:BypassRefreshTokenExpiration is empty");

                Assert_NotEmpty(_configuration["LogMongoDB:ConnectionString"], "LogMongoDB:ConnectionString is empty");
                Assert_NotEmpty(_configuration["LogMongoDB:Database"], "LogMongoDB:Database is empty");

                Assert_NotEmpty(_configuration["ApplicationInfo:Name"], "ApplicationInfo:Name is empty");
                Assert_NotEmpty(_configuration["ApplicationInfo:Stack"], "ApplicationInfo:Stack is empty");
                Assert_NotEmpty(_configuration["ApplicationInfo:Version"], "ApplicationInfo:Version is empty");


                Assert_NotEmpty(_configuration["HostInfo:Hostname"], "HostInfo:Hostname is empty");
                Assert_NotEmpty(_configuration["HostInfo:Ip"], "HostInfo:Ip is empty");

                Assert_NotEmpty(_configuration["CloudInfo:Instance:Id"], "CloudInfo:Instance:Id is empty");
                Assert_NotEmpty(_configuration["CloudInfo:Provider"], "CloudInfo:Provider is empty");
                Assert_NotEmpty(_configuration["CloudInfo:Region"], "CloudInfo:Region is empty");
                Assert_NotEmpty(_configuration["CloudInfo:Service"], "CloudInfo:Service is empty");

                Assert_NotEmpty(_configuration["LoggerConfiguration:MinimunOutput"], "LoggerConfiguration:MinimunOutput is empty");
                Assert_NotEmpty(_configuration["LoggerConfiguration:EndPointSaveDictionary:Stat:LogOutput"], "LoggerConfiguration:EndPointSaveDictionary:Stat:LogOutput is empty");
                Assert_NotEmpty(_configuration["LoggerConfiguration:EndPointSaveDictionary:Stat:EndPoint"], "LoggerConfiguration:EndPointSaveDictionary:Stat:EndPoint is empty");
                Assert_NotEmpty(_configuration["LoggerConfiguration:EndPointSaveDictionary:Stat:EndPointName"], "LoggerConfiguration:EndPointSaveDictionary:Stat:EndPointName is empty");
                Assert_NotEmpty(_configuration["LoggerConfiguration:EndPointSaveDictionary:Log:LogOutput"], "LoggerConfiguration:EndPointSaveDictionary:Log:LogOutput is empty");
                Assert_NotEmpty(_configuration["LoggerConfiguration:EndPointSaveDictionary:Log:EndPoint"], "LoggerConfiguration:EndPointSaveDictionary:Log:EndPoint is empty");
                Assert_NotEmpty(_configuration["LoggerConfiguration:EndPointSaveDictionary:Log:EndPointName"], "LoggerConfiguration:EndPointSaveDictionary:Log:EndPointNameis empty");

                Assert_NotEmpty(_configuration["ServiceBusConfiguration:EndPoint"], "ServiceBusConfiguration:EndPoint is empty");
                Assert_NotEmpty(_configuration["ServiceBusConfiguration:ProcessingResponsesQueue"], "ServiceBusConfiguration:ProcessingResponsesQueue is empty");
                Assert_NotEmpty(_configuration["ServiceBusConfiguration:SyncTopicName"], "ServiceBusConfiguration:SyncTopicName is empty");
                Assert_NotEmpty(_configuration["ServiceBusConfiguration:PublishTopicName"], "ServiceBusConfiguration:PublishTopicName is empty");
                Assert_NotEmpty(_configuration["ServiceBusConfiguration:UpdateTopicName"], "ServiceBusConfiguration:UpdateTopicName is empty");
                Assert_NotEmpty(_configuration["ServiceBusConfiguration:SendSchedulerQueue"], "ServiceBusConfiguration:SendSchedulerQueue is empty");
                Assert_NotEmpty(_configuration["ServiceBusConfiguration:ResponseSchedulerQueue"], "ServiceBusConfiguration:ResponseSchedulerQueue is empty");

                Assert_NotEmpty(_configuration["LegacyLoginOptions:EnableTSDigitalAnagraph"], "LegacyLoginOptions:EnableTSDigitalAnagraph is empty");
                Assert_NotEmpty(_configuration["LegacyLoginOptions:HashSecretKey"], "LegacyLoginOptions:HashSecretKey is empty");

                Assert_NotEmpty(_configuration["WsMipaafConfiguration:Url"], "WsMipaafConfiguration:Url is empty");
                Assert_NotEmpty(_configuration["WsMipaafConfiguration:UrlAsync"], "WsMipaafConfiguration:UrlAsync is empty");

                Assert_NotEmpty(_configuration["TsMeteringSettings:BaseUrl"], "TsMeteringSettings:BaseUrl is empty");
                Assert_NotEmpty(_configuration["TsMeteringSettings:Authorization"], "TsMeteringSettings:Authorization is empty");
                Assert_NotEmpty(_configuration["TsMeteringSettings:AppName"], "TsMeteringSettings:AppName is empty");
                Assert_NotEmpty(_configuration["TsMeteringSettings:AppVersion"], "TsMeteringSettings:AppVersion is empty");


                try
                {
                    Console.WriteLine("Starting connection with AzureSQL Server DB");
                    using var connection = new SqlConnection(_configuration.GetConnectionString("Repository"));
                    try
                    {
                        if (connection.State != ConnectionState.Open)
                            connection.Open();
                        Console.WriteLine("Connection with AzureSQL Server DB - OK");
                    }
                    finally
                    {
                        connection.Close();
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception($"Connecion to Azure SQL Server fail: {ex.Message}");
                }

                try
                {
                    Console.WriteLine("Starting connection with Atlas MongoDB");
                    var client = new MongoClient(_configuration["MongoConnection:ConnectionString"]);
                    var db = client.GetDatabase(_configuration["MongoConnection:Database"]);
                    List<string> collectionList = new List<string>();
                    foreach (BsonDocument collection in db.ListCollectionsAsync().Result.ToListAsync<BsonDocument>().Result)
                    {
                        collectionList.Add(collection["name"].AsString);
                    }
                    Console.WriteLine("Connection with Atlas MongoDB - OK");
                    Console.WriteLine($"Found {collectionList.Count()} collection in the database");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Connection with Atlas MongoDB Fail {ex.Message}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                return BadRequest($"Error: {ex.Message}");
            }

            return Ok();
        }

        /// <summary>
        /// Get Application Info
        /// </summary>
        /// <returns></returns>
        [HttpGet("info")]
        public IActionResult Info()
        {
            var result = new
            {
                Name = _configuration["ApplicationInfo:Name"],
                Version = _configuration["ApplicationInfo:Version"]
            };

            return Ok(result);
        }

        /// <summary>
        /// Get Application Info
        /// </summary>
        /// <returns></returns>
        [HttpGet("health")]
        public IActionResult Health()
        {
            var result = new
            {
                Status = "UP",
                Message = "The mighty service is alive!"
            };

            return Ok(result);
        }
    }
}