USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_ISCRITTI_BANDO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE view [dbo].[OLD2_VIEW_ISCRITTI_BANDO] as

 select 
	D.*,
	Cv.value as classeiscriz
	,CV1.value as ClassificazioneSOA
	,'CANCELLA_ISCRIZIONE' as MAKE_DOC_NAME
	,'BANDO' as OPEN_DOC_NAME

 from CTL_DOC_Destinatari D  with(nolock) 
 inner join ctl_doc c1  with(nolock) on D.id_doc=C1.LinkedDoc and c1.TipoDoc like'CONFERMA_ISCRIZIONE%' and c1.StatoFunzionale='Notificato'
 left join CTL_DOC_Value CV  with(nolock) on CV.IdHeader=c1.Id and CV.DSE_ID='CLASSI' and CV.DZT_Name='ClasseIscriz'
 left join CTL_DOC_Value CV1  with(nolock) on CV1.IdHeader=c1.Id and CV1.DSE_ID='CLASSI' and CV1.DZT_Name='ClassificazioneSOA'





GO
