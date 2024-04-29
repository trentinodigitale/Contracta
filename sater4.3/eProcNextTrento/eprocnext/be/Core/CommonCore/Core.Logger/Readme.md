# Core.Logger

This project implements custom logic for writing log data following the HELK
TS PAAS json format.

## Source tree structure
1. `AbstractClasses`: contains generic abstract class used inside project;
  1. `AbsLogger.cs`: save log entry to the choosen output (passed in configuration);
2. `Cache`: inner implementation of Redis Cache Manager, used internally by logger;
3. `EventHub`: inner implementation for Azure Event Hub client to write JSON entry;
4. `HelkLogEntry`: contains all source for managing Helk Log Entry JSON format data;
  1. `Builders/StandardHelkLogEntryBuilder.cs`: Builder which is responsible to populate the Helk Log Entry with fixed information from Http Context and application settings;
5. `Interfaces`: contains all interfaces used inside project;
6. `Logger`: contains implementation of AbsLogger for Helk Logger;
7. `Middleware`: contains a dotnet core middleware for calculating exact processing time;
8. `NoSql`: inner NoSql repository implementation, used for *saving and loading Helk Logger configuration*;
9. `Sql`: inner Sql repository implementation, is a repository with caching-querying pattern used to retrieve current user information from DB;
10. `Types`: contains types used inside project for generic operations;

## Helk Logger configuration

Actually the Helk Logger load its configuration with the following logic:

* `appsetting.json` must contains the following sections, which are used to connect to MongoDB for searching a saved configuration and to populate standard information for Helk log entries:
  ``` js
  "ConnectionStrings": {
    // ...
    "Redis": "YOUR_REDIS_CACHE_SERVICE_CONNECTION_STRING";
  },
  // LogMongoDB => Used for connection on Mongo DB, required to load/save configuration
  // Could be Mongo DB instance different from MongoConnection
  "LogMongoDB": {
    "ConnectionString": "mongodb://s.biagetti:password@40.118.65.195:27017",
    "Database": "eProcNextDB"
  },
  // Application Info
  "ApplicationInfo": {
    "Name": "eProcurement Next", // Given from TS
    "Stack": "3", // 0 => node, 1 => java, 2 => python, 3 => dotnet
    "Version": "0.1"
  },
  // Server application info, get from Azure
  "HostInfo": {
    "Hostname": "eprocnext-dev.azurewebsites.net",
    "Ip": "40.114.194.188"
  },
  "CloudInfo": {
    "Instance": {
      "Id": "34f65f4e-ec95-4ff8-afe8-00977ccccdc5" // Azure subscription ID
    },
    "Provider": "1", // 0 => aws (Amazon Web Service), 1 => az (Azure), 2 => gcp (Google Cloud Platform)
    "Region": "westeurope",
    "Service": "0" // 0 => aks (Azure Kubernet Service), 1 => ec2 (Amazon EC2 Service), 2 => ecs (Amazon ECS container Service)
  },
  ```
* `appsettings.json` *could have* the following section which specifies an initial configuration:
    ``` js
    // Standard / First configuration => is the default loaded if Environment is set to "Testing";
    // This is used for Starting configuration if a configuration entry is not found on Mongo DB
    "LoggerConfiguration": {
        "MinimunOutput": 4, // 0 => disabled, 1 => error, 2 => warning, 3 => debug, 4 => info
        "EndPointSaveDictionary": { // Specify for now two entry with the following key: "Stat", "Log"
          "Stat": {
            "LogOutput": 0, // 0 => HELK; 1 => No SQL; 2 => SQL (TO DO);
            "EndPoint": "<SPECIFY_YOUR_HELK_EVENT_HUB_ENDPOINT_CONNECTION_STRING>",
            "EndPointName": "eprocnext-applogs"
          },
          "Log": {
            "LogOutput": 0, // 0 => HELK; 1 => No SQL; 2 => SQL (TO DO);
            "EndPoint": "SPECIFY_YOUR_HELK_EVENT_HUB_ENDPOINT_CONNECTION_STRING",
            "EndPointName": "eprocnext-applogs"
          }
        }
    },
    ```
    * REMEMBER => this configuration is used as default ONLY the first time executing Helk Logger, when a configuration on MongoDB is not found;
* After the first execution, HelkLogger automatically creates a collection and save the configuration on MongoDB;
* If this configuration is not provided and there are no saved configuration on MongoDb, Helk Logger creates a default values that redirect both logs and stats output on MongoDB;

## Register at Starup.cs

For registring Helk Logger service on your web API application, just use the extension method on startup.cs:
``` csharp
// ...
using Core.Logger;

public IConfiguration Configuration { get; }

public void ConfigureServices(IServiceCollection services)
{
    // ...

    services.AddHelkLogger(Configuration);

    // ...
}
```

Remember that actually the project use Microsoft StackExchange package to connect to Azure Redis cache
service. Docker container for Redis cache is not actually supported. 

## Use it inside Controller or registered service
You can use Helk Logger inside your controller or service following this
simple example:

``` csharp
public class HelkLogEventHubTest
{
    // Logger object
    protected IHelkLogger Logger { get; }

    // Use dependency injection for request IHelkLogger object
    public HelkLogEventHubTest(IHelkLogger logger)
    {
        Logger = logger;
    }

    // Use method Log or Stat for write LogEntryData object
    // To Log or Stat channel 
    public void Simple_Log_Test()
    {
        Logger.Log(new LogEntryData
        {
            Message = $"Random test message - {Guid.NewGuid()}",
            Level = LogLevel.info,
        });
    }
}
```