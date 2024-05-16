USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_ESITO_ESCLUSA_NO_FASE_AMM_OFFERTA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE PROCEDURE [dbo].[OLD2_ESITO_ESCLUSA_NO_FASE_AMM_OFFERTA]
	( @iddoc int , @IdUser int  )
AS
BEGIN


	SET NOCOUNT ON;
	--Stato lotto per capire se in valutazione tecnica devo andare sulla document_microlotti_dettagli per idheader=idpda and tipodoc='PDA_MICROLOTTI'
	--lotto che mi serve e voce=0 l'informazione sta in stato riga
	declare @idpda as int
	declare @idofferta as int
	declare @idlottooff as int
	declare @idNewDoc as int
	declare @StatoPDA as varchar(100)

	declare @fascicolo as varchar(100)
	declare @TipoDoc as varchar(100)
	declare @IdRow as int

	declare @idlottosciolto int 

	declare @Body as nvarchar(max)
	declare @StatoRiga varchar(1000)
	declare @Posizione varchar(1000)
	declare @idBando as int

	declare @InversioneBuste varchar(100)



	select @TipoDoc = TipoDoc from ctl_doc with(nolock) where id = @IdDoc

	select top 0 cast( '' as varchar(10)) as NumeroLotto into  #LottiDaEscludere 

	------------------------------------------------------------------
	--	recupero i dati per effettuare l'esclusione in funzione del documento di provenienza
	------------------------------------------------------------------
	if @TipoDoc = 'ESITO_ESCLUSA' 
	begin
		--recupero id pda e id offerta
		select 	@idpda=c2.id , @idofferta=IdMsg ,@StatoPDA = StatoPDA , @Body = c1.body , @fascicolo = c1.Fascicolo , @IdRow = IdRow , @idBando = c2.LinkedDoc
			from ctl_doc c1 WITH(NOLOCK) 
				inner join Document_PDA_OFFERTE  WITH(NOLOCK) on IdRow=c1.LinkedDoc
				inner join ctl_doc c2  WITH(NOLOCK) on c2.Id=Document_PDA_OFFERTE.IdHeader
			where c1.id=@iddoc 

		insert into #LottiDaEscludere ( Numerolotto ) 
			select NumeroLotto from Document_MicroLotti_Dettagli with(nolock) where TipoDoc = 'PDA_OFFERTE' and idheader =  @IdRow  and voce = 0 and StatoRiga not in ( 'decaduta' , 'esclusoEco' , 'escluso' )

	END


	if @TipoDoc = 'ESITO_LOTTO_SCIOGLI_RISERVA' 
	begin
		--recupero id pda e id offerta
		select @idpda=c2.id , @idofferta=IdMsg, @idlottosciolto=c1.LinkedDoc , @StatoPDA = StatoPDA , @Body = c1.body , @fascicolo = c1.Fascicolo , @idBando = c2.LinkedDoc
			from ctl_doc c1
				inner join Document_PDA_OFFERTE on IdRow=c1.IdDoc
				inner join ctl_doc c2 on c2.Id=Document_PDA_OFFERTE.IdHeader
			where c1.id=@iddoc 
		
		insert into #LottiDaEscludere ( Numerolotto ) 
			select NumeroLotto from Document_MicroLotti_Dettagli with(nolock) where  idHeaderLotto = @idlottosciolto  and voce = 0 and TipoDoc in ( 'OFFERTA' , 'PDA_OFFERTE' ) 

	END


	if @TipoDoc = 'ESCLUDI_LOTTI' 
	begin

		select @idpda=C1.IdDoc , @idofferta=IdMsg, @StatoPDA = StatoPDA , @Body = c1.body , @fascicolo = c1.Fascicolo , @IdRow = D.IdRow , @idBando = P.LinkedDoc
			from ctl_doc c1 with(NOLOCK)
				inner join Document_PDA_OFFERTE D with(NOLOCK) on D.IdHeader=C1.IdDoc and D.IdMsg=C1.LinkedDoc
				inner join ctl_doc P on P.id = D.idheader
			where c1.id = @iddoc

		insert into #LottiDaEscludere ( Numerolotto ) 		
			select NumeroLotto 
				from Document_Pda_Escludi_Lotti  with(NOLOCK) 
				where IdHeader=@iddoc and StatoLotto = 'escluso' and NumeroLotto not in ( select NumeroLotto from Document_MicroLotti_Dettagli with(nolock) where TipoDoc = 'PDA_OFFERTE' and idheader =  @IdRow  and voce = 0 and StatoRiga in ( 'decaduta' , 'esclusoEco' , 'escluso' ) )
				

	end


	select @InversioneBuste  = isnull( InversioneBuste , '0' ) from Document_Bando where idheader  =  @idBando

	---------------------------------------------------------------------------------
	-- PER ogni lotto da escludere recupero lo stato in cui si trova e creo il documento di esclusione adeguato 
	---------------------------------------------------------------------------------
	declare CurProg Cursor Static for 
		select DM.id as idlottooff  , Dm.Posizione , dm2.StatoRiga
			from Document_PDA_OFFERTE DO WITH(NOLOCK) 
				inner join Document_MicroLotti_Dettagli DM  WITH(NOLOCK) on DM.TipoDoc = 'PDA_OFFERTE' and DM.IdHeader=DO.IdRow and DM.Voce=0
				inner join #LottiDaEscludere T on T.NumeroLotto = DM.numerolotto

				inner join Document_MicroLotti_Dettagli DM2  WITH(NOLOCK) on DM2.TipoDoc = 'PDA_MICROLOTTI' and DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 --and DM2.StatoRiga in ('daValutare','InValutazione','PrimaFaseTecnica')


			where  IdMsg=@idofferta and DO.idheader=@idpda

	open CurProg

	FETCH NEXT FROM CurProg INTO @idlottooff, @Posizione , @StatoRiga

	WHILE @@FETCH_STATUS = 0
	BEGIN


		-- il lotto è in valutazione tecnica
		if @StatoRiga in ('daValutare','InValutazione','PrimaFaseTecnica')
		begin

			Insert into ctl_doc (IDpfu,Tipodoc,StatoDoc,Body,LinkedDoc,StatoFunzionale,Deleted,fascicolo)
				select @IdUser , 'ESITO_LOTTO_ESCLUSA','Saved',@Body,@idlottooff,'DOCUMENTO_ESITO_LOTTO_PRONTO_INVIO',1,@fascicolo

		end
		else -- altrimenti è in valutazione economica
		begin

			-- se è stata superata la valutazione economica si rende necessaria anche un ripristina fase del lotto per riportare il lotto alle origini


			-- se il lotto è in aggiudicazione e non è ex art 133 creo la decadenza
			if @StatoRiga like 'aggiudicazione%' and @Posizione like 'Aggiudica%' and isnull( @InversioneBuste , '0' ) <> '1'
			BEGIN
				Insert into ctl_doc (idpfu,StatoDoc,fascicolo,tipodoc,LinkedDoc,body,StatoFunzionale)
					select @IdUser,'Saved',@fascicolo,'DECADENZA',@idlottooff,@Body ,'DOCUMENTO_ESITO_LOTTO_PRONTO_INVIO'
			
				set @idNewDoc = SCOPE_IDENTITY()
				insert into CTL_DOC_Value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) values( @idNewDoc , 'INFO' , 0 , 'InterrompiProcedura' , '' )
				insert into CTL_DOC_Value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) values( @idNewDoc , 'INFO' , 0 , 'DecadenzaTuttiLotti' , '' )
				
			END
			ELSE
			--altrimenti creo il documento di esclusione  economica
			BEGIN
				Insert into ctl_doc (IDpfu,Tipodoc,StatoDoc,Body,LinkedDoc,StatoFunzionale,Deleted,fascicolo)
					select @IdUser , 'ESITO_ECO_LOTTO_ESCLUSA','Saved',@Body,@idlottooff,'DOCUMENTO_ESITO_LOTTO_PRONTO_INVIO',1,@fascicolo
			END
				



		end

	            			 
		FETCH NEXT FROM CurProg INTO @idlottooff , @Posizione , @StatoRiga
	END 

	CLOSE CurProg
	DEALLOCATE CurProg

