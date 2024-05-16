USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Verifica_Dati_Parix]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[Verifica_Dati_Parix] 
(
	@session_id					varchar(250),
	@codice_fiscale				varchar(250)
)
as
begin


	--declare @session_id varchar(200)
	--declare @codice_fiscale varchar(400)
	--set @session_id = '152747067'
	--set @codice_fiscale = '04178170652'
	---- '152747067', '04178170652'
	

	declare @nome_campo varchar(500)
	declare @valoreParix varchar(max)
	declare @valoreUtente varchar(max)

	declare @esito int
	set @esito = 1 -- i campi sono coincidenti o parix non ha ritornato nulla


	-- se parix non ha ritornato niente per l'azienda che si sta censendo
	if not exists(select id from parix_dati where sessionId = @session_id and codice_fiscale = @codice_fiscale)
	begin 
		select 'i-dati-sono-variati' as esito 
		return 0
	end

	declare CurFields Cursor static for  
		Select nome_campo, valore
			from parix_dati where sessionId = @session_id and codice_fiscale = @codice_fiscale

	open CurFields

	FETCH NEXT FROM CurFields  INTO @nome_campo , @valoreParix

	-- itero su tutti i campi ritornati da parix
	WHILE @@FETCH_STATUS = 0 and @esito > 0
	BEGIN
	
		IF @valoreParix <> '' 
		BEGIN
		
			set @valoreParix = ltrim(@valoreParix)
			set @valoreParix = rtrim(@valoreParix)
			set @valoreParix = upper(@valoreParix)
			
			-- se il campo esiste tra i campi inputati dall'utente
			IF exists( select top 1 idRow from FormRegistrazione where sessionid = @session_id and codice_fiscale = @codice_fiscale )
			BEGIN
			
				set @valoreUtente = '' --default
				select top 1 @valoreUtente = valore from FormRegistrazione where sessionid = @session_id and codice_fiscale = @codice_fiscale and nome_campo = @nome_campo

				if upper(@nome_campo) = 'PIVA'
				begin
					set @valoreParix = 'IT' + @valoreParix
				end 
				
				set @valoreUtente = ltrim(@valoreUtente)
				set @valoreUtente = rtrim(@valoreUtente)
				set @valoreUtente = upper(@valoreUtente)

				-- se il campo è l'email (pec) dell'azienda segnalo al chiamante che c'è stata una sua variazione rispetto ai dati parix
				IF upper(@nome_campo) = 'EMAIL' and @valoreParix <> @valoreUtente
				BEGIN
					set @esito = -2
				END
				
				-- se l'utente ha cambiato il valore che parix gli aveva ritornato
				IF @valoreParix <> @valoreUtente
				BEGIN
				
					--print 'dati variati.'
					--print '@valoreParix = ' + @valoreParix
					--print '@valoreUtente = ' + @valoreUtente
				
					set @esito = -1

				END
			
			END
		
		END


		-- passo al campo successivo
		FETCH NEXT FROM CurFields INTO @nome_campo , @valoreParix
		
	END 
	
	CLOSE CurFields
	DEALLOCATE CurFields
	
	--print 'esito: ' + @esito
	
	IF @esito < 0
	BEGIN

		IF @esito = -2
		BEGIN
			select 'variazione-email' as esito 
		END
		ELSE
		BEGIN
			select 'i-dati-sono-variati' as esito 
		END

	END
	ELSE
	BEGIN
		select top 0 'i-dati-NON-sono-variati' as esito 
	END

end




GO
