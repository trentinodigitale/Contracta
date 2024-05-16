USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_View_Criteri_Valutazione_Gara]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD_View_Criteri_Valutazione_Gara]
AS
select * from 
(
    select idheader, value, dzt_name
    from ctl_doc_value  p with(nolock)
	where dse_id = 'CRITERI_ECO'
        
) as P
    pivot
    (
        min(value)
        for p.dzt_name in ([PunteggioEconomico], [PunteggioTecnico],[PunteggioTecMin], [FormulaEcoSDA], [Coefficiente_X], [PunteggioTEC_100], [PunteggioTEC_TipoRip], [ModAttribPunteggio] )
    ) as PIV


GO
