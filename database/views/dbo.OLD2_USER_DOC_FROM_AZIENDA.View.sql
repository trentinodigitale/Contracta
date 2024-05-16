USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_USER_DOC_FROM_AZIENDA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------
--[OK]Vista usata per il from sul doc user_doc
---------------------------------------------------------------

CREATE VIEW [dbo].[OLD2_USER_DOC_FROM_AZIENDA] 
AS

SELECT 
    IdAzi
  , IdAzi AS ID_FROM
  ,idpfu as ID_DOC
  ,IdAzi as Azienda
  , pfuProfili
  ,aziProfili  
  FROM AZIENDE
  inner join profiliutente on idazi=pfuidazi




GO
