USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_PDA_MICROLOTTI_VIEW_CRON_E_DOC]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_PDA_MICROLOTTI_VIEW_CRON_E_DOC] AS 

select
	APS_Date, APS_IdPfu, APS_State, APS_Note, APS_UserProfile, APS_ID_DOC, APS_Doc_Type, APS_ID_ROW
	from CTL_ApprovalSteps with(nolock)
	where APS_Doc_Type='PDA_MICROLOTTI'

union all

select 
	BANDO_SDA_LISTA_DOCUMENTI.[Data] APS_Date, BANDO_SDA_LISTA_DOCUMENTI.IdPfu APS_IdPfu, case when IsNull(BANDO_SDA_LISTA_DOCUMENTI.PrevDoc,0) > 0 then 'Modificata Commissione' else BANDO_SDA_LISTA_DOCUMENTI.TipoDoc end APS_State, BANDO_SDA_LISTA_DOCUMENTI.Titolo APS_Note, '' APS_UserProfile, CTL_DOC.Id APS_ID_DOC, BANDO_SDA_LISTA_DOCUMENTI.TipoDoc APS_Doc_Type, BANDO_SDA_LISTA_DOCUMENTI.LinkedDoc APS_ID_ROW
	from CTL_DOC with (nolock)
		left outer join BANDO_SDA_LISTA_DOCUMENTI on CTL_DOC.LinkedDoc = BANDO_SDA_LISTA_DOCUMENTI.linkeddoc
	where BANDO_SDA_LISTA_DOCUMENTI.TipoDoc='COMMISSIONE_PDA'

GO
