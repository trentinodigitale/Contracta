USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_INVIO_LISTINO_CONVENZIONE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD2_INVIO_LISTINO_CONVENZIONE] ( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;
		declare @id int
		declare @azienda_mit int
		declare @codicemodelloconvenzione as varchar(200)
		declare @nomemodellolistino as varchar(200)

		select @azienda_mit=pfuidazi from ProfiliUtente where idpfu=@IdUser
		

		--controllo se esiste un documento già per la convenzione in questione
		select @id=id from ctl_doc where linkedDoC=@idDoc and Tipodoc='LISTINO_CONVENZIONE' and StatoFunzionale in ('InLavorazione','Inviato','Confermato') and deleted = 0 
		--se non esiste un documento già in atto allora crea il nuovo
		if ISNULL(@id,'0') = 0
		BEGIN
			
			Insert into ctl_doc (Titolo,TipoDoc,linkedDoc,Idpfu,Azienda,Destinatario_azi,Destinatario_user,Body,idpfuincharge,JumpCheck)
				select 'Listino Convenzione','LISTINO_CONVENZIONE',@idDoc,@IdUser,@azienda_mit,DC.AZI_Dest,DC.ReferenteFornitore,'Listino Prodotti della Convenzione "' + C.titolo + '"',ReferenteFornitore,'RICHIESTA-FIRMA:'+ DC.RichiestaFirma
					from Document_Convenzione  DC
					inner join ctl_doc C on DC.id=C.id and C.tipodoc='CONVENZIONE'
					where DC.id=@idDoc
			
			set @Id = scope_identity()	
			--inserisci il modello dinamico per i prodotti
			--recupero codicemodello convenzione
			select @codicemodelloconvenzione=value from 
				ctl_doc_value 
				where idheader=@idDoc and DSE_ID='TESTATA_PRODOTTI' and Dzt_Name='Tipo_Modello_Convenzione'
			
			---mi inserisco sul documento di listino il tipomodello selezionato
			insert into ctl_doc_value (idheader,DSE_ID,DZT_Name,Value)
				values (@Id,'TESTATA_PRODOTTI','Tipo_Modello_Convenzione', @codicemodelloconvenzione)



			set @nomemodellolistino='MODELLO_BASE_CONVENZIONI_' + @codicemodelloconvenzione + '_MOD_PerfListino'

			insert into CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
				values ( @Id,'PRODOTTI',@nomemodellolistino)

			--metto un modello dinamico se non richiedo la firma degli allegati
			IF EXISTS (Select * from CTL_DOC where id=@Id and JumpCheck='RICHIESTA-FIRMA:no')
			BEGIN
				Insert into CTL_DOC_SECTION_MODEL ( IdHeader,DSE_ID,MOD_Name)
				Values (@Id,'FIRMA','LISTINO_CONVENZIONE_NO_FIRMA')
			END


			declare @IdHeader INT
			declare @IdRow1 INT
			declare @idr INT

			declare CurProg Cursor Static for 
				select  @id as IdHeader, m.id as IdRow1
						from Document_MicroLotti_Dettagli m
					where m.IdHeader  = @idDoc and TipoDoc='CONVENZIONE'
					order by m.id

			open CurProg

			FETCH NEXT FROM CurProg INTO @IdHeader,@IdRow1
			WHILE @@FETCH_STATUS = 0
			BEGIN

				INSERT into Document_MicroLotti_Dettagli ( IdHeader,TipoDoc )
					select @Id , 'LISTINO_CONVENZIONE' as TipoDoc

				set @idr = @@identity				
				-- ricopio tutti i valori
				exec COPY_RECORD  'Document_MicroLotti_Dettagli'  ,@IdRow1  , @idr , ',Id,IdHeader,TipoDoc, '			 
				
				FETCH NEXT FROM CurProg INTO @IdHeader,@IdRow1
			
			END 

			CLOSE CurProg
			DEALLOCATE CurProg


		END


END





GO
