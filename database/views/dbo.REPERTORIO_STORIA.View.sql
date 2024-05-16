USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPERTORIO_STORIA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[REPERTORIO_STORIA] as 
SELECT     APS_ID_ROW, APS_Doc_Type, APS_ID_DOC, APS_State as StatoRepertorio, APS_Note, APS_Allegato, APS_UserProfile, APS_IdPfu, APS_IsOld, APS_Date
FROM         CTL_ApprovalSteps

GO
