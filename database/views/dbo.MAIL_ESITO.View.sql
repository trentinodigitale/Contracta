USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_ESITO]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[MAIL_ESITO]  AS
select id as iddoc,'I' as LNG,
* from document_esito


GO
