USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_PROGRAMMAZIONE_IA_TESTATA_VIEW ]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_BANDO_PROGRAMMAZIONE_IA_TESTATA_VIEW ]  as 

select 
	 b.idRow, SoggettiAmmessi, ImportoBando, MaxNumeroIniziative, MaxFinanziabile, dataCreazione, DataEstenzioneInizio, DataEstenzioneFine, FAX, DataRiferimentoInizio, DataRiferimentoFine, DataPresentazioneRisposte, StatoBando, Ufficio, NumeroBUR, DataBUR, dgrN, dgrDel, TipoBando, TipoAppalto, RichiestaQuesito, ReceivedQuesiti, RecivedIstanze, MotivoEstensionePeriodo, ClasseIscriz, RichiediProdotti, ProceduraGara, TipoBandoGara, CriterioAggiudicazioneGara, ImportoBaseAsta, Iva, ImportoBaseAsta2, Oneri, CriterioFormulazioneOfferte, CalcoloAnomalia, OffAnomale, NumeroIndizione, DataIndizione, gg_QuesitiScadenza, DataTermineQuesiti, ClausolaFideiussoria, VisualizzaNotifiche, CUP, CIG, GG_OffIndicativa, HH_OffIndicativa, MM_OffIndicativa, DataScadenzaOffIndicativa, GG_Offerta, HH_Offerta, MM_Offerta, DataScadenzaOfferta, GG_PrimaSeduta, HH_PrimaSeduta, MM_PrimaSeduta, DataAperturaOfferte, TipoAppaltoGara, ProtocolloBando, DataRevoca, Conformita, Divisione_lotti, NumDec, DirezioneEspletante, DataProtocolloBando, ModalitadiPartecipazione, TipoIVA, EvidenzaPubblica, Opzioni, Complex, RichiestaCampionatura, TipoGiudizioTecnico, TipoProceduraCaratteristica, GeneraConvenzione, ListaAlbi, Appalto_Verde, Acquisto_Sociale, Motivazione_Appalto_Verde, Motivazione_Acquisto_Sociale, Riferimento_Gazzetta, Data_Pubblicazione_Gazzetta, BaseAstaUnitaria, IdentificativoIniziativa 
	, d.Azienda 
	, d.richiestafirma
	, d.Body
	,CD.idrow as Idheader
	
from CTL_DOC_Destinatari CD 
	inner join CTL_DOC d on CD.idHeader=D.id
	left join Document_Bando b on d.id = b.idheader
--where d.tipodoc='BANDO_FABBISOGNI' and deleted=0

GO
