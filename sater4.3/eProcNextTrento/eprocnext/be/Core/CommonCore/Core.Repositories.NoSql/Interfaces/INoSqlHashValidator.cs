namespace Core.Repositories.NoSql.Interfaces
{
    public interface INoSqlHashValidator<T>
    {
        bool ValidateHash(T param);
    }
}
