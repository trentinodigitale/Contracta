namespace eProcurementNext.RegistroImprese.CERVED
{

    public class OutCerved1
    {
        public int peopleTotalNumber { get; set; }
        public int companiesTotalNumber { get; set; }
        public Company[] companies { get; set; }
        public object[] people { get; set; }
    }

    public class Company
    {
        public Dati_Anagrafici dati_anagrafici { get; set; }
        public Dati_Attivita dati_attivita { get; set; }
        public Dati_Pa dati_pa { get; set; }
    }

    public class Dati_Anagrafici
    {
        public int id_soggetto { get; set; }
        public string denominazione { get; set; }
        public string codice_fiscale { get; set; }
        public string partita_iva { get; set; }
        public Indirizzo indirizzo { get; set; }
    }

    public class Indirizzo
    {
        public string descrizione { get; set; }
        public string cap { get; set; }
        public string codice_comune { get; set; }
        public string descrizione_comune { get; set; }
        public string codice_comune_istat { get; set; }
        public string provincia { get; set; }
        public string descrizione_provincia { get; set; }
    }

    public class Dati_Attivita
    {
        public string codice_ateco { get; set; }
        public string ateco { get; set; }
        public string codice_stato_attivita { get; set; }
        public bool flag_operativa { get; set; }
        public string codice_rea { get; set; }
        public Company_Form company_form { get; set; }
    }

    public class Company_Form
    {
        public string code { get; set; }
        public string description { get; set; }
        public string company_form_class { get; set; }
    }

    public class Dati_Pa
    {
        public bool ente { get; set; }
        public bool fornitore { get; set; }
        public bool partecipata { get; set; }
    }

}
