USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_RDA_INAPPROVE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[DASHBOARD_VIEW_RDA_INAPPROVE]
AS
SELECT     dbo.Document_RDA.RDA_Type, dbo.Document_RDA.RDA_ID, dbo.Document_RDA.RDA_Owner, dbo.Document_RDA.RDA_Name, 
                      dbo.Document_RDA.RDA_DataCreazione, dbo.Document_RDA.RDA_Protocol, dbo.Document_RDA.RDA_Object, dbo.Document_RDA.RDA_Total, 
                      dbo.Document_RDA.RDA_Stato, dbo.Document_RDA.RDA_AZI, dbo.Document_RDA.RDA_Plant_CDC, dbo.Document_RDA.RDA_Valuta, 
                      dbo.Document_RDA.RDA_InBudget, dbo.Document_RDA.RDA_BDG_Periodo, dbo.Document_RDA.RDA_Deleted, dbo.Document_RDA.RDA_BuyerRole, 
                      dbo.Document_RDA.RDA_ResidualBudget, dbo.Document_RDA.RDA_CEO, dbo.Document_RDA.RDA_SOCRic, dbo.Document_RDA.RDA_PlantRic, 
                      dbo.Document_RDA.RDA_MCE, dbo.Document_RDA.RDA_DataScad, dbo.Document_RDA.RDA_Utilizzo, dbo.Document_RDA.RDA_Type AS Expr1, 
                      dbo.CTL_ApprovalSteps.APS_ID_ROW, dbo.CTL_ApprovalSteps.APS_Doc_Type, dbo.CTL_ApprovalSteps.APS_ID_DOC, 
                      dbo.CTL_ApprovalSteps.APS_State, dbo.CTL_ApprovalSteps.APS_Note, dbo.CTL_ApprovalSteps.APS_Allegato, 
                      dbo.CTL_ApprovalSteps.APS_UserProfile, dbo.CTL_ApprovalSteps.APS_IdPfu, dbo.CTL_ApprovalSteps.APS_IsOld, dbo.CTL_ApprovalSteps.APS_Date, 
                      dbo.ProfiliUtente.IdPfu, dbo.ProfiliUtente.pfuTs, dbo.ProfiliUtente.pfuIdAzi, dbo.ProfiliUtente.pfuNome, dbo.ProfiliUtente.pfuLogin, 
                      dbo.ProfiliUtente.pfuRuoloAziendale, dbo.ProfiliUtente.pfuPassword, dbo.ProfiliUtente.pfuPrefissoProt, dbo.ProfiliUtente.pfuAdmin, 
                      dbo.ProfiliUtente.pfuAcquirente, dbo.ProfiliUtente.pfuVenditore, dbo.ProfiliUtente.pfuInvRdO, dbo.ProfiliUtente.pfuRcvOff, dbo.ProfiliUtente.pfuInvOff, 
                      dbo.ProfiliUtente.pfuIdPfuBCopiaA, dbo.ProfiliUtente.pfuIdPfuSCopiaA, dbo.ProfiliUtente.pfuCopiaRdo, dbo.ProfiliUtente.pfuCopiaOffRic, 
                      dbo.ProfiliUtente.pfuImpMaxRdO, dbo.ProfiliUtente.pfuImpMaxOff, dbo.ProfiliUtente.pfuImpMaxRdoAnn, dbo.ProfiliUtente.pfuImpMaxOffAnn, 
                      dbo.ProfiliUtente.pfuIdLng, dbo.ProfiliUtente.pfuParametriBench, dbo.ProfiliUtente.pfuSkillLevel1, dbo.ProfiliUtente.pfuSkillLevel2, 
                      dbo.ProfiliUtente.pfuSkillLevel3, dbo.ProfiliUtente.pfuSkillLevel4, dbo.ProfiliUtente.pfuSkillLevel5, dbo.ProfiliUtente.pfuSkillLevel6, 
                      dbo.ProfiliUtente.pfuE_Mail, dbo.ProfiliUtente.pfuTestoSollecito, dbo.ProfiliUtente.pfuDeleted, dbo.ProfiliUtente.pfuBizMail, 
                      dbo.ProfiliUtente.pfuCatalogo, dbo.ProfiliUtente.pfuProfili, dbo.ProfiliUtente.pfuFunzionalita, dbo.ProfiliUtente.pfuopzioni, dbo.ProfiliUtente.pfuTel, 
                      dbo.ProfiliUtente.pfuCell, dbo.ProfiliUtente.pfuSIM, dbo.ProfiliUtente.pfuIdMpMod
FROM         dbo.Document_RDA INNER JOIN
                      dbo.CTL_ApprovalSteps ON dbo.Document_RDA.RDA_ID = dbo.CTL_ApprovalSteps.APS_ID_DOC INNER JOIN
                      dbo.ProfiliUtenteAttrib ON dbo.CTL_ApprovalSteps.APS_UserProfile = dbo.ProfiliUtenteAttrib.attValue INNER JOIN
                      dbo.ProfiliUtente ON dbo.ProfiliUtenteAttrib.IdPfu = dbo.ProfiliUtente.IdPfu
