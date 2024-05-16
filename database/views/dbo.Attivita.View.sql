USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Attivita]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Attivita]
AS
SELECT     IdDg AS IdAtv, dgCodiceInterno AS atvAtecord, dgIdDsc AS atvIdDsc
FROM         dbo.DominiGerarchici
WHERE     (dgTipoGerarchia = 18) AND (dgDeleted = 0)
GO
