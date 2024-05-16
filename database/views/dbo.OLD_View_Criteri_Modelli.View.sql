USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_View_Criteri_Modelli]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*recupera i criteri aggiudicazione di un lotto*/
CREATE VIEW [dbo].[OLD_View_Criteri_Modelli]
AS

select * from 
(
    select 
		idheader, value, dzt_name
    from 
		CTL_DOC M with(nolock) 
			inner join ctl_doc_value  p with(nolock) on M.Id=p.IdHeader
	where m.tipodoc = 'CONFIG_MODELLI_LOTTI'
			and m.deleted=0 and isnull( m.linkeddoc  , 0 ) = 0 and 
			dse_id in ('CRITERI','AMBITO')
        
) as P
    pivot
    (
		--la min è presente perchè ci serve una funzione di aggregazione mail dato è unicoper criterio
        min(value)
        for p.dzt_name in ([Conformita],[CriterioAggiudicazioneGara], [TipoProcedureApplicate],[MacroAreaMerc])
    ) as PIV
GO