WHERE     (dbo.CTL_ApprovalSteps.APS_State <> 'Compiled') AND (dbo.CTL_ApprovalSteps.APS_Doc_Type = 'RDA') AND 
                      (dbo.ProfiliUtenteAttrib.dztNome = 'UserRole') AND (dbo.CTL_ApprovalSteps.APS_IdPfu = '')
UNION ALL
SELECT     Document_RDA_1.RDA_Type, Document_RDA_1.RDA_ID, Document_RDA_1.RDA_Owner, Document_RDA_1.RDA_Name, 
                      Document_RDA_1.RDA_DataCreazione, Document_RDA_1.RDA_Protocol, Document_RDA_1.RDA_Object, Document_RDA_1.RDA_Total, 
                      Document_RDA_1.RDA_Stato, Document_RDA_1.RDA_AZI, Document_RDA_1.RDA_Plant_CDC, Document_RDA_1.RDA_Valuta, 
                      Document_RDA_1.RDA_InBudget, Document_RDA_1.RDA_BDG_Periodo, Document_RDA_1.RDA_Deleted, Document_RDA_1.RDA_BuyerRole, 
                      Document_RDA_1.RDA_ResidualBudget, Document_RDA_1.RDA_CEO, Document_RDA_1.RDA_SOCRic, Document_RDA_1.RDA_PlantRic, 
                      Document_RDA_1.RDA_MCE, Document_RDA_1.RDA_DataScad, Document_RDA_1.RDA_Utilizzo, Document_RDA_1.RDA_Type AS Expr1, 
                      CTL_ApprovalSteps_1.APS_ID_ROW, CTL_ApprovalSteps_1.APS_Doc_Type, CTL_ApprovalSteps_1.APS_ID_DOC, CTL_ApprovalSteps_1.APS_State, 
                      CTL_ApprovalSteps_1.APS_Note, CTL_ApprovalSteps_1.APS_Allegato, CTL_ApprovalSteps_1.APS_UserProfile, CTL_ApprovalSteps_1.APS_IdPfu, 
                      CTL_ApprovalSteps_1.APS_IsOld, CTL_ApprovalSteps_1.APS_Date, ProfiliUtente_1.IdPfu, ProfiliUtente_1.pfuTs, ProfiliUtente_1.pfuIdAzi, 
                      ProfiliUtente_1.pfuNome, ProfiliUtente_1.pfuLogin, ProfiliUtente_1.pfuRuoloAziendale, ProfiliUtente_1.pfuPassword, ProfiliUtente_1.pfuPrefissoProt, 
                      ProfiliUtente_1.pfuAdmin, ProfiliUtente_1.pfuAcquirente, ProfiliUtente_1.pfuVenditore, ProfiliUtente_1.pfuInvRdO, ProfiliUtente_1.pfuRcvOff, 
                      ProfiliUtente_1.pfuInvOff, ProfiliUtente_1.pfuIdPfuBCopiaA, ProfiliUtente_1.pfuIdPfuSCopiaA, ProfiliUtente_1.pfuCopiaRdo, 
                      ProfiliUtente_1.pfuCopiaOffRic, ProfiliUtente_1.pfuImpMaxRdO, ProfiliUtente_1.pfuImpMaxOff, ProfiliUtente_1.pfuImpMaxRdoAnn, 
                      ProfiliUtente_1.pfuImpMaxOffAnn, ProfiliUtente_1.pfuIdLng, ProfiliUtente_1.pfuParametriBench, ProfiliUtente_1.pfuSkillLevel1, 
                      ProfiliUtente_1.pfuSkillLevel2, ProfiliUtente_1.pfuSkillLevel3, ProfiliUtente_1.pfuSkillLevel4, ProfiliUtente_1.pfuSkillLevel5, 
                      ProfiliUtente_1.pfuSkillLevel6, ProfiliUtente_1.pfuE_Mail, ProfiliUtente_1.pfuTestoSollecito, ProfiliUtente_1.pfuDeleted, ProfiliUtente_1.pfuBizMail, 
                      ProfiliUtente_1.pfuCatalogo, ProfiliUtente_1.pfuProfili, ProfiliUtente_1.pfuFunzionalita, ProfiliUtente_1.pfuopzioni, ProfiliUtente_1.pfuTel, 
                      ProfiliUtente_1.pfuCell, ProfiliUtente_1.pfuSIM, ProfiliUtente_1.pfuIdMpMod
FROM         dbo.Document_RDA AS Document_RDA_1 INNER JOIN
                      dbo.CTL_ApprovalSteps AS CTL_ApprovalSteps_1 ON Document_RDA_1.RDA_ID = CTL_ApprovalSteps_1.APS_ID_DOC INNER JOIN
                      dbo.ProfiliUtente AS ProfiliUtente_1 ON CTL_ApprovalSteps_1.APS_IdPfu = ProfiliUtente_1.IdPfu
WHERE     (CTL_ApprovalSteps_1.APS_State <> 'Compiled') AND (CTL_ApprovalSteps_1.APS_Doc_Type = 'RDA')





GO
