USE [AFLink_TND]
GO
/****** Object:  View [dbo].[view_ProfiliUtenteAttrib]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[view_ProfiliUtenteAttrib] as
	select top 1 * from ProfiliUtenteAttrib
GO
