USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[VALIDATE_LOGIN]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
---------------------------------------------------------------
--[OK] per il controllo della validita della LOgin inserita allla creazione del nuovo utente
---------------------------------------------------------------

CREATE PROCEDURE [dbo].[VALIDATE_LOGIN](@LOG as VARCHAR(1000) OUTPUT) 
AS
DECLARE @numeri VARCHAR(1000)
DECLARE @minuscole VARCHAR(1000)
DECLARE @maiuscole VARCHAR(1000)
DECLARE @caratteri VARCHAR(1000)
DECLARE @k INT
DECLARE @tot INT
DECLARE @controllo INT
set @controllo=0
declare @carattere varchar(1)

SET @numeri = '1234567890'
SET @minuscole = 'qwertyuiopasdfghjklzxcvbnm'
SET @maiuscole = 'QWERTYUIOPASDFGHJKLZXCVBNM'
SET @caratteri = '-_@.'

SET @k = 1
set @tot = len(@LOG)

WHILE (@k <=@tot)
	BEGIN
	
		set @carattere = substring(@LOG, @k,1)
		if (charindex( @carattere, @numeri COLLATE Latin1_General_CS_AS) > 0 )or
		    (charindex( @carattere, @minuscole COLLATE Latin1_General_CS_AS) > 0 )or
			  (charindex( @carattere, @maiuscole COLLATE Latin1_General_CS_AS) > 0 )or
				(charindex( @carattere, @caratteri COLLATE Latin1_General_CS_AS) > 0)
				
				set @controllo=@controllo + 1
		else
		set @controllo=@controllo - 1
	  SET @k =@k + 1
	END
	if @controllo=@tot
	select 'approved!' as res
	else
		select top 0 'approved!' as res

GO
