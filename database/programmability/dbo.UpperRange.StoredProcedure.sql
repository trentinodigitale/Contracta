USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[UpperRange]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[UpperRange]( @RngLow INT, @RngUp INT OUTPUT) AS
 DECLARE @B0 INT
 DECLARE @B1 INT
 DECLARE @B2 INT
 DECLARE @B3 INT
 DECLARE @t INT
 
 IF @RngLow < 0
 BEGIN
  SELECT @t = @RngLow + 2147483647 + 1
  SELECT @B0 = @t % 256
  SELECT @t = @t / 256
  SELECT @B1 = @t % 256
  SELECT @t = @t / 256
  SELECT @B2 = @t % 256
  SELECT @t = @t / 256
  SELECT @B3 = @t + 128
 END ELSE BEGIN
  SELECT @t = @RngLow
  SELECT @B0 = @t % 256
  SELECT @t = @t / 256
  SELECT @B1 = @t % 256
  SELECT @t = @t / 256
  SELECT @B2 = @t % 256
  SELECT @t = @t / 256
  SELECT @B3 = @t
 END
 -- Calcola l'intervallo superiore sostituendo 255 a 0
 IF @B0 = 0
 BEGIN
  SELECT @B0 = 255
  IF @B1 = 0
  BEGIN
   SELECT @B1 = 255
   IF @B2 = 0 SELECT @B2 = 255
  END
 END
 IF @B3 > 127
  SELECT @RngUp = ((((((@B3 - 256) * 256) + @B2) * 256) + @B1) * 256) + @B0
 ELSE
  SELECT @RngUp = (((((@B3 * 256) + @B2) * 256) + @B1) * 256) + @B0
GO
