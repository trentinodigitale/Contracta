USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_PERMISSION_PDA_LST_BUSTE_TEC]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[DOCUMENT_PERMISSION_PDA_LST_BUSTE_TEC]
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
	declare @IdOfferta as int
	declare @StatoTecnicoLotto as varchar(200)

	set @passed = 0 -- non passato
	set @IdCommissione = -1
	--set @passed = 0
	--return
	--apertura solo per il presidente della commissione B
	--oppure per tutti gli utenti se tutti i lotti della gara sono in uno stato diverso da "da valutare" e diverso da "in valutazione"
	
	
	--select * from document_microlotti_dettagli where id=50079
	--recupero id offerta
	
	--select * from Document_MicroLotti_Dettagli where id=48720


	-- il profilo di amministratore puo accedere
	-- oppure il profilo investigativo
	if exists( select idpfu from ProfiliUtenteAttrib where  dztnome = 'Profilo' and attvalue in ( 'Amministratore' , 'Profilo_Investigativo' ) and idPfu = @idPfu )
	begin

		set @passed = 1

	end
	else
	begin


		--recupero idpda
		select 
				@IdPDA=idheader 
			from 
				document_microlotti_dettagli 
			where 	
				id=@idDoc
	
	
		--recupero id del bando
		select @TipoDoc=jumpcheck,@IdBando=linkeddoc from ctl_doc where id=@IdPDA
	
		--recupero documento commissione e se esiste faccio i controlli
		--altrimenti sono le vecchie PDA
		select @IdCommissione=ID from ctl_doc where linkedDoc=@IdBando and tipodoc='COMMISSIONE_PDA' and statofunzionale='pubblicato'  and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc 
	
		if @IdCommissione <> -1
		begin

			select @StatoTecnicoLotto=statoriga
				from Document_MicroLotti_Dettagli
					where id = @idDoc --48717

			--se in uno stato finale sblocco per tutti
			if @StatoTecnicoLotto in ('NonGiudicabile','Deserta','interrotto','AggiudicazioneDef','NonAggiudicabile','AggiudicazioneProvv' , 'AggiudicazioneCond')
				set @passed = 1		
			else
			begin
				--se esiste un lotto in uno stato diverso da "da valutare" e diverso da "in valutazione"
	--			if exists ( 
	--				select 
	--						* 
	--					from 
	--						document_microlotti_dettagli	
	--					where 
	--						--idheader=@IdPDA and voce=0 and tipodoc='PDA_MICROLOTTI'
	--						id=@idDoc
	--						and statoriga in ('InValutazione','daValutare')
	--				)
	--			begin
				
					--controllo che l'utente loggato è il presidente della commissione B		
					if exists(select UtenteCommissione from	Document_CommissionePda_Utenti where idheader=@IdCommissione and /*ruolocommissione='15548' and */ TipoCommissione='G' and UtenteCommissione=@idPfu)
						set @passed = 1
				--end
			end

		end
		else
			set @passed = 1


		-- se sei un utente che è presente nei riferimenti del bando con ruolo Bando/Inviti puoi accedere
		if exists(  select idheader from document_bando_riferimenti where idheader = @IdBando and  ruoloriferimenti = 'Bando' and idPfu = @idPfu )
			set @passed = 1


	end

	-- Verifico se l'utente può aprire
	if @passed = 1
		select 1 as bP_Read , 1 as bP_Write
	else
		select 0 as bP_Read , 0 as bP_Write from profiliutente where idpfu = -100	

end



GO
