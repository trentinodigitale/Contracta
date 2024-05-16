USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[EncryptPwdBase]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[EncryptPwdBase] (@AlgoritmoPwd NVARCHAR(2) , @PwdIN NVARCHAR(200) , @PwdOUT NVARCHAR(200) OUTPUT )
AS
BEGIN 

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

	SET @PwdOUT = ''


	SET @i = 1

	WHILE @i <= @nLen
	BEGIN

		 SET @strTemp = SUBSTRING (@pwdIN, @i, 1)

		 IF (@i % 2) = 0 -- pari
			 SET @nAsc = ASCII(@strTemp) + (@i + ASCII(@offsetpari))
		 ELSE
			 SET @nAsc = ASCII(@strTemp) + (@i + ASCII(@offsetdisp))

		 IF (@nAsc > 255) 
			 SET @nAsc = @nAsc - 255

		 SET @strTemp = CHAR(@nAsc)
		 SET @PwdOUT = @PwdOUT + @strTemp

		 SET @i = @i + 1
	END


END




GO
