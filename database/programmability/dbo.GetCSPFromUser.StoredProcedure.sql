USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetCSPFromUser]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetCSPFromUser] (@IdPfu INT)
AS
SELECT a.dgCodiceInterno AS CodiceInterno
  FROM DFBPfuCsp pfuCSP, DominiGerarchici a, DominiGerarchici b
 WHERE pfuCSP.IdPfu = @IdPfu
   AND pfuCSP.cspValue = b.dgCodiceInterno
   AND b.dgTipoGerarchia = 16
   AND a.dgTipoGerarchia = 16
   AND b.dgDeleted = 0
   AND a.dgDeleted = 0
   AND a.dgpath LIKE b.dgPath + '%'
ORDER BY a.dgCodiceInterno
GO
