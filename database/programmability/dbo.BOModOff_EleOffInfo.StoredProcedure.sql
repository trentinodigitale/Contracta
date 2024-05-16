USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOff_EleOffInfo]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModOff_EleOffInfo] (@IdPfu INT) AS
 SELECT Offerte.IdOff, 
  Modelli.mdlNome, 
  Modelli.mdlOggetto, 
  Modelli.mdlDTO, 
  Modelli.mdlNote, 
  ModelliAziende.mazProtocollo, 
  ModelliAziende.mazDataInvio, 
  Aziende.aziRagioneSociale, 
  Aziende.aziIdDscFormaSoc,
  Aziende.aziIndirizzoLeg, 
  Aziende.aziLocalitaLeg,
  Aziende.aziProvinciaLeg,
  Aziende.aziStatoLeg,
  Aziende.aziTelefono1,
  Aziende.aziFAX,
  Aziende.aziE_Mail,
  Aziende.aziLogo
 FROM Offerte
  INNER JOIN Modelli ON Offerte.offIdMdl = Modelli.IdMdl
  INNER JOIN ModelliAziende ON ModelliAziende.mazIdOff = Offerte.IdOff
  INNER JOIN ProfiliUtente ON Modelli.mdlIdPfu = ProfiliUtente.IdPfu
  INNER JOIN Aziende ON ProfiliUtente.pfuIdAzi = Aziende.IdAzi
 WHERE offIdPfu = @IdPfu
 ORDER BY IdOff
GO
