USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Richiesta_Atti_Gara_Dossier_View]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Richiesta_Atti_Gara_Dossier_View]
AS
select C.id
       ,C.IdPfu as Doc_Owner
       ,C.Titolo as name
       ,C.DataInvio as ReceivedDataMsg
       ,C.Protocollo as ProtocolloOfferta
       ,C.Fascicolo as ProtocolBG
       ,C.ProtocolloRiferimento as ProtocolloBando
       ,Tipo_Appalto as Tipologia
       ,aziRagioneSociale as RagSoc
       , pfuidazi as AZI
       , C.TipoDoc as TipoDocumento
	   ,C2.Azienda as muIdAziDest
	   ,C2.Azienda as AZI_Dest
       

from CTL_DOC C
inner join Document_Richiesta_Atti on  C.id=idHeader
inner join profiliutente p on C.idpfu = p.idpfu
inner join CTL_DOC C2 on c2.id=c.LinkedDoc

GO
