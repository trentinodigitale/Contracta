USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ESITO_ESCLUSA_NO_FASE_AMM]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[OLD_ESITO_ESCLUSA_NO_FASE_AMM]
	( @iddoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;
	--Stato lotto per capire se in valutazione tecnica devo andare sulla document_microlotti_dettagli per idheader=idpda and tipodoc='PDA_MICROLOTTI'
	--lotto che mi serve e voce=0 l'informazione sta in stato riga
	declare @idpda as int
	declare @idofferta as int
	declare @idlottooff as int
	
	--recupero id pda e id offerta
	 select @idpda=c2.id , @idofferta=IdMsg
		from ctl_doc c1
		inner join Document_PDA_OFFERTE on IdRow=c1.LinkedDoc
		inner join ctl_doc c2 on c2.Id=Document_PDA_OFFERTE.IdHeader
	where c1.id=@iddoc 

	--recupero tutti i lotti per l'offerta che sono in Valutazione Tecnica
	if exists (
				select * from Document_PDA_OFFERTE DO
				inner join Document_MicroLotti_Dettagli DM on DM.IdHeader=DO.IdRow and DM.Voce=0
				inner join Document_MicroLotti_Dettagli DM2 on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and DM2.StatoRiga in ('daValutare','InValutazione')
				where  IdMsg=@idofferta and DO.idheader=@idpda
			  )
	BEGIN
		---Creo il documento ESITO_LOTTO_ESCLUSA per ogni lotto in valutazione tecnica
		declare CurProg Cursor Static for 
		
		select DM.id as idlottooff from Document_PDA_OFFERTE DO
		inner join Document_MicroLotti_Dettagli DM on DM.IdHeader=DO.IdRow and DM.Voce=0
		inner join Document_MicroLotti_Dettagli DM2 on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and DM2.StatoRiga in ('daValutare','InValutazione')
		where  IdMsg=@idofferta and DO.idheader=@idpda

		open CurProg

		FETCH NEXT FROM CurProg 
		INTO @idlottooff
		WHILE @@FETCH_STATUS = 0
			BEGIN

				Insert into ctl_doc (IDpfu,Tipodoc,StatoDoc,Body,LinkedDoc,StatoFunzionale,Deleted,fascicolo)
				select @IdUser , 'ESITO_LOTTO_ESCLUSA','Saved',Body,@idlottooff,'DOCUMENTO_ESITO_LOTTO_PRONTO_INVIO',1,fascicolo
				from Ctl_doc where id=@iddoc
	            			 
				 FETCH NEXT FROM CurProg 
			   INTO @idlottooff
			 END 

		CLOSE CurProg
		DEALLOCATE CurProg

	END

	--recupero tutti i lotti per l'offerta che sono in Valutazione Economica aggiudicato
	if exists (
				select * from Document_PDA_OFFERTE DO
				inner join Document_MicroLotti_Dettagli DM on DM.IdHeader=DO.IdRow and DM.Voce=0
				inner join Document_MicroLotti_Dettagli DM2 on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and Dm2.StatoRiga not in ('daValutare','InValutazione') and left(DM2.statoriga,14) = 'aggiudicazione'
				where  IdMsg=@idofferta and DO.idheader=@idpda
				
			 )
	BEGIN
		declare CurProg Cursor Static for 
		select DM.id as idlottooff from Document_PDA_OFFERTE DO
				inner join Document_MicroLotti_Dettagli DM on DM.IdHeader=DO.IdRow and DM.Voce=0
				inner join Document_MicroLotti_Dettagli DM2 on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and Dm2.StatoRiga not in ('daValutare','InValutazione') and left(DM2.statoriga,14) = 'aggiudicazione'
				where  IdMsg=@idofferta and DO.idheader=@idpda

		open CurProg

		FETCH NEXT FROM CurProg 
		INTO @idlottooff
		WHILE @@FETCH_STATUS = 0
			BEGIN				
					
					--controllo se è aggiudicataria, allora diventa decaduta e si crea il documento di decadenza in automatico
					IF EXISTS (Select * from Document_MicroLotti_Dettagli where id=@idlottooff and Posizione like 'Aggiudica%' )
					BEGIN
						Insert into ctl_doc (idpfu,StatoDoc,fascicolo,tipodoc,LinkedDoc,body,StatoFunzionale)
						select @IdUser,'Saved',fascicolo,'DECADENZA',@idlottooff,Body,'DOCUMENTO_ESITO_LOTTO_PRONTO_INVIO'
						from ctl_doc where id=@iddoc
					END
					ELSE
					--altrimenti creo il documento di esclusione 
					BEGIN
						Insert into ctl_doc (IDpfu,Tipodoc,StatoDoc,Body,LinkedDoc,StatoFunzionale,Deleted,fascicolo)
						select @IdUser , 'ESITO_ECO_LOTTO_ESCLUSA','Saved',Body,@idlottooff,'DOCUMENTO_ESITO_LOTTO_PRONTO_INVIO',1,fascicolo
						from Ctl_doc where id=@iddoc
					END
				
	            			 
				 FETCH NEXT FROM CurProg 
			   INTO @idlottooff
			 END 

		CLOSE CurProg
		DEALLOCATE CurProg

		
	END

	--recupero tutti i lotti per l'offerta che sono in Valutazione Economica non aggiudicato
	if exists (
				select * from Document_PDA_OFFERTE DO
				inner join Document_MicroLotti_Dettagli DM on DM.IdHeader=DO.IdRow and DM.Voce=0
				inner join Document_MicroLotti_Dettagli DM2 on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and Dm2.StatoRiga not in ('daValutare','InValutazione') and left(DM2.statoriga,14) <> 'aggiudicazione'
				where  IdMsg=@idofferta and DO.idheader=@idpda
	 )
	BEGIN
	    declare CurProg Cursor Static for 
		select DM.id as idlottooff from Document_PDA_OFFERTE DO
				inner join Document_MicroLotti_Dettagli DM on DM.IdHeader=DO.IdRow and DM.Voce=0
				inner join Document_MicroLotti_Dettagli DM2 on DM.numerolotto=DM2.NumeroLotto and DM2.IdHeader=@idpda and DM2.Voce=0 and Dm2.StatoRiga not in ('daValutare','InValutazione') and left(DM2.statoriga,14) <> 'aggiudicazione'
				where  IdMsg=@idofferta and DO.idheader=@idpda

		open CurProg

		FETCH NEXT FROM CurProg 
		INTO @idlottooff
		WHILE @@FETCH_STATUS = 0
			BEGIN

				Insert into ctl_doc (IDpfu,Tipodoc,StatoDoc,Body,LinkedDoc,StatoFunzionale,Deleted,fascicolo)
				select @IdUser , 'ESITO_ECO_LOTTO_ESCLUSA','Saved',Body,@idlottooff,'DOCUMENTO_ESITO_LOTTO_PRONTO_INVIO',1,fascicolo
				from Ctl_doc where id=@iddoc
	            			 
				 FETCH NEXT FROM CurProg 
			   INTO @idlottooff
			 END 

		CLOSE CurProg
		DEALLOCATE CurProg



		 
	END



	
END



GO
