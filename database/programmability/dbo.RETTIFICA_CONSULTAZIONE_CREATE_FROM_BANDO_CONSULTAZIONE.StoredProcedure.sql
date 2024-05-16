USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RETTIFICA_CONSULTAZIONE_CREATE_FROM_BANDO_CONSULTAZIONE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE  PROCEDURE [dbo].[RETTIFICA_CONSULTAZIONE_CREATE_FROM_BANDO_CONSULTAZIONE] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON

	declare @Id as INT
	declare @PrevDoc as INT
	set @PrevDoc=0
	
	declare @Errore as nvarchar(2000)
	declare @motivaz_ret as Nvarchar(4000)

	set @motivaz_ret = dbo.CNV('RETTIFICA_CONSULTAZIONE_MSG_BANDO_CONSULTAZIONE', 'I' )

	set @Errore = ''
	---controllo se per quel bando esiste una proroga/estensione
	IF EXISTS ( select * from ctl_doc where LinkedDoc=@idDoc and TipoDoc='PROROGA_CONSULTAZIONE' and StatoFunzionale='InLavorazione' )
	BEGIN
		set @Errore = 'Il documento di rettifica non puo essere creato se non viene conclusa l''estensione in corso sul bando'
	END
		-- cerco una versione precedente del documento 
		set @id = null
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'RETTIFICA_CONSULTAZIONE' ) and statofunzionale in ( 'InLavorazione','InApprovazione')

		-- se non esiste lo creo
		if @id is null and  @Errore = '' 
		begin
			   -- altrimenti lo creo
			     -- cambio statoFunzionale del Bando
				Update CTL_DOC set StatoFunzionale='InRettifica' where id=@idDoc ---OK
			   --recupero un eventuale precedente proroga inviata
			   Select @PrevDoc = case when max(id) > 0 then  max(id) else 0 end
			   from CTL_DOC
						where LinkedDoc=@idDoc and tipodoc='RETTIFICA_CONSULTAZIONE' and Statofunzionale='Inviato'
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo,LinkedDoc,PrevDoc,jumpcheck,Body,ProtocolloRiferimento,NumeroDocumento,Caption,Fascicolo,note,FascicoloGenerale,VersioneLinkedDoc )
					select 
							@IdUser as idpfu , 'RETTIFICA_CONSULTAZIONE' as TipoDoc ,  
							'Rettifica Consultazione Num. ' + Protocollo as Titolo,  
							 @idDoc as LinkedDoc,@PrevDoc,'BANDO_CONSULTAZIONE',Body,Protocollo,CIG,'',Fascicolo,@motivaz_ret,'', 'Rettifica Consultazione' 								 
						from document_bando 
							inner join ctl_doc on id=idheader 
						where idheader = @idDoc

				set @id = SCOPE_IDENTITY()
				
				----recupero tutti i dati del Bando
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','ProtocolloBando',protocollo
					from CTL_DOC where id = @idDoc 


				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','Descrizione',Body
					from CTL_DOC where id = @idDoc 
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','OLD_DataPresentazioneRisposte',CONVERT(nvarchar(30), DataScadenzaOfferta, 126)
					from document_bando where idheader = @idDoc
				
				
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','OLD_DataTermineQuesiti',CONVERT(nvarchar(30), DataTermineQuesiti, 126)
					from document_bando where idheader = @idDoc

				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','DataPresentazioneRisposte',CONVERT(nvarchar(30), DataScadenzaOfferta, 126)
					from document_bando where idheader = @idDoc
				
				
				
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					select 
						@id,'TESTATA','DataTermineQuesiti',CONVERT(nvarchar(30), DataTermineQuesiti, 126)
						from document_bando where idheader = @idDoc
				
				

				--se la data DataTermineQuesiti del BANDO è superata non consento di editare il campo
				if EXISTS (Select * from Document_Bando where idHeader=@idDoc and getdate() > DataTermineQuesiti )
				BEGIN
					Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
					VALUES (@id,'TESTATA','Not_Editable',' DataTermineQuesiti ')
		
				END




				--Recupero gli atti di gara del Bando e li inserisco nella rettifica
				insert into Document_Atti_Rettifica ( idHeader , Allegato_OLD,Descrizione_OLD,AnagDoc)
						select @id,Allegato,Descrizione,AnagDoc
						from CTL_DOC_ALLEGATI
						where idHEader=@idDoc
				

		end		
		
		
		

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
SET NOCOUNT OFF
END

















GO
