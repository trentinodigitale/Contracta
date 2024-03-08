
namespace EProcNext.DTO.Interfaces
{
    public interface INoSqlSecurityEntity
    {
        string Id { get; }
        long Azienda { get; }
        uint Hash { get; set; }
    }
}
