USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_view_Document_NoTIER_Prodotti_nolock]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[OLD2_view_Document_NoTIER_Prodotti_nolock] as
	select * from Document_NoTIER_Prodotti with(nolock)
GO
