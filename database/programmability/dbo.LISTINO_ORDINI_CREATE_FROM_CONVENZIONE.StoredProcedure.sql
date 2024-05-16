USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[LISTINO_ORDINI_CREATE_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[LISTINO_ORDINI_CREATE_FROM_CONVENZIONE] ( @idDoc int , @IdUser int  )
AS
BEGIN
	
	SET NOCOUNT ON;

	declare @id int
	declare @azienda_mit int
	declare @codicemodelloconvenzione as varchar(200)
	declare @nomemodellolistino as varchar(200)
	declare @Errore as nvarchar(2000)

	set @Errore = ''

	--recupero azienda utente collegato
	select @azienda_mit=pfuidazi from ProfiliUtente with (nolock) where idpfu=@IdUser
		

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
		
		--prima di creare controllo che ci sia una riga sul listino convenzione
		if not exists (
			select top 1 id 
				from Document_MicroLotti_Dettagli with (nolock) 
				where 
					tipodoc = 'CONVENZIONE' and IdHeader = @idDoc and cig <> ''
		)
		set @Errore = 'Operazione non consentita caricare prima dei CIG nel listino ordinativo e salvare'


		if  @Errore = ''
		begin

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

		end


	END


	if @Errore=''

		-- rirorna l'id del documento
		select @Id as id
	
	else

	begin
		-- rirorna l'errore
		select 'ERRORE' as id , @Errore as Errore
	end

END




GO
