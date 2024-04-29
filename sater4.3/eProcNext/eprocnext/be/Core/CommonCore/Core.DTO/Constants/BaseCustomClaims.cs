using System.Security.Claims;

namespace Core.Common.Constants.Authentication
{
    /// <summary>
    /// Base custom claims used for system JWT security token
    /// </summary>
    public class BaseCustomClaims
    {
        /// <summary>
        /// UserName / Login
        /// </summary>
        public static string Name => ClaimTypes.Name;
        
        /// <summary>
        /// User real Name
        /// </summary>
        public static string Surname => ClaimTypes.Surname;
        
        /// <summary>
        /// User Surname
        /// </summary>
        public static string GivenName => ClaimTypes.GivenName;
        
        /// <summary>
        /// User ID from Database
        /// </summary>
        public static string NameIdentifier => ClaimTypes.NameIdentifier;
        
        /// <summary>
        /// Primary Tenant ID
        /// </summary>
        public static string TenantId => "tenant_id";

        /// <summary>
        /// Actually logged Tenant ID (valid only for user who is administrator of more than one tenant)
        /// </summary>
        public static string LoginTenantId => "login_tenant_id";

        /// <summary>
        /// Is Persona FISICA / GIURIDICA flag
        /// </summary>
        public static string IsPersonaGiuridica => "is_persona_giuridica";
        
        /// <summary>
        /// Company VAT number
        /// </summary>
        public static string PartitaIva => "partita_iva";
        
        /// <summary>
        /// Company TAX code
        /// </summary>
        public static string CodiceFiscale => "codice_fiscale";
        
        /// <summary>
        /// User profile (from DATABASE)
        /// </summary>
        public static string Profile => "profile";

        /// <summary>
        /// User role
        /// </summary>
        public static string Role => ClaimTypes.Role;
        
        /// <summary>
        /// Flag that is true only for tenant from legacy integration
        /// </summary>
        public static string LegacyTenant => "legacy_tenant";

        /// <summary>
        /// Tenant activation license status
        /// </summary>
        public static string TenantLicenseStatus => "tenant_license_status";
    }
}
