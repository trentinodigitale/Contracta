USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_AZI_VIEW_SCHEDA_ANAGRAFICA_ATTIVITA_PROF]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD2_AZI_VIEW_SCHEDA_ANAGRAFICA_ATTIVITA_PROF] as


select 
	idVat as id,  
	--'###' + vatvalore_ft + '###' as AttivitaProfessionale , 
	vatvalore_ft as AttivitaProfessionale_s , 
	lnk as idAzi 

from dm_attributi  
	where dztnome = 'AttivitaProfessionale' and idapp = 1


GO
