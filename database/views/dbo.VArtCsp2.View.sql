USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VArtCsp2]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VArtCsp2] AS SELECT idart, artidazi, dgCodiceInterno, dgCodiceEsterno, dgPath FROM DominiGerarchici, articoli WHERE dgCodiceInterno <> 0 AND artcspvalue = cast(dgCodiceInterno AS int) AND artdeleted = 0 AND dgTipoGerarchia = 244
GO
