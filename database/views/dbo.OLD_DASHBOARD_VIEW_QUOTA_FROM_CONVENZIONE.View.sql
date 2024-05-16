USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_QUOTA_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   view [dbo].[OLD_DASHBOARD_VIEW_QUOTA_FROM_CONVENZIONE] as
	select 
		DC.DOC_OWNER,
		DC.ID,
		DC.id as ID_FROM,
		DC.protocol as ProtocolloRiferimento,
		DC.DOC_NAME as BodyContratto,
		DC.Id as LinkedDoc,
		DC.Total,
		DC.NumOrd,
		(DC.Total - ISNULL(S.totQ,0)) as Importo_Residuo_Quote
	 from Document_Convenzione DC with(nolock)
		 left join  (
			select  ctl_doc.linkeddoc, isnull(sum(importo),0) as totQ 
			from Document_Convenzione_Quote with(nolock) ,ctl_doc with(nolock)
			where tipodoc='QUOTA' and idheader=id and statodoc='Sended'
			group by linkeddoc) S
		 on DC.id=S.linkeddoc

	where DC.Deleted = 0



GO
