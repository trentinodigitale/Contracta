USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_COM_DPE_FORNITORI_ADDFROM]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Versione=2&data=2014-01-16&Attivita=50092&Nominativo=Sabato
CREATE VIEW [dbo].[OLD2_COM_DPE_FORNITORI_ADDFROM]
AS
SELECT IdAzi                                                            AS IndRow
     --, IdAzi 
     --, aziRagioneSociale
     , aziIndirizzoLeg + ' - ' + aziLocalitaLeg + ' - ' + aziStatoLeg   AS Indirizzo
     , DM_1.vatvalore_ft     AS codicefiscale
     , *
  FROM 
     Aziende 
     LEFT OUTER JOIN DM_Attributi AS DM_1 ON Aziende.IdAzi = DM_1.lnk AND DM_1.idApp = 1 AND DM_1.dztNome = 'codicefiscale' 
 WHERE 
    aziDeleted = 0
    and azivenditore = 2
   


   





GO
