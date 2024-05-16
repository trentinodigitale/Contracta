USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_PERMISSION_PDA_RIEPILOGO_LOTTO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[OLD_DOCUMENT_PERMISSION_PDA_RIEPILOGO_LOTTO]
( 
	@idPfu   as int  , 
	@idDoc as varchar(50) ,
	@param as varchar(250)  = NULL  
)
as
begin
	
	declare @IdBando int
	declare @TipoDoc as varchar(200)
	declare @IdCommissione as int
	declare @passed int -- variabile di controllo
	declare @IdPDA as int

	set @passed = 0 -- non passato
	set @IdCommissione = -1

	-- il profilo di amministratore puo accedere
	if exists( select idpfu from ProfiliUtenteAttrib with (nolock) where  dztnome = 'Profilo' and attvalue in ('Direttore', 'Amministratore' ) and idPfu = @idPfu )
	begin

		set @passed = 1

	end
	else
	begin


		--apertura solo per il presidente della commissione A
		--oppure per tutti gli utenti se tutti i lotti della gara
		--hanno raggiunto uno degli stati finali (deserta,interrotto,aggiudicazionedef,nonaggiudicabile,nongiudicabile)
	
		--select * from document_microlotti_dettagli where id=50079
	
		--recupero id della PDA
		select @IdPDA=idheader from document_microlotti_dettagli with (nolock) where id=@idDoc
	
		--recupero id del bando
		select @TipoDoc=TipoDoc,@IdBando=linkeddoc from ctl_doc with (nolock) where id=@IdPDA

		--recupero tipodoc bando
		select @TipoDoc=TipoDoc from ctl_doc where id=@IdBando	

		--recupero documento commissione e se esiste faccio i controlli
		--altrimenti sono le vecchie PDA
		select @IdCommissione=ID from ctl_doc with (nolock) where linkedDoc=@IdBando and tipodoc='COMMISSIONE_PDA' and statofunzionale='pubblicato'  and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc 
	
		if @IdCommissione <> -1
		begin
		
		
			--se esiste un lotto in uno stato non finale allora effettuo i controlli
			--if exists ( 
			--	select 
			--		* 
			--	from 
			--		document_microlotti_dettagli	
			--	where 
			--		idheader=@IdPDA and voce=0 and tipodoc='PDA_MICROLOTTI'
			--		and statoriga not in ('NonGiudicabile','Deserta','interrotto','AggiudicazioneDef','NonAggiudicabile')
			--	)
			--begin
			
				--controllo che l'utente loggato è il presidente della commissione A		
				if exists(select UtenteCommissione from	Document_CommissionePda_Utenti with (nolock) where idheader=@IdCommissione and TipoCommissione='C' )
				begin

					if exists(select UtenteCommissione from	Document_CommissionePda_Utenti with (nolock) where idheader=@IdCommissione and ruolocommissione='15548' and TipoCommissione='C' and UtenteCommissione=@idPfu)
						set @passed = 1

				end
				else
				begin
					if exists(select UtenteCommissione from	Document_CommissionePda_Utenti with (nolock) where idheader=@IdCommissione and ruolocommissione='15548' and TipoCommissione='A' and UtenteCommissione=@idPfu)
						set @passed = 1
				END
			--end
		
		end


		-- se sei un utente che è presente nei riferimenti del bando con ruolo Bando/Inviti puoi accedere
		if exists(  select idheader from document_bando_riferimenti with (nolock) where idheader = @IdBando and  ruoloriferimenti = 'Bando' and idPfu = @idPfu )
			set @passed = 1
		
		--se utente collegato rup della gara passa
		if exists(  select idrow from CTL_DOC_Value with (nolock) where idheader = @IdBando and  DSE_ID = 'InfoTec_comune' and dzt_name='UserRUP' and value = @idPfu )
			set @passed = 1 
	end


	-- Verifico se l'utente può aprire
	if @passed = 1
		select 1 as bP_Read , 1 as bP_Write
	else
		select 0 as bP_Read , 0 as bP_Write from profiliutente where idpfu = -100	



end






GO
