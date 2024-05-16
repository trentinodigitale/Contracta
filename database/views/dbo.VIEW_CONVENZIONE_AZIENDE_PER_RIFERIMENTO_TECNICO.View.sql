USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_CONVENZIONE_AZIENDE_PER_RIFERIMENTO_TECNICO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW  
	
	[dbo].[VIEW_CONVENZIONE_AZIENDE_PER_RIFERIMENTO_TECNICO]
	
	as

	select 
		idheader as IdDoc, 
		R.idpfu as Idpfu_RiferimentoTecnico,
		
		--se utente riferimento tecnico non ha profilo GESTORE CONVENZIONE
		--faccio ritornare azienda diversa come fosse non di agenzia per limitare l'accesso
		case 
			when AR.pfuidazi = AC.pfuidazi and PU.IdUsAttr is  null then - AR.pfuidazi
			else AR.pfuidazi
		end as Azienda_RiferimentoTecnico,

		--AR.pfuidazi as Azienda_RiferimentoTecnico,
		AC.pfuidazi as Azienda_Compilatore 
		

	from  
		Document_Bando_Riferimenti R with (nolock) 
			inner join ctl_doc C with (nolock) on id = idHeader	
			inner join ProfiliUtente AC with (nolock) on AC.idpfu = C.idpfu 
			inner join ProfiliUtente AR with (nolock) on AR.idpfu = R.idpfu 
			left join ProfiliUtenteAttrib PU  with (nolock) on PU.idpfu = R.idpfu and PU.attValue ='GestoreNegoziElettro'
	where
		R.RuoloRiferimenti ='ReferenteTecnico'
	

	

	


GO
