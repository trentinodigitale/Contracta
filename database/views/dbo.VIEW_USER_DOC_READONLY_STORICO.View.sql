USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_USER_DOC_READONLY_STORICO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[VIEW_USER_DOC_READONLY_STORICO] as
select 
	c.destinatario_user as idpfu,
	c.protocollo,
	ISNULL(C.datainvio,c.data) as data,
    c.tipodoc as OPEN_DOC_NAME ,
	c.destinatario_user as ID_FROM,
	c.id,
	case when c.TipoDoc = 'USER_DOC_OPERATION' then c.Titolo else c.TipoDoc end as TipoDoc

	from ctl_doc c with (nolock )
where tipodoc in ('USER_DOC','USER_DOC_OE','USER_DOC_READONLY','USERDOC_UPD_BASE','CAMBIO_RUOLO_UTENTE','USERDOC_UPD_DATICODICEFISCALE')
	or ( tipodoc in ('CESSAZIONE','SUBENTRO','CESSAZIONE_UTENTE_OE')	and StatoFunzionale='Inviato' )
	or ( tipodoc in ('SUBENTRO_OE')	and StatoFunzionale in ('Inviato','Variato','InLavorazione') )

	or (  tipodoc in ( 'USER_DOC_OPERATION' ) and  StatoFunzionale='Confermato' )

UNION ALL

select 
	cv.Value as idpfu,
	c.protocollo,
	ISNULL(C.datainvio,c.data) as data,
    c.tipodoc as OPEN_DOC_NAME ,
	cv.Value as ID_FROM,
	c.id,
	c.TipoDoc

	from ctl_doc c with (nolock)
		left join CTL_DOC_Value CV with (nolock) on CV.IdHeader=C.id and CV.DSE_ID='SUBENTRATO' and CV.DZT_Name='IdPfuSubentro' and cv.Row=0
where tipodoc in ('SUBENTRO')	and StatoFunzionale='Inviato'
	or ( tipodoc in ('SUBENTRO_OE')	and StatoFunzionale in ('Inviato','Variato','InLavorazione') )



GO
