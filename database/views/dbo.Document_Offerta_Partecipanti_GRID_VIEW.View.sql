USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Offerta_Partecipanti_GRID_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Document_Offerta_Partecipanti_GRID_VIEW] as
select 
	DOP.*,
	case when DOP.Ruolo_Impresa IN ('Mandataria') OR ISNULL(IdAzi,0) > 0 then ' RagSoc INDIRIZZOLEG LOCALITALEG PROVINCIALEG '
		else ''
	end as NotEditable

	from Document_Offerta_Partecipanti DOP with(nolock)
GO
