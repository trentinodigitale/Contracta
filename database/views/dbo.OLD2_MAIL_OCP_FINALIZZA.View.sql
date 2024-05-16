USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_MAIL_OCP_FINALIZZA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[OLD2_MAIL_OCP_FINALIZZA] AS

	select
	
		  a.idRow as iddoc
		, 'I' as LNG	
		, d.TipoDoc
		
		, g.Protocollo as protocolloGara
		, g.Body as oggettoGara
		, og.W3IDGARA as idGara

		--, dbo.CNV_ESTESA( d.TipoDoc, 'I') as nomeDocumento

		, case when d.StatoFunzionale = 'Invio_con_errori' then 'E'' stato inviato un documento di tipo ''' + d.TipoDoc + ''' con il seguente errore : '
			   when d.StatoFunzionale = 'Inviato' then 'Si informa che la stessa e'' stata inviata con successo all''Osservatorio Regionale dei Contratti Pubblici' 
		  end as esitoInvio

		, d.Body as msgError
		
	from Services_Integration_Request a with(nolock)
			inner join ctl_doc d with(NOLOCK) on d.id = a.idRichiesta
			left join Document_OCP_GARA og with(nolock) on og.idHeader = d.id
			inner join ctl_doc g with(nolock) on g.id = d.LinkedDoc
	--where d.tipodoc like 'OCP%'
		
	
GO
