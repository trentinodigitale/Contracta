USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Get_CompanyId]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE  [dbo].[Get_CompanyId] (@CompanyLog  char(7), @CompanyId INT OUTPUT) AS
Begin
  DECLARE @MyId INT
  DECLARE @Alfa0 INT
  DECLARE @Alfa1 INT
  DECLARE @Alfa2 INT
  DECLARE @Alfa3 INT
  DECLARE @Alfa4 INT
  DECLARE @Alfa5 INT
  DECLARE @Alfa6 INT
  DECLARE @Calc INT
  DECLARE @Code char(7)
 set @CompanyLog = UPPER (@CompanyLog)
 set @Calc = 0
 set @Code = @CompanyLog       --esempio input Companylog
 set @Alfa6 = ascii(substring(@Code, 1, 1)) - 65 
 set @Calc = (@Calc * 26) + @Alfa6
 set @Alfa5 = ascii(substring(@Code, 2, 1)) - 65 
 set @Calc = (@Calc * 26) + @Alfa5
 set @Alfa4 = ascii(substring(@Code, 3, 1)) - 48 
 set @Calc = (@Calc * 10) + @Alfa4
 set @Alfa3 = ascii(substring(@Code, 4, 1)) - 48
 set @Calc = (@Calc * 10) + @Alfa3
 set @Alfa2 = ascii(substring(@Code, 5, 1)) - 48
 set @Calc = (@Calc * 10) + @Alfa2
 set @Alfa1 = ascii(substring(@Code, 6, 1)) - 65 
 set @Calc = (@Calc * 26) + @Alfa1
 set @Alfa0 = ascii(substring(@Code, 7, 1)) - 65 
 set @Calc = (@Calc * 26) + @Alfa0
 set @Calc = @Calc + 1
 set @CompanyId=@Calc 
End
GO
