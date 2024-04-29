using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eProcurementNext.Core.PDND
{
    public class AnacForm
    {
        public List<StazioniAppaltanti> stazioniAppaltanti { get; set; }
        public Appalto appalto { get; set; }
        public string eform { get; set; }
        public string espd { get; set; }
    }

    public class Appalto
    {
        public string codiceAppalto { get; set; }
        public List<CategorieMerceologiche> categorieMerceologiche { get; set; }
        public string strumentiSvolgimentoProcedure { get; set; }
        public string contrattiDisposizioniParticolari { get; set; }
        public List<MotivoUrgenza> motivoUrgenza { get; set; }
        public string linkDocumenti { get; set; }
        //public DatiBase datiBase { get; set; }
        //public DatiBaseProcedura datiBaseProcedura { get; set; }
        //public DatiBaseStrumentiProcedura datiBaseStrumentiProcedura { get; set; }
        public List<Lotti> lotti { get; set; }
    }

    public class Body
    {
        public AnacForm anacForm { get; set; }
    }

    public class Categoria
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class CategorieMerceologiche
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class Codice
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class CodIstat
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class CondizioniNegoziatum
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class ContrattiDisposizioniParticolari
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class TipologiaLavoro
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class DatiBase
    {
        public string oggetto { get; set; }
        public int importo { get; set; }
        public string oggettoContratto { get; set; }
    }

    public class DatiBaseAccessibilità
    {
        public string accessibilit { get; set; }
        public string giustificazione { get; set; }
    }

    public class DatiBaseAggiudicazione
    {
        public string criteriAggiudicazione { get; set; }
    }

    public class DatiBaseAggiuntivi
    {
        public string affidamentiRiservati { get; set; }
    }

    public class DatiBaseContratto
    {
        public string codNUTS { get; set; }
    }

    public class DatiBaseCPV
    {
        public string tipoClassificazione { get; set; }
        public string cpvPrevalemte { get; set; }
        public List<string> cpvSecondarie { get; set; }
    }

    public class DatiBaseDocumenti
    {
        public string url { get; set; }
        public List<string> lingue { get; set; }
    }

    public class DatiBaseImporto
    {
        public bool contrattiSuccessivi { get; set; }
    }

    public class DatiBaseProcedura
    {
        public TipoProcedura tipoProcedura { get; set; }
        public bool proceduraAccelerata { get; set; }
        public GiustificazioniAggiudicazioneDiretta giustificazioniAggiudicazioneDiretta { get; set; }
    }

    public class DatiBaseStrumentiProcedura
    {
        public string accordoQuadro { get; set; }
        public string sistemaDinamicoAcquisizione { get; set; }
        public string astaElettronica { get; set; }
    }

    public class DatiBaseTermineInvio
    {
        public string scadenzaPresentazioneInvito { get; set; }
        public string oraScadenzaPresentazioneInvito { get; set; }
    }

    public class GiustificazioniAggiudicazioneDiretta
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class Lotti
    {
        public string lotIdentifier { get; set; }
        public List<CategorieMerceologiche> categorieMerceologiche { get; set; }
        public List<CondizioniNegoziatum> condizioniNegoziata { get; set; }
        public ContrattiDisposizioniParticolari contrattiDisposizioniParticolari { get; set; }
        public CodIstat codIstat { get; set; }
        public bool afferenteInvestimentiPNRR { get; set; }
        public bool acquisizioneCup { get; set; }
        public List<string> cupLotto { get; set; }
        public string motivoEsclusioneOrdinarioSpeciale { get; set; }
        public string modalitaAcquisizione { get; set; }
        public string oggettoPrincipaleContratto { get; set; }
        public List<PrestazioniComprese> prestazioniComprese { get; set; }
        public bool servizioPubblicoLocale { get; set; }
        public bool ripetizioniEConsegneComplementari { get; set; }
        public bool lavoroOAcquistoPrevistoInProgrammazione { get; set; }
        public string cui { get; set; }
        public string ccnl { get; set; }
        public List<TipologiaLavoro> tipologiaLavoro { get; set; }
        public bool opzioniRinnovi { get; set; }
        public Categoria categoria { get; set; }
        public QuadroEconomicoStandard? quadroEconomicoStandard { get; set; }
        //public DatiBase datiBase { get; set; }
        //public DatiBaseContratto datiBaseContratto { get; set; }
        //public DatiBaseAggiuntivi datiBaseAggiuntivi { get; set; }
        //public DatiBaseAggiudicazione datiBaseAggiudicazione { get; set; }
        //public DatiBaseTermineInvio datiBaseTermineInvio { get; set; }
        //public DatiBaseImporto datiBaseImporto { get; set; }
        //public DatiBaseCPV datiBaseCPV { get; set; }
        //public DatiBaseAccessibilità datiBaseAccessibilit { get; set; }
        //public DatiBaseDocumenti datiBaseDocumenti { get; set; }
    }

    public class FunzioniSvolte
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class MotivoUrgenza
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class PrestazioniComprese
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class QuadroEconomicoStandard
    {
        public int impLavori { get; set; }
        public int impServizi { get; set; }
        public int impForniture { get; set; }
        public int impTotaleSicurezza { get; set; }
        public int ulterioriSommeNoRibasso { get; set; }
        public int impProgettazione { get; set; }
        public int sommeOpzioniRinnovi { get; set; }
        public int sommeRipetizioni { get; set; }
        public int sommeADisposizione { get; set; }
    }

    public class BaseModel
    {
       public Scheda scheda { get; set; }
    }

    public class Scheda
    {
        public string _idScheda { get; set; }
        public Codice codice { get; set; }
        public string versione { get; set; }
        public Stato _stato { get; set; }
        public DateTime _dataCreazione { get; set; }
        public Body body { get; set; }
    }

    public class Stato
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }

    public class StazioniAppaltanti
    {
        public string codiceFiscale { get; set; }
        public string codiceAusa { get; set; }
        public string codiceCentroCosto { get; set; }
        public List<FunzioniSvolte> funzioniSvolte { get; set; }
        public bool saTitolare { get; set; }
    }

    public class TipoProcedura
    {
        public string idTipologica { get; set; }
        public string codice { get; set; }
    }


}
