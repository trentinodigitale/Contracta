USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ESITO_ESCLUSA_NO_FASE_AMM]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE  PROCEDURE [dbo].[ESITO_ESCLUSA_NO_FASE_AMM]
	( @iddoc int , @IdUser int  )
AS
BEGIN


	SET NOCOUNT ON;


		exec ESITO_ESCLUSA_NO_FASE_AMM_OFFERTA  @iddoc , @IdUser 

	----Stato lotto per capire se in valutazione tecnica devo andare sulla document_microlotti_dettagli per idheader=idpda and tipodoc='PDA_MICROLOTTI'
	----lotto che mi serve e voce=0 l'informazione sta in stato riga
	--declare @idpda as int
	--declare @idofferta as int
	--declare @idlottooff as int
	--declare @idNewDoc as int
	--declare @StatoPDA as varchar(100)

	
	----recupero id pda e id offerta
	--select 	@idpda=c2.id , @idofferta=IdMsg ,@StatoPDA = StatoPDA
	--	from ctl_doc c1 WITH(NOLOCK) 
	--		inner join Document_PDA_OFFERTE  WITH(NOLOCK) on IdRow=c1.LinkedDoc
	--		inner join ctl_doc c2  WITH(NOLOCK) on c2.Id=Document_PDA_OFFERTE.IdHeader
	--	where c1.id=@iddoc 

	---------------------------------------------------------------------------
	----recupero tutti i lotti per l'offerta che sono in Valutazione Tecnica
	---------------------------------------------------------------------------
	--if exists (
	--			select DO.idheader 
	--				from Document_PDA_OFFERTE DO  WITH(NOLOCK) 
	--					inner join Document_MicroLotti_Dettagli DM  WITH(NOLOCK) on DM.IdHeader=DO.IdRow and DM.Voce=0
	--					inner join Document_MicroLotti_Dettagli DM2  WITH(NOLOCK) on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and DM2.StatoRiga in ('daValutare','InValutazione','PrimaFaseTecnica')
	--				where  IdMsg=@idofferta and DO.idheader=@idpda
	--		  )
	--BEGIN
	--	---Creo il documento ESITO_LOTTO_ESCLUSA per ogni lotto in valutazione tecnica
	--	declare CurProg Cursor Static for 
	--		select DM.id as idlottooff 
	--			from Document_PDA_OFFERTE DO WITH(NOLOCK) 
	--				inner join Document_MicroLotti_Dettagli DM  WITH(NOLOCK) on DM.IdHeader=DO.IdRow and DM.Voce=0
	--				inner join Document_MicroLotti_Dettagli DM2  WITH(NOLOCK) on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and DM2.StatoRiga in ('daValutare','InValutazione','PrimaFaseTecnica')
	--			where  IdMsg=@idofferta and DO.idheader=@idpda

	--	open CurProg

	--	FETCH NEXT FROM CurProg INTO @idlottooff

	--	WHILE @@FETCH_STATUS = 0
	--	BEGIN

	--		Insert into ctl_doc (IDpfu,Tipodoc,StatoDoc,Body,LinkedDoc,StatoFunzionale,Deleted,fascicolo)
	--			select @IdUser , 'ESITO_LOTTO_ESCLUSA','Saved',Body,@idlottooff,'DOCUMENTO_ESITO_LOTTO_PRONTO_INVIO',1,fascicolo
	--				from Ctl_doc  WITH(NOLOCK) where id=@iddoc
	            			 
	--		FETCH NEXT FROM CurProg INTO @idlottooff
	--	END 

	--	CLOSE CurProg
	--	DEALLOCATE CurProg

	--END

	---------------------------------------------------------------------------
	----recupero tutti i lotti per l'offerta che sono in Valutazione Economica aggiudicato
	---------------------------------------------------------------------------
	--if exists (
	--			select DO.idheader
	--				from Document_PDA_OFFERTE DO WITH(NOLOCK) 
	--					inner join Document_MicroLotti_Dettagli DM  WITH(NOLOCK) on DM.IdHeader=DO.IdRow and DM.Voce=0
	--					inner join Document_MicroLotti_Dettagli DM2  WITH(NOLOCK) on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and Dm2.StatoRiga not in ('daValutare','InValutazione','PrimaFaseTecnica') and left(DM2.statoriga,14) = 'aggiudicazione'
	--				where  IdMsg=@idofferta and DO.idheader=@idpda
				
	--		 )
	--BEGIN

	--	declare CurProg Cursor Static for 
	--		select DM.id as idlottooff 
	--			from Document_PDA_OFFERTE DO WITH(NOLOCK) 
	--				inner join Document_MicroLotti_Dettagli DM  WITH(NOLOCK) on DM.IdHeader=DO.IdRow and DM.Voce=0
	--				inner join Document_MicroLotti_Dettagli DM2  WITH(NOLOCK) on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and Dm2.StatoRiga not in ('daValutare','InValutazione','PrimaFaseTecnica') and left(DM2.statoriga,14) = 'aggiudicazione'
	--			where  IdMsg=@idofferta and DO.idheader=@idpda

	--	open CurProg

	--	FETCH NEXT FROM CurProg INTO @idlottooff
		
	--	WHILE @@FETCH_STATUS = 0
	--	BEGIN				
					
	--		--controllo se è aggiudicataria, allora diventa decaduta e si crea il documento di decadenza in automatico
	--		IF EXISTS (Select * from Document_MicroLotti_Dettagli where id=@idlottooff and Posizione like 'Aggiudica%' ) and @StatoPDA <> '222'
	--		BEGIN
	--			Insert into ctl_doc (idpfu,StatoDoc,fascicolo,tipodoc,LinkedDoc,body,StatoFunzionale)
	--				select @IdUser,'Saved',fascicolo,'DECADENZA',@idlottooff,Body,'DOCUMENTO_ESITO_LOTTO_PRONTO_INVIO'
	--					from ctl_doc WITH(NOLOCK)  where id=@iddoc
			
	--			set @idNewDoc = SCOPE_IDENTITY()
	--			insert into CTL_DOC_Value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) values( @idNewDoc , 'INFO' , 0 , 'InterrompiProcedura' , '' )
	--			insert into CTL_DOC_Value ( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] ) values( @idNewDoc , 'INFO' , 0 , 'DecadenzaTuttiLotti' , '' )
				
	--		END
	--		ELSE
	--		--altrimenti creo il documento di esclusione 
	--		BEGIN
	--			Insert into ctl_doc (IDpfu,Tipodoc,StatoDoc,Body,LinkedDoc,StatoFunzionale,Deleted,fascicolo)
	--				select @IdUser , 'ESITO_ECO_LOTTO_ESCLUSA','Saved',Body,@idlottooff,'DOCUMENTO_ESITO_LOTTO_PRONTO_INVIO',1,fascicolo
	--					from Ctl_doc  WITH(NOLOCK) where id=@iddoc
	--		END
				
	            			 
	--		FETCH NEXT FROM CurProg INTO @idlottooff
	--	END 

	--	CLOSE CurProg
	--	DEALLOCATE CurProg

		
	--END


	-------------------------------------------------------------------------------------
	----recupero tutti i lotti per l'offerta che sono in Valutazione Economica non aggiudicato
	-------------------------------------------------------------------------------------
	--if exists (
	--			select DO.idheader
	--				from Document_PDA_OFFERTE DO WITH(NOLOCK) 
	--					inner join Document_MicroLotti_Dettagli DM  WITH(NOLOCK) on DM.IdHeader=DO.IdRow and DM.Voce=0
	--					inner join Document_MicroLotti_Dettagli DM2  WITH(NOLOCK) on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and Dm2.StatoRiga not in ('daValutare','InValutazione','PrimaFaseTecnica') and left(DM2.statoriga,14) <> 'aggiudicazione'
	--				where  IdMsg=@idofferta and DO.idheader=@idpda
	-- )
	--BEGIN
	--    declare CurProg Cursor Static for 
	--		select DM.id as idlottooff 
	--			from Document_PDA_OFFERTE DO WITH(NOLOCK) 
	--				inner join Document_MicroLotti_Dettagli DM  WITH(NOLOCK) on DM.IdHeader=DO.IdRow and DM.Voce=0
	--				inner join Document_MicroLotti_Dettagli DM2  WITH(NOLOCK) on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and Dm2.StatoRiga not in ('daValutare','InValutazione','PrimaFaseTecnica') and left(DM2.statoriga,14) <> 'aggiudicazione'
	--			where  IdMsg=@idofferta and DO.idheader=@idpda

	--	open CurProg

	--	FETCH NEXT FROM CurProg INTO @idlottooff
		
	--	WHILE @@FETCH_STATUS = 0
	--	BEGIN

	--		Insert into ctl_doc (IDpfu,Tipodoc,StatoDoc,Body,LinkedDoc,StatoFunzionale,Deleted,fascicolo)
	--			select @IdUser , 'ESITO_ECO_LOTTO_ESCLUSA','Saved',Body,@idlottooff,'DOCUMENTO_ESITO_LOTTO_PRONTO_INVIO',1,fascicolo
	--				from Ctl_doc  WITH(NOLOCK) where id=@iddoc
	            			 
	--		FETCH NEXT FROM CurProg INTO @idlottooff
	--	END 

	--	CLOSE CurProg
	--	DEALLOCATE CurProg

	--END

	
END



GO
