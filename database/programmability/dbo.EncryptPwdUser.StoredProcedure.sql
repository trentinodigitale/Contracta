USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[EncryptPwdUser]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[EncryptPwdUser] (@IdPfu int, @PwdIN NVARCHAR(250),@PwdOUT NVARCHAR(250) OUTPUT)
AS
BEGIN 
	
	declare @MakeCryptPwd as char(1)
	declare @AlgoritmoPwd as varchar(2)
	
	set @PwdOUT=@PwdIN
	set @MakeCryptPwd=''

	--controllo se devo cifrare oppure no la PWD da una REGDEFAULT
	select top 1 @MakeCryptPwd=isnull(rdDefValue,'') from 
		RegDefault 
	where 
		rdpath='Software\AFSoluzioni\AFLink\Options\User' 
		and rdkey='ActivePasswordEncryption'
		and rdDeleted = 0
	
	
	if @MakeCryptPwd <> '0'
	begin
		set @PwdOUT = ''
		set @AlgoritmoPwd = '0'

		--recupero tipo algoritmo per la cifratura dalla configurazione
		select 	@AlgoritmoPwd=DZT_ValueDef from lib_dictionary where dzt_name='SYS_PWD_ALGORITMO'
		
		--se passato l'utente recupero tipo algoritmo dall'utente
		if @IdPfu <> -1
			select @AlgoritmoPwd=pfuAlgoritmoPassword from profiliutente where idpfu=@IdPfu
		
		set @AlgoritmoPwd=isnull(@AlgoritmoPwd,'0')

		
		--SWITCH sul tipo di algoritmo
		if @AlgoritmoPwd = '0'
			
			--ALGORTIMO REVERSIBILE
			exec EncryptPwdBase @AlgoritmoPwd , @PwdIN , @PwdOUT output		

		else			
		if @AlgoritmoPwd = '1'
			
			--ALGORTIMO NON REVERSIBILE
			exec EncryptPwdNonReversibile @PwdIN , @PwdOUT output		
		
		else 
			--DEFAULT ALGORITMO REVERSIBILE
			exec EncryptPwdBase @AlgoritmoPwd , @PwdIN , @PwdOUT output	
	end
	
	
END
GO
