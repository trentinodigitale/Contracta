USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_MICROLOTTI_VIEW_CRONOLOGIA]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PDA_MICROLOTTI_VIEW_CRONOLOGIA] AS 
select
	* ,
	APS_ID_DOC as idheader,
	APS_Doc_Type as tipodoc
from  CTL_ApprovalSteps with(nolock)
	where APS_Doc_Type='PDA_MICROLOTTI'
GO
