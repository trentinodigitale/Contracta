USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PDA_DRILL_MICROLOTTO_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [dbo].[OLD_PDA_DRILL_MICROLOTTO_TESTATA_VIEW]  as
select 
		
		 ModelloPDA_DrillTestata
		, ModelloPDA_DrillLista
		, l.* 
		, c.Conformita  
		, c.CriterioAggiudicazioneGara
		, t.StatoFunzionale
		, c.CalcoloAnomalia
		, coalesce(CEco.UtenteCommissione,CU.UtenteCommissione,0) as PresAgg
		, isnull(B.TipoSceltaContraente,'') as TipoSceltaContraente
		, case when CT.DataScadenza < GETDATE()  or ISNULL(num.count_risposte_da_inviare,1) = 0 or num.LinkedDoc is null then '1' else '0' end as CAN_TERMINA

		--disattiviamo il comando "Verifica Anomalia" se il numero di offerte ammesse è inferiore a 5  , la gara è al prezzo e la data invio bando è >= 20-05-2017 
		, case when offers.numOff < 5 and c.CriterioAggiudicazioneGara = 15531 and gara.DataInvio >= '2017-05-20' then '1' else '0' end as bloccaVerificaAnomalia
		--, dbo.get_APERTURA_BUSTE_FROM_LOTTO(l.Id)  as APERTURA_BUSTE 
		, 1 as APERTURA_BUSTE
		, c.TipoAggiudicazione , b.RegoleAggiudicatari

		, dbo.ListRiferimentiBando(t.linkeddoc , 'Bando' ) as UsersRiferimentiBando
		, rup.Value as UserRUP
		, b.Visualizzazione_Offerta_Tecnica

		, par.value as AttivaFilePending

	 from 
		--commentato uso perchè pesante e ritorna molte colonne non utili
		--PDA_MICROLOTTI_VIEW_TESTATA t with(nolock)
		
		CTL_DOC t with(nolock)
		
			inner join Document_PDA_TESTATA TP with(nolock) on t.id = TP.idheader
			inner join document_bando b with(nolock) on b.idheader = t.Linkeddoc
			inner join ctl_doc gara with(nolock) on gara.id = t.LinkedDoc

			left outer join ctl_doc_value rup with(nolock) on t.LinkedDoc = rup.idHeader and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
			left outer join ctl_doc_value par with(nolock) on par.idHeader = gara.id and  par.dzt_name = 'AttivaFilePending' and par.dse_id = 'PARAMETRI'

			left outer join Document_Modelli_MicroLotti m with(nolock) on m.Codice = TP.ListaModelliMicrolotti
		
			left outer join Document_Microlotti_Dettagli tl with(nolock) on tl.idheader = t.id and tl.tipoDoc = 'PDA_MICROLOTTI' and tl.Voce = 0 and tl.NumeroLotto = '1'

		
			left outer join ctl_doc COM with(nolock) on COM.linkeddoc=t.linkeddoc and COM.tipodoc='COMMISSIONE_PDA' and COM.deleted=0 and COM.statofunzionale='pubblicato'
			left outer join Document_CommissionePda_Utenti CU with(nolock) on COM.id=CU.idheader and CU.TipoCommissione='A' and CU.ruolocommissione='15548'
			left outer join Document_CommissionePda_Utenti CEco with(nolock) on COM.id=CEco.idheader and CEco.TipoCommissione='C' and CEco.ruolocommissione='15548'
		
		
			inner join PDA_LISTA_MICROLOTTI_VIEW l with(nolock) on l.idDoc = t.id

			inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO c with(nolock) on t.LinkedDoc = c.idBando and l.NumeroLotto = c.N_Lotto

			--recupero il documento di offerta migliorativa se esiste
			left join ctl_doc CT with(nolock) on CT.tipodoc='PDA_COMUNICAZIONE' and CT.LinkedDoc=l.idDoc and CT.VersioneLinkedDoc=l.id and CT.StatoFunzionale in ( 'Inviato','Inviata Risposta') and CT.JumpCheck='1-OFFERTA'

			--recupero numero di risposte da inviare
			left join (select count(*) as count_risposte_da_inviare,LinkedDoc from ctl_doc with(nolock) where  tipodoc='PDA_COMUNICAZIONE_OFFERTA'  and statofunzionale <> 'Inviata Risposta' group by LinkedDoc ) as num on num.LinkedDoc=CT.id

			left join (  
					select count(a1.IdRow) as numOff, a1.IdHeader, a2.NumeroLotto
							from Document_PDA_OFFERTE a1 with(nolock)
									inner join Document_MicroLotti_Dettagli a2 with(nolock) on a2.IdHeader = a1.IdRow and a2.TipoDoc = 'PDA_OFFERTE'
							where a1.StatoPDA in ( '2' ,'22' , '222' ,'9') --ammessa=2 ammessa con riserva=22 ammessa ex art
									and a2.StatoRiga not in ( 'esclusoEco' , 'escluso' , 'anomalo' , 'decaduta' , 'NonConforme') -- <> 'escluso'
									and a2.Voce = 0
							group by a1.IdHeader, a2.NumeroLotto
					) as offers on offers.IdHeader = t.id and offers.NumeroLotto = l.NumeroLotto


	
	


GO
