USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_RISULTATODIGARA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[MAIL_RISULTATODIGARA]
AS
select id as iddoc,'I' as LNG,* from document_risultatodigara

GO
