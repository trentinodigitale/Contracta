USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModRic_DelRic]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModRic_DelRic](@IdRic INT) AS
  BEGIN TRAN
  DELETE ValoriAttributi_Int FROM ValoriAttributi_Int 
    INNER JOIN RicercheParametri ON ValoriAttributi_Int.IdVat = RicercheParametri.rpmIdVat
    WHERE (RicercheParametri.rpmIdRic = @IdRic)
  IF @@ERROR <> 0 GOTO lblWrong
  DELETE ValoriAttributi_Float FROM ValoriAttributi_Float 
    INNER JOIN RicercheParametri ON ValoriAttributi_Float.IdVat = RicercheParametri.rpmIdVat
    WHERE (RicercheParametri.rpmIdRic = @IdRic)
  IF @@ERROR <> 0 GOTO lblWrong
  DELETE ValoriAttributi_NVarChar FROM ValoriAttributi_NVarChar
    INNER JOIN RicercheParametri ON ValoriAttributi_NVarChar.IdVat = RicercheParametri.rpmIdVat
    WHERE (RicercheParametri.rpmIdRic = @IdRic)
  IF @@ERROR <> 0 GOTO lblWrong
  DELETE ValoriAttributi_Money FROM ValoriAttributi_Money
    INNER JOIN RicercheParametri ON ValoriAttributi_Money.IdVat = RicercheParametri.rpmIdVat
    WHERE (RicercheParametri.rpmIdRic = @IdRic)
  IF @@ERROR <> 0 GOTO lblWrong
  DELETE ValoriAttributi_Datetime FROM ValoriAttributi_Datetime 
    INNER JOIN RicercheParametri ON ValoriAttributi_Datetime.IdVat = RicercheParametri.rpmIdVat
    WHERE (RicercheParametri.rpmIdRic = @IdRic)
  IF @@ERROR <> 0 GOTO lblWrong
  DELETE ValoriAttributi_Descrizioni FROM ValoriAttributi_Descrizioni 
    INNER JOIN RicercheParametri ON ValoriAttributi_Descrizioni.IdVat = RicercheParametri.rpmIdVat 
    WHERE (RicercheParametri.rpmIdRic = @IdRic)
  IF @@ERROR <> 0 GOTO lblWrong
  DELETE ValoriAttributi_NVarChar FROM ValoriAttributi_NVarChar
    INNER JOIN RicercheParametri ON ValoriAttributi_NVarChar.IdVat = RicercheParametri.rpmIdVat 
    WHERE (RicercheParametri.rpmIdRic = @IdRic)
  IF @@ERROR <> 0 GOTO lblWrong
  DELETE ValoriAttributi_Keys FROM ValoriAttributi_Keys
    INNER JOIN RicercheParametri ON ValoriAttributi_Keys.IdVat = RicercheParametri.rpmIdVat
    WHERE (RicercheParametri.rpmIdRic = @IdRic)
  IF @@ERROR <> 0 GOTO lblWrong
  DELETE RichercheArticoli WHERE (RichercheArticoli.racIdRic = @IdRic)
  IF @@ERROR <> 0 GOTO lblWrong
  DECLARE @CurIdVat INT
  DECLARE MyCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR 
   SELECT rpmIdVat FROM RicercheParametri WHERE rpmIdRic = @IdRic
  OPEN MyCursor
  FETCH NEXT FROM MyCursor INTo @CurIdVat
  WHILE @@FETCH_STATUS = 0
  BEGIN
    DELETE RicercheParametri WHERE rpmIdRic = @IdRic AND rpmIdVat = @CurIdVat
    IF @@ERROR <> 0 GOTO lblWrong
    DELETE ValoriAttributi WHERE IdVat = @CurIdVat
    IF @@ERROR <> 0 GOTO lblWrong
    FETCH NEXT FROM MyCursor INTo @CurIdVat
  END
  DELETE Ricerche WHERE (Ricerche.IdRic = @IdRic)
  IF @@ERROR <> 0 GOTO lblWrong
  /*
  RAISERROR('Sarebbe andato tutto bene!',16,1)
  IF @@ERROR <> 0 GOTO lblWrong
  */
  COMMIT TRAN
  GOTO lblEnd
lblWrong:
  ROLLBACK TRAN
lblEnd:
  CLOSE MyCursor
  DEALLOCATE MyCursor
GO
