USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONFIG_MODELLI_PROGRAMMAZIONE_LIST_ATTRIB]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CONFIG_MODELLI_PROGRAMMAZIONE_LIST_ATTRIB] as 
select a.name
	from syscolumns a, sysobjects b
	where a.id = b.id
	   and b.name = 'Document_Programmazione_Dettagli'
		and a.name not in (
				'Id'
				,'IdHeader'
				,'TipoDoc'				
				,'StatoRiga'
				,'EsitoRiga'
				,'Plant'
				,'CODICE_CUI'	
				,'NumeroRiga'			
		)

GO
