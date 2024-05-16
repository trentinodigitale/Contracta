USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PROROGA_CONSULTAZIONE_CREATE_FROM_BANDO_CONSULTAZIONE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  PROCEDURE [dbo].[PROROGA_CONSULTAZIONE_CREATE_FROM_BANDO_CONSULTAZIONE] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON

	declare @Id as INT
	declare @PrevDoc as INT
	set @PrevDoc=0
	
	declare @Errore as nvarchar(2000)
	set @Errore = ''
		-- cerco una versione precedente del documento 
		set @id = null
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PROROGA_CONSULTAZIONE' ) and statofunzionale = 'InLavorazione'

		IF EXISTS ( select * from ctl_doc where LinkedDoc=@idDoc and TipoDoc='RETTIFICA_CONSULTAZIONE' and StatoFunzionale='InLavorazione' )
		BEGIN
			set @Errore = 'Il documento di proroga non puo essere creato se non viene conclusa la rettifica in corso sul bando'
		END
		

		-- se non esiste lo creo
		if @id is null and @Errore=''
		begin
			   -- altrimenti lo creo
			   --recupero un eventuale precedente proroga inviata
			   Select @PrevDoc = case when max(id) > 0 then  max(id) else 0 end
			   from CTL_DOC
						where LinkedDoc=@idDoc and tipodoc='PROROGA_CONSULTAZIONE' and Statofunzionale='Inviato'
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo,LinkedDoc,PrevDoc,jumpcheck,Body,ProtocolloRiferimento,NumeroDocumento,Caption,Fascicolo,VersioneLinkedDoc,FascicoloGenerale )
				select 
					@IdUser as idpfu , 'PROROGA_CONSULTAZIONE' as TipoDoc ,  
					'Proroga Consultazione Num. ' + Protocollo as Titolo,  
					 @idDoc as LinkedDoc,@PrevDoc,'BANDO_CONSULTAZIONE',Body,Protocollo,CIG,'',Fascicolo,'PROROGA_CONSULTAZIONE' ,''
				from document_bando 
				inner join ctl_doc on id=idheader
				where idheader = @idDoc
				set @id = SCOPE_IDENTITY()
				----recupero tutti i dati del Bando
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','ProtocolloBando',Protocollo
				from ctl_doc where id = @idDoc
				
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','Descrizione',Body
				from CTL_DOC where id = @idDoc --and tipodoc='BANDO_GARA' 
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','OLD_DataPresentazioneRisposte',CONVERT(nvarchar(30), DataScadenzaOfferta, 126)
				from document_bando where idheader = @idDoc				
				
			
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','OLD_DataTermineQuesiti',CONVERT(nvarchar(30), DataTermineQuesiti, 126)
				from document_bando where idheader = @idDoc

			
				

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
