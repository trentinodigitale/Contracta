USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PROGETTI_CONDIVISI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_PROGETTI_CONDIVISI]
AS
SELECT DISTINCT 
                      idProgetto, StatoProgetto, Peg, Protocol, Importo, Tipologia, TipoProcedura,CriterioAggiudicazione, NumLotti, AllegatoDpe, UserDirigente, 
                      DataInvio, Versione, NumDetermina, UserProvveditore, DataDetermina, ProtocolloBando, DataCompilazione, ReferenteUffAppalti, CAST(Oggetto AS nvarchar(200)) AS Sintesi, SUBSTRING(PEG, 23, 2) AS PegCOD, Deleted,Pratica,
					  case statoprogetto when 'AlProvv' then 'PROGETTO_COMP_PARZIALE' else 'PROGETTO' end as OPEN_DOC_NAME
FROM         dbo.Document_Progetti
WHERE     (Storico = 0)

GO
