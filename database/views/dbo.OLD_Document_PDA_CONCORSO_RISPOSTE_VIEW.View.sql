USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_Document_PDA_CONCORSO_RISPOSTE_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[OLD_Document_PDA_CONCORSO_RISPOSTE_VIEW] as
	
	select
		
		o.IdRow, o.IdHeader, NumRiga, aziRagioneSociale, ProtocolloOfferta, ReceivedDataMsg, o.IdMsg, IdMittente, idAziPartecipante,
		
		case when StatoPDA='99' and ISNULL(ritiro.id,0) > 0 then '999' else StatoPDA end as StatoPDA 

		, o.TipoDoc
		--, case when isnull( BE.Value, 0 ) = 1 and StatoPDA <> '99' then '0' else '1' end as bReadEconomica
		, case when isnull( BD.Value,0 ) = 1 and StatoPDA <> '99' then '0' else '1' end as bReadDocumentazione
		
		, dbo.PDA_MICROLOTTI_ListaMotivazioni( o.idRow ) as Motivazione
		
		, o.VerificaCampionatura
		,o.warning
		,o.EsclusioneLotti
		,ISNULL(ritiro.id,0) as id_ritira_offerta
		,ISNULL(o.Avvalimento,'') as Avvalimento
		,ISNULL(o.stato_firma_PDA_AMM,'') as stato_firma_PDA_AMM
		, CASE when agg.idheader is null then null else '1' end as AggiudicatarioLotto
		
		, dbo.GetListaLottiOfferti( o.IdMsg ) as lottiOfferti
		, BA.Divisione_lotti


	from Document_PDA_OFFERTE o with(nolock)
		
		inner join CTL_DOC d with(nolock) on o.idHeader = d.id
		inner join document_bando BA with(nolock) on d.linkedDoc = BA.idheader
		--left outer join MessageStatus eco with(nolock) on isnull(o.Tipodoc , '') <> 'OFFERTA' and o.idMsg = eco.idmsg and eco.SectionName = 'MicroLotti' 
		--left outer join MessageStatus doc with(nolock) on isnull(o.Tipodoc , '') <> 'OFFERTA' and o.idMsg = doc.idmsg and doc.SectionName = 'DOCUMENTAZIONE'
		--left outer join CTL_DOC_VALUE BE with(nolock) on o.Tipodoc = 'RISPOSTA_CONCORSO' and o.idMsg = BE.idHeader and BE.DSE_ID = 'BUSTA_ECONOMICA' and BE.DZT_Name = 'LettaBusta' 
		left outer join CTL_DOC_VALUE BD with(nolock) on o.Tipodoc in ( 'RISPOSTA_CONCORSO') and o.idMsg = BD.idHeader and BD.DSE_ID = 'BUSTA_DOCUMENTAZIONE' and BD.DZT_Name = 'LettaBusta'
		left outer join ctl_doc ritiro with(nolock) on ritiro.LinkedDoc=o.IdMsg and ritiro.TipoDoc='RITIRA_RISPOSTA_CONCORSO' and ritiro.Deleted=0 and ritiro.StatoFunzionale='Inviato'

		-- recupera l'eventuale aggiudicazione che il fornitore ha su un lotto
		left join  ( select idheader   from  Document_MicroLotti_Dettagli with(nolock) 
							where  Posizione in ( 'Aggiudicatario definitivo','Aggiudicatario definitivo condizionato','Aggiudicatario provvisorio','Idoneo definitivo','Idoneo provvisorio' ) and voce = 0 and tipodoc = 'PDA_OFFERTE' 
							group by IdHeader ) as Agg on agg.IdHeader = o.IdRow

		



GO
