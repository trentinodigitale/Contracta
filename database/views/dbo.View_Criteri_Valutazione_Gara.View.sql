USE [AFLink_TND]
GO
/****** Object:  View [dbo].[View_Criteri_Valutazione_Gara]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Criteri_Valutazione_Gara]
AS
select * from 
(
    select idheader, value, dzt_name
    from ctl_doc_value  p with(nolock)
	where dse_id in( 'CRITERI_ECO', 'CRITERI_ECO_TESTATA')
        
) as P
    pivot
    (
        min(value)
        for p.dzt_name in ([PunteggioEconomico], [PunteggioTecnico],[PunteggioTecMin], [FormulaEcoSDA], [Coefficiente_X], [PunteggioTEC_100], [PunteggioTEC_TipoRip], [ModAttribPunteggio],[PunteggioECO_TipoRip] )
    ) as PIV

GO
