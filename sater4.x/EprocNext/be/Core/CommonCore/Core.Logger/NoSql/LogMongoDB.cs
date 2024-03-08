namespace Core.Logger.NoSql
{
    public interface ILoggerDBSettings
    {
        string ConnectionString { get; }
        string Database { get; }
    }

    public class LogMongoDB : ILoggerDBSettings
    {
        public string ConnectionString { get; set; }
        public string Database { get; set; }
    }
}
