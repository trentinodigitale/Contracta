namespace eProcurementNext.Session
{
    public class SessionProperty
    {
        public const string Id = "_id";
        public const string Timeout = "Timeout";
        public const string LastUpdate = "LastUpdate";
        public const string LastUpdatePage = "LastUpdatePage";
        public const string Expires = "Expires";

        public const string redirectback = "redirectback";
        public const string strMnemonicoMP = "strMnemonicoMP";
        public const string FlagCheckWeb = "FlagCheckWeb";
        public const string IDAZIENDA = "IDAZIENDA";
        public const string PartenzaSeller = "PartenzaSeller";
        public const string AvailRisVideo = "AvailRisVideo";
        public const string ProvenienzaMyHomePage = "ProvenienzaMyHomePage";
        public const string closeparent = "closeparent";
        public const string USERNAME = "USERNAME";
        public const string PASSWORD = "PASSWORD";
        public const string ajax = "ajax";
        public const string IDMSGPARTECIPA = "IDMSGPARTECIPA";
        public const string STRURLPARTECIPA = "STRURLPARTECIPA";
        public const string strCheckIscrizione = "strCheckIscrizione";

        public const string IdPfu = "IdPfu";
        public const string Funzionalita = "Funzionalita";
        public const string strSuffLing = "strSuffLing";
        public const string IdMP = "IdMP";
        public const string IDAZI = "IDAZI";
        public const string IDAZI_Master = "IDAZI_Master";
        public const string SESSION_SUFFIX = "strSuffLing";
        public const string SESSION_USER = "IdPfu";
        public const string SESSION_WORKROOM = "IdMP";
        public const string SESSION_PERMISSION = "Funzionalita";

        public const string ChangeMultilinguismo = "ChangeMultilinguismo";
    }
}

namespace eProcurementNext.Razor.Enums
{
    public enum CheckSessionRedirectType
    {
        ExitExpired,
        ExitDos,
        ExitMultiSession
    }
}