END


















--	-------------------------------------------------------------------------
--	--recupero tutti i lotti per l'offerta che sono in Valutazione Tecnica
--	-------------------------------------------------------------------------
--	if exists (
--				select DO.idheader 
--					from Document_PDA_OFFERTE DO  WITH(NOLOCK) 
--						inner join Document_MicroLotti_Dettagli DM  WITH(NOLOCK) on DM.IdHeader=DO.IdRow and DM.Voce=0
--						inner join Document_MicroLotti_Dettagli DM2  WITH(NOLOCK) on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and DM2.StatoRiga in ('daValutare','InValutazione','PrimaFaseTecnica')
--					where  IdMsg=@idofferta and DO.idheader=@idpda
--			  )
--	BEGIN
--		---Creo il documento ESITO_LOTTO_ESCLUSA per ogni lotto in valutazione tecnica
--		declare CurProg Cursor Static for 
--			select DM.id as idlottooff  , Dm2.Posizione , dm2.StatoRiga
--				from Document_PDA_OFFERTE DO WITH(NOLOCK) 
--					inner join Document_MicroLotti_Dettagli DM  WITH(NOLOCK) on DM.IdHeader=DO.IdRow and DM.Voce=0
--					inner join Document_MicroLotti_Dettagli DM2  WITH(NOLOCK) on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and DM2.StatoRiga in ('daValutare','InValutazione','PrimaFaseTecnica')
--				where  IdMsg=@idofferta and DO.idheader=@idpda

