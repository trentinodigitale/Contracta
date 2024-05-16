USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_LISTINO_ORDINI_CREATE_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[OLD_LISTINO_ORDINI_CREATE_FROM_CONVENZIONE] ( @idDoc int , @IdUser int  )
AS
BEGIN
	
	SET NOCOUNT ON;

	declare @id int
	declare @azienda_mit int
	declare @codicemodelloconvenzione as varchar(200)
	declare @nomemodellolistino as varchar(200)

	select @azienda_mit=pfuidazi from ProfiliUtente where idpfu=@IdUser
		

	--controllo se esiste un documento LISTINO_ORDINI collegato alla convenzione in questione
	select @id=id 
		from 
			ctl_doc with (nolock) 
		where linkedDoC=@idDoc and Tipodoc='LISTINO_ORDINI' 
				--and StatoFunzionale in ('InLavorazione','Inviato','Confermato') and deleted = 0 
				and deleted = 0 
		
	--se non esiste un documento già in atto allora crea il nuovo
	if ISNULL(@id,'0') = 0
	BEGIN
			
		Insert into ctl_doc (Titolo,TipoDoc,linkedDoc,Idpfu,Azienda,Destinatario_azi,Destinatario_user,Body,idpfuincharge,JumpCheck)
			select 'Listino Ordini','LISTINO_ORDINI',@idDoc,@IdUser,@azienda_mit,DC.AZI_Dest, ReferenteFornitore ,'Listino Ordini della Convenzione "' + C.titolo + '"',ReferenteFornitore,'RICHIESTA-FIRMA:'+ DC.RichiestaFirma
				from 
					Document_Convenzione  DC with (nolock)
						inner join ctl_doc C with (nolock) on DC.id=C.id and C.tipodoc='CONVENZIONE'
				where 
					DC.id=@idDoc
			
		set @Id = scope_identity()	
			
			
			
		--inserisci il modello dinamico per i prodotti
		--recupero codicemodello convenzione
		select @codicemodelloconvenzione=value from 
			ctl_doc_value 
			where idheader=@idDoc and DSE_ID='TESTATA_PRODOTTI' and Dzt_Name='Tipo_Modello_Convenzione'
			
		---mi inserisco sul documento di listino il tipomodello selezionato
		insert into ctl_doc_value (idheader,DSE_ID,DZT_Name,Value)
			values (@Id,'TESTATA_PRODOTTI','Tipo_Modello_Convenzione', @codicemodelloconvenzione)



		set @nomemodellolistino='MODELLO_BASE_CONVENZIONI_' + @codicemodelloconvenzione + '_MOD_ListinoOrdini'

		insert into CTL_DOC_SECTION_MODEL (IdHeader, DSE_ID, MOD_Name)
			values ( @Id,'PRODOTTI',@nomemodellolistino)


		--metto un modello dinamico se non richiedo la firma degli allegati
		IF EXISTS (Select * from CTL_DOC where id=@Id and JumpCheck='RICHIESTA-FIRMA:no')
		BEGIN
			Insert into CTL_DOC_SECTION_MODEL ( IdHeader,DSE_ID,MOD_Name)
			Values (@Id,'FIRMA','LISTINO_CONVENZIONE_NO_FIRMA')
		END

		------nuovo modo 
			
		--declare @Filter as varchar(500)
		--declare @DestListField as varchar(500)

		--set @Filter = ' Tipodoc=''CONVENZIONE'' '
		--set @DestListField = ' ''LISTINO_CONVENZIONE'' as TipoDoc, '''' as EsitoRiga '
		  
		  
		  

		--exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @idDoc, @Id, 'IdHeader', 
		--					' Id,IdHeader,TipoDoc,EsitoRiga ', 
		--					@Filter, 
		--					' TipoDoc, EsitoRiga ', 
		--					@DestListField,
		--					' id '
		----- fine nuovo modo





			


	END


	select @Id as id , '' as Errore

END




GO
