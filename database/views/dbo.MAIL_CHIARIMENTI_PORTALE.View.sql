USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_CHIARIMENTI_PORTALE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[MAIL_CHIARIMENTI_PORTALE]
AS


--SELECT     

--	a.id AS iddoc,
--	'I' AS LNG,
--	LEFT(CONVERT(varchar(20), CAST(b.expirydate AS datetime), 105) + ' ' + CONVERT(varchar(20),	CAST(b.expirydate AS datetime), 114), 16) AS expirydate,
--	b.ProtocolloBando, 
--	b.ProtocolloBando as Protocollo, 
--	b.Oggetto, 
--	a.Domanda, 
--	a.aziragionesociale, 
--	a.azitelefono1, 
--	a.azifax, 
--    a.azie_mail, 
--    a.Protocol
    
--FROM         
--	dbo.Document_Chiarimenti a 
--		INNER JOIN dbo.CHIARIMENTI_PORTALE_FROM_BANDI b ON a.ID_ORIGIN = b.ID_ORIGIN and ISNULL(Document,'')  = ''

--union all
 
select

	a.id as iddoc,
	'I' AS LNG,
	isnull( 
		CONVERT(varchar(20), b.DataScadenzaOfferta , 105) + ' ' + CONVERT(varchar(5), b.DataScadenzaOfferta , 114),
		CONVERT(varchar(20), d.DataScadenza , 105) + ' ' + CONVERT(varchar(5), d.DataScadenza , 114) ) AS expirydate,
	isnull( b.ProtocolloBando , d.ProtocolloGenerale ) as ProtocolloBando,
	d.Protocollo ,
	Body as Oggetto,
	dbo.NL_To_BR( dbo.HTML_Encode( a.Domanda)) as  Domanda, 
	a.aziragionesociale, 
	a.azitelefono1, 
	a.azifax, 
	a.azie_mail, 
	a.Protocol
  
  from Document_Chiarimenti a 
	  INNER JOIN CTL_DOC d ON a.ID_ORIGIN = d.id and DOCUMENT <> ''
	  left outer join document_bando b on b.idheader = d.id
	  






GO
