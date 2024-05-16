USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetAziLog]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[GetAziLog] (@IdAzi AS INTeger, @AziLog AS VARCHAR(7) OUTPUT)
 AS
 DECLARE @Alfa0 INT
 DECLARE @Alfa1 INT
 DECLARE @Alfa2 INT
 DECLARE @Alfa3 INT
 DECLARE @Alfa4 INT
 DECLARE @Alfa5 INT
 DECLARE @Alfa6 INT
 DECLARE @Calc INT
 SET @Calc = @IdAzi  + 193335999
 SET @Alfa0 = @Calc % 26
 SET @Calc = @Calc / 26
 SET @Alfa1 = @Calc % 26
 SET @Calc = @Calc / 26
 SET @Alfa2 = @Calc % 10
 SET @Calc = @Calc / 10
 SET @Alfa3 = @Calc % 10
 SET @Calc = @Calc / 10
 SET @Alfa4 = @Calc % 10
 SET @Calc = @Calc / 10
 SET @Alfa5 = @Calc % 26
 SET @Calc = @Calc / 26
 SET @Alfa6 = @Calc % 26
 SET @Calc = @Calc / 26
 SET @AziLog = CHAR(@Alfa6 + 65) + CHAR(@Alfa5 + 65) + CHAR(@Alfa4 + 48) + CHAR(@Alfa3 + 48) + CHAR(@Alfa2 + 48) + CHAR(@Alfa1 + 65) + CHAR(@Alfa0 + 65)
GO
