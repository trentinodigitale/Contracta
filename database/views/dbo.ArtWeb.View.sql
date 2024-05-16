USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ArtWeb]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ArtWeb] AS
SELECT Articoli.IdArt as IdArt, 
       ValoriAttributi_Nvarchar.vatValore as artWeb
  FROM Articoli, DfVatArt, ValoriAttributi, ValoriAttributi_Nvarchar
 WHERE Articoli.IdArt = DfVatArt.IdArt
   AND DfVatArt.IdVat = ValoriAttributi.IdVat
   AND ValoriAttributi.IdVat = ValoriAttributi_Nvarchar.IdVat
   AND ValoriAttributi.vatIdDzt = 117
GO
