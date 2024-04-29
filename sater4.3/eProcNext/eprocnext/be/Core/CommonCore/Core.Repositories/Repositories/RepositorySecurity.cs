using Core.Repositories.Interfaces;
using Microsoft.Extensions.Configuration;
using NeoSmart.Hashing.XXHash.Core;
using System.Linq;
using System.Text;

namespace Core.Repositories.Repositories
{
    public class RepositorySecurity: BaseRepository, IRepositorySecurity
    {
        public RepositorySecurity(IConfiguration config, ISqlSessionProvider session): base(config)
        {
            Session = session;
        }

        public ISqlSessionProvider Session { get; }

        public uint GetHash(string id)
        {
            string messageToSign = $"{id}{Session.TenantId}{Session.AccountId}{Session.SecretHashKey}";
            return XXHash.XXH32(Encoding.ASCII.GetBytes(messageToSign));
        }

        public bool ValidateHash(string id, uint hash)
        {
            string messageToSign = $"{id}{Session.TenantId}{Session.AccountId}{Session.SecretHashKey}";
            return hash == XXHash.XXH32(Encoding.ASCII.GetBytes(messageToSign));
        }

        public bool HasValidEntityHash<TDto>(TDto dto, bool applySecurityHash)
        {
            if (applySecurityHash)
            {
                if (typeof(ISecurityDTO).IsAssignableFrom(typeof(TDto)))
                {
                    return ValidateHash(KeyIdValues(dto)?.OrderBy(el => el.ToString()).Select(el => el?.ToString()).Aggregate((l, r) => l + r), (dto as ISecurityDTO).Hash);
                }
            }
            return true;
        }
    }
}
