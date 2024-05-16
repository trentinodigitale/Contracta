USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempOff_EleOffInfoProspect]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.TempOff_EleOffInfoProspect    Script Date: 04/07/2000 17.56.11 ******/
CREATE PROCEDURE [dbo].[TempOff_EleOffInfoProspect] (@IdOff INT, @IdAzi INT) 
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
  Aziende.aziTelefono1,
  Aziende.aziFAX,
  Aziende.aziE_Mail,
  Aziende.aziLogo
 FROM TempOfferte
  INNER JOIN TempModelli ON TempOfferte.offIdMdl = TempModelli.IdMdl
  INNER JOIN TempModelliAziende ON TempModelliAziende.mazIdOff = TempOfferte.IdOff
  INNER JOIN Aziende ON Aziende.IdAzi = @IdAzi
 WHERE TempOfferte.IdOff = @IdOff
GO
