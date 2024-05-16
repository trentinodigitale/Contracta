USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Bando_GARA_Riferimenti_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Document_Bando_GARA_Riferimenti_VIEW] AS
select
	DR.*,
	case 
		when DR.RuoloRiferimenti = 'ReferenteTecnico' then ' RuoloRiferimenti ' 
			else '' end 
		as NotEditable
	from Document_Bando_Riferimenti DR with(nolock)	
GO
