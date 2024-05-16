USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ISTANZA_COPY_FROM_OFFERTA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[ISTANZA_COPY_FROM_OFFERTA]( @newId as int , @idDoc as int, @idpfu as int ) 
as



	
	exec AFS_DECRYPT_DATI  @idPfu ,  'CTL_DOC_Value' , 'TOTALI' ,  'idHeader'  ,  @idDoc   ,'OFFERTA_TESTATA_TOTALI' , ' Value ' , '' , ''
		
	insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
	select @newId as IdHeader, DSE_ID, Row, DZT_Name, Value 
		from CTL_DOC_Value with(nolock)
			--where IdHeader = @idDoc and DSE_ID not in ('ESECUTRICI','RTI','SUBAPPALTO','AUSILIARIE')
			where IdHeader = @idDoc

	--ricopio la struttura RTI		
	insert into Document_Offerta_Partecipanti
		( [IdHeader], [TipoRiferimento], [IdAziRiferimento], [RagSocRiferimento], [IdAzi], [RagSoc], [CodiceFiscale], [IndirizzoLeg], [LocalitaLeg], [ProvinciaLeg], [Ruolo_Impresa])
			
	select 
		@newId,[TipoRiferimento], [IdAziRiferimento], [RagSocRiferimento], [IdAzi], [RagSoc], [CodiceFiscale], [IndirizzoLeg], [LocalitaLeg], [ProvinciaLeg], [Ruolo_Impresa]
			from 
				Document_Offerta_Partecipanti 
			where idheader = @idDoc  order by idrow



	--ALLA CREAZIONE VALORIZZO I CAMPI ESITO COMPLESSIVO
	delete from CTL_DOC_Value where IdHeader=@newId and DSE_ID='TESTATA_DOCUMENTAZIONE' and DZT_Name='EsitoRiga'
			
	insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value)
		select @newId,'TESTATA_DOCUMENTAZIONE','EsitoRiga','<img src="../images/Domain/State_Warning.gif"><br/>E'' necessario eseguire il comando "Verifica Informazioni"'

	delete from CTL_DOC_Value where IdHeader=@newId and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='EsitoRiga'
			
	insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value)
		select @newId,'TESTATA_PRODOTTI','EsitoRiga','<img src="../images/Domain/State_Err.gif"><br/>E'' necessario eseguire il comando "Verifica Informazioni"'

	--tolgo i dati in chiaro per la sezione dei totali del vecchio documento
	--exec AFS_CRYPT_DATI 'CTL_DOC_Value' ,'idHeader'  ,  @idDoc ,'OFFERTA_TESTATA_TOTALI','idrow, idHeader, DSE_ID, Row, DZT_Name ','dse_id=''TOTALI'''	
	exec AFS_CRYPTED_CLEAN 'CTL_DOC_Value' ,  'idHeader'  ,  @idDoc   ,'OFFERTA_TESTATA_TOTALI'  ,'idrow, idHeader, DSE_ID, Row, DZT_Name ','dse_id=''TOTALI'''

	--cifro la sezione dei totali sul nuovo documento
	exec AFS_CRYPT_DATI 'CTL_DOC_Value' ,'idHeader'  ,  @newId ,'OFFERTA_TESTATA_TOTALI','idrow, idHeader, DSE_ID, Row, DZT_Name ','dse_id=''TOTALI'''	



	--decript prima di copiare gli allegati
	exec AFS_DECRYPT_DATI  @idPfu ,  'CTL_DOC_ALLEGATI' , 'DOCUMENTAZIONE' ,  'idHeader'  ,  @idDoc   ,'OFFERTA_ALLEGATI' , 'idrow, idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile, DataScadenza, DSE_ID, EvidenzaPubblica, RichiediFirma' , '' , 1 
	Insert into CTL_DOC_ALLEGATI ( idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile,RichiediFirma )
		select  @newId as  idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile,RichiediFirma 
			from CTL_DOC_ALLEGATI with(nolock)
			where IdHeader = @idDoc

	--cripto di nuovo la precedente
	exec AFS_CRYPT_DATI 'CTL_DOC_ALLEGATI' ,'idHeader'  ,  @idDoc ,'OFFERTA_ALLEGATI','idrow, idHeader',''	
	   
	--cripto la nuova
	exec AFS_CRYPT_DATI 'CTL_DOC_ALLEGATI' ,'idHeader'  ,  @newId ,'OFFERTA_ALLEGATI','idrow, idHeader',''	


	----COPIA i PRODOTTI DALLA PRECEDENTE OFFERTA
	
	--decript prima di copiare
	exec START_OFFERTA_CHECK_PRODUCT @idDoc , @idPfu



	declare @Filter as varchar(500)
	declare @DestListField as varchar(500)

	set @Filter = ' Tipodoc=''OFFERTA'' '
	set @DestListField = ' ''OFFERTA'' as TipoDoc, '''' as EsitoRiga '
	exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @idDoc, @newId, 'IdHeader', 
						' Id,IdHeader,TipoDoc,EsitoRiga,idheaderlotto ', 
						@Filter, 
						' TipoDoc, EsitoRiga ', 
						@DestListField,
						' id '


	--cripto di nuovo la precedente
	exec END_OFFERTA_CHECK_PRODUCT @idDoc , @idPfu

	---CRIPTO LA NUOVA
	exec END_OFFERTA_CHECK_PRODUCT @newId , @idPfu


	----se sul bando è richiesta la terna per il subappalto inserisco le 3 righe sulla griglia del subappalto
	---- visto che sto copiano perchè faccio questo e non li ricopio dalla precedente offerta?
	--IF EXISTS ( Select * from Document_Bando with(nolock) where idHeader=@idOrigin and ISNULL(Richiesta_terna_subappalto,'')='1') 
	--BEGIN	

	--	insert into Document_Offerta_Partecipanti ( IdHeader,TipoRiferimento,IdAzi,RagSoc,CodiceFiscale,IndirizzoLeg,LocalitaLeg ,ProvinciaLeg)
	--		select @newId , 'SUBAPPALTO','','','','','',''

	--	insert into Document_Offerta_Partecipanti ( IdHeader,TipoRiferimento,IdAzi,RagSoc,CodiceFiscale,IndirizzoLeg,LocalitaLeg ,ProvinciaLeg)
	--		select @newId , 'SUBAPPALTO','','','','','',''

	--	insert into Document_Offerta_Partecipanti ( IdHeader,TipoRiferimento,IdAzi,RagSoc,CodiceFiscale,IndirizzoLeg,LocalitaLeg ,ProvinciaLeg)
	--		select @newId , 'SUBAPPALTO','','','','','',''
		
	--END






GO
