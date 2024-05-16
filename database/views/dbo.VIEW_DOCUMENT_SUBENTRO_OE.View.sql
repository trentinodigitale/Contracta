USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_DOCUMENT_SUBENTRO_OE]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [dbo].[VIEW_DOCUMENT_SUBENTRO_OE] as
	select a.Id, a.IdPfu,a.Titolo, a.Protocollo, a.DataInvio, a.StatoFunzionale, Destinatario_User as Utente, b.value as IdPfuSubentro , --c.value as SenzaCessazione,
		d.Value as Allegato, P.pfuIdAzi, P.pfuIdAzi as Azienda
		/*, case
			when p.pfuDeleted=1 then ' SenzaCessazione '
				else ''
		end as   Not_Editable*/
			 

		from ctl_doc a
				left join profiliutente P with(nolock) on p.idpfu=Destinatario_User
				left join ctl_doc_value b with(nolock) ON b.idheader = a.id and b.dse_id = 'SUBENTRATO' and b.DZT_Name = 'IdPfuSubentro'
				--left join ctl_doc_value c with(nolock) ON c.idheader = a.id and c.dse_id = 'SUBENTRATO' and c.DZT_Name = 'SenzaCessazione'
				left join ctl_doc_value d with(nolock) ON d.idheader = a.id and d.dse_id = 'SUBENTRATO' and d.DZT_Name = 'allegato'
				
		
		where a.tipodoc = 'SUBENTRO_OE'


GO
