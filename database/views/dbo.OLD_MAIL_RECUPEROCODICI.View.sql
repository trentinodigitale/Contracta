USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_MAIL_RECUPEROCODICI]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_MAIL_RECUPEROCODICI]
AS
SELECT     dbo.Lingue.lngSuffisso AS LNG, dbo.ProfiliUtente.IdPfu AS iddoc, dbo.Aziende.IdAzi, dbo.Aziende.aziTs, dbo.Aziende.aziLog, 
                      dbo.Aziende.aziDataCreazione, dbo.Aziende.aziRagioneSociale, dbo.Aziende.aziRagioneSocialeNorm, dbo.Aziende.aziIdDscFormaSoc, 
                      dbo.Aziende.aziPartitaIVA, dbo.Aziende.aziE_Mail, dbo.Aziende.aziAcquirente, dbo.Aziende.aziVenditore, dbo.Aziende.aziProspect, 
                      dbo.Aziende.aziIndirizzoLeg, dbo.Aziende.aziIndirizzoOp, dbo.Aziende.aziLocalitaLeg, dbo.Aziende.aziLocalitaOp, dbo.Aziende.aziProvinciaLeg, 
                      dbo.Aziende.aziProvinciaOp, dbo.Aziende.aziStatoLeg, dbo.Aziende.aziStatoOp, dbo.Aziende.aziCAPLeg, dbo.Aziende.aziCapOp, 
                      dbo.Aziende.aziPrefisso, dbo.Aziende.aziTelefono1, dbo.Aziende.aziTelefono2, dbo.Aziende.aziFAX, dbo.Aziende.aziLogo, 
                      dbo.Aziende.aziIdDscDescrizione, dbo.Aziende.aziProssimoProtRdo, dbo.Aziende.aziProssimoProtOff, dbo.Aziende.aziGphValueOper, 
                      dbo.Aziende.aziDeleted, dbo.Aziende.aziDBNumber, dbo.Aziende.aziAtvAtecord, dbo.Aziende.aziSitoWeb, dbo.Aziende.aziCodEurocredit, 
                      dbo.Aziende.aziProfili, dbo.Aziende.aziProvinciaLeg2, dbo.Aziende.aziStatoLeg2, dbo.ProfiliUtente.IdPfu, dbo.ProfiliUtente.pfuTs, 
                      dbo.ProfiliUtente.pfuIdAzi, dbo.ProfiliUtente.pfuNome, dbo.ProfiliUtente.pfuLogin, dbo.ProfiliUtente.pfuRuoloAziendale, dbo.ProfiliUtente.pfuPassword, 
                      dbo.ProfiliUtente.pfuPrefissoProt, dbo.ProfiliUtente.pfuAdmin, dbo.ProfiliUtente.pfuAcquirente, dbo.ProfiliUtente.pfuVenditore, 
                      dbo.ProfiliUtente.pfuInvRdO, dbo.ProfiliUtente.pfuRcvOff, dbo.ProfiliUtente.pfuInvOff, dbo.ProfiliUtente.pfuIdPfuBCopiaA, 
                      dbo.ProfiliUtente.pfuIdPfuSCopiaA, dbo.ProfiliUtente.pfuCopiaRdo, dbo.ProfiliUtente.pfuCopiaOffRic, dbo.ProfiliUtente.pfuImpMaxRdO, 
                      dbo.ProfiliUtente.pfuImpMaxOff, dbo.ProfiliUtente.pfuImpMaxRdoAnn, dbo.ProfiliUtente.pfuImpMaxOffAnn, dbo.ProfiliUtente.pfuIdLng, 
                      dbo.ProfiliUtente.pfuParametriBench, dbo.ProfiliUtente.pfuSkillLevel1, dbo.ProfiliUtente.pfuSkillLevel2, dbo.ProfiliUtente.pfuSkillLevel3, 
                      dbo.ProfiliUtente.pfuSkillLevel4, dbo.ProfiliUtente.pfuSkillLevel5, dbo.ProfiliUtente.pfuSkillLevel6, dbo.ProfiliUtente.pfuE_Mail, 
                      dbo.ProfiliUtente.pfuTestoSollecito, dbo.ProfiliUtente.pfuDeleted, dbo.ProfiliUtente.pfuBizMail, dbo.ProfiliUtente.pfuCatalogo, 
                      dbo.ProfiliUtente.pfuProfili, dbo.ProfiliUtente.pfuFunzionalita, dbo.ProfiliUtente.pfuopzioni, dbo.ProfiliUtente.pfuTel, dbo.ProfiliUtente.pfuCell, 
                      dbo.ProfiliUtente.pfuSIM, dbo.ProfiliUtente.pfuIdMpMod, dbo.Lingue.IdLng, dbo.Lingue.lngIdDsc, dbo.Lingue.lngSuffisso, dbo.Lingue.lngUltimaMod, 
                      dbo.Lingue.lngDeleted
FROM         dbo.Aziende INNER JOIN
                      dbo.ProfiliUtente ON dbo.Aziende.IdAzi = dbo.ProfiliUtente.pfuIdAzi INNER JOIN
                      dbo.Lingue ON dbo.ProfiliUtente.pfuIdLng = dbo.Lingue.IdLng


GO
