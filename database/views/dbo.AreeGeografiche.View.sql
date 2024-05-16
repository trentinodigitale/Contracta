USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AreeGeografiche]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AreeGeografiche]
AS
SELECT     IdDg AS Idgph, dgCodiceInterno AS gphValue, dgIdDsc AS gphIdDsc
FROM         dbo.DominiGerarchici
WHERE     (dgTipoGerarchia = 17) AND (dgDeleted = 0)
GO
