namespace eProcurementNext.RegistroImprese
{
    public interface IParixClient
    {
        // getParixInfo

        public string getParixInfo(string CodFisc, string SessionKey, string ConnString, string extra = "");
    }
}
