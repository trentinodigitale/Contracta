USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[checkPwdSecurity]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------
--controlla se la password rispetta i criteri di sicurezza del sistema
---------------------------------------------------------------

CREATE PROCEDURE [dbo].[checkPwdSecurity](@password as VARCHAR(1000) OUTPUT) 
AS

--declare @password varchar(1000)
--set @password = 'federico-FeD3ric0test'

DECLARE @k INT
DECLARE @tot INT

DECLARE @numeri VARCHAR(1000)
DECLARE @minuscole VARCHAR(1000)
DECLARE @maiuscole VARCHAR(1000)

DECLARE @totNumeri VARCHAR(1000)
DECLARE @totMinuscole VARCHAR(1000)
DECLARE @totMaiuscole VARCHAR(1000)
DECLARE @totSpecialchar VARCHAR(1000)
DECLARE @totCaratteri VARCHAR(1000)
DECLARE @totCaratteriMax varchar(100)

-- Recupero i parametri di sicurezza della password dalle sys 
set @totNumeri = (select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name = 'SYS_PWD_NUMERI')
set @totMinuscole = (select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name = 'SYS_PWD_MINUSCOLE')
set @totMaiuscole = (select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name = 'SYS_PWD_MAIUSCOLE')
set @totSpecialchar = (select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name = 'SYS_PWD_CARSPECIALI')
set @totCaratteri = (select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name = 'SYS_PWD_TOTCHAR')
set @totCaratteriMax = (select DZT_ValueDef from lib_dictionary with(nolock) where DZT_Name = 'SYS_PWD_TOTCHAR_MAX')


--print 'tot numeri : ' + @totNumeri
--print 'tot minuscole : ' + @totMinuscole
--print 'tot maiuscole : ' + @totMaiuscole
--print 'tot specialchar : ' + @totSpecialchar 
--print 'tot caratteri : ' + @totCaratteri

SET @numeri = '1234567890'
SET @minuscole = 'qwertyuiopasdfghjklzxcvbnm'
SET @maiuscole = 'QWERTYUIOPASDFGHJKLZXCVBNM'

SET @k = 1
set @tot = len(@password)

declare @carattere varchar(1)
declare @numMin INT
declare @numMai INT
declare @numSpe INT
declare @numNum INT

set @numMin = 0
set @numMai = 0
set @numSpe = 0
set @numNum = 0


-- Se ha almeno un numero sufficiente di caratteri per passare il test
if len(@password) >=  @totCaratteri and len(@password) <=  @totCaratteriMax
begin

	WHILE (@k <=@tot)
	BEGIN
		
		set @carattere = substring(@password, @k,1)
		
		--PRINT @carattere
		
		-- Conto i numeri nella password
		if charindex( @carattere, @numeri COLLATE Latin1_General_CS_AS) > 0
			set @numNum = @numNum + 1		
		else
			-- Conto i caratteri minuscoli nella password
			if charindex( @carattere, @minuscole COLLATE Latin1_General_CS_AS) > 0
				set @numMin = @numMin + 1
			else
				-- Conto i caratteri minuscoli nella password
				if charindex( @carattere, @maiuscole COLLATE Latin1_General_CS_AS) > 0
					set @numMai = @numMai + 1		
				else
					-- Conto i caratteri speciali nella password
					set @numSpe = @numSpe + 1	
		
		--Incremento il contatore di ciclo
		SET @k =@k + 1

	END
	
	-- Se la password ha soddisfatto i criteri di sicurezza imposti dal sistema	
	if @numSpe >= @totSpecialchar and @numMai >= @totMaiuscole and @numMin >= @totMinuscole and @numNum >= @totNumeri
		select 'approved!' as res
	else
		select top 0 'approved!' as res


end
else
	select top 0 'approved!' as res




--PRINT 'tot numeri : ' + str(@numNum)
--PRINT 'tot minusc : ' + str(@numMin)
--PRINT 'tot maiusc : ' + str(@numMai)
--PRINT 'tot specia : ' + str(@numSpe)




GO
