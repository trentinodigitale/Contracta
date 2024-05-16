USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PROGETTI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_PROGETTI]
AS
SELECT idProgetto, StatoProgetto, DataInvio, Protocol, CAST(Oggetto AS nvarchar(200)) AS Oggetto, AllegatoDpe, UserDirigente,   
                Importo, Tipologia, TipoProcedura,CriterioAggiudicazione,NumLotti, Versione, Deleted, NumDetermina, DataDetermina, ProtocolloBando, Peg,
                ReferenteUffAppalti,Pratica
FROM  dbo.Document_Progetti
WHERE (Deleted <> 1)


GO
