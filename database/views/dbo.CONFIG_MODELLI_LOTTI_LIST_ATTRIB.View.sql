USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONFIG_MODELLI_LOTTI_LIST_ATTRIB]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[CONFIG_MODELLI_LOTTI_LIST_ATTRIB] as 
select a.name
	from syscolumns a, sysobjects b
	where a.id = b.id
	   and b.name = 'Document_MicroLotti_Dettagli'
		and a.name not in (
				'Id'
				,'IdHeader'
				,'TipoDoc'
				,'Graduatoria'
				,'Sorteggio'
				,'Posizione'
				,'Aggiudicata'
				,'Exequo'
				,'StatoRiga'
				,'EsitoRiga'
				,'ValoreOfferta'
				,'NumeroLotto'
				--,'CodiceAIC'
				,'CIG'				
				,'ValoreAccessorioTecnico'
				,'TipoAcquisto'
				,'Subordinato'
				,'ArticoliPrimari'
				,'SelRow'
				,'Erosione'
				,'Variante'
				,'PesoVoce'
				,'NumeroRiga'
				,'ValoreEconomico'
				,'PunteggioTecnico'
				,'ValoreImportoLotto'
				,'idHeaderLotto'
				,'Voce'
				,'ValoreSconto'
				,'ValoreRibasso'
				,'PunteggioTecnicoAssegnato'
				,'PunteggioTecnicoRiparCriterio'
				,'PunteggioTecnicoRiparTotale'
				--ATTRIBUTI RIMOSSI DAL FOGLIO
				,'ClasseRimborsoMedicinale'
				,'CodiceProdotto'
				,'EstremiGURI'
				,'ImportoAnnuoLotto'
				,'importoBaseAsta'
				,'ImportoBaseAstaUnitaria'
				,'ImportoTriennaleLotto'
				,'MarcaturaCE'
				,'NumeroCampioni'
				,'PrezzoInLettere'
				,'PrezzoUnitario'
				,'PrezzoUnitarioOfferta'
				,'PrezzoUnitarioRiferimento'
				,'PrezzoVenditaConfezione'
				,'PrezzoVenditaUnitario'
				,'Qty'
				--,'RagSocProduttore'
				,'ScontoObbligatorioUnitario'
				,'ScontoUlteriore'
				,'ScorporoIVA'
				,'TotaleOffertaUnitario'
				,'Versamento'
				--,'Certificazioni'
				,'CODICE_AZIENDA_SANITARIA'
				,'DenominazioneProdotto'
				,'DESCRIZIONE_CND'
				,'DESCRIZIONE_CODICE_CPV'
				,'DescrizioneAIC'
				,'IDENTIFICATIVO_OGGETTO_INIZIATIVA'
				
				-- escluso perchè sostituito da equivalente numerico
				,'ONERI_SICUREZZA'
				,'CONTENUTO_DI_UM_CONFEZIONE'
				--Escluso perchè duplicato
				,'NUMERO_UNITA_POSOLOGICA_CONTENUTA_INT_BANCALE'
				--Escluso perchè campo tecnico
				,'PercAgg'
				,'PunteggioEconomicoAssegnato'
				,'AmpiezzaGamma'
		)
		and a.name not in ( select REL_ValueInput from CTL_Relations with(nolock) where REL_Type = 'CONFIG_MODELLI_LOTTI_LIST_ATTRIB_NOT_IN' )










GO
