USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_MAIL_FORWARD]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_MAIL_FORWARD]
AS
SELECT  
'I' as LNG,   
 C.id as IdDoc, 
 C.IdPfu,
 C.TipoDoc,
 C.StatoDoc, 
 C.Deleted,
 SIGN_HASH as MailTo,
 Titolo as Oggetto,
 Body,
 C.LinkedDoc,
 C.ID as ID_FROM


FROM         ctl_doc as C
			

where TipoDoc='DOCUMENT_MAIL_INOLTRO' and Deleted=0



GO
