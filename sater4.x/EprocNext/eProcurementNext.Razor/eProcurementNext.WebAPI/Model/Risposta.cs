namespace eProcurementNext.WebAPI.Model
{
    public class Risposta : RispostaBase
    {

        public string? idAppalto { get; set; }

    }

    public class Errori
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
        public string dettaglio { get; set; }
    }

    public class RispostaBase
    {
        public int status { get; set; }
        public string detail { get; set; }
        public string title { get; set; }
        public string type { get; set; }
        public List<Errori>? errori { get; set; }
    }

    public class RispostaCig : RispostaBase
    {
        public int totRows { get; set; }
        public int totPages { get; set; }
        public int currentPage { get; set; }
        public int elementPage { get; set; }
        public List<Tipologica>? result { get; set; }

    }

    public class Tipologica
    {
        public string cig { get; set; }
        public string lotIdentifier { get; set; }
    }
    public class RispostaServizi : RispostaBase
    {
        public List<ListaEsiti>? listaEsiti { get; set; }
        public class Dettaglio
        {
            public string idTipologica { get; set; }
            public string codice { get; set; }
        }

        public class Esito
        {
            public string idTipologica { get; set; }
            public string codice { get; set; }
        }

        public class ListaEsiti
        {
            public string idAppalto { get; set; }
            public string idScheda { get; set; }
            public string idAvviso { get; set; }
            public Esito esito { get; set; }
            public TipoOperazione tipoOperazione { get; set; }
            public DateTime dataControllo { get; set; }
            public Dettaglio dettaglio { get; set; }
            public List<Errori> errori { get; set; }
        }

        public class TipoOperazione
        {
            public string idTipologica { get; set; }
            public string codice { get; set; }
        }
    }
}
