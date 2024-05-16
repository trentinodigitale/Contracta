USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BOModOfid_DelOfid]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[BOModOfid_DelOfid](@IdMdl INT) AS
  -- Cancellazione logica
  BEGIN TRAN
  UPDATE Modelli SET mdlDeleted = 1 WHERE IdMdl = @IdMdl
  UPDATE Offerte SET offDeleted = 1 WHERE IdOff IN (
   SELECT mazIdOff FROM ModelliAziende WHERE mazIdMdl = @IdMdl )
  COMMIT TRAN
GO
