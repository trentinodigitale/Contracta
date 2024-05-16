USE [AFLink_TND]
GO
/****** Object:  View [dbo].[View_Criteri_Valutazione_Lotto]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[View_Criteri_Valutazione_Lotto]
AS
select * from 
(
    select idheader, value, dzt_name
    from Document_Microlotti_DOC_Value  p with(nolock)
	where ( (dse_id = 'CRITERI_ECO' and dzt_name <> 'ModAttribPunteggio' ) or (dse_id = 'CRITERI_ECO_LOTTO' and dzt_name = 'ModAttribPunteggio' ) or ( dse_id = 'CRITERI_ECO_TESTATA' and dzt_name = 'PunteggioECO_TipoRip' ) )
        
) as P
    pivot
    (
        min(value)
        for p.dzt_name in ([PunteggioEconomico], [PunteggioTecnico],[PunteggioTecMin], [FormulaEcoSDA], [Coefficiente_X], [PunteggioTEC_100], [PunteggioTEC_TipoRip], [ModAttribPunteggio] ,[PunteggioECO_TipoRip] ,[TipoAggiudicazione] )
    ) as PIV



GO
