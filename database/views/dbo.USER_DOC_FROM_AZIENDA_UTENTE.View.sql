USE [AFLink_TND]
GO
/****** Object:  View [dbo].[USER_DOC_FROM_AZIENDA_UTENTE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------
--[OK] creare un nuovo utente dal viewer Profili Utenti
---------------------------------------------------------------

CREATE VIEW [dbo].[USER_DOC_FROM_AZIENDA_UTENTE] 
AS

SELECT 
   IdAzi
  ,idpfu AS ID_FROM
  ,idpfu as ID_DOC
  ,idazi as Azienda
  , pfuProfili
	,aziProfili
    
  FROM AZIENDE
  inner join profiliutente on idazi=pfuidazi





GO
