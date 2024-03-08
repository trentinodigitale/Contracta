using System.Text.Json.Serialization;

namespace Core.Logger.Types
{
    public enum LogOutput
    {
        HELK,
        NoSql,
        Sql,
    }

    public enum ApplicationArea
    {
        Anag = 0,
        Core = 1,
        Specific = 2,
        ServiceBus = 3,
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum BusinessUnit
    {
        digital, enterprise, tspaas, studio,
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum ApplicationStack
    {
        node, java, python, dotnet
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum LogLevel
    {
        disabled, error, warning, debug, info
    }

    //[JsonConverter(typeof(JsonStringEnumConverter))]
    //public enum ApplicationEnvironment
    //{
    //    dev, test, prod, automated_test
    //}

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum CloudProvider
    {
        aws, az, gcp,
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum CloudService
    {
        aks, ec2, ecs,
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum HttpRequestMethod
    {
        get, post, put, delete, patch, option, head, connect, trace
    }
}
