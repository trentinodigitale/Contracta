USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PopolaConAziende]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[PopolaConAziende] (@IdMP AS INT)  AS
IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'ConAziende')
        delete FROM ConAziende
ELSE
 create table ConAziende (Conta  INT , AtvAtecord VARCHAR(25),UltimaModifica DATETIME default GETDATE(),ConIdMP INT, ConProfilo char(1))
insert INTo ConAziende (conta,atvatecord,ConIdMP, ConProfilo) 
SELECT count(vv.mpaidazi), vv.dgCodiceInterno, vv.mpaidmp, vv.Profilo
  from
(
SELECT e.mpaidazi, c.dgCodiceInterno, e.mpaidmp, 'B' AS Profilo
FROM v_AziAteco a, DominiGerarchici c, mpaziende e
WHERE   a.idazi= e.mpaidazi
        AND a.dgPath like c.dgPath + '%'
        AND c.dgCodiceInterno not like 'k%'
        AND c.dgDeleted = 0 
        AND c.dgTipoGerarchia = 18
        AND e.mpadeleted=0
        AND e.mpaacquirente <> 0 
        AND e.mpavenditore  = 0 
        AND c.dgCodiceInterno <> '0'
union all 
SELECT e.mpaidazi, c.dgCodiceInterno, e.mpaidmp, 'S' AS Profilo
FROM v_AziAteco a, DominiGerarchici c, mpaziende e
WHERE   a.idazi= e.mpaidazi
        AND a.dgPath like c.dgPath + '%'
        AND c.dgCodiceInterno not like 'k%'
        AND c.dgDeleted = 0 
        AND c.dgTipoGerarchia = 18
        AND e.mpadeleted=0
        AND e.mpaacquirente = 0 
        AND e.mpavenditore  <> 0 
        AND c.dgCodiceInterno <> '0'
union all
SELECT e.mpaidazi, c.dgCodiceInterno, e.mpaidmp, 'B' AS Profilo
FROM v_AziAteco a, DominiGerarchici c, mpaziende e
WHERE   a.idazi= e.mpaidazi
        AND a.dgPath like c.dgPath + '%'
        AND c.dgCodiceInterno not like 'k%'
        AND c.dgDeleted = 0 
        AND c.dgTipoGerarchia = 18
        AND e.mpadeleted=0
        AND e.mpaacquirente <> 0 
        AND e.mpavenditore  <> 0 
        AND c.dgCodiceInterno <> '0'
 
union all
SELECT e.mpaidazi, c.dgCodiceInterno, e.mpaidmp, 'S' AS Profilo
FROM v_AziAteco a, DominiGerarchici c, mpaziende e
WHERE   a.idazi= e.mpaidazi
        AND a.dgPath like c.dgPath + '%'
        AND c.dgCodiceInterno not like 'k%'
        AND c.dgDeleted = 0 
        AND c.dgTipoGerarchia = 18
        AND e.mpadeleted=0
        AND e.mpaacquirente <> 0 
        AND e.mpavenditore  <> 0 
        AND c.dgCodiceInterno <> '0'
union all 
SELECT e.mpaidazi, c.dgCodiceInterno, e.mpaidmp, 'S' AS Profilo
FROM v_AziAteco a, DominiGerarchici c, mpaziende e
WHERE   a.idazi= e.mpaidazi
        AND a.dgPath like c.dgPath + '%'
        AND c.dgCodiceInterno not like 'k%'
        AND c.dgDeleted = 0 
        AND c.dgTipoGerarchia = 18
        AND e.mpadeleted=0
        AND e.mpaprospect <> 0 
        AND c.dgCodiceInterno <> '0'
union all 
SELECT e.mpaidazi, c.dgCodiceInterno, e.mpaidmp, 'B' AS Profilo
FROM v_AziAteco a, DominiGerarchici c, mpaziende e
WHERE   a.idazi= e.mpaidazi
        AND a.dgPath like c.dgPath + '%'
        AND c.dgCodiceInterno not like 'k%'
        AND c.dgDeleted = 0 
        AND c.dgTipoGerarchia = 18
        AND e.mpadeleted=0
        AND e.mpaprospect <> 0 
        AND c.dgCodiceInterno <> '0'
union all 
SELECT e.mpaidazi, c.dgCodiceInterno, e.mpaidmp, 'T' AS Profilo
FROM v_AziAteco a, DominiGerarchici c, mpaziende e
WHERE   a.idazi= e.mpaidazi
        AND a.dgPath like c.dgPath + '%'
        AND c.dgCodiceInterno not like 'k%'
        AND c.dgDeleted = 0 
        AND c.dgTipoGerarchia = 18
        AND e.mpadeleted=0
        AND c.dgCodiceInterno <> '0'
) vv 
group by vv.dgCodiceInterno, vv.mpaidmp, vv.Profilo
having count(vv.mpaidazi)>0
insert INTo ConAziende (conta,atvatecord,ConIdMP, conProfilo) 
SELECT 0,'0',idmp, 'B' FROM MarketPlace
insert INTo ConAziende (conta,atvatecord,ConIdMP, conProfilo) 
SELECT 0,'0',idmp, 'S' FROM MarketPlace
insert INTo ConAziende (conta,atvatecord,ConIdMP, conProfilo) 
SELECT 0,'0',idmp, 'T' FROM MarketPlace
GO
