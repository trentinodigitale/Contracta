USE [AFLink_TND]
GO
/****** Object:  View [dbo].[WorkFlow_Doc_View]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
create view [dbo].[WorkFlow_Doc_View] as 

select w.* , pfuNome
 from CTL_ApprovalSteps w
	left outer join profiliutente p on APS_IdPfu = idpfu
	inner join CTL_DOC d on Id = APS_ID_DOC and TipoDoc = APS_Doc_Type


GO
