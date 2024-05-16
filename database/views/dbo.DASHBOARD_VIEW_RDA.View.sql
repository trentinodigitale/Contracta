USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RDA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[DASHBOARD_VIEW_RDA]
AS
SELECT     dbo.Document_RDA.RDA_ID, dbo.Document_RDA.RDA_Owner, dbo.Document_RDA.RDA_Name, dbo.Document_RDA.RDA_DataCreazione, 
                      dbo.Document_RDA.RDA_Protocol, dbo.Document_RDA.RDA_Object, dbo.Document_RDA.RDA_Total, dbo.Document_RDA.RDA_Stato, 
                      dbo.Document_RDA.RDA_AZI, dbo.Document_RDA.RDA_Plant_CDC, dbo.Document_RDA.RDA_Valuta, dbo.Document_RDA.RDA_InBudget, 
                      dbo.Document_RDA.RDA_BDG_Periodo, dbo.Document_RDA.RDA_Deleted, dbo.Document_RDA.RDA_BuyerRole, 
                      dbo.Document_RDA.RDA_ResidualBudget, dbo.Document_RDA.RDA_CEO, dbo.Document_RDA.RDA_SOCRic, dbo.Document_RDA.RDA_PlantRic, 
                      dbo.Document_RDA.RDA_MCE, dbo.Document_RDA.RDA_DataScad, dbo.Document_RDA.RDA_Utilizzo, dbo.ProfiliUtente.IdPfu, dbo.ProfiliUtente.pfuTs, 
                      dbo.ProfiliUtente.pfuIdAzi, dbo.ProfiliUtente.pfuNome, dbo.ProfiliUtente.pfuLogin, dbo.ProfiliUtente.pfuRuoloAziendale, dbo.ProfiliUtente.pfuPassword, 
                      dbo.ProfiliUtente.pfuPrefissoProt, dbo.ProfiliUtente.pfuAdmin, dbo.ProfiliUtente.pfuAcquirente, dbo.ProfiliUtente.pfuVenditore, 
                      dbo.ProfiliUtente.pfuInvRdO, dbo.ProfiliUtente.pfuRcvOff, dbo.ProfiliUtente.pfuInvOff, dbo.ProfiliUtente.pfuIdPfuBCopiaA, 
                      dbo.ProfiliUtente.pfuIdPfuSCopiaA, dbo.ProfiliUtente.pfuCopiaRdo, dbo.ProfiliUtente.pfuCopiaOffRic, dbo.ProfiliUtente.pfuImpMaxRdO, 
                      dbo.ProfiliUtente.pfuImpMaxOff, dbo.ProfiliUtente.pfuImpMaxRdoAnn, dbo.ProfiliUtente.pfuImpMaxOffAnn, dbo.ProfiliUtente.pfuIdLng, 
                      dbo.ProfiliUtente.pfuParametriBench, dbo.ProfiliUtente.pfuSkillLevel1, dbo.ProfiliUtente.pfuSkillLevel2, dbo.ProfiliUtente.pfuSkillLevel3, 
                      dbo.ProfiliUtente.pfuSkillLevel4, dbo.ProfiliUtente.pfuSkillLevel5, dbo.ProfiliUtente.pfuSkillLevel6, dbo.ProfiliUtente.pfuE_Mail, 
                      dbo.ProfiliUtente.pfuTestoSollecito, dbo.ProfiliUtente.pfuDeleted, dbo.ProfiliUtente.pfuBizMail, dbo.ProfiliUtente.pfuCatalogo, 
                      dbo.ProfiliUtente.pfuProfili, dbo.ProfiliUtente.pfuFunzionalita, dbo.ProfiliUtente.pfuopzioni, dbo.ProfiliUtente.pfuTel, dbo.ProfiliUtente.pfuCell, 
                      dbo.ProfiliUtente.pfuSIM, dbo.ProfiliUtente.pfuIdMpMod, dbo.Document_RDA.RDA_Type
FROM         dbo.Document_RDA INNER JOIN
                      dbo.ProfiliUtente ON dbo.Document_RDA.RDA_Owner = CAST(dbo.ProfiliUtente.IdPfu AS varchar)
WHERE     (dbo.Document_RDA.RDA_Deleted = ' ')





GO
