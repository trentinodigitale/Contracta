USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_DRILL_MICROLOTTO_TESTATA_RIEPILOGO_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [dbo].[PDA_DRILL_MICROLOTTO_TESTATA_RIEPILOGO_VIEW]  as


select 
		
		 l.id
		 ,t.IdPfu, t.IdDoc, t.TipoDoc, t.StatoDoc, t.Data, t.Protocollo, t.PrevDoc, 
		 t.Deleted, t.Titolo, t.Body, t.Azienda, t.StrutturaAziendale, t.DataInvio, 
		 t.DataScadenza, t.ProtocolloRiferimento, t.ProtocolloGenerale, 
		 t.Fascicolo, t.Note, t.DataProtocolloGenerale, t.LinkedDoc, 
		 t.SIGN_HASH, t.SIGN_ATTACH, t.SIGN_LOCK, t.JumpCheck, t.StatoFunzionale, 
		 t.Destinatario_User, t.Destinatario_Azi, t.RichiestaFirma, t.NumeroDocumento, 
		 t.DataDocumento, t.Versione, t.VersioneLinkedDoc, t.idRow, t.idHeader, t.ImportoBaseAsta, t.ImportoBaseAsta2, t.DataAperturaOfferte, 
		 
		 t.ModalitadiPartecipazione, 
		 t.CriterioFormulazioneOfferte, 
		 t.CUP, t.CIG, t.DataIISeduta, t.NumeroIndizione, t.DataIndizione, t.NRDeterminazione, t.Oggetto, t.DataDetermina, t.ListaModelliMicrolotti, t.ModelloPDA, t.ModelloPDA_DrillTestata, t.ModelloPDA_DrillLista, t.ModelloOfferta_Drill
		, l.CIG as CIG_LOTTO , 	l.NumeroLotto , l.Descrizione
		
		
		, l.StatoRiga , l.aziRagioneSociale
		, t.divisione_lotti , l.ValoreImportoLotto


		---- CRITERI AGGIUDICAZIONE
		--, t.CriterioAggiudicazioneGara 
		--, t.Conformita 
		--, t.CalcoloAnomalia --???
		--, t.OffAnomale

		----CRITERI_ECO
		----PunteggioEconomico ??
		----PunteggioTecnico ??
		----PunteggioTecMin
		----FormulaEcoSDA
		----Coefficiente_X

		--, t.PunteggioTEC_100
		--, t.PunteggioTEC_TipoRip

		--, t.TipoSceltaContraente

		-------------------------
		-- CRITEREI DI VALUTAZIONE
		-------------------------
		, c.*
		--, isnull(CU.UtenteCommissione,0) as PresAgg
		, t.PresAgg

		, t.PresTec
		, case when l.StatoRiga in ( 'daValutare', 'InValutazione' ) then '1' else '0' end as InValutazione
		,t.Concessione
		--,dbo.get_APERTURA_BUSTE_FROM_LOTTO_TEC (l.Id) as APERTURA_BUSTE_TECNICHE
		, 1 as APERTURA_BUSTE_TECNICHE
		--RECUPERO DEL PARAMETRO per la rappresentazione dei riepiloghi tecnici ed economici ( riepilogo finale ) , 
		--di base in presenza di riparametrazione vengono nascoste le colonne dei punteggi non riparametrati. 
		--questo parametro consente di non nascondere le colonne consentendo di avere un raffronto fra il punteggio ottenuto 
		--con la riparametrazione e quello ottenuto inizialmente.
		--, dbo.PARAMETRI('PDA_MICROLOTTI','PUNTEGGI_ORIGINALI','SHOW','NO',-1) as PUNTEGGI_ORIGINALI
		,P.PUNTEGGI_ORIGINALI		

		, t.AttivaFilePending
		
		--presnti in PDA_LISTA_MICROLOTTI_VIEW e non più in BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO
		, l.num_criteri_eco 
		,l.ValutazioneSoggettiva
		,t.Lista_Utenti_Commissione
		,t.UserRUP
	 from 
	 
		--PDA_MICROLOTTI_VIEW_TESTATA t with(nolock)
		
		--inner join PDA_LISTA_MICROLOTTI_VIEW l with(nolock)on l.idDoc = t.id
		
		PDA_LISTA_MICROLOTTI_VIEW l with(nolock)

		inner join PDA_MICROLOTTI_VIEW_TESTATA t with(nolock) on l.idDoc = t.id
		
		inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO c with(nolock) on t.LinkedDoc = c.idBando and l.NumeroLotto = c.N_Lotto
		--left outer join ctl_doc COM with(nolock)on COM.linkeddoc=t.linkeddoc and COM.tipodoc='COMMISSIONE_PDA' and COM.deleted=0 and COM.statofunzionale='pubblicato'
		--left outer join Document_CommissionePda_Utenti CU with(nolock)on COM.id=CU.idheader and CU.TipoCommissione='A' and CU.ruolocommissione='15548'
		
		--left outer join Document_CommissionePda_Utenti CTec with(nolock) on COM.id=CTec.idheader and CTec.TipoCommissione='G' and CTec.ruolocommissione='15548'
		cross join ( select dbo.PARAMETRI('PDA_MICROLOTTI','PUNTEGGI_ORIGINALI','SHOW','NO',-1) as PUNTEGGI_ORIGINALI  ) as P




GO
