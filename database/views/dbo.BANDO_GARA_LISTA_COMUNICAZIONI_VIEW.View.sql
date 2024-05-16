USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_GARA_LISTA_COMUNICAZIONI_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[BANDO_GARA_LISTA_COMUNICAZIONI_VIEW]  as
select 
		[Id], 
		[IdPfu],
		[TipoDoc], 
		[StatoDoc], 
		[Data],
		[Protocollo],
		[Titolo],
		[DataInvio],
		[LinkedDoc], 
		[StatoFunzionale],		 
		o.TipoDoc as OPEN_DOC_NAME,
		azienda as aziende

	from ctl_doc  o with(nolock) 
	where o.deleted = 0 and o.tipodoc in ('COMUNICAZIONE_OE') and StatoDoc='Sended'
UNION
select 
		o.Id, 
		o.IdPfu,
		o.TipoDoc, 
		o.StatoDoc, 
		o.Data,
		o.Protocollo,
		o.Titolo,
		o.DataInvio,
		com.LinkedDoc as Linkeddoc,
		o.StatoFunzionale,		 
		o.TipoDoc as OPEN_DOC_NAME,
		o.azienda as aziende
	from ctl_doc o with(nolock) 
		inner join CTL_DOC COM with(nolock)  on COM.Id=o.LinkedDoc and COM.TipoDoc='COMUNICAZIONE_OE'
	where o.deleted = 0 and o.tipodoc in ('COMUNICAZIONE_OE_RISP') 

			

GO
