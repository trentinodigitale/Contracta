USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_AQ_QUOTA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MAIL_AQ_QUOTA]
AS
SELECT  
'I' as LNG,   
 C.id as IdDoc,
 C.Azienda as IdAzi,
 C.IdPfu,
 C.TipoDoc,
 C.StatoDoc,
 convert( varchar , C.DataInvio , 103 ) as DataInvio,
 C.Protocollo,
 C.PrevDoc,
 C.Deleted,
 C.Titolo,
 C.Body,
 C.Azienda,
 C.ProtocolloGenerale,
 C.LinkedDoc,
 C.StatoFunzionale,
 C.ID as ID_FROM,
 C.ID as IdHeader,

	Document_Convenzione_Quote.importo,
--DC.NumOrd,
B.Protocollo as ProtocolloRiferimento,
B.body as BodyContratto,
DC.ImportoBaseAsta as Total 

FROM ctl_doc as C with(nolock)
inner join Document_Bando DC  with(nolock) on C.LinkedDoc=DC.idHeader
inner join CTL_DOC B  with(nolock) on B.id=DC.idHeader
left join Aziende  with(nolock) on C.Azienda=IdAzi
left join Document_Convenzione_Quote  with(nolock) on Document_Convenzione_Quote.idHeader=C.id
where C.TipoDoc='AQ_QUOTA' and C.StatoDoc='Sended'
GO
