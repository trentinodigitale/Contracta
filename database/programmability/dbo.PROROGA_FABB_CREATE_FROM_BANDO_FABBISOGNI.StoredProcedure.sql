USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PROROGA_FABB_CREATE_FROM_BANDO_FABBISOGNI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE  PROCEDURE [dbo].[PROROGA_FABB_CREATE_FROM_BANDO_FABBISOGNI]
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
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PROROGA_FABB' ) and statofunzionale = 'InLavorazione'

		-- se non esiste lo creo
		if @id is null and @Errore=''
		begin
			   -- altrimenti lo creo
			   --recupero un eventuale precedente proroga inviata
			   Select @PrevDoc = case when max(id) > 0 then  max(id) else 0 end
			   from CTL_DOC
						where LinkedDoc=@idDoc and tipodoc='PROROGA_FABB' and Statofunzionale='Inviato'
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo,LinkedDoc,PrevDoc,jumpcheck,Body,ProtocolloRiferimento,NumeroDocumento,Caption,Fascicolo,VersioneLinkedDoc,idPfuInCharge )
				select 
					@IdUser as idpfu , 'PROROGA_FABB' as TipoDoc ,  
					'Proroga Richiesta dei Fabbisogni Num. ' + Protocollo as Titolo,  
					 @idDoc as LinkedDoc,@PrevDoc,'BANDO_FABBISOGNI',Body,Protocollo,CIG,'',Fascicolo,'Proroga Richiesta dei Fabbisogni',@IdUser
				from document_bando 
				inner join ctl_doc on id=idheader --and tipodoc = 'BANDO_GARA'
				where idheader = @idDoc
				set @id = SCOPE_IDENTITY()

				----recupero tutti i dati del Bando
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','ProtocolloBando',Protocollo
				from ctl_doc where id = @idDoc
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','CIG',CIG
				from document_bando where idheader = @idDoc
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','Descrizione',Body
				from CTL_DOC where id = @idDoc --and tipodoc='BANDO_GARA' 
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','OLD_DataPresentazioneRisposte',CONVERT(nvarchar(30), DataPresentazioneRisposte, 126)
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
