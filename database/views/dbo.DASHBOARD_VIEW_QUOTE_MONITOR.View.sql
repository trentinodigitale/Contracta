USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_QUOTE_MONITOR]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE view [dbo].[DASHBOARD_VIEW_QUOTE_MONITOR] as
select 
CTL_DOC.ID ,
CTL_DOC.ID as IDDOC,
CTL_DOC.IdPfu ,
CTL_DOC.TipoDoc ,
CTL_DOC.StatoDoc ,
CTL_DOC.Protocollo ,
CTL_DOC.PrevDoc ,
CTL_DOC.Deleted ,
CTL_DOC.Titolo ,
CTL_DOC.Body ,
CTL_DOC.DataInvio ,
CTL_DOC.LinkedDoc ,
Document_Convenzione_Quote.importo,

CTL_DOC.Azienda as AZI_Ente,
'QUOTA' as OPEN_DOC_NAME,
Document_Convenzione.DOC_NAME as BodyContratto,
Document_Convenzione.Protocol as ProtocolloRiferimento,
(Document_Convenzione.Total - ISNULL(S.totQ,0)) as Importo_Residuo_Quote 

 
from CTL_DOC 
inner join Document_Convenzione_Quote on CTL_DOC.ID=idHEader
inner join Document_Convenzione on  CTL_DOC.linkedDoc=Document_Convenzione.id
left join  (select  ctl_doc.linkeddoc, isnull(sum(importo),0) as totQ from Document_Convenzione_Quote,ctl_doc where tipodoc='QUOTA' and idheader=id and statodoc='Sended' group by linkeddoc) S
 on Document_Convenzione.id=S.linkeddoc

where tipoDoc='QUOTA' and CTL_DOC.Deleted=0
GO
