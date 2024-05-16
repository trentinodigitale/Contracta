USE [AFLink_TND]
GO
/****** Object:  View [dbo].[COM_DPE_FORNITORI_PLUS_ADDFROM]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[COM_DPE_FORNITORI_PLUS_ADDFROM]
AS
SELECT IdAzi                                                            AS IndRow
     , IdAzi 
     , aziRagioneSociale
     , aziIndirizzoLeg + ' - ' + aziLocalitaLeg + ' - ' + aziStatoLeg   AS Indirizzo
  FROM Aziende 
     , MPAziende
 WHERE IdAzi = mpaIdAzi
   AND mpaIdMp = 1
   AND aziDeleted = 0
   AND mpaDeleted = 0


GO
