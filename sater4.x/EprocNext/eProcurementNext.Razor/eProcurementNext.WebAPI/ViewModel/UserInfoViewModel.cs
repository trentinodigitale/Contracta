namespace eProcurementNext.WebAPI.Model
{
    public class UserInfoViewModel
    {
        public static string tablePrefix = "pfu";
        public string Nome { get; set; }
        public string RuoloAziendale { get; set; }
        public string E_Mail { get; set; }
        public string Tel { get; set; }
        public string CodiceFiscale { get; set; }
        public string LastLogin { get; set; }
        public string DataCreazione { get; set; }

        public AziendaInfoViewModel AziendaAssociata { get; set; }

        public UserInfoViewModel(
            string _nome,
            string _ruoloAziendale,
            string _e_Mail,
            string _tel,
            string _codiceFiscale,
            string _lastLogin,
            string _dataCreazione,
            AziendaInfoViewModel _aziendaAssociata
            )
        {
            Nome = _nome;
            RuoloAziendale = _ruoloAziendale;
            E_Mail = _e_Mail;
            Tel = _tel;
            CodiceFiscale = _codiceFiscale;
            LastLogin = _lastLogin;
            DataCreazione = _dataCreazione;
            AziendaAssociata = _aziendaAssociata;
        }

    }
}
