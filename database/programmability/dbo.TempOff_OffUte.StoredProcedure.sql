USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[TempOff_OffUte]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[TempOff_OffUte] 
with recompile
AS
SELECT TempOfferte.IdOff,
  TempOfferte.offStato,
  TempOfferte.offProtocollo,
  TempOfferte.offOggetto,
  TempOfferte.offIdPfu,        
  ProfiliUtente.pfuBizMail,
  ProfiliUtente.pfuE_Mail,
  Lingue.lngSuffisso,
  Aziende.IdAzi,
  Aziende.aziRagioneSociale,
  Aziende.aziE_Mail,
  Aziende.aziTelefono1,
  Aziende.aziFax,
  Aziende.aziSitoWeb,
  Aziende.aziIndirizzoLeg,
  Aziende.aziProvinciaLeg,
  Aziende.aziStatoLeg,
  Aziende.aziLog 
FROM TempOfferte
INNER JOIN ProfiliUtente ON TempOfferte.offIdPfu = ProfiliUtente.IdPfu
INNER JOIN Lingue ON ProfiliUtente.pfuIdLng = Lingue.IdLng
INNER JOIN Aziende ON ProfiliUtente.pfuIdAzi = Aziende.IdAzi
GO
