USE [AFLink_TND]
GO
/****** Object:  View [dbo].[View_Criteri_Aggiudicazione_Lotto]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/*recupera i criteri aggiudicazione di un lotto*/
CREATE VIEW [dbo].[View_Criteri_Aggiudicazione_Lotto]
AS

select * from 
(
    select idheader, value, dzt_name
    from Document_Microlotti_DOC_Value  p with(nolock)
	where dse_id = 'CRITERI_AGGIUDICAZIONE'
        
) as P
    pivot
    (
		--la min è presente perchè ci serve una funzione di aggregazione mail dato è unicoper criterio
        min(value)
        for p.dzt_name in ([CriterioAggiudicazioneGara], [Conformita],[CalcoloAnomalia], [OffAnomale],[ModalitaAnomalia_TEC],[ModalitaAnomalia_ECO])
    ) as PIV

	





GO
