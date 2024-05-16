USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[usp_Encrypt]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_Encrypt] (@pwdIN NVARCHAR(200), @pwdOUT NVARCHAR(200) OUTPUT)
AS

DECLARE @strTemp    NVARCHAR(100)
DECLARE @nAsc       INTEGER
DECLARE @nLen       INTEGER
DECLARE @i          INTEGER
DECLARE @offsetpari CHAR(1)
DECLARE @offsetdisp CHAR(1)

/* Costanti */

SET @offsetpari = 'h'
SET @offsetdisp = 'e'

/* Fine Costanti */

SET @nLen = len (@pwdIN)

SET @pwdOUT = ''


SET @i = 1

WHILE @i <= @nLen
BEGIN

     SET @strTemp = SUBSTRING (@pwdIN, @i, 1)

     IF (@i % 2) = 0 -- pari
         SET @nAsc = ASCII(@strTemp) + (@i + ASCII(@offsetpari))
     ELSE
         SET @nAsc = ASCII(@strTemp) + (@i + ASCII(@offsetdisp))

     IF (@nAsc <= 0) 
         SET @nAsc = @nAsc - 255

     SET @strTemp = CHAR(@nAsc)
     SET @pwdOUT = @pwdOUT + @strTemp

     SET @i = @i + 1
END



GO
