USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_DOCUMENT_CARRELLO]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[VIEW_DOCUMENT_CARRELLO] as 

select C.* , D.UnitadiMisura ,   co.Mandataria 
	from carrello C with(nolock ) 
		inner join		document_microlotti_dettagli D with(nolock )  on C.Id_Product=D.id
		inner join document_convenzione co with(nolock )  on Id_Convenzione = co.id

GO
