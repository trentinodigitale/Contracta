USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CK_SEC_BANDO_SEMPLIFICATO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE   proc [dbo].[CK_SEC_BANDO_SEMPLIFICATO] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin

	-- FG291222 
	-- DICHIARO LE VARIABILI PER IL RECUPERO DELL'UTENZA RUP E COMPILATORE
	declare 
	@idRup as int,
	@idCompilatore int

	-- verifico se la sezione puo essere aperta.
	declare @Blocco nvarchar(1000)
	set @Blocco = ''


	-- FG291222 
	-- reupero il codice dell'utente RUP   
	select @idRup=value 
	from CTL_DOC_Value with(nolock) 
	where idheader = @IdDoc and DSE_ID = 'InfoTec_comune' and dzt_name = 'UserRUP';
	
	select @idCompilatore = idpfu 
	from CTL_DOC with(nolock) where id = @IdDoc

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
