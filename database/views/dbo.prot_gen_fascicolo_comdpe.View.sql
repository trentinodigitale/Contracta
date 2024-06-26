USE [AFLink_TND]
GO
/****** Object:  View [dbo].[prot_gen_fascicolo_comdpe]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[prot_gen_fascicolo_comdpe] as 

	select	 IdCom as id
			 , fascicoloSecondario 
			 , dbo.GetColumnValue (fascicoloSecondario, '.', 1) AS ANNO_FASCICOLO
 			 , replace( replace(fascicoloSecondario, dbo.GetColumnValue (fascicoloSecondario, '.', 1) + '.', '') + '###','.' + dbo.GetColumnValue (fascicoloSecondario, '.', dbo.contaOccorrenze(fascicoloSecondario,'.') + 1 )+ '###', '') as CLASSIFICA_FASCICOLO
			 , dbo.GetColumnValue (fascicoloSecondario, '.', dbo.contaOccorrenze( fascicoloSecondario,'.') + 1 ) AS PROG_FASCICOLO
			 , dbo.getAOO( owner ) as AOO
		from document_Com_DPE with(nolock) 

GO
