USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DominiGerarchici_FRA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[DominiGerarchici_FRA]
AS
SELECT DominiGerarchici.IdDg            AS IdTab, 
       DescsFRA.dscTesto                  AS tabTesto, 
       DominiGerarchici.dgTipoGerarchia AS tabTipo,
       DominiGerarchici.dgCodiceInterno AS tabValue,
       DominiGerarchici.dgCodiceEsterno AS tabCode,
       DominiGerarchici.dgPath          AS tabPath,
       DominiGerarchici.dgLivello       AS tabLiv,
       DominiGerarchici.dgFoglia        AS tabFoglia,
       DominiGerarchici.dgLenPathPadre  AS tabLenPathPadre,
       DominiGerarchici.dgDeleted       AS tabDeleted,
       DominiGerarchici.dgUltimaMod     AS tabUltimaMod
  FROM DominiGerarchici, DescsFRA 
 WHERE DominiGerarchici.dgIdDsc = DescsFRA.IdDsc
   AND DominiGerarchici.dgUltimaMod >= DescsFRA.dscUltimaMod
UNION ALL
SELECT DominiGerarchici.IdDg            AS IdTab, 
       DescsFRA.dscTesto                  AS tabTesto, 
       DominiGerarchici.dgTipoGerarchia AS tabTipo,
       DominiGerarchici.dgCodiceInterno AS tabValue,
       DominiGerarchici.dgCodiceEsterno AS tabCode,
       DominiGerarchici.dgPath          AS tabPath,
       DominiGerarchici.dgLivello       AS tabLiv,
       DominiGerarchici.dgFoglia        AS tabFoglia,
       DominiGerarchici.dgLenPathPadre  AS tabLenPathPadre,
       DominiGerarchici.dgDeleted       AS tabDeleted,
       DescsFRA.dscUltimaMod              AS tabUltimaMod
  FROM DominiGerarchici, DescsFRA 
 WHERE DominiGerarchici.dgIdDsc = DescsFRA.IdDsc
   AND DominiGerarchici.dgUltimaMod < DescsFRA.dscUltimaMod
GO
