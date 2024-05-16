USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Filter_User_Tipo_Procedura]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[Filter_User_Tipo_Procedura] as 

	select idpfu , REL_ValueOutput as tdrcodice  
		from ProfiliUtenteAttrib with(NOLOCK)
			inner join CTL_Relations with(NOLOCK) on REL_Type='Filter_User_Tipo_Procedura' and REL_ValueInput=attValue
	where dztNome='Profilo'

GO
