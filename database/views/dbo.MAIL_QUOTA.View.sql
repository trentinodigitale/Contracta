USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_QUOTA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[MAIL_QUOTA]
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
DC.NumOrd,
DC.Protocol as ProtocolloRiferimento,
DC.Doc_name as BodyContratto,
DC.Total 

FROM         ctl_doc as C
inner join document_convenzione DC on LinkedDoc=DC.ID
left join Aziende on Azienda=IdAzi
left join Document_Convenzione_Quote on Document_Convenzione_Quote.idHeader=C.id
where TipoDoc='QUOTA' and StatoDoc='Sended'
GO
