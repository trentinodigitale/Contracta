USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_GET_PARAMETRI_GGAP_REQUESTS]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VIEW_GET_PARAMETRI_GGAP_REQUESTS]
AS
    SELECT G.Id AS ID
	       , Ric_Cig.Id AS ID_RICHIESTA_SMART_CIG
	       , 'smartCigInserisciGgap' AS OPERAZIONE_RICHIESTA
        FROM CTL_DOC G WITH (NOLOCK)
                INNER JOIN CTL_DOC Ric_Cig WITH (NOLOCK) ON Ric_Cig.LinkedDoc = G.Id
                	AND Ric_Cig.TipoDoc = 'RICHIESTA_SMART_CIG'
                	AND Ric_Cig.Deleted = 0
                	AND Ric_Cig.StatoFunzionale <> 'Annullato'

GO
