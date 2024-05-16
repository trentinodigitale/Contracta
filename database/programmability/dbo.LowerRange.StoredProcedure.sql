USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[LowerRange]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
    Nome Stored....................: LowerRange
    Data Creazione.................: 19/06/2000
*/
CREATE PROCEDURE [dbo].[LowerRange]( @RngLow INT, @RngUp INT OUTPUT) AS
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
 -- Calcola l'intervallo superiore sostituendo 0 al valore di @b0, @b1, @b2
 SELECT @b0 = 0
 SELECT @b1 = 0
 SELECT @b2 = 0
 IF @B3 > 127
  SELECT @RngUp = ((((((@B3 - 256) * 256) + @B2) * 256) + @B1) * 256) + @B0
 ELSE
  SELECT @RngUp = (((((@B3 * 256) + @B2) * 256) + @B1) * 256) + @B0
GO