--		open CurProg

--		FETCH NEXT FROM CurProg INTO @idlottooff, @Posizione , @StatoRiga

--		WHILE @@FETCH_STATUS = 0
--		BEGIN

--			Insert into ctl_doc (IDpfu,Tipodoc,StatoDoc,Body,LinkedDoc,StatoFunzionale,Deleted,fascicolo)
--				select @IdUser , 'ESITO_LOTTO_ESCLUSA','Saved',@Body,@idlottooff,'DOCUMENTO_ESITO_LOTTO_PRONTO_INVIO',1,@fascicolo
--					--from Ctl_doc  WITH(NOLOCK) where id=@iddoc
	            			 
--			FETCH NEXT FROM CurProg INTO @idlottooff , @Posizione , @StatoRiga
--		END 

--		CLOSE CurProg
--		DEALLOCATE CurProg

--	END

--	-------------------------------------------------------------------------
--	--recupero tutti i lotti per l'offerta che sono in Valutazione Economica aggiudicato
--	-------------------------------------------------------------------------
--	if exists (
--				select DO.idheader
--					from Document_PDA_OFFERTE DO WITH(NOLOCK) 
--						inner join Document_MicroLotti_Dettagli DM  WITH(NOLOCK) on DM.IdHeader=DO.IdRow and DM.Voce=0
--						inner join Document_MicroLotti_Dettagli DM2  WITH(NOLOCK) on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and Dm2.StatoRiga not in ('daValutare','InValutazione','PrimaFaseTecnica') and left(DM2.statoriga,14) = 'aggiudicazione'
--					where  IdMsg=@idofferta and DO.idheader=@idpda
				
--			 )
--	BEGIN

--		declare CurProg Cursor Static for 
--			select DM.id as idlottooff 
--				from Document_PDA_OFFERTE DO WITH(NOLOCK) 
--					inner join Document_MicroLotti_Dettagli DM  WITH(NOLOCK) on DM.IdHeader=DO.IdRow and DM.Voce=0
--					inner join Document_MicroLotti_Dettagli DM2  WITH(NOLOCK) on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and Dm2.StatoRiga not in ('daValutare','InValutazione','PrimaFaseTecnica') and left(DM2.statoriga,14) = 'aggiudicazione'
--				where  IdMsg=@idofferta and DO.idheader=@idpda

