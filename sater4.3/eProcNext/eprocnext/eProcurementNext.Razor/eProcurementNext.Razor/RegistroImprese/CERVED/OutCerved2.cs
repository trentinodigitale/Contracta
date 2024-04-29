namespace eProcurementNext.RegistroImprese.CERVED
{


    public class OutCerved2
    {
        public Dati_Anagrafici2 dati_anagrafici { get; set; }
        public Dati_Attivita2 dati_attivita { get; set; }
        public Dati_Economici_Dimensionali dati_economici_dimensionali { get; set; }
    }

    public class Dati_Anagrafici2
    {
        public int id_soggetto { get; set; }
        public string denominazione { get; set; }
        public string codice_fiscale { get; set; }
        public string partita_iva { get; set; }
        public Indirizzo2 indirizzo { get; set; }
        public string telefono { get; set; }
        public string url_sito_web { get; set; }
        public Pec pec { get; set; }
    }

    public class Indirizzo2
    {
        public string toponimo { get; set; }
        public string denominazione { get; set; }
        public string civico { get; set; }
        public string cap { get; set; }
        public string codice_comune { get; set; }
        public string codice_comune_istat { get; set; }
        public string comune { get; set; }
        public string provincia { get; set; }
        public string frazione { get; set; }
        public string regione { get; set; }
        public string nazione { get; set; }
        public string area_geografica { get; set; }
    }

    public class Pec
    {
        public string[] email { get; set; }
    }

    public class Dati_Attivita2
    {
        public string codice_stato_attivita { get; set; }
        public string stato_attivita { get; set; }
        public bool flag_operativa { get; set; }
        public string data_costituzione { get; set; }
        public string natura_giuridica { get; set; }
        public string codice_rea { get; set; }
        public string data_iscrizione_rea { get; set; }
        public Ateco_Info ateco_info { get; set; }
        public Company_Form2 company_form { get; set; }
    }

    public class Ateco_Info
    {
        public Codifica_Ateco codifica_ateco { get; set; }
        public Codifica_Nace codifica_nace { get; set; }
        public Codifiche_Sic[] codifiche_sic { get; set; }
        public Codifica_Rae codifica_rae { get; set; }
        public Codifica_Sae codifica_sae { get; set; }
    }

    public class Codifica_Ateco
    {
        public string codice_ateco { get; set; }
        public string ateco { get; set; }
        public string codice_macrosettore { get; set; }
        public string macrosettore { get; set; }
    }

    public class Codifica_Nace
    {
        public string codice { get; set; }
        public string declaratoria { get; set; }
        public string descrizione { get; set; }
        public string declaratoria_inglese { get; set; }
        public string descrizione_inglese { get; set; }
    }

    public class Codifica_Rae
    {
        public string codice { get; set; }
        public string declaratoria { get; set; }
    }

    public class Codifica_Sae
    {
        public string codice { get; set; }
        public string declaratoria { get; set; }
    }

    public class Codifiche_Sic
    {
        public string codice { get; set; }
        public string declaratoria_inglese { get; set; }
        public string descrizione_inglese { get; set; }
    }

    public class Company_Form2
    {
        public string code { get; set; }
        public string description { get; set; }
        public string company_form_class { get; set; }
    }

    public class Dati_Economici_Dimensionali
    {
        public int numero_dipendenti { get; set; }
        public int anno_ultimo_bilancio { get; set; }
        public string data_chiusura_ultimo_bilancio { get; set; }
        public float fatturato { get; set; }
        public float capitale_sociale { get; set; }
        public string tipologia_capitale_sociale { get; set; }
        public float mol { get; set; }
        public float attivo { get; set; }
        public float patrimonio_netto { get; set; }
        public float utile_perdita_esercizio { get; set; }
    }


}
