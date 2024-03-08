namespace eProcurementNext.WebAPI.Model
{
    public class AziendaInfoViewModel
    {
        public static string tablePrefix = "azi";

        public string RagioneSociale { get; set; }
        public string DataCreazione { get; set; }
        public string PartitaIva { get; set; }
        public string E_Mail { get; set; }
        public string IndirizzoLeg { get; set; }
        public string LocalitaLeg { get; set; }
        public string ProvinciaLeg { get; set; }
        public string StatoLeg { get; set; }
        public string CapLeg { get; set; }
        public string SitoWeb { get; set; }

        public AziendaInfoViewModel(
            string _ragioneSociale,
            string _dataCreazione,
            string _partitaIva,
            string _e_Mail,
            string _indirizzoLeg,
            string _localitaLeg,
            string _provinciaLeg,
            string _statoLeg,
            string _capLeg,
            string _sitoWeb
            )
        {
            RagioneSociale = _ragioneSociale;
            DataCreazione = _dataCreazione;
            PartitaIva = _partitaIva;
            E_Mail = _e_Mail;
            IndirizzoLeg = _indirizzoLeg;
            LocalitaLeg = _localitaLeg;
            ProvinciaLeg = _provinciaLeg;
            StatoLeg = _statoLeg;
            CapLeg = _capLeg;
            SitoWeb = _sitoWeb;
        }

    }
}
