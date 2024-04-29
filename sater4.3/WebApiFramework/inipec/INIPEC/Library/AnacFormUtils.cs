using Newtonsoft.Json;
using System;

namespace INIPEC.Library
{
    public static class AnacFormUtils
    {
        public static string getJsonWithOptAttrib(object obj)
        {
            var jsonSettings = new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore
            };

            // Serializzazione dell'oggetto in formato JSON
            return JsonConvert.SerializeObject(obj, jsonSettings);
        }
    }
}

namespace INIPEC.Library.DTO
{
    public class ConsultaAvviso
    {
        public int status { get; set; }
        public string title { get; set; }
        public string detail { get; set; }
        public string type { get; set; }
        public Avviso avviso { get; set; }
        //public SchedaConsulta scheda { get; set; }
        //public Appalto1 appalto { get; set; }
        //public object piano { get; set; }
    }

    public class Avviso
    {
        /*
        public string idAvviso { get; set; }
        public string idAppalto { get; set; }
        public string idPianificazione { get; set; }
        public DateTime dataCreazione { get; set; }
        public DateTime dataPubblicazione { get; set; }
        public TipologicaPCP stato { get; set; }
        public DateTime dataControllo { get; set; }
        public TipologicaPCP azione { get; set; }*/
        public DatiPubblicazioneEU datiPubblicazioneEU { get; set; }
        public DatiPubblicazioneIT datiPubblicazioneIT { get; set; }
    }

    public class TipologicaPCP
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class DatiPubblicazioneEU
    {
        public string noticeId { get; set; }
        public string versionId { get; set; }
        public TipologicaPCP tipo { get; set; }
        public TipologicaPCP stato { get; set; }
        public string publicationId { get; set; }
        public string publicationUrl { get; set; }
        public DateTime? dataControllo { get; set; }
        public DateTime? dataInoltroPubblicazione { get; set; }
        public DateTime? dataRicezionePubblicazione { get; set; }
        public DateTime? dataPubblicazione { get; set; }
    }

    public class DatiPubblicazioneIT
    {
        public string idAvvisoPVL { get; set; }
        public TipologicaPCP tipo { get; set; }
        public TipologicaPCP stato { get; set; }
        public DateTime? dataControllo { get; set; }
        public DateTime? dataInoltroPubblicazione { get; set; }
        public DateTime? dataPubblicazione { get; set; }
    }

    public class SchedaConsulta
    {
        public string _idScheda { get; set; }
        public TipologicaPCP stato { get; set; }
        public Codice codice { get; set; }
        public string versione { get; set; }
        public DateTime dataCreazione { get; set; }
        public BodyConsulta body { get; set; }
    }

    public class BodyConsulta
    {
        public AnacformConsulta anacForm { get; set; }
        //public string espd { get; set; }
        //public string eform { get; set; }
    }

    public class AnacformConsulta
    {
        public StazioniAppaltanti[] stazioniAppaltanti { get; set; }
        public AppaltoConsulta appalto { get; set; }
        public LottiConsulta[] lotti { get; set; }
    }

    public class AppaltoConsulta
    {
        public string codiceAppalto { get; set; }
        public TipologicaPCP[] categorieMerceologiche { get; set; }
    }

    public class StazioniAppaltanti
    {
        public string codiceFiscale { get; set; }
        public string codiceAusa { get; set; }
        public string codiceCentroCosto { get; set; }
        //public object[] funzioniSvolte { get; set; }
        public bool saTitolare { get; set; }
    }

    public class LottiConsulta
    {
        public string lotIdentifier { get; set; }
        public TipologicaPCP[] categorieMerceologiche { get; set; }
        public TipologicaPCP contrattiDisposizioniParticolari { get; set; }
        public TipologicaPCP codIstat { get; set; }
        public bool afferenteInvestimentiPNRR { get; set; }
        public bool acquisizioneCup { get; set; }
        public string[] cupLotto { get; set; }
        public Finanziamenti[] finanziamenti { get; set; }
        public bool servizioPubblicoLocale { get; set; }
        public bool saNonSoggettaObblighi24Dicembre2015 { get; set; }
        public bool iniziativeNonSoddisfacenti { get; set; }
        public bool lavoroOAcquistoPrevistoInProgrammazione { get; set; }
        public string ccnl { get; set; }
        public TipologicaPCP modalitaAcquisizione { get; set; }
        public bool opzioniRinnovi { get; set; }
        public IpotesiCollegamento ipotesiCollegamento { get; set; }
        public Categoria categoria { get; set; }
    }

    public class IpotesiCollegamento
    {
        public string[] cigCollegato { get; set; }
        public TipologicaPCP motivoCollegamento { get; set; }
    }

    public class Finanziamenti
    {
        public TipologicaPCP tipoFinanziamento { get; set; }
        public float importo { get; set; }
    }

    public class Appalto1
    {
        public string idAppalto { get; set; }
        public string codiceAppalto { get; set; }
        public string oggetto { get; set; }
        public DateTime dataCreazione { get; set; }
        public DateTime dataModifica { get; set; }
        public TipologicaPCP stato { get; set; }
    }

}