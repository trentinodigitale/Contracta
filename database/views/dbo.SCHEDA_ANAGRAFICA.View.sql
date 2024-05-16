USE [AFLink_TND]
GO
/****** Object:  View [dbo].[SCHEDA_ANAGRAFICA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[SCHEDA_ANAGRAFICA]
AS
SELECT  a.IdAzi
     ,  a.aziLog
     ,  a.aziDataCreazione
     ,  a.aziRagioneSociale
     ,  a.aziRagioneSocialeNorm
     ,  a.aziIdDscFormaSoc
     ,  a.aziPartitaIVA
     ,  a.aziE_Mail
     ,  a.aziAcquirente
     ,  a.aziVenditore
     ,  a.aziProspect
     ,  a.aziIndirizzoLeg
     ,  a.aziIndirizzoOp
     ,  a.aziLocalitaLeg
     ,  a.aziLocalitaOp
     ,  case when geo.DMV_DescML is null then  a.aziProvinciaLeg else geo.DMV_DescML end as aziProvinciaLeg
     ,  a.aziProvinciaOp
     
	 ,  case when geo1.DMV_DescML is null then  a.aziStatoLeg else geo1.DMV_DescML end as aziStatoLeg
     ,  a.aziStatoOp
     ,  a.aziCAPLeg
     ,  a.aziCapOp
     ,  a.aziPrefisso
     ,  a.aziTelefono1
     ,  a.aziTelefono2
     ,  a.aziFAX
     ,  a.aziLogo
     ,  a.aziGphValueOper
     ,  a.aziDeleted
     , dbo.getAtecoAzi(a.IdAzi) AS aziAtvAtecord 
     , a.azisitoWeb
	 ,a.TipodiAmministr
	 , d.vatValore_FV as codicefiscale
	 , d1.vatValore_FT  as TIPO_AMM_ER
	 , d2.vatValore_FT  as PARTICIPANTID
	 , CS.aziDataCreazione as DataSogCessato

  FROM Aziende a with(nolock)
	left outer join dbo.DM_Attributi d with(nolock) on d.lnk = a.idazi and d.idApp = 1 and d.dztNome = 'CodiceFiscale' 
	left outer join dbo.DM_Attributi d1 with(nolock) on d1.lnk = a.idazi and d1.idApp = 1 and d1.dztNome = 'TIPO_AMM_ER'
	left outer join dbo.DM_Attributi d2 with(nolock) on d2.lnk = a.idazi and d2.idApp = 1 and d2.dztNome = 'PARTICIPANTID'

	left outer join document_Aziende CS with(nolock) on CS.TipoOperAnag  in ( 'OE_CESSAZIONE' , 'AZI_CESSAZIONE' ) and CS.idAZI = a.idAzi and CS.Stato = 'Sended'
	left outer join LIB_DomainValues geo with(nolock) on geo.DMV_DM_ID = 'GEO' and geo.DMV_Cod = isnull(a.aziprovincialeg2,'')
	left outer join LIB_DomainValues geo1 with(nolock) on geo1.DMV_DM_ID = 'GEO' and geo1.DMV_Cod = isnull(a.aziStatoLeg2 ,'')

GO
