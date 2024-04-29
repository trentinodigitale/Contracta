namespace Core.Repositories.NoSql.Interfaces
{
    public interface INoSqlLinqDynamicFilter
    {
        string Where { get; set; }
        string OrderBy { get; set; }
    }
}
