USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_MAIL_CESSAZIONE]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[OLD2_MAIL_CESSAZIONE]
AS
SELECT     
					dbo.Lingue.lngSuffisso AS LNG, 
					C.id AS iddoc, dbo.Aziende.IdAzi, dbo.Aziende.aziTs, dbo.Aziende.aziLog, 
                      dbo.Aziende.aziDataCreazione, dbo.Aziende.aziRagioneSociale, dbo.Aziende.aziRagioneSocialeNorm, dbo.Aziende.aziIdDscFormaSoc, 
                      dbo.Aziende.aziPartitaIVA, dbo.Aziende.aziE_Mail, dbo.Aziende.aziAcquirente, dbo.Aziende.aziVenditore, dbo.Aziende.aziProspect, 
                      dbo.Aziende.aziIndirizzoLeg, dbo.Aziende.aziIndirizzoOp, dbo.Aziende.aziLocalitaLeg, dbo.Aziende.aziLocalitaOp, dbo.Aziende.aziProvinciaLeg, 
                      dbo.Aziende.aziProvinciaOp, dbo.Aziende.aziStatoLeg, dbo.Aziende.aziStatoOp, dbo.Aziende.aziCAPLeg, dbo.Aziende.aziCapOp, 
                      dbo.Aziende.aziPrefisso, dbo.Aziende.aziTelefono1, dbo.Aziende.aziTelefono2, dbo.Aziende.aziFAX, dbo.Aziende.aziLogo, 
                      dbo.Aziende.aziIdDscDescrizione, dbo.Aziende.aziProssimoProtRdo, dbo.Aziende.aziProssimoProtOff, dbo.Aziende.aziGphValueOper, 
                      dbo.Aziende.aziDeleted, dbo.Aziende.aziDBNumber, dbo.Aziende.aziAtvAtecord, dbo.Aziende.aziSitoWeb, dbo.Aziende.aziCodEurocredit, 
                      dbo.Aziende.aziProfili, dbo.Aziende.aziProvinciaLeg2, dbo.Aziende.aziStatoLeg2, p.IdPfu, p.pfuTs, 
                      p.pfuIdAzi, p.pfuNome, p.pfuLogin, p.pfuRuoloAziendale, p.pfuPassword, p.pfuCodiceFiscale, 
                      p.pfuPrefissoProt, p.pfuAdmin, p.pfuAcquirente, p.pfuVenditore, 
                      p.pfuInvRdO, p.pfuRcvOff, p.pfuInvOff, p.pfuIdPfuBCopiaA, 
                      p.pfuIdPfuSCopiaA, p.pfuCopiaRdo, p.pfuCopiaOffRic, p.pfuImpMaxRdO, 
                      p.pfuImpMaxOff, p.pfuImpMaxRdoAnn, p.pfuImpMaxOffAnn, p.pfuIdLng, 
                      p.pfuParametriBench, p.pfuSkillLevel1, p.pfuSkillLevel2, p.pfuSkillLevel3, 
                      p.pfuSkillLevel4, p.pfuSkillLevel5, p.pfuSkillLevel6, p.pfuE_Mail, 
                      p.pfuTestoSollecito, p.pfuDeleted, p.pfuBizMail, p.pfuCatalogo, 
                      p.pfuProfili, p.pfuFunzionalita, p.pfuopzioni, p.pfuTel, p.pfuCell, 
                      p.pfuSIM, p.pfuIdMpMod, dbo.Lingue.IdLng, dbo.Lingue.lngIdDsc, dbo.Lingue.lngSuffisso, dbo.Lingue.lngUltimaMod, 
                      dbo.Lingue.lngDeleted
FROM         
			CTL_DOC C with (nolock) 
				inner join ProfiliUtente P with (nolock) ON C.Destinatario_User=P.IdPfu
				inner join Aziende  with (nolock) on idazi=pfuidazi
				inner join Lingue  ON pfuIdLng  = IdLng

where C.tipodoc  in ('CESSAZIONE_UTENTE','CESSAZIONE_UTENTE_OE','CESSAZIONE')

GO
