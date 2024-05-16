USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CTL_DOC_SUB_QUESTIONARIO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[CTL_DOC_SUB_QUESTIONARIO]
AS


    select SUB.*, QUEST.idpfu as IdPfuRichiedente 
	   from ctl_doc SUB
		  inner join ctl_doc QUEST on SUB.LinkedDoc=QUEST.id
	   where SUB.tipodoc='SUB_QUESTIONARIO_FABBISOGNI' and SUB.deleted=0





GO
