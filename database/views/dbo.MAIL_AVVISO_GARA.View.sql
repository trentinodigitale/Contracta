USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_AVVISO_GARA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[MAIL_AVVISO_GARA] AS
	SELECT 
		  --avviso.id as iddoc,
		  CV.idrow as iddoc,
		  'I' as LNG,
		  
		  avviso.protocollo as registroDiSistema,
	  	  avviso.note as TestoDellaComunicazione,
		  avviso.SIGN_ATTACH as allegato,
		  avviso.Fascicolo,
		  avviso.DataInvio,
		  avviso.StatoFunzionale,
		  pf.pfunome as compilatore,

		  gara.Body as oggettoGara,
		  gara.protocollo as registroDiSistemaGara,
		  gara.Titolo as titoloGara

	from CTL_DOC avviso
		left join profiliutente pf ON pf.idpfu = avviso.IdPfu
		left join ctl_doc gara on gara.id= avviso.linkeddoc 
		inner join ctl_doc_value CV on avviso.id= CV.IdHeader 
	where avviso.TipoDoc='AVVISO_GARA'




GO
