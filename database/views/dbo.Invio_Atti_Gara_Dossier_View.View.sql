USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Invio_Atti_Gara_Dossier_View]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Invio_Atti_Gara_Dossier_View]
AS
select  C.id
       ,C.IdPfu as Doc_Owner
       ,C.Titolo as name
       ,C.DataInvio as ReceivedDataMsg
       ,C.Protocollo as ProtocolloOfferta
       ,C.Fascicolo as ProtocolBG
       ,C.ProtocolloRiferimento as ProtocolloBando
       ,Tipo_Appalto as Tipologia
       ,aziRagioneSociale as RagSoc
       ,C.TipoDoc as TipoDocumento
       ,p.pfuidazi as AZI
       ,C.LinkedDoc
	   ,p2.pfuidazi as muIdAziDest
	   ,p2.pfuidazi as AZI_Dest

from CTL_DOC C
inner join Document_Richiesta_Atti on  LinkedDoc=idHeader
inner join profiliutente p on C.idpfu = p.idpfu
inner join CTL_DOC C2 on C2.id=C.LinkedDoc
inner join profiliutente p2 on C2.idpfu = p2.idpfu


GO
