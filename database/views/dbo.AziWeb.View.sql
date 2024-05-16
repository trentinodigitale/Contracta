USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AziWeb]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[AziWeb] AS
SELECT Aziende.IdAzi as IdAzi, ValoriAttributi_Nvarchar.vatValore as aziWeb
  FROM Aziende, DfVatAzi, ValoriAttributi, ValoriAttributi_Nvarchar
 WHERE Aziende.IdAzi = DfVatAzi.IdAzi
   AND DfVatAzi.IdVat = ValoriAttributi.IdVat
   AND ValoriAttributi.IdVat = ValoriAttributi_Nvarchar.IdVat
   AND ValoriAttributi.vatIdDzt = 76
GO
