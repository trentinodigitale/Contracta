USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_PROGRAMMAZIONE_DESTINATARI_INFO_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_BANDO_PROGRAMMAZIONE_DESTINATARI_INFO_VIEW] as


select 
		C.id,
		ISNULL(CV.Value,0) as NumeroPartecipanti,
		ISNULL(DB.RecivedIstanze,0) as NumeroRisposte,
		case when ISNULL(CV.Value,0) > 0 then 
				cast(ISNULL(DB.RecivedIstanze,0) as float)/cast(ISNULL(CV.Value,0) as float) * 100 
				else 0 
		end as Percentuale_Risposte
		--sum( case when  isnull( idHeader , 0 ) <> 0 then 1 else 0 end ) as NumeroPartecipanti,
		--sum( case when  StatoIscrizione='Completato' then 1 else 0 end ) as NumeroRisposte,
		--case when count(*) > 0 then ( sum( case when  StatoIscrizione='Completato' then 1 else 0 end ) / count(*) ) * 100 else null end as Percentuale_Risposte



	from
		ctl_doc C
		left outer join Document_Bando DB on DB.idHeader=C.id
	--	left outer join CTL_DOC_Destinatari CD on CD.idHeader=id and Seleziona='Includi' 
		left outer join CTL_DOC_VALUE CV on CV.IdHeader=C.id and DSE_ID='NUMERO_PARTECIPANTI' and DZT_Name='NUMEROPARTECIPANTI'
	where C.tipodoc='BANDO_PROGRAMMAZIONE' and C.deleted=0
	--group by id

GO
