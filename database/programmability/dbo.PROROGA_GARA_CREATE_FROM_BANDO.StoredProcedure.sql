USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PROROGA_GARA_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[PROROGA_GARA_CREATE_FROM_BANDO] 
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
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'PROROGA_GARA' ) and statofunzionale = 'InLavorazione'

		-- se non esiste lo creo
		if @id is null
		begin
			   -- altrimenti lo creo
			   --recupero un eventuale precedente proroga inviata
			   Select @PrevDoc = case when max(id) > 0 then  max(id) else 0 end
			   from CTL_DOC
						where LinkedDoc=@idDoc and tipodoc='PROROGA_GARA' and Statofunzionale='Inviato'
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo,LinkedDoc,PrevDoc,jumpcheck,Body,ProtocolloRiferimento,NumeroDocumento,Fascicolo )
				select 
					@IdUser as idpfu , 'PROROGA_GARA' as TipoDoc ,  
					'Proroga gara Num. ' + ProtocolloBando as Titolo,  
					 @idDoc as LinkedDoc,@PrevDoc,itype+';'+iSubtype,Object_Cover1,ProtocolloBando,CIG,ProtocolBG
				from TAB_MESSAGGI_FIELDS where idmsg = @idDoc
				set @id = @@identity
				----recupero tutti i dati del Bando
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','ProtocolloBando',ProtocolloBando
				from TAB_MESSAGGI_FIELDS where idmsg = @idDoc
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','CIG',CIG
				from TAB_MESSAGGI_FIELDS where idmsg = @idDoc
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','Descrizione',Object_Cover1
				from TAB_MESSAGGI_FIELDS where idmsg = @idDoc
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','OLD_DataPresentazioneRisposte',ExpiryDate
				from TAB_MESSAGGI_FIELDS where idmsg = @idDoc
				
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','OLD_DataSeduta',DataAperturaOfferte
				from TAB_MESSAGGI_FIELDS where idmsg = @idDoc
				
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','OLD_DataTermineQuesiti',TermineRichiestaQuesiti
				from TAB_MESSAGGI_FIELDS where idmsg = @idDoc
				
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
