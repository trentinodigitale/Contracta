USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_SEDUTA_VIRTUALE_LST_LOTTI_TEC_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[OLD2_SEDUTA_VIRTUALE_LST_LOTTI_TEC_VIEW] as 
	
	select distinct 
				sv.id,
				Lp.id as lotto ,
				Lp.numerolotto , 
				Lp.Descrizione , 
				lp.StatoRiga , 
				case when lo.statoriga = 'Escluso' then null else lp.Aggiudicata end as Aggiudicata,
				case when lo.statoriga = 'Escluso' then null else lp.Aggiudicata end as  idAziPartecipante,
				'SEDUTA_VIRTUALE_LOTTO' as OPEN_DOC_NAME,
				psv.Lista_Lotti

		from ctl_doc sv with(nolock) 
             inner join ctl_doc b with(nolock) on b.id = sv.LinkedDoc --BANDO_GARA
             inner join ctl_doc p with(nolock) on b.id = p.LinkedDoc and p.deleted = 0 and p.tipodoc = 'PDA_MICROLOTTI'
             inner join Document_PDA_OFFERTE op with(nolock) on op.idheader = p.id and op.idAziPartecipante = sv.Azienda
             inner join document_microlotti_dettagli lp with(nolock) on lp.idheader = p.id and  lp.TipoDoc = 'PDA_MICROLOTTI' and lp.Voce = 0
             left join document_microlotti_dettagli lo with(nolock) on lo.idheader = op.idrow and  lo.TipoDoc = 'PDA_OFFERTE' and lo.voce = 0  and lo.numerolotto = lp.NumeroLotto
             inner join ctl_doc o with(nolock) on b.id = o.LinkedDoc and o.deleted = 0 and o.tipodoc = 'OFFERTA' and op.IdMsg = o.id
             inner join Document_Parametri_Sedute_Virtuali psv with(nolock) on psv.deleted = 0 
			 where sv.TipoDoc='SEDUTA_VIRTUALE' and      
				 ( 
                           ( psv.Visibilita_Lotti = 'tutti' )
                           or
                           ( psv.Visibilita_Lotti = 'partecipanti' and lo.id is not null )
                    )





GO
