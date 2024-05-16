USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ViewGetParametriAggiornaPubblicazioneGgap]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ViewGetParametriAggiornaPubblicazioneGgap]
AS
    SELECT G.Id AS ID
           , G.Id AS ID_BANDO
	       , Ric_Cig.Id AS ID_RICHIESTA_CIG
	       , 'garaAggiornaPubblicazioneGgap' AS OPERAZIONE_RICHIESTA
        FROM CTL_DOC G WITH (NOLOCK)
                INNER JOIN CTL_DOC Ric_Cig WITH (NOLOCK) ON Ric_Cig.LinkedDoc = G.Id
                	AND Ric_Cig.TipoDoc = 'RICHIESTA_CIG'
                	AND Ric_Cig.Deleted = 0
                	AND Ric_Cig.StatoFunzionale <> 'Annullato'

        --WHERE G.Id = 478310

GO
