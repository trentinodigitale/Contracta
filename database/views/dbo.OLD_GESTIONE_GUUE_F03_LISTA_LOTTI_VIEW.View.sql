USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_GESTIONE_GUUE_F03_LISTA_LOTTI_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_GESTIONE_GUUE_F03_LISTA_LOTTI_VIEW] as
select 
	CV.IdHeader,
	CV.IdRow,
	CV.Value as IdLotto,
	DT.NumeroLotto,
	ISNULL(DT.Descrizione,DT.DESCRIZIONE_CODICE_REGIONALE) as Descrizione,
	C_DELTA.StatoFunzionale,
	C_DELTA.body as EsitoRiga,
	C_DELTA.id as id_delta,
	'DELTA_TED_AGGIUDICAZIONE' as OPEN_DOC_NAME,
	isnull(cast(Z.N as varchar(100)),'0') +  '/' + CV_agg.value as colonnatecnica
	from 
		ctl_doc G_GUUE with (nolock) 
			inner join ctl_doc_value CV with(nolock) on CV.IdHeader = G_GUUE.id and CV.DSE_ID='LISTA_LOTTI' and cv.DZT_Name='IdLotto'
			
			left join ctl_doc_value C2 with (nolock) on C2.idheader = id and C2.DSE_ID='DELTA_TED_AGGIUDICAZIONE' and C2.DZT_Name='Id' and C2.Row = CV.Row

			inner join Document_MicroLotti_Dettagli DT with(nolock) on DT.Id=CV.Value  --accediamo con id del lotto della convenzione
			--recupero informazione numero aggiudicatami (M) inserita in creazione della Gestione GUUE
			inner join ctl_doc_value CV_agg with(nolock) on CV_agg.idheader=CV.idheader and  CV.row=CV_agg.Row and CV_agg.DSE_ID='LISTA_LOTTI' and CV_agg.DZT_Name='Num_Aggiudicatari'  
			--recupero il numero di documenti GESTIONE_GUUE_F03 con stesso idlotto
			left join  (
						--select count(*) as num,TED_CIG_AGG 
						--	from Document_TED_Aggiudicazione with(nolock)  
						--		inner join ctl_doc C with(nolock) on C.Id=idHeader and C.TipoDoc='DELTA_TED_AGGIUDICAZIONE' and C.Deleted=0
						--	group by TED_CIG_AGG) Z on  Z.TED_CIG_AGG=DT.cig

						select 
							C2.value as IdTed , count(*) as N
							 --* 
							from 
								ctl_doc with(nolock)
									--inner join ctl_doc_value C1 with (nolock) on C1.idheader = id and C1.DSE_ID='LISTA_LOTTI' and C1.DZT_Name='IdLotto'
									inner join ctl_doc_value C2 with (nolock) on C2.idheader = id and C2.DSE_ID='DELTA_TED_AGGIUDICAZIONE' and C2.DZT_Name='Id' --and C2.Row = C1.Row
							where
								tipodoc='GESTIONE_GUUE_F03' and Deleted=0
							group by C2.value


						) Z on IdTed = C2.value

			left join ctl_doc_value CV_DELTA with(nolock) on CV_DELTA.idheader=CV.idheader and CV.row=CV_DELTA.Row and CV_DELTA.DSE_ID='DELTA_TED_AGGIUDICAZIONE'  and CV_DELTA.DZT_Name='Id' 
			left join ctl_doc C_DELTA with(nolock) on C_DELTA.id=CV_DELTA.Value and C_DELTA.TipoDoc='DELTA_TED_AGGIUDICAZIONE'
	where 
		G_GUUE.tipodoc='GESTIONE_GUUE_F03'  and G_GUUE.Deleted=0
		
GO
