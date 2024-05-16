USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[sp_AddToMarketplace]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[sp_AddToMarketplace] (@SrcAzilog AS char (7), @DstMPLog AS VARCHAR (12)) AS
DECLARE @SrcIdAzi   AS INT
DECLARE @DstIdMp    AS INT
DECLARE @IdMpa      AS INT
SELECT @SrcIdAzi = IdAzi 
  FROM Aziende
 WHERE aziLog = @SrcAzilog
IF @SrcIdAzi IS NULL
   begin
         raiserror ('Azienda [%s] non trovata', 16, 1, @SrcAziLog)
         return 99
   end
SELECT @DstIdMp = IdMp 
  FROM MarketPlace
 WHERE mpLog = @DstMPLog
IF @DstIdMp IS NULL
   begin
         raiserror ('Marketplace [%s] non trovato', 16, 1, @DstMPLog)
         return 99
   end
IF exists (SELECT * FROM MPAziende WHERE mpaIdAzi = @SrcIdAzi AND mpaIdMp = @DstIdMp)
   begin
         raiserror ('L''Azienda [%s] _ giO presente per il Marketplace [%s]', 16, 1, @SrcAziLog, @DstMPLog)
         return 99
   end
SELECT top 1 @IdMpa = IdMpa  
  FROM MPAziende 
 WHERE mpaIdAzi = @srcIdAzi
 ORDER BY IdMpa 
IF @IdMpa IS NULL
   begin
         raiserror ('L''Azienda [%s] non _ presente in alcun Marketplace', 16, 1, @SrcAziLog)
         return 99
   end
set transaction isolation level serializable 
begin tran
insert INTo MPAziende (mpaIdAzi, mpaIdMp, mpaAcquirente, mpaVenditore, mpaProfili, mpaProspect)
SELECT mpaIdAzi, @DstIdMp, mpaAcquirente, mpaVenditore, mpaProfili, mpaProspect
  FROM MPAziende 
 WHERE IdMpa = @IdMpa
IF @@error <> 0
   begin
        raiserror ('Errore "Insert" MPAziende', 16, 1)
        rollback tran
        return 99
   end
commit tran
GO
