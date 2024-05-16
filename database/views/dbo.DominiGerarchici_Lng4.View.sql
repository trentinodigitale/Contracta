USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DominiGerarchici_Lng4]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[DominiGerarchici_Lng4]
AS
SELECT DominiGerarchici.IdDg            AS IdTab, 
       DescsLng4.dscTesto               AS tabTesto, 
       DominiGerarchici.dgTipoGerarchia AS tabTipo,
       DominiGerarchici.dgCodiceInterno AS tabValue,
       DominiGerarchici.dgCodiceEsterno AS tabCode,
       DominiGerarchici.dgPath          AS tabPath,
       DominiGerarchici.dgLivello       AS tabLiv,
       DominiGerarchici.dgFoglia        AS tabFoglia,
       DominiGerarchici.dgLenPathPadre  AS tabLenPathPadre,
       DominiGerarchici.dgDeleted       AS tabDeleted,
       DominiGerarchici.dgUltimaMod     AS tabUltimaMod
  FROM DominiGerarchici, DescsLng4 
 WHERE DominiGerarchici.dgIdDsc = DescsLng4.IdDsc
   AND DominiGerarchici.dgUltimaMod >= DescsLng4.dscUltimaMod
UNION ALL
SELECT DominiGerarchici.IdDg            AS IdTab, 
       DescsLng4.dscTesto               AS tabTesto, 
       DominiGerarchici.dgTipoGerarchia AS tabTipo,
       DominiGerarchici.dgCodiceInterno AS tabValue,
       DominiGerarchici.dgCodiceEsterno AS tabCode,
       DominiGerarchici.dgPath          AS tabPath,
       DominiGerarchici.dgLivello       AS tabLiv,
       DominiGerarchici.dgFoglia        AS tabFoglia,
       DominiGerarchici.dgLenPathPadre  AS tabLenPathPadre,
       DominiGerarchici.dgDeleted       AS tabDeleted,
       DescsLng4.dscUltimaMod           AS tabUltimaMod
  FROM DominiGerarchici, DescsLng4 
 WHERE DominiGerarchici.dgIdDsc = DescsLng4.IdDsc
   AND DominiGerarchici.dgUltimaMod < DescsLng4.dscUltimaMod
GO
