USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_ISCRITTI_BANDO_EXCEL]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



 CREATE  view [dbo].[OLD_VIEW_ISCRITTI_BANDO_EXCEL] as
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
		cv.value as classeiscriz
		, i.DMV_DescML as Descrizione
		--,II.DMV_DescML as Descrizione_OLD
		--,III.DMV_DescML as Descrizione_OLD2
		

	 from CTL_DOC_Destinatari D with(nolock) 
	     inner join Aziende A    with(nolock)  on D.IdAzi = A.idazi and aziDeleted = 0	
	     inner join ctl_doc c1  with(nolock) on D.id_doc=C1.LinkedDoc and c1.TipoDoc like'CONFERMA_ISCRIZIONE%' and c1.StatoFunzionale='Notificato'
		left join CTL_DOC_Value CV  with(nolock) on CV.IdHeader=c1.Id and CV.DSE_ID='CLASSI' and CV.DZT_Name='ClasseIscriz'
		left outer join ClasseIscriz i  with(nolock) on charindex( '###' + i.dmv_cod + '###'  , CV.Value ) > 0
		--left join CTL_DOC_Value CV1  with(nolock) on CV1.IdHeader=c1.Id and CV1.DSE_ID='CLASSI' and CV1.DZT_Name='ClassificazioneSOA'
		--left join CTL_DOC_Value CV2  with(nolock) on CV2.IdHeader=c1.Id and CV2.DSE_ID='CLASSI' and CV2.DZT_Name='AttivitaProfessionale'
		--left outer join CategoriaSOA II  with(nolock) on charindex( '###' + II.dmv_cod + '###'  , CV1.Value ) > 0
		--left outer join LIB_DomainValues II  with(nolock) on II.DMV_DM_ID='GerarchicoSOA' and charindex( '###' + II.dmv_cod + '###'  , CV1.Value ) > 0
		--left outer join LIB_DomainValues III  with(nolock) on III.DMV_DM_ID='TipologiaIncarico' and charindex( '###' + III.dmv_cod + '###'  , CV2.Value ) > 0
		






GO
