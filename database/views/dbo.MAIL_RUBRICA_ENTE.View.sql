USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_RUBRICA_ENTE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[MAIL_RUBRICA_ENTE]
AS
SELECT * ,'I' as lng   ,idpfu as iddoc
FROM         profiliutente,aziende
where idazi=pfuidazi
--and aziacquirente=3
GO
