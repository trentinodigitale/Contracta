namespace eProcurementNext.RegistroImprese
{
    public class Factory
    {
        public static IParixClient getClient(string clientName)
        {
            // TODO completare con tutti i nomi / tipi di client

            if (clientName == "CERVED.CervedClient")
            {
                return new CERVED.CervedClient();
            }
            else if(clientName == "ClasseAdrierClient")
            {
                return new ClasseAdrierClient();
            }
            else if(clientName == "ClasseParixClient")
            {
                return new ClasseParixClient();
            }
            return null;
        }
    }
}
