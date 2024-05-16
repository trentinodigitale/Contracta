USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_BANDO_CRONOLOGIA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  proc [dbo].[CK_SEC_BANDO_CRONOLOGIA] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin


	-- verifico se la sezione puo essere aperta.

	declare @Blocco nvarchar(1000)
	set @Blocco = ''

	declare @del varchar(20)
	-- FG291222 
	--DICHIARO LE VARIABILI PER L'UTENZA RUP E COMPILATORE
	declare 
	@rup as int,
	@compilatore int


	
	if left( @IdDoc , 3 ) <> 'new'
	begin

		-- FG291222 
		-- recupero il compilatore dal documento 
		select 
			@del = deleted, 
			@Compilatore = idpfu from CTL_DOC with(nolock) where id = @IdDoc
	

		if  @del = '1'
		begin

				set @Blocco = 'NON_VISIBILE'		
		
		end
    
	end

	-- FG291222 
	-- reupero il codice dell'utente RUP   
	select @Rup=value 
		from CTL_DOC_Value with(nolock) 
		where idheader = @IdDoc and DSE_ID = 'InfoTec_comune' and dzt_name = 'UserRUP'

	-- se l'utente collegato ha il profilo URP all'ora l'accesso alle sezioni è limitato alla testa
	if exists( select idpfu from profiliutenteattrib with (nolock) where idpfu = @IdUser and dztnome = 'Profilo' and attvalue = 'URP' ) 
		-- FG291222 
		--se utente collegato è il compilatore deve vedere
		and ( @Compilatore <> @IdUser )
		--se utente rup devo vedere lo stesso
		and ( @Rup <> @IdUser)

	begin
		set @Blocco = 'NON_VISIBILE'		
	end


	select @Blocco as Blocco

end




GO
