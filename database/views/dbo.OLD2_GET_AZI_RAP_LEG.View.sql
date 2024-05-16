USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_GET_AZI_RAP_LEG]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD2_GET_AZI_RAP_LEG] as 


	select top 0
		-----------------------
		-----------------------
		az.idAzi ,
		-----------------------
		-----------------------

		left( d1.vatValore_FV , 16 ) as CFTIM ,		-- Codice fiscale ALFANUMERICO (16) X 
		left( d2.vatValore_FV , 40 ) as COGTIM ,	-- Cognome ALFANUMERICO (40)  
		left( d3.vatValore_FV , 20 ) as NOMETIM		-- Nome ALFANUMERICO (20) 


		from aziende az with(nolock)
			inner join DM_Attributi d1 with(nolock) on d1.idApp = 1 and d1.lnk = az.idAzi and d1.dztNome = 'CFRapLeg'
			left join DM_Attributi d2 with(nolock) on d2.idApp = 1 and d2.lnk = az.idAzi and d2.dztNome = 'CognomeRapLeg'
			left join DM_Attributi d3 with(nolock) on d3.idApp = 1 and d3.lnk = az.idAzi and d3.dztNome = 'NomeRapLeg'

		where d1.vatValore_FV <> ''

GO
