USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_RETTIFICA_CONVENZIONE_CREATE_FROM_CONVENZIONE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  PROCEDURE [dbo].[OLD_RETTIFICA_CONVENZIONE_CREATE_FROM_CONVENZIONE] ( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as INT
	declare @PrevDoc as INT
	declare @Errore as nvarchar(2000)
	declare @NoteConvenzione as nvarchar(max)

	set @PrevDoc=0
	set @Errore = ''

	-- cerco una versione precedente del documento 
	set @id = null
	select @id = id from CTL_DOC with(nolock) where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'RETTIFICA_CONVENZIONE' ) and statofunzionale in ( 'InLavorazione' )

	-- se non esiste lo creo
	if @id is null and  @Errore = '' 
	begin

			-- Recupero un eventuale precedente rettifica inviata
			SELECT @PrevDoc = case when max(id) > 0 then  max(id) else 0 end
				FROM CTL_DOC WITH(NOLOCK)
				WHERE LinkedDoc=@idDoc and tipodoc='RETTIFICA_CONVENZIONE' and Statofunzionale='Inviato'

			INSERT INTO CTL_DOC (IdPfu,idPfuInCharge,  TipoDoc, Titolo,LinkedDoc,PrevDoc,Body,ProtocolloRiferimento )
				select 	@IdUser as idpfu , @IdUser, 'RETTIFICA_CONVENZIONE' as TipoDoc , 'Rettifica convenzione Num. ' + Protocollo as Titolo,  @idDoc as LinkedDoc,@PrevDoc,Body,Protocollo
					from Document_Convenzione c  with(nolock)
						inner join ctl_doc d on c.id = d.id 
					where d.id = @idDoc


			set @id = SCOPE_IDENTITY()


			-- Recupero tutti i dati del Bando
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','Titolo',Titolo
				from ctl_doc with(nolock)
				where id = @idDoc

			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select @id,'TESTATA','Protocollo',Protocollo
				from CTL_DOC with(nolock)
				where id = @idDoc 

			--recupero campo note dalla convenzione--
			select @NoteConvenzione=Note from CTL_DOC with(nolock) where id=@idDoc 
			Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select @id,'NOTE','NoteConvenzione',@NoteConvenzione
				

			--Recupero gli atti di gara del Bando e li inserisco nella rettifica
			insert into Document_Atti_Rettifica ( idHeader , Allegato_OLD,Descrizione_OLD,AnagDoc,EvidenzaPubblica )
					select @id,Allegato,Descrizione,AnagDoc, EvidenzaPubblica
					from CTL_DOC_ALLEGATI with(nolock)
					where idHEader=@idDoc

			-- travaso gli allegati richiesti nella controparte di rettifica per permetterne la modifica
			insert into Document_Bando_DocumentazioneRichiesta (idHeader, TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, AllegatoRichiesto, Obbligatorio, TipoFile, AnagDoc, NotEditable, RichiediFirma )
					select @id,TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, AllegatoRichiesto, Obbligatorio, TipoFile, AnagDoc, NotEditable, RichiediFirma 
					from Document_Bando_DocumentazioneRichiesta with(nolock)
					where idHEader=@idDoc

			-- PREV_DOC_RICHIESTA 

			DECLARE @riga INT
			DECLARE @TipoInterventoDocumentazione VARCHAR(4000) ,@LineaDocumentazione VARCHAR(4000), @DescrizioneRichiesta VARCHAR(4000), @AllegatoRichiesto VARCHAR(4000), @Obbligatorio VARCHAR(4000), @TipoFile VARCHAR(4000), @AnagDoc VARCHAR(4000), @RichiediFirma VARCHAR(4000)

			set @riga = 0

			DECLARE curs CURSOR STATIC FOR     
				select TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, AllegatoRichiesto, Obbligatorio, TipoFile, AnagDoc, RichiediFirma 
					from Document_Bando_DocumentazioneRichiesta with(nolock)
					where idHEader=@idDoc


			OPEN curs 
			FETCH NEXT FROM curs INTO @TipoInterventoDocumentazione, @LineaDocumentazione, @DescrizioneRichiesta, @AllegatoRichiesto, @Obbligatorio, @TipoFile, @AnagDoc, @RichiediFirma 

			WHILE @@FETCH_STATUS = 0   
			BEGIN  

				INSERT INTO CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								   values ( @id, 'PREV_DOC_RICHIESTA',@riga, 'TipoInterventoDocumentazione',@TipoInterventoDocumentazione )

				INSERT INTO CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								   values ( @id, 'PREV_DOC_RICHIESTA',@riga, 'LineaDocumentazione',@LineaDocumentazione )

				INSERT INTO CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								   values ( @id, 'PREV_DOC_RICHIESTA',@riga, 'DescrizioneRichiesta',@DescrizioneRichiesta )

				INSERT INTO CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								   values ( @id, 'PREV_DOC_RICHIESTA',@riga, 'AllegatoRichiesto',@AllegatoRichiesto )

				INSERT INTO CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								   values ( @id, 'PREV_DOC_RICHIESTA',@riga, 'Obbligatorio',@Obbligatorio )

				INSERT INTO CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								   values ( @id, 'PREV_DOC_RICHIESTA',@riga, 'TipoFile',@TipoFile )

				INSERT INTO CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								   values ( @id, 'PREV_DOC_RICHIESTA',@riga, 'AnagDoc',@AnagDoc )

				INSERT INTO CTL_DOC_VALUE ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								   values ( @id, 'PREV_DOC_RICHIESTA',@riga, 'RichiediFirma',@RichiediFirma )

				set @riga = @riga + 1

				FETCH NEXT FROM curs INTO @TipoInterventoDocumentazione, @LineaDocumentazione, @DescrizioneRichiesta, @AllegatoRichiesto, @Obbligatorio, @TipoFile, @AnagDoc, @RichiediFirma 

			END  

			CLOSE curs   
			DEALLOCATE curs

	END


	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end

END


GO
