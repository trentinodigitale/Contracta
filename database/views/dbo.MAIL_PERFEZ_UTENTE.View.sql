USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_PERFEZ_UTENTE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MAIL_PERFEZ_UTENTE]
AS
SELECT P.*,Aziende.* ,'I' as lng   ,C.id as iddoc
FROM        ctl_doc C,profiliutente P,aziende
where idazi=pfuidazi and C.idpfu=P.IdPfu
--and aziacquirente=3


GO
