namespace Core.DTO.Common
{
    /// <summary>
    /// UserClaims
    /// </summary>
    public class DecodedUserClaims
    {
#pragma warning disable CS1591 // Manca il commento XML per il tipo o il membro visibile pubblicamente
        public string Name { get; set; }
        public string Surname { get; set; }
        public string GivenName { get; set; }
        public long NameIdentifier { get; set; }
        public long TenantId { get; set; }
        public long LoginTenantId { get; set; }
        public string IsPersonaGiuridica { get; set; }
        public string PartitaIva { get; set; }
        public string CodiceFiscale { get; set; }
        public string Profile { get; set; }
        public string Role { get; set; }
        public byte TenantLicenseStatus { get; set; }
        public string CUAACodice => !string.IsNullOrEmpty(CodiceFiscale) && CodiceFiscale != PartitaIva ? CodiceFiscale : PartitaIva;
    }
}