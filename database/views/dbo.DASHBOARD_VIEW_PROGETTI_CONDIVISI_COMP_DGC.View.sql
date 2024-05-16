USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_PROGETTI_CONDIVISI_COMP_DGC]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_PROGETTI_CONDIVISI_COMP_DGC]
AS
SELECT DISTINCT 
       idProgetto, StatoProgetto, Peg, Protocol, Importo, Tipologia, TipoProcedura, CriterioAggiudicazione, NumLotti, AllegatoDpe, UserDirigente, 
       DataInvio, Versione, NumDetermina, UserProvveditore, DataDetermina, ProtocolloBando, DataCompilazione, ReferenteUffAppalti, 
       CAST(Oggetto AS NVARCHAR(200)) AS Sintesi, SUBSTRING(PEG, 23, 2) AS PegCOD, Deleted, Pratica,
	   isnull(pfunome,ReferenteUffAppalti) as  Descrizione
  FROM dbo.Document_Progetti left outer join profiliutente on ReferenteUffAppalti = cast(idpfu as varchar)
 WHERE Storico = 0
   AND Tipologia = '2'

GO
