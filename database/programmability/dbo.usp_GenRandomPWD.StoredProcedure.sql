USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_GenRandomPWD]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_GenRandomPWD] (@strPWD NVARCHAR(250) OUTPUT)
AS
BEGIN 

DECLARE @Cnt            INT
DECLARE @Char           INT
DECLARE @MinMax         INT
DECLARE @MaiMax         INT
DECLARE @NumMax         INT
DECLARE @CharMax        INT
DECLARE @Len            INT
DECLARE @Pos            INT
DECLARE @strPWDTmp      NVARCHAR(250)

declare @SYS_PWD_TOTCHAR int
SET @strPWDTmp = ''

SET @MinMax = 3
SET @MaiMax = 2
SET @CharMax = 1
SET @NumMax = 2
set @SYS_PWD_TOTCHAR = 8

DECLARE @totNumeri VARCHAR(1000)


-- Recupero quantio caratteri di ogni tipo dalle sys se presenti
if exists(select DZT_ValueDef from lib_dictionary where DZT_Name = 'SYS_PWD_MAIUSCOLE')
	set @MaiMax = cast( (select isnull(DZT_ValueDef,2) from lib_dictionary where DZT_Name = 'SYS_PWD_MAIUSCOLE') as int )

if exists(select DZT_ValueDef from lib_dictionary where DZT_Name = 'SYS_PWD_MINUSCOLE')
	set @MinMax = cast ( (select isnull(DZT_ValueDef,3) from lib_dictionary where DZT_Name = 'SYS_PWD_MINUSCOLE') as int )

if exists(select DZT_ValueDef from lib_dictionary where DZT_Name = 'SYS_PWD_CARSPECIALI')
	set @CharMax = cast(  (select isnull(DZT_ValueDef,1) from lib_dictionary where DZT_Name = 'SYS_PWD_CARSPECIALI') as int )

if exists(select DZT_ValueDef from lib_dictionary where DZT_Name = 'SYS_PWD_NUMERI')
	set @NumMax = cast( (select isnull(DZT_ValueDef,2) from lib_dictionary where DZT_Name = 'SYS_PWD_NUMERI') as int)


if exists(select DZT_ValueDef from lib_dictionary where DZT_Name = 'SYS_PWD_TOTCHAR')
	set @SYS_PWD_TOTCHAR = cast( (select isnull(DZT_ValueDef,2) from lib_dictionary where DZT_Name = 'SYS_PWD_TOTCHAR') as int)


-- se la somma delle varie tipologie non supera il numero minimo di caratteri compenso aggiungendo la differenza in minuscole
if @SYS_PWD_TOTCHAR > @MinMax + @MaiMax + @CharMax + @NumMax 
	set @MinMax = @SYS_PWD_TOTCHAR - ( @MaiMax + @CharMax + @NumMax )



/* Maiuscole */

SET @Cnt = 0

WHILE @Cnt < @MaiMax
BEGIN
        SET @Cnt = @Cnt + 1
        SET @Char = 0

        WHILE NOT (@Char BETWEEN 65 AND 90)
        BEGIN
                SET @Char = ROUND(RAND() * 93 + 33, 0)
        END

        SET @strPWDTmp = @strPWDTmp + CHAR(@Char)
END

/* Minuscole */

SET @Cnt = 0

WHILE @Cnt < @MinMax
BEGIN
        SET @Cnt = @Cnt + 1
        SET @Char = 0

        WHILE NOT (@Char BETWEEN 97 AND 122)
        BEGIN
                SET @Char = ROUND(RAND() * 93 + 33, 0)
        END

        SET @strPWDTmp = @strPWDTmp + CHAR(@Char)
END


/* Caratteri speciali */

SET @Cnt = 0

WHILE @Cnt < @CharMax
BEGIN
        SET @Cnt = @Cnt + 1
        SET @Char = 0

        WHILE NOT (@Char BETWEEN 91 AND 95) AND NOT (@Char BETWEEN 58 AND 64) AND NOT (@Char BETWEEN 33 AND 47)
        BEGIN
                SET @Char = ROUND(RAND() * 93 + 33, 0)
        END

        SET @strPWDTmp = @strPWDTmp + CHAR(@Char)
END


/* Due numeri */
SET @Cnt = 0

WHILE @Cnt < @NumMax
BEGIN
        SET @Cnt = @Cnt + 1
        SET @Char = 0

        WHILE NOT (@Char BETWEEN 48 AND 57)
        BEGIN
                SET @Char = ROUND(RAND() * 93 + 33, 0)
        END

        SET @strPWDTmp = @strPWDTmp + CHAR(@Char)
END

/* Scramble */
SET @Len = LEN(@strPWDTMP)
SET @strPWD = REPLICATE ('{', @Len)
SET @Cnt = 0

WHILE @Cnt < @Len
BEGIN
        SET @Cnt = @Cnt + 1

        SET @Pos =  ROUND(RAND() * @Len, 0)

        WHILE RTRIM(SUBSTRING(@strPWD, @Pos, 1)) <> '{'
        BEGIN
                SET @Pos =  ROUND(RAND() * @Len, 0)
        END
        
        SET @strPWD = STUFF(@strPWD, @Pos, 1, SUBSTRING(@strPWDTMP, @Cnt, 1))
        
END


END


GO
