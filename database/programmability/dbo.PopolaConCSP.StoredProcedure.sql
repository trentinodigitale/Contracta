USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PopolaConCSP]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[PopolaConCSP] (@IdMP AS INT)  
AS
IF EXISTS(SELECT TABLE_NAME 
            FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_NAME = 'ConCSP')
      delete FROM ConCSP
ELSE
     create table ConCSP (Conta  INT , ConCspCode VARCHAR(25),UltimaModifica DATETIME default GETDATE(),ConIdMP INT)
insert INTo ConCSP (conta,ConCspCode,ConIdMP) 
SELECT count(a.idart),c.dgCodiceInterno, e.mpaidmp
FROM VArtCsp a, mpaziende e, DominiGerarchici c
WHERE   a.artidazi = e.mpaidazi 
        AND c.dgCodiceInterno <> 0
        AND a.dgPath like c.dgPath + '%'
        AND c.dgTipoGerarchia = 16
        AND e.mpadeleted=0
group by c.dgCodiceInterno, e.mpaidmp
having count(a.idart)>0
insert INTo ConCsp(conta,ConCspCode,ConIdMP) 
SELECT 0, '0', IdMp FROM MarketPlace
GO
