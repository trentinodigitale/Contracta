USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempOff_EleOffInfo]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TempOff_EleOffInfo] (@IdOff INT)
with recompile
 AS
 SELECT TempOfferte.IdOff, 
  TempModelli.mdlNome, 
  TempModelli.mdlOggetto, 
  TempModelli.mdlDTO, 
  TempModelli.mdlNote, 
  TempModelliAziende.mazProtocollo, 
  TempModelliAziende.mazDataInvio, 
  Aziende.aziRagioneSociale, 
  Aziende.aziIdDscFormaSoc,
  Aziende.aziIndirizzoLeg, 
  Aziende.aziLocalitaLeg,
  Aziende.aziProvinciaLeg,
  Aziende.aziStatoLeg,
  Aziende.aziCapLeg,
  Aziende.aziTelefono1,
  Aziende.aziTelefono2,
  Aziende.aziFAX,
  Aziende.aziE_Mail,
  Aziende.aziLogo,
  Aziende.aziPartitaIVA,
  Aziende.aziGphValueOper,
  Aziende.aziAtvAtecord,
  Aziende.aziSitoWeb,
  ProfiliUtente.pfuIdAzi AS IdAzi
 FROM TempOfferte
  INNER JOIN TempModelli ON TempOfferte.offIdMdl = TempModelli.IdMdl
  INNER JOIN TempModelliAziende ON TempModelliAziende.mazIdOff = TempOfferte.IdOff
  INNER JOIN ProfiliUtente ON TempModelli.mdlIdPfu = ProfiliUtente.IdPfu
  INNER JOIN Aziende ON ProfiliUtente.pfuIdAzi = Aziende.IdAzi
 WHERE TempOfferte.IdOff = @IdOff
GO
