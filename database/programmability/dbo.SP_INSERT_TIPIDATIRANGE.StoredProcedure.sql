USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_INSERT_TIPIDATIRANGE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[SP_INSERT_TIPIDATIRANGE] ( @idtid int, @DESCR VARCHAR(500))
AS
BEGIN

declare @IdDsc int
declare @ITA varchar(500)
declare @artCode varchar(10)
declare @codext varchar(100)
declare @tdrRelOrdine int
declare @tdrCodice  int

--set @ITA='Istituzione Mutualistica - Altro'






set @ITA= @DESCR

INSERT INTO DescsI (dscTesto) VALUES (@ITA)

      IF @@ERROR <> 0
      BEGIN
	   RAISERROR ('Errore "INSERT" DescsI per il codice [%s]', 16, 1, @artCode)
           ROLLBACK TRAN
           RETURN
      END

      SET @IdDsc = @@IDENTITY

	 --set @ITA= '156 -  	China Renminbi (Yuan)'

      INSERT INTO DescsUK (IdDsc, dscTesto) VALUES (@IdDsc, @ITA)

      IF @@ERROR <> 0
      BEGIN
	   RAISERROR ('Errore "INSERT" DescsUK per il codice [%s]', 16, 1, @artCode)
           ROLLBACK TRAN
           RETURN
      END

      INSERT INTO DescsE (IdDsc, dscTesto) VALUES (@IdDsc, @ITA)

      IF @@ERROR <> 0
      BEGIN
	   RAISERROR ('Errore "INSERT" DescsE per il codice [%s]', 16, 1, @artCode)
           ROLLBACK TRAN
           RETURN
      END

      INSERT INTO DescsFRA (IdDsc, dscTesto) VALUES (@IdDsc, @ITA)

      IF @@ERROR <> 0
      BEGIN
	   RAISERROR ('Errore "INSERT" DescsFRA per il codice [%s]', 16, 1, @artCode)
           ROLLBACK TRAN
           RETURN
      END

    --  INSERT INTO DescsDE (IdDsc, dscTesto) VALUES (@IdDsc, @ITA)

    --  IF @@ERROR <> 0
    --  BEGIN
	   --RAISERROR ('Errore "INSERT" DescsDE per il codice [%s]', 16, 1, @artCode)
    --       ROLLBACK TRAN
    --       RETURN
    --  END


      
	select @tdrCodice=max(cast(tdrCodice as int)) from TipiDatiRange
	where tdrIdTid=@idtid

	select @tdrRelOrdine=max(cast(tdrRelOrdine as int)) from TipiDatiRange
	where tdrIdTid=@idtid

	set @tdrRelOrdine = @tdrRelOrdine + 1 
	set @tdrCodice = @tdrCodice + 1
	set @codext=@tdrCodice

      
	insert into       dbo.TipiDatiRange
	(tdrIdTid, tdrIdDsc, tdrRelOrdine, tdrUltimaMod, tdrCodice, tdrDeleted, tdrCodiceEsterno, tdrCodiceRaccordo)
	values
	(@idtid,@IdDsc,@tdrRelOrdine,getdate(),@tdrCodice ,0,@codext,@codext)

END
GO