--		open CurProg

--		FETCH NEXT FROM CurProg INTO @idlottooff
		
--		WHILE @@FETCH_STATUS = 0
--		BEGIN				
					
--			--controllo se è aggiudicataria, allora diventa decaduta e si crea il documento di decadenza in automatico
--			IF EXISTS (Select * from Document_MicroLotti_Dettagli where id=@idlottooff and Posizione like 'Aggiudica%' ) and @StatoPDA <> '222'
--			BEGIN
--				Insert into ctl_doc (idpfu,StatoDoc,fascicolo,tipodoc,LinkedDoc,body,StatoFunzionale)
--					select @IdUser,'Saved',@fascicolo,'DECADENZA',@idlottooff,@Body ,'DOCUMENTO_ESITO_LOTTO_PRONTO_INVIO'
--						--from ctl_doc WITH(NOLOCK)  where id=@iddoc
			
--				set @idNewDoc = SCOPE_IDENTITY()
--				insert into CTL_DOC_Value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) values( @idNewDoc , 'INFO' , 0 , 'InterrompiProcedura' , '' )
--				insert into CTL_DOC_Value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) values( @idNewDoc , 'INFO' , 0 , 'DecadenzaTuttiLotti' , '' )
				
--			END
--			ELSE
--			--altrimenti creo il documento di esclusione 
--			BEGIN
--				Insert into ctl_doc (IDpfu,Tipodoc,StatoDoc,Body,LinkedDoc,StatoFunzionale,Deleted,fascicolo)
--					select @IdUser , 'ESITO_ECO_LOTTO_ESCLUSA','Saved',@Body,@idlottooff,'DOCUMENTO_ESITO_LOTTO_PRONTO_INVIO',1,@fascicolo
--						--from Ctl_doc  WITH(NOLOCK) where id=@iddoc
--			END
				
	            			 
--			FETCH NEXT FROM CurProg INTO @idlottooff
--		END 

--		CLOSE CurProg
--		DEALLOCATE CurProg

		
--	END


--	-----------------------------------------------------------------------------------
--	--recupero tutti i lotti per l'offerta che sono in Valutazione Economica non aggiudicato
--	-----------------------------------------------------------------------------------
--	if exists (
--				select DO.idheader
--					from Document_PDA_OFFERTE DO WITH(NOLOCK) 
--						inner join Document_MicroLotti_Dettagli DM  WITH(NOLOCK) on DM.IdHeader=DO.IdRow and DM.Voce=0
--						inner join Document_MicroLotti_Dettagli DM2  WITH(NOLOCK) on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and Dm2.StatoRiga not in ('daValutare','InValutazione','PrimaFaseTecnica') and left(DM2.statoriga,14) <> 'aggiudicazione'
--					where  IdMsg=@idofferta and DO.idheader=@idpda
--	 )
--	BEGIN
--	    declare CurProg Cursor Static for 
--			select DM.id as idlottooff 
--				from Document_PDA_OFFERTE DO WITH(NOLOCK) 
--					inner join Document_MicroLotti_Dettagli DM  WITH(NOLOCK) on DM.IdHeader=DO.IdRow and DM.Voce=0
--					inner join Document_MicroLotti_Dettagli DM2  WITH(NOLOCK) on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and Dm2.StatoRiga not in ('daValutare','InValutazione','PrimaFaseTecnica') and left(DM2.statoriga,14) <> 'aggiudicazione'
--				where  IdMsg=@idofferta and DO.idheader=@idpda

--		open CurProg

--		FETCH NEXT FROM CurProg INTO @idlottooff
		
--		WHILE @@FETCH_STATUS = 0
GO
