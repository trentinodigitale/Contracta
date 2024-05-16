USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RETTIFICA_GARA_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[RETTIFICA_GARA_CREATE_FROM_BANDO]
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET xact_abort on
	BEGIN TRAN

	SET NOCOUNT ON

	declare @Id as INT
	declare @PrevDoc as INT
	declare @idmsgcurs as int 
	set @PrevDoc=0
	declare @motivaz_ret as Nvarchar(4000)
	declare @isubtype as varchar(10)


	select @iSubtype=iSubtype from TAB_MESSAGGI_FIELDS where idmsg = @idDoc

	set @motivaz_ret = dbo.CNV('RETTIFICA_GARA_MSG_' + @isubtype, 'I' )

	declare @Errore as nvarchar(2000)
	set @Errore = ''

	---controllo se per quel bando esiste una revoca
	IF EXISTS ( select * from ctl_doc where LinkedDoc=@idDoc and TipoDoc='REVOCA_GARA' and StatoFunzionale='InLavorazione' )
	BEGIN
		set @Errore = 'Il documento di rettifica non puo essere creato se non viene conclusa la revoca in corso sul bando'
	END
	---controllo se per quel bando esiste una proroga/estensione
	IF EXISTS ( select * from ctl_doc where LinkedDoc=@idDoc and TipoDoc='PROROGA_GARA' and StatoFunzionale='InLavorazione' )
	BEGIN
		set @Errore = 'Il documento di rettifica non puo essere creato se non viene conclusa l''estensione in corso sul bando'
	END
		-- cerco una versione precedente del documento 
		set @id = null
		select @id = id from CTL_DOC where LinkedDoc = @idDoc and deleted = 0 and TipoDoc in ( 'RETTIFICA_GARA' ) and statofunzionale in ( 'InLavorazione','InApprovazione')

		-- se non esiste lo creo
		if @id is null and  @Errore = '' 
		begin
			   -- altrimenti lo creo
			   -- cambio advancedState del Bando e dei suoi DocCollegati
			   exec UPDATE_FIELD_MESSAGGIO 'AdvancedState', @idDoc ,'6'	
			   
					declare CurProg2 Cursor Static for 
					   select idmsg as idmsgcurs  from tab_messaggi_fields 
						 where iddoc=( select iddoc from tab_messaggi_fields where idmsg=@idDoc)
						 and idmsg <> @idDoc

					open CurProg2
		
					FETCH NEXT FROM CurProg2 
					INTO @idmsgcurs
					WHILE @@FETCH_STATUS = 0
					BEGIN
						
						exec UPDATE_FIELD_MESSAGGIO 'AdvancedState', @idmsgcurs ,'6'	
						 			 
					FETCH NEXT FROM CurProg2 
					INTO @idmsgcurs
					END 

					CLOSE CurProg2
					DEALLOCATE CurProg2
			   
			   
			   --recupero un eventuale precedente rettifica inviata
			   Select @PrevDoc = case when max(id) > 0 then  max(id) else 0 end
			   from CTL_DOC
						where LinkedDoc=@idDoc and tipodoc='RETTIFICA_GARA' and Statofunzionale='Inviato'
				INSERT into CTL_DOC (
					IdPfu,  TipoDoc, 
					Titolo,LinkedDoc,PrevDoc,jumpcheck,Body,ProtocolloRiferimento,NumeroDocumento,Fascicolo,note )
				select 
					@IdUser as idpfu , 'RETTIFICA_GARA' as TipoDoc ,  
					'Rettifica gara Num. ' + ProtocolloBando as Titolo,  
					 @idDoc as LinkedDoc,@PrevDoc,itype+';'+iSubtype,Object_Cover1,ProtocolloBando,CIG,ProtocolBG,@motivaz_ret
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

					Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','DataPresentazioneRisposte',ExpiryDate
				from TAB_MESSAGGI_FIELDS where idmsg = @idDoc
				
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','DataSeduta',DataAperturaOfferte
				from TAB_MESSAGGI_FIELDS where idmsg = @idDoc
				
				
				Insert into ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				select 
					@id,'TESTATA','DataTermineQuesiti',TermineRichiestaQuesiti
				from TAB_MESSAGGI_FIELDS where idmsg = @idDoc


				--Recupero gli atti di gara del Bando e li inserisco nella rettifica
				declare @value as varchar (1000)
				--recupero il valore del field che le info degli allegati
				IF EXISTS (Select * from TAB_MESSAGGI where idmsg=@idDoc and msgiSubType=48)
				BEGIN
					select   @value=dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldTab_PRODUCTS3>', CAST(MSGTEXT AS VARCHAR(8000))) + 26,4000))
					from Tab_Messaggi where idMsg = @idDoc 				
				END
				ELSE
				BEGIN
					select   @value=dbo.GetField(SUBSTRING (MSGTEXT, CHARINDEX ('<AFLinkFieldTab_BANDO>', CAST(MSGTEXT AS VARCHAR(8000))) + 22,4000))
					from Tab_Messaggi where idMsg = @idDoc 
				END
				
				if @value <> ''
				BEGIN				
					select @value=items from dbo.split( @value ,'#' ) where items like '%Pos_Attach_griglia%'
					--adesso in @value ci sono gli attOrderFile della tab_Attach
					select @value=SUBSTRING(@value,24,4000)				
					
					declare @items INT
					declare @nguid varchar(500)

					declare CurProg Cursor Static for 
					select items from dbo.split( @value ,',') -- order by 1 asc

					open CurProg
		
					FETCH NEXT FROM CurProg 
					INTO @items
					WHILE @@FETCH_STATUS = 0
					BEGIN
						select @nguid=newid() 
						Insert into CTL_Attach ( ATT_Obj, ATT_Hash, ATT_Size, ATT_Name, ATT_Type)
						select objFile,@nguid,datalength(objFile),objName,RIGHT(objName, CHARINDEX('.',REVERSE(objName))-1)
						from tab_Attach,tab_obj
						where attidmsg=@idDoc and attorderFile=@items and attidObj=idObj
						insert into Document_Atti_Rettifica ( idHeader , Allegato_OLD)
						select @id,objName + '*' + RIGHT(objName, CHARINDEX('.',REVERSE(objName))-1) + '*' + cast(datalength(objFile) as varchar(200)) + '*' + @nguid
						from tab_Attach,tab_obj
						where attidmsg=@idDoc and attorderFile=@items and attidObj=idObj  			 
					FETCH NEXT FROM CurProg 
					INTO @items
					END 

					CLOSE CurProg
					DEALLOCATE CurProg

				END

				
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
COMMIT
SET xact_abort off
END




GO
