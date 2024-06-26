USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DOCUMENT_PERMISSION_PDA_VALUTA_LOTTO_ECO]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OLD_DOCUMENT_PERMISSION_PDA_VALUTA_LOTTO_ECO]
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
	declare @NumeroLotto as varchar(10)

	set @passed = 0 -- non passato
	set @IdCommissione = -1


	-- il profilo di amministratore puo accedere
	if exists( select idpfu from ProfiliUtenteAttrib where  dztnome = 'Profilo' and attvalue = 'Amministratore' and idPfu = @idPfu )
	begin

		set @passed = 1

	end
	else
	begin


		--set @passed = 0
		--return
		--apertura solo per il presidente della commissione B
		--oppure per tutti gli utenti se tutti i lotti della gara sono in uno stato diverso da "da valutare" e diverso da "in valutazione"
	
	
		--select * from document_microlotti_dettagli where id=50079
		--recupero id offerta
		select @IdOfferta=linkeddoc from ctl_doc where id=@idDoc
		--select linkeddoc from ctl_doc where id=69168	
	

		--recupero idpda e numerolotto corrente
		select 
			top 1 @IdPDA=DO.idheader , @NumeroLotto = D.NumeroLotto
			from 
				document_microlotti_dettagli D inner join  Document_PDA_OFFERTE DO on D.idheader=DO.idrow
			where
				DO.TipoDoc='OFFERTA'
				and id=@IdOfferta
	
	--	select 
	--		top 1 DO.idheader 
	--	from 
	--		document_microlotti_dettagli D inner join  Document_PDA_OFFERTE DO on D.idheader=DO.idrow
	--	where
	--		DO.TipoDoc='OFFERTA'
	--		and id=50420
	
	
	

	--	select 
	--				* 
	--			from 
	--				document_microlotti_dettagli	
	--			where 
	--				idheader=69159 and voce=0 and tipodoc='PDA_MICROLOTTI'
	--				and statoriga not in ('InValutazione','daValutare')

		--recupero id del bando
		select @TipoDoc=jumpcheck,@IdBando=linkeddoc from ctl_doc where id=@IdPDA
	
		--recupero documento commissione e se esiste faccio i controlli
		--altrimenti sono le vecchie PDA
		select @IdCommissione=ID from ctl_doc where deleted=0 and linkedDoc=@IdBando and tipodoc='COMMISSIONE_PDA' and statofunzionale='pubblicato'  and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc 
		--set @IdCommissione=-1
		if @IdCommissione <> -1
		begin
		
			--se il lotto è in uno stato tra questi: "Valutato","Completo"
			--allora passano solo le persone preposte alla valutazione economica
			if exists ( 
				select 
					* 
					from 
						document_microlotti_dettagli	
					where 
						idheader=@IdPDA and voce=0 and tipodoc='PDA_MICROLOTTI'
						and statoriga in ('Valutato','Completo') and NumeroLotto=@NumeroLotto
				)
			begin
			
				
				--controllo che l'utente loggato è il presidente della commissione C/A		
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

			end
			else
			begin
				--se in uno stato finale sblocco per tutti
				set @passed = 1
			end

		end
		else
			set @passed = 1


	END


	-- Verifico se l'utente può aprire
	if @passed = 1
		select 1 as bP_Read , 1 as bP_Write
	else
		select 0 as bP_Read , 0 as bP_Write from profiliutente where idpfu = -100	

end


GO
