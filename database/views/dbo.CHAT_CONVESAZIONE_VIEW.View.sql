USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CHAT_CONVESAZIONE_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[CHAT_CONVESAZIONE_VIEW] AS
SELECT
		CA.*,
		id,LinkedDoc
FROM
ctl_doc
INNER JOIN CTL_ApprovalSteps CA ON LinkedDoc=APS_ID_DOC and APS_Doc_Type='CHAT'
WHERE TIPODOC='CHAT'

GO
