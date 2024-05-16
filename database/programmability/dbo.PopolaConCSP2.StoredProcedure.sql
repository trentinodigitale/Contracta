USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PopolaConCSP2]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[PopolaConCSP2] (@IdMP AS INT)  
AS
IF EXISTS(SELECT TABLE_NAME 
            FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = 'ConCSP')
      delete FROM ConCSP
ELSE
     create table ConCSP (Conta  INT , ConCspCode VARCHAR(25),UltimaModifica DATETIME default GETDATE(),ConIdMP INT)
insert INTo ConCSP (conta,ConCspCode,ConIdMP) 
SELECT count(a.idart),c.dgCodiceInterno, e.mpaidmp
FROM VArtCsp2 a, mpaziende e, DominiGerarchici c
WHERE   a.artidazi = e.mpaidazi 
        AND c.dgCodiceInterno <> 0
        AND a.dgPath like c.dgPath + '%'
        AND c.dgTipoGerarchia = 244
        AND e.mpadeleted=0
group by c.dgCodiceInterno, e.mpaidmp
having count(a.idart)>0
insert INTo ConCsp(conta,ConCspCode,ConIdMP) 
SELECT 0, '0', IdMp FROM MarketPlace
GO
