USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_AVCP_ELENCO_PARTECIPANTI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[OLD_DASHBOARD_VIEW_AVCP_ELENCO_PARTECIPANTI]  as


	select distinct
			C.id,
			c.id as IdHEader, 		
			case when c.tipodoc = 'AVCP_GRUPPO' THEN '' ELSE ISNULL(L.Codicefiscale,'') END as Codicefiscale,
			--ISNULL(L.Ragionesociale,V2.Value) as aziragionesociale, 
			ISNULL(V2.Value,L.Ragionesociale) as aziragionesociale,
			ISNULL(L.aggiudicatario,V3.Value ) as aggiudicatario,
			C.LinkedDoc,
			C.LinkedDoc as Versione,
			 C.tipodoc as OPEN_DOC_NAME,
			V.Value as aziIdDscFormaSoc		
			, s.id as idheader_doc	
			, l.Estero
	from CTL_DOC C  with(nolock) 
			left join document_AVCP_partecipanti L with(nolock)  on c.Statofunzionale in ( 'Pubblicato','Annullato' ) and c.deleted=0  and C.TipoDoc in ('AVCP_GRUPPO','AVCP_OE') and L.idHeader=C.id --and C.TipoDoc = ( 'AVCP_OE')
			left join ctl_doc_value V  with(nolock) on V.idheader =C.id and V.DZT_NAME='aziIdDscFormaSoc' and V.DSE_ID='TESTATA'
			left join ctl_doc_value V2  with(nolock) on V2.idheader =C.id and V2.DZT_NAME='RagioneSociale' and V2.DSE_ID='TESTATA'
			left join ctl_doc_value V3  with(nolock) on V3.idheader =C.id and V3.DZT_NAME='Aggiudicatario' and V3.DSE_ID='TESTATA'
			inner join ctl_doc s  with(nolock) on s.versione = c.LinkedDoc and s.tipodoc in ( 'AVCP_LOTTO' )  and s.deleted = 0 and s.StatoFunzionale = 'Pubblicato'
	where C.TipoDoc in ('AVCP_GRUPPO','AVCP_OE') and c.Statofunzionale in ( 'Pubblicato' ,'Annullato' ) and c.deleted=0











GO
