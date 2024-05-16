USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOff_LanciaOff]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModOff_LanciaOff] (@IdOff INT) AS
 
 DECLARE @Stato INT
 DECLARE @CurIdPfu INT
 DECLARE @CurIdAzi INT
 DECLARE @CurIdMdl INT
 SELECT @Stato = offStato, @CurIdPfu = offIdPfu , @CurIdMdl = offIdMdl FROM Offerte WHERE IdOff = @IdOff
 IF @Stato <> 2 BEGIN
  RAISERROR ('Offerta Non Processabile',16,-1)
  GOTO lblFine
 END
 --Ottiene il protocollo
 DECLARE @Prot NVARCHAR(12)
 DECLARE @NProt INT
 SELECT @Prot = pfuPrefissoProt, @CurIdAzi = pfuIdAzi FROM ProfiliUtente WHERE IdPfu = @CurIdPfu
 SELECT @NProt = aziProssimoProtOff FROM Aziende WHERE IdAzi = @CurIdAzi
 SELECT @Prot = @Prot + ' ' + RIGHT('0000' + CAST(@NProt AS NVARCHAR),4)
 SELECT @NProt = @NProt + 1
 BEGIN TRAN
 UPDATE Aziende SET aziProssimoProtOff = @NProt WHERE IdAzi = @CurIdAzi
 UPDATE Offerte SET offProtocollo = @Prot, offStato = 3 WHERE IdOff = @IdOff
 -- Segnala che almeno il modello ha avuto almenu un'offerta in risposta
 UPDATE Modelli SET mdlStato = 3 WHERE IdMdl = @CurIdMdl
 COMMIT TRAN
lblFine:
GO
