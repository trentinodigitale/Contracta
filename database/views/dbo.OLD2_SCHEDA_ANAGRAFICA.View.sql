USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_SCHEDA_ANAGRAFICA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD2_SCHEDA_ANAGRAFICA]
AS
SELECT IdAzi
     , aziLog
     , aziDataCreazione
     , aziRagioneSociale
     , aziRagioneSocialeNorm
     , aziIdDscFormaSoc
     , aziPartitaIVA
     , aziE_Mail
     , aziAcquirente
     , aziVenditore
     , aziProspect
     , aziIndirizzoLeg
     , aziIndirizzoOp
     , aziLocalitaLeg
     , aziLocalitaOp
     , aziProvinciaLeg
     , aziProvinciaOp
     , aziStatoLeg
     , aziStatoOp
     , aziCAPLeg
     , aziCapOp
     , aziPrefisso
     , aziTelefono1
     , aziTelefono2
     , aziFAX
     , aziLogo
     , aziGphValueOper
     , aziDeleted
     , dbo.getAtecoAzi(IdAzi) AS aziAtvAtecord 
     , azisitoWeb
	 ,TipodiAmministr
	 , d.vatValore_FV as codicefiscale
	 , d1.vatValore_FT  as TIPO_AMM_ER
	 , d2.vatValore_FT  as PARTICIPANTID
  FROM Aziende
	left outer join dbo.DM_Attributi d on d.lnk = idazi and d.idApp = 1 and d.dztNome = 'CodiceFiscale' 
	left outer join dbo.DM_Attributi d1 on d1.lnk = idazi and d1.idApp = 1 and d1.dztNome = 'TIPO_AMM_ER'
	left outer join dbo.DM_Attributi d2 on d2.lnk = idazi and d2.idApp = 1 and d2.dztNome = 'PARTICIPANTID'




GO
