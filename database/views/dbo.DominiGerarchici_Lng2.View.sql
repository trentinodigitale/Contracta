USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DominiGerarchici_Lng2]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[DominiGerarchici_Lng2]
AS
SELECT DominiGerarchici.IdDg            AS IdTab, 
       DescsLng2.dscTesto               AS tabTesto, 
       DominiGerarchici.dgTipoGerarchia AS tabTipo,
       DominiGerarchici.dgCodiceInterno AS tabValue,
       DominiGerarchici.dgCodiceEsterno AS tabCode,
       DominiGerarchici.dgPath          AS tabPath,
       DominiGerarchici.dgLivello       AS tabLiv,
       DominiGerarchici.dgFoglia        AS tabFoglia,
       DominiGerarchici.dgLenPathPadre  AS tabLenPathPadre,
       DominiGerarchici.dgDeleted       AS tabDeleted,
       DominiGerarchici.dgUltimaMod     AS tabUltimaMod
  FROM DominiGerarchici, DescsLng2 
 WHERE DominiGerarchici.dgIdDsc = DescsLng2.IdDsc
   AND DominiGerarchici.dgUltimaMod >= DescsLng2.dscUltimaMod
UNION ALL
SELECT DominiGerarchici.IdDg            AS IdTab, 
       DescsLng2.dscTesto               AS tabTesto, 
       DominiGerarchici.dgTipoGerarchia AS tabTipo,
       DominiGerarchici.dgCodiceInterno AS tabValue,
       DominiGerarchici.dgCodiceEsterno AS tabCode,
       DominiGerarchici.dgPath          AS tabPath,
       DominiGerarchici.dgLivello       AS tabLiv,
       DominiGerarchici.dgFoglia        AS tabFoglia,
       DominiGerarchici.dgLenPathPadre  AS tabLenPathPadre,
       DominiGerarchici.dgDeleted       AS tabDeleted,
       DescsLng2.dscUltimaMod           AS tabUltimaMod
  FROM DominiGerarchici, DescsLng2 
 WHERE DominiGerarchici.dgIdDsc = DescsLng2.IdDsc
   AND DominiGerarchici.dgUltimaMod < DescsLng2.dscUltimaMod
GO
