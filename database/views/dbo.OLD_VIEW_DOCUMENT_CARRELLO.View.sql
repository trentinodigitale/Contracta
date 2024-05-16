USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_VIEW_DOCUMENT_CARRELLO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[OLD_VIEW_DOCUMENT_CARRELLO] as 

select C.* , D.UnitadiMisura
	from carrello C inner join
		document_microlotti_dettagli D on C.Id_Product=D.id
GO
