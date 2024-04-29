using System.Security.Claims;

namespace Core.Common.Constants.Authentication
{
    public class BaseCustomClaims
    {
        public static string Name => ClaimTypes.Name;
        public static string Surname => ClaimTypes.Surname;
        public static string GivenName => ClaimTypes.GivenName;
        public static string NameIdentifier => ClaimTypes.NameIdentifier;
        public static string TenantId => "tenant_id";
        public static string LoginTenantId => "login_tenant_id";
        public static string IsPersonaGiuridica => "isPersonaGiuridica";
        public static string PartitaIva => "partitaIva";
        public static string Profile => "profile";
        public static string Role => ClaimTypes.Role;
    }
}
