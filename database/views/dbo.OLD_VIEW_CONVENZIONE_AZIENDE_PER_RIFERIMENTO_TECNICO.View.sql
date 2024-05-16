USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_CONVENZIONE_AZIENDE_PER_RIFERIMENTO_TECNICO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create VIEW  
	
	[dbo].[OLD_VIEW_CONVENZIONE_AZIENDE_PER_RIFERIMENTO_TECNICO]
	
	as

	select 
		idheader as IdDoc, 
		R.idpfu as Idpfu_RiferimentoTecnico,
		AR.pfuidazi as Azienda_RiferimentoTecnico,
		AC.pfuidazi as Azienda_Compilatore 
		

	from  
		Document_Bando_Riferimenti R with (nolock) 
			inner join ctl_doc C with (nolock) on id = idHeader	
			inner join ProfiliUtente AC with (nolock) on AC.idpfu = C.idpfu 
			inner join ProfiliUtente AR with (nolock) on AR.idpfu = R.idpfu 
GO
