USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_MAIL_DETAIL_CHIARIMENTI_BANDO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD2_MAIL_DETAIL_CHIARIMENTI_BANDO]
AS
SELECT     
  a.id AS iddoc, 
  'I' AS LNG, 
  --LEFT(CONVERT(varchar(20), 
  --CAST(b.expirydate AS datetime), 105) + ' ' + CONVERT(varchar(20), 
  --CAST(DB.DataScadenzaOfferta AS datetime), 114), 16) AS expirydate,
  LEFT(CONVERT(varchar(20), CAST(DB.DataScadenzaOfferta AS datetime), 105) + ' ' + CONVERT(varchar(20), 
  CAST(DB.DataScadenzaOfferta AS datetime), 114), 16) AS expirydate, 
  LEFT(CONVERT(varchar(20), CAST(a.datacreazione AS datetime), 105) + ' ' + CONVERT(varchar(20), 
  CAST(a.datacreazione AS datetime), 114), 16) AS datacreazione, 
  --b.ProtocolloBando, 
  --b.Oggetto, 
  a.Domanda, 
  a.Risposta,
  a.aziragionesociale, 
  a.azitelefono1, 
  a.azifax, 
  a.azie_mail, 
  a.Protocol,
  --C.protocollo as ProtocolloBando,
  C.protocollo ,
  db.ProtocolloBando,
  C.Body as Oggetto,
  P.pfuNome 
FROM         dbo.Document_Chiarimenti a  with (nolock)
        inner join CTL_DOC C  with (nolock)on a.Id_Origin=C.id
		left join Document_bando DB   with (nolock) on DB.idheader=C.id
		left outer join profiliutente P with (nolock) on a.idPfuInCharge=P.idpfu
where isnull(a.document,'')<>''


GO
