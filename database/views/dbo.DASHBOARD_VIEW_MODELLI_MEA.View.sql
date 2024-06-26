USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_MODELLI_MEA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[DASHBOARD_VIEW_MODELLI_MEA]  as
	select 
		d.Id,
		d.Tipodoc,
		d.Statodoc,
		d.Deleted,
		case when N.id is null then D.titolo else '<b>( In Modifica )</b> ' + D.titolo end as Titolo,
		d.Data,
		d.Protocollo,
		d.Statofunzionale,
		d.Datainvio,
		d.Body as Oggetto,
		ISNULL(d.idpfu,'') as idpfu ,
		d.Body
	from ctl_doc d with(nolock)
			left join CTL_DOC N with(nolock) on N.tipodoc = 'CONFIG_MODELLI_MEA' and N.statofunzionale in ( 'InLavorazione'  ) and N.PrevDoc = D.id and N.deleted = 0 
	where d.TipoDoc='CONFIG_MODELLI_MEA' and d.deleted=0

GO
