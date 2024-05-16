USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_ANDAMENTO_ASTA_RIEPILOGO_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   view [dbo].[OLD_ANDAMENTO_ASTA_RIEPILOGO_VIEW] as
select 
		A.id as Idheader
		,isnull(O.id,0) as IdRow
		,isnull(O.id,0) as ID_DOC
		,D.aziRagioneSociale
		,isnull(O1.value,0) as ValoreEconomico
		,isnull(O2.value,0) as PunteggioTecnico
		,isnull(O3.value,0) as PunteggioEconomico
		,isnull(O4.value,0) as ValoreOfferta
		,isnull(O4.value,0) as ValoreOffertaSconto
		,O.statoFunzionale
		,isnull(ARD.Graduatoria,1000) as Graduatoria
		,'OFFERTA_ASTA' as OPEN_DOC_NAME

		from 
			ctl_doc A
			inner join ctl_doc_destinatari D on D.idHeader=A.id 
			left outer join
				ctl_doc O on O.TipoDoc='OFFERTA_ASTA' and O.LinkedDoc=A.id and O.StatoFunzionale='Inviato' and O.Azienda=D.idazi
			left outer join
				(select max (idrow) as idrow, idheader,idaziFornitore  from document_asta_rilanci group by idheader,idaziFornitore) TOPR on TOPR.idheader=A.id and TOPR.idaziFornitore=D.idazi
			left outer join
				document_asta_rilanci AR on AR.idrow=TOPR.idrow 
			left outer join
				document_microlotti_dettagli ARD on ARD.id=AR.idheaderlottoOff
			left outer join
				ctl_doc_value O1 on O1.IdHeader=O.id and O1.DSE_ID='TOTALI' and O1.DZT_Name='ValoreEconomico'
			left outer join
				ctl_doc_value O2 on O2.IdHeader=O.id and O2.DSE_ID='TOTALI' and O2.DZT_Name='PunteggioTecnico'
            left outer join
				ctl_doc_value O3 on O3.IdHeader=O.id and O3.DSE_ID='TOTALI' and O3.DZT_Name='PunteggioEconomico'
			left outer join
				ctl_doc_value O4 on O4.IdHeader=O.id and O4.DSE_ID='TESTATA_PRODOTTI' and O4.DZT_Name='ValoreOfferta'

		where A.TipoDoc = 'BANDO_ASTA'
			  and A.statoDoc='Sended'	
			  --and A.id=73403	
GO
