using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Http;

namespace eProcurementNext.Session
{
    public interface ISession : ITSCollection
    {
        public void Init(string id);

        public bool AutoSave { get; set; }

        public void Load(string id);

        public bool Delete();

        public bool IsExpired();
        public bool Refresh();

        public bool IsActive(string token);
        public bool IsLogged(HttpContext ctx, string Cookie_Auth_Name);

        public long NumeroUtentiCollegati();

        public string SessionID { get; }
        public string SessionIDMinimal { get; }
        public int Timeout { get; }

        public DateTime LastUpdate { get; }
        public string? LastUpdatePath { get; set; }
        public bool SigningOut { get; set; }
        public bool EncryptData();

    }

}
