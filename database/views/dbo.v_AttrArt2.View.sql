USE [AFLink_TND]
GO
/****** Object:  View [dbo].[v_AttrArt2]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[v_AttrArt2]
as
select a.IdArt, b.artIdAzi, a.IdVat
  from dfvatart a, articoli b
 where a.idart = b.idart
   and b.artdeleted = 0
GO
