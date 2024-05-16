USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_BANDO_LISTA_DOCUMENTI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  proc [dbo].[CK_SEC_BANDO_LISTA_DOCUMENTI] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin


	-- verifico se la sezione puo essere aperta.

	declare @Blocco nvarchar(1000)
	set @Blocco = ''

	declare @del varchar(20)
	declare @VisualizzaNotifiche as varchar(10)
	declare @DataScadenzaOffIndicativa as datetime
	declare @DataAperturaOfferte as datetime
	declare @DataScadenzaOfferta as datetime

	-- FG291222 
	-- DICHIARO LE VARIABILI PER IL RECUPERO DELL'UTENZA RUP E COMPILATORE
	declare 
	@idRup as int,
	@idCompilatore int


	if left( @IdDoc , 3 ) <> 'new'
	begin
	
		select	@VisualizzaNotifiche=VisualizzaNotifiche,
				@DataScadenzaOffIndicativa=DataScadenzaOffIndicativa,
				@DataAperturaOfferte=DataAperturaOfferte,
				@DataScadenzaOfferta=DataScadenzaOfferta
		from Document_Bando where idHeader=@IdDoc
	


		select @del = deleted  from CTL_DOC where id = @IdDoc


		if  @del = '1'
		begin

				set @Blocco = 'NON_VISIBILE'		
		
		end

		if @SectionName = 'LISTA_OFFERTE'
		BEGIN	
			If 	@VisualizzaNotifiche = '0'  --1 significa=si 0 significa=no
			BEGIN
				IF getdate() > @DataScadenzaOfferta 
					set @Blocco = ''
				ELSE
					set @Blocco = 'La visualizzazione delle offerte è disponibile al superamento della data "Termine Presentazioni Offerte"'
			END
			ELSE
			BEGIN
				set @Blocco = ''				
			END		
		END
    

	end

	-- FG291222 
	-- reupero il codice dell'utente RUP   
	select @idRup=value 
		from CTL_DOC_Value with(nolock) 
		where idheader = @IdDoc and DSE_ID = 'InfoTec_comune' and dzt_name = 'UserRUP';
	
	select @idCompilatore = idpfu 
		from 
			CTL_DOC with(nolock) where id = @IdDoc

	-- se l'utente collegato ha il profilo URP all'ora l'accesso alle sezioni è limitato alla testa
	if exists( select idpfu from profiliutenteattrib where idpfu = @IdUser and dztnome = 'Profilo' and attvalue = 'URP' ) 
		-- FG291222 
		--se utente collegato è il compilatore deve vedere
		and ( @idCompilatore <> @IdUser )
		--se utente rup devo vedere lo stesso
		and ( @idRup <> @IdUser)
	begin
		set @Blocco = 'NON_VISIBILE'		
	end


	select @Blocco as Blocco

end








GO
