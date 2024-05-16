USE [AFLink_TND]
GO
/****** Object:  View [dbo].[v_AziAteco]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[v_AziAteco]
AS
SELECT IdAzi, AtvAtecord, dgCodiceInterno, dgCodiceEsterno, dgPath
FROM DominiGerarchici, AziAteco
WHERE dgCodiceInterno <> 0 AND cast(AtvAtecord as varchar(20)) = dgCodiceInterno and dgTipoGerarchia = 18
GO
