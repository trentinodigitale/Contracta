USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_MICROLOTTI_VIEW_CRON_E_DOC]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PDA_MICROLOTTI_VIEW_CRON_E_DOC] AS 

select
	APS_Date, APS_IdPfu, APS_State, APS_Note, APS_UserProfile, APS_ID_DOC, APS_Doc_Type, APS_ID_ROW
	from CTL_ApprovalSteps with(nolock)
	where APS_Doc_Type='PDA_MICROLOTTI'

union all

select 
	b.[Datainvio] APS_Date, 
	b.IdPfu APS_IdPfu, 
	b.TipoDoc APS_State, 
	--b.Titolo APS_Note,
	'Commissione Registro n°: ' + b.protocollo as APS_Note,
	'' APS_UserProfile,
	p.Id APS_ID_DOC,
	b.TipoDoc APS_Doc_Type, 
	b.LinkedDoc APS_ID_ROW
	from CTL_DOC P with (nolock)
		left outer join CTL_DOC b with (nolock) on p.LinkedDoc = b.linkeddoc
	where b.TipoDoc='COMMISSIONE_PDA' and b.deleted = 0  and b.StatoFunzionale <> 'InLavorazione'

GO
