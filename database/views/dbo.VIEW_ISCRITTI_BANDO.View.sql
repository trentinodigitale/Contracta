USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_ISCRITTI_BANDO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE view [dbo].[VIEW_ISCRITTI_BANDO] as

 select 
	D.idrow, 
	D.idHeader,
	D.IdPfu, 
	A.IdAzi, 
	A.aziRagioneSociale, 
	A.aziPartitaIVA, 
	A.aziE_Mail, 
	A.aziIndirizzoLeg, 
	A.aziLocalitaLeg, 
	A.aziProvinciaLeg, 
	A.aziStatoLeg, 
	A.aziCAPLeg, 
	A.aziTelefono1, 
	A.aziFAX, 
	A.aziDBNumber, 
	A.aziSitoWeb, 
	D.CDDStato, 
	D.Seleziona, 
	D.NumRiga, 
	D.CodiceFiscale, 
	D.StatoIscrizione, 
	D.DataIscrizione, 
	D.DataScadenzaIscrizione, 
	D.DataSollecito, 
	D.Id_Doc, 
	D.DataConferma, 
	D.NumeroInviti,	
	Cv.value as classeiscriz
	,CV1.value as ClassificazioneSOA
	,'CANCELLA_ISCRIZIONE' as MAKE_DOC_NAME
	,'BANDO' as OPEN_DOC_NAME

 from CTL_DOC_Destinatari D  with(nolock) 
	
	inner join Aziende A    with(nolock)  on D.IdAzi = A.idazi and aziDeleted = 0

	inner join ctl_doc c1  with(nolock) on D.id_doc=C1.LinkedDoc and c1.TipoDoc like'CONFERMA_ISCRIZIONE%' and c1.StatoFunzionale='Notificato'
	left join CTL_DOC_Value CV  with(nolock) on CV.IdHeader=c1.Id and CV.DSE_ID='CLASSI' and CV.DZT_Name='ClasseIscriz'
	left join CTL_DOC_Value CV1  with(nolock) on CV1.IdHeader=c1.Id and CV1.DSE_ID='CLASSI' and CV1.DZT_Name='ClassificazioneSOA'






GO
