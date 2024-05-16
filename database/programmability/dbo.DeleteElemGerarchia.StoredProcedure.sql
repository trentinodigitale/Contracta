USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DeleteElemGerarchia]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
Autore: Alfano Antonio
Scopo: Delete logico elemento della gerarchia
Data: 7/6/2001
*/
CREATE PROCEDURE [dbo].[DeleteElemGerarchia](@IdTid INT,@CodiceInterno VARCHAR(20))
AS
begin
DECLARE @dgPath VARCHAR(100)
DECLARE @dgLivello INT
begin tran
--Update dgDeleted=1 del nodo dato in input e di tutto il sottoalbero legato 
update DominiGerarchici
set dgDeleted=1
WHERE dgCodiceInterno in (SELECT b.dgCodiceInterno FROM DominiGerarchici a,DominiGerarchici b
WHERE b.dgpath like  a.dgpath+'%' AND a.dgCodiceInterno=@CodiceInterno AND a.dgTipoGerarchia=@IdTid AND b.dgTipoGerarchia=@IdTid) AND dgTipoGerarchia=@IdTid 
    IF @@error <> 0
                                           begin
                                                raiserror ('Errore update DominiGerarchici(DeleteElemGerarchia) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
SELECT @dgLivello=dglivello,@dgpath=dgpath  FROM DominiGerarchici
WHERE   dgCodiceInterno=@CodiceInterno AND dgTipoGerarchia= @IdTid
--caso in cui il vecchio padre non sia il primo nodo (--a che serve?)
IF left(@dgPath,len(@dgPath)-4)<>''  begin --if
--Caso in cui il vecchio padre diventa foglia (non ha figli)
IF not exists (SELECT  *
FROM dominiGerarchici 
WHERE dgpath like left(@dgPath,len(@dgPath)-4)+'%'  
and dglivello=@dgLivello AND dgTipoGerarchia=@IdTid AND dgpath<>@dgPath AND dgDeleted=0)        BEGIN  --iff
update dominiGerarchici    --Aggiornamento del vecchio padre (dgfoglia=1)
set dgfoglia=1
WHERE  dgpath=left(@dgPath,len(@dgPath)-4) AND dgTipoGerarchia=@IdTid AND dgDeleted=0 
IF @@error <> 0
                                           begin
                                                raiserror ('Errore Update DominiGerarchici (DeleteElemGerarchia) ', 16, 1) 
                                                rollback tran
                                                return 99
                                                 END
                                                            END --iff
end --if
commit tran
end
GO
