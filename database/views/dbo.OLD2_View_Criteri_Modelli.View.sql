USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_View_Criteri_Modelli]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*recupera i criteri aggiudicazione di un lotto*/
CREATE VIEW [dbo].[OLD2_View_Criteri_Modelli]
AS

select * from 
(
    select idheader, value, dzt_name
    from ctl_doc_value  p with(nolock)
	where dse_id in ('CRITERI','AMBITO')
        
) as P
    pivot
    (
		--la min è presente perchè ci serve una funzione di aggregazione mail dato è unicoper criterio
        min(value)
        for p.dzt_name in ([Conformita],[CriterioAggiudicazioneGara], [TipoProcedureApplicate],[MacroAreaMerc])
    ) as PIV

	







GO
