USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VArtCsp]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[VArtCsp]
AS
SELECT idart, artidazi, dgCodiceInterno, dgCodiceEsterno, dgPath
  FROM DominiGerarchici, articoli
 WHERE dgCodiceInterno <> 0 
   AND CAST(artcspvalue AS VARCHAR(20)) = dgCodiceInterno 
   AND artdeleted = 0 
   AND dgTipoGerarchia = 16
GO
