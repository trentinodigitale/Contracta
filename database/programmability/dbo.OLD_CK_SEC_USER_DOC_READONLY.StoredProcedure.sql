USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CK_SEC_USER_DOC_READONLY]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  proc [dbo].[OLD_CK_SEC_USER_DOC_READONLY] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin


	--recupero profilo azienda utente collegato
	declare @aziProfili varchar(50)
	declare @AziVenditore int
	
	select top 1 @aziProfili  = aziProfili , @AziVenditore = AziVenditore from aziende,profiliutente where pfuidazi=idazi and idpfu = @IdDoc
	
	
	

	-- verifico se la sezione puo essere aperta.
	declare @Blocco nvarchar(1000)
	set @Blocco = ''
	

	-- quando l'utente apre la propora scheda anagrafica
	if @IdDoc = @IdUser
	begin
			
		--la sezione profili non si vede ne per OE ne per ENTE
		if @SectionName = 'PROFILI'
			set @Blocco = 'NON_VISIBILE'

		--la sezione RUOLI non è visibile se sono OE
		if @SectionName in(  'RUOLI' , 'RESPONSABILE')
		begin

		
			set @Blocco = 'NON_VISIBILE'

			-- se l'azienda è profili P ( procurement ) quindi un ENTE allora posso visualizzare la scheda per l'ente
			if charindex( 'P' , @aziProfili ) > 0 
				set @Blocco = ''
				
		end

	end

	-- per gli OE non è necessaria la scheda dei responsabili
	if @AziVenditore > 0 and @SectionName in(  'RESPONSABILE' )
	begin
		set @Blocco = 'NON_VISIBILE'
	END


	-- la scheda Elenco PI è visualizzata solamente se l'utente è Punto Ordinante/RUP/RUP PDG 
	if @SectionName in(  'ELENCO_PI' )
	begin

		if not exists( select * from profiliutenteattrib with(nolock) where idpfu = @IdDoc and dztNome = 'UserRole' and attValue in ( 'PO' , 'RUP_PDG' , 'RUP' ) )
		begin

			set @Blocco = 'NON_VISIBILE'

		end				
	end



	select @Blocco as Blocco

end
GO
