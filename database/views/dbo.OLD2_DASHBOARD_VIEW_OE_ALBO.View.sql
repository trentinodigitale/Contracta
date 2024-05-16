USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_OE_ALBO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE view [dbo].[OLD2_DASHBOARD_VIEW_OE_ALBO] as

 select 
	D.idrow, 
	D.idHeader,
	D.IdPfu, 
	A.IdAzi, 
	--A.aziRagioneSociale, 
	D.aziRagioneSociale,
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
	Cv.value as classeiscriz,
	CV1.value as ClassificazioneSOA,
	CV2.value as AttivitaProfessionale
	,A.aziLog
	,DM.vatValore_FT as aziCodiceFiscale 
	,convert( varchar(10) , D.DataScadenzaIscrizione , 121 )   as DataDA 
	,convert( varchar(10) , D.DataScadenzaIscrizione , 121 )   as DataA 
	,convert( varchar(10) , D.DataConferma , 121 ) as data_ultima_valutazione_a 
	,convert( varchar(10) , D.DataConferma , 121 ) as data_ultima_valutazione_da 
	, D.idHeader as ListaAlbi
	--,dbo.Get_Desc_ClasseIscriz(isnull(Cv.value,''),'I') as ClasseIscrizDesc
	,D.Is_Group
 from CTL_DOC_Destinatari D  with(nolock) 
 	
	inner join Aziende A    with(nolock)  on D.IdAzi = A.idazi and aziDeleted = 0
	inner join ctl_doc c1  with(nolock) on D.id_doc=C1.LinkedDoc and c1.TipoDoc like'CONFERMA_ISCRIZIONE%' and c1.StatoFunzionale='Notificato'
	left join CTL_DOC_Value CV  with(nolock) on CV.IdHeader=c1.Id and CV.DSE_ID='CLASSI' and CV.DZT_Name='ClasseIscriz'
	left join CTL_DOC_Value CV1  with(nolock) on CV1.IdHeader=c1.Id and CV1.DSE_ID='CLASSI' and CV1.DZT_Name='ClassificazioneSOA'
	left join CTL_DOC_Value CV2  with(nolock) on CV2.IdHeader=c1.Id and CV2.DSE_ID='CLASSI' and CV2.DZT_Name='AttivitaProfessionale'
	left outer join DM_Attributi DM with(nolock) on DM.lnk=A.IdAzi and DM.idApp=1 and DM.dztNome='codicefiscale'



GO
