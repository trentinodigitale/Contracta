USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_AZI_VIEW_SCHEDA_ANAGRAFICA_SOA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD_AZI_VIEW_SCHEDA_ANAGRAFICA_SOA] as


select 
	idVat as id,  
	vatvalore_ft as ClassificazioneSOA_S , 
	lnk as idAzi 

from dm_attributi    with (nolock)
	where dztnome = 'ClassificazioneSOA' and idapp = 1
GO
