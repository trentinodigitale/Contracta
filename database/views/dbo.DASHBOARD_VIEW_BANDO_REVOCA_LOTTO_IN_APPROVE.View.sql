USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_BANDO_REVOCA_LOTTO_IN_APPROVE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[DASHBOARD_VIEW_BANDO_REVOCA_LOTTO_IN_APPROVE] as
select 

	R.*
	,R.idPfuInCharge as InCharge
	,B.Titolo as NomeBando
	,B.Body as OggettoBando
from CTL_DOC  R  with(nolock) 
	inner join CTL_DOC B  with(nolock) on B.id = R.linkeddoc
	
	inner join CTL_ApprovalSteps s  with(nolock) on R.tipodoc = APS_Doc_Type and APS_State = 'InCharge' and APS_ID_DOC = R.id and APS_IsOld=0
	
where R.deleted = 0 and R.TipoDoc='BANDO_REVOCA_LOTTO'








GO
