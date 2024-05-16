USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_DETAIL_CHIARIMENTI]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[MAIL_DETAIL_CHIARIMENTI]
AS
SELECT     
	a.id AS iddoc, 
	'I' AS LNG, 
	--LEFT(CONVERT(varchar(20), CAST(b.expirydate AS datetime), 105) + ' ' + CONVERT(varchar(20), CAST(b.expirydate AS datetime), 114), 16) AS expirydate,
	LEFT(CONVERT(varchar(20), CAST(a.datacreazione AS datetime), 105) + ' ' + CONVERT(varchar(20), 
    CAST(a.datacreazione AS datetime), 114), 16) AS datacreazione,
	c.protocollo as ProtocolloBando, 
	c.body as Oggetto, 
	a.Domanda, 
	a.Risposta,
	a.aziragionesociale, 
	a.azitelefono1, 
	a.azifax, 
    a.azie_mail, 
	a.Protocol , 
	c.protocollo  as Protocollo ,
	az.aziragionesociale as Ente_RagioneSociale
FROM dbo.Document_Chiarimenti a 
--INNER JOIN dbo.CHIARIMENTI_PORTALE_FROM_BANDI b ON a.ID_ORIGIN = b.ID_ORIGIN
INNER JOIN Document_Bando b on a.ID_ORIGIN = b.idHeader
inner join ctl_doc c on c.id=b.idHeader
inner join aziende az on az.idazi = c.azienda

GO
