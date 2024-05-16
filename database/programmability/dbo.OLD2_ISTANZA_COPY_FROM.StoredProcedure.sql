USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_ISTANZA_COPY_FROM]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

















CREATE proc [dbo].[OLD2_ISTANZA_COPY_FROM]( @idDoc as int , @idpfu int = -1, @tipodocNew varchar(200) = '') 
as
--Versione=6&data=2018-05-17&Attivita=177795&Nominativo=Federico	aggiunto per motivi di sicurezza blocco se documento di partenza non di pertinenza dell'utente ( idPfu, idPfuInCharge, fa parte dell'azienda )
--Versione=5&data=2016-12-02&Attivita=125916&Nominativo=Francesco
--Versione=4&data=2014-09-04&Attivita=62233&Nominativo=Sabato
--Versione=3&data=2013-02-08&Attivita=41407&Nominativo=Francesco
begin

	SET NOCOUNT  ON

	declare @newId int
	declare @documento as varchar(200)
	declare @TipoDoc as varchar(200)
	declare @idOrigin int
	declare @errore nvarchar(2000)
	declare @titolo as nvarchar(500)
	declare @TipoBando as varchar(500)

	set @errore = ''

	-- SE L'UTENTE CHE STA EFFETTUANDO LA COPIA NON E' L'IDPFU DEL DOCUMENTO O L'IDPFUINCHARGE O UN UTENTE DELL'AZIENDA DELL'UTENTE CHE HA CREATO IL DOCUMENTO, BLOCCO
	IF NOT EXISTS (

		select da.id 
			from ctl_doc da with(nolock)
					INNER JOIN ProfiliUtente u1 with(nolock) on u1.idpfu = da.IdPfu
					INNER JOIN ProfiliUtente u2 with(nolock) on u2.pfuIdAzi = u1.pfuIdAzi and u2.pfuDeleted = 0
			where da.id = @idDoc and ( da.IdPfu = @idpfu or da.idPfuInCharge = @idpfu or u2.IdPfu = @idpfu )

	)
	BEGIN

		set @errore = 'Copia non possibile. Documento non di pertinenza'

	END



	IF @errore = '' 
	BEGIN
		
		
		select @TipoDoc=Tipodoc,@idOrigin=LinkedDoc from CTL_DOC with (nolock) where Id=@idDoc
		
		--SE SI TRATTA DI ISTANZE RETTIFICO IL TITOLO COME FATTO SULLA CREAZIONE DELLA PRIMA ISTANZA
		if @TipoDoc like 'ISTANZA_%'
		begin
			
			--recupero tipobando a cui è relativa l'istanza
			select @TipoBando=TipoBando 
				from ctl_doc with (nolock) 
					inner join  document_bando with (nolock) on idheader=id 
						where id=@idOrigin

			set @titolo='Istanza Iscrizione'
				if @TipoBando in ('ALBO_ME_4','AlboLavori_2','AlboFornitori_2')
					set @titolo='Domanda di Ammissione'
		end	


		insert into CTL_DOC (  IdPfu, idPfuInCharge , IdDoc, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted, Titolo, Body, Azienda, StrutturaAziendale, DataScadenza, ProtocolloRiferimento, Fascicolo, Note, LinkedDoc, Destinatario_User, Destinatario_Azi, RichiestaFirma )
			select @idpfu,@idpfu, IdDoc, case when ISNULL(@tipodocNew,'') <> '' then @tipodocNew else TipoDoc end, 'Saved' as StatoDoc, getdate() as Data, '' Protocollo, id as PrevDoc, 0 as Deleted, ISNULL(@titolo,Titolo), Body, Azienda, StrutturaAziendale, DataScadenza, ProtocolloRiferimento, Fascicolo, Note, LinkedDoc,  Destinatario_User, Destinatario_Azi, RichiestaFirma 
				from CTL_DOC with(nolock)
					where id = @idDoc

		set @newId = SCOPE_IDENTITY()
		
		
		Select @TipoDoc=TipoDoc,@idOrigin=LinkedDoc from CTL_DOC with(nolock) where id=@newId

		--
		--SE NON SONO LO STESSO UTENTE INVIO UNA MAIL AL PRECEDENTE
		--
		IF @idpfu <> -1
		BEGIN
			declare @idPfuInCharge INT
			declare @stessa_azi as varchar(10)

			set @idPfuInCharge = 0

			Select @idPfuInCharge=ISNULL(idPfuInCharge,0) from CTL_DOC with(nolock) where id=@idDoc

			--verifico se è un utente della stessa azienda di @idpfu
			IF ( @idPfuInCharge > 0  )
			BEGIN
				IF EXISTS (Select * from profiliUtente with(nolock) where idpfu=@idpfu and pfuidazi=(Select pfuIdAzi from ProfiliUtente with(nolock) where idpfu=@idPfuInCharge) )
				BEGIN
						IF EXISTS (Select * from CTL_DOC with(nolock) where id=@idDoc and  idPfuInCharge <> @idpfu)
						BEGIN

							insert into ctl_mail (IdDoc ,IdUser ,TypeDoc,[State] )
								select  @newId,idPfuInCharge,'AVVISO_NUOVA_OFFERTA',0 		
									from  CTL_DOC with(nolock)
										where id=@idDoc
						END
				END
				ELSE
				BEGIN
					set @stessa_azi = 'NO'
				END

			END
			
			-- caso di Idpfuincharge non avvalorato o idpfuincharge non appartiene alla stessa azienda di @idpfu
			IF( @idPfuInCharge = 0 or  @stessa_azi = 'NO' )
			BEGIN
				IF EXISTS (Select * from CTL_DOC with(nolock) where id=@idDoc and  idpfu <> @idpfu)
				BEGIN
					insert into ctl_mail (IdDoc ,IdUser ,TypeDoc,[State] )
						select  @newId,idpfu,'AVVISO_NUOVA_OFFERTA',0 		
							from  CTL_DOC with(nolock) 
								where id=@idDoc
				END
			END
		END
		

		IF  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES  WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='CTL_DOC_SIGN')  and @tipodoc not in ('OFFERTA','MANIFESTAZIONE_INTERESSE','DOMANDA_PARTECIPAZIONE', 'RISPOSTA_CONCORSO')
		BEGIN
		
			--insert into CTL_DOC_SIGN (  idHeader )
			--		values( @newId )
			if exists ( select idHeader from CTL_DOC_SIGN with(nolock) where idHeader = @idDoc )
			begin 

				insert into CTL_DOC_SIGN ( idHeader, F1_DESC, F1_SIGN_HASH, F1_SIGN_ATTACH, F1_SIGN_LOCK, F2_DESC, F2_SIGN_HASH, F2_SIGN_ATTACH, F2_SIGN_LOCK, F3_DESC, F3_SIGN_HASH, F3_SIGN_ATTACH, F3_SIGN_LOCK, F4_DESC, F4_SIGN_HASH, F4_SIGN_ATTACH, F4_SIGN_LOCK )
					select @newId as idHeader, F1_DESC, F1_SIGN_HASH, F1_SIGN_ATTACH, F1_SIGN_LOCK, F2_DESC, F2_SIGN_HASH, F2_SIGN_ATTACH, F2_SIGN_LOCK, F3_DESC, F3_SIGN_HASH, F3_SIGN_ATTACH, F3_SIGN_LOCK, F4_DESC, F4_SIGN_HASH, F4_SIGN_ATTACH, F4_SIGN_LOCK 
							from CTL_DOC_SIGN with(nolock)
								where idHeader = @idDoc
			end
			else
			begin
				insert into CTL_DOC_SIGN (IdHEader,F1_SIGN_ATTACH,F2_SIGN_HASH)
					select @newId,SIGN_ATTACH,SIGN_HASH 
						from Document_Parametri_Abilitazioni DP with(nolock)
							inner join ctl_doc with(nolock) on idheader=id
								where DP.tipodoc='ALBO' and DP.deleted=0				
			end
				
		END
	

		
		--IF EXISTS (Select * from ctl_doc with(nolock) where tipodoc='OFFERTA' and id=@idDoc)
		--BEGIN
			
			--exec AFS_DECRYPT_DATI  @idPfu ,  'CTL_DOC_Value' , 'TOTALI' ,  'idHeader'  ,  @idDoc   ,'OFFERTA_TESTATA_TOTALI' , ' Value ' , '' , ''
		
			--insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
			--select @newId as IdHeader, DSE_ID, Row, DZT_Name, Value 
			--	from CTL_DOC_Value with(nolock)
			--		--where IdHeader = @idDoc and DSE_ID not in ('ESECUTRICI','RTI','SUBAPPALTO','AUSILIARIE')
			--		where IdHeader = @idDoc

			----ricopio la struttura RTI		
			--insert into Document_Offerta_Partecipanti 
			--	( [IdHeader], [TipoRiferimento], [IdAziRiferimento], [RagSocRiferimento], [IdAzi], [RagSoc], [CodiceFiscale], [IndirizzoLeg], [LocalitaLeg], [ProvinciaLeg], [Ruolo_Impresa])
			
			--select 
			--	@newId,[TipoRiferimento], [IdAziRiferimento], [RagSocRiferimento], [IdAzi], [RagSoc], [CodiceFiscale], [IndirizzoLeg], [LocalitaLeg], [ProvinciaLeg], [Ruolo_Impresa]
			--		from 
			--			Document_Offerta_Partecipanti 
			--		where idheader = @idDoc 


			----ALLA CREAZIONE VALORIZZO I CAMPI ESITO COMPLESSIVO
			--delete from CTL_DOC_Value where IdHeader=@newId and DSE_ID='TESTATA_DOCUMENTAZIONE' and DZT_Name='EsitoRiga'
			
			--insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value)
			--	select @newId,'TESTATA_DOCUMENTAZIONE','EsitoRiga','<img src="../images/Domain/State_Warning.gif"><br/>E'' necessario eseguire il comando "Verifica Informazioni"'

			--delete from CTL_DOC_Value where IdHeader=@newId and DSE_ID='TESTATA_PRODOTTI' and DZT_Name='EsitoRiga'
			
			--insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value)
			--	select @newId,'TESTATA_PRODOTTI','EsitoRiga','<img src="../images/Domain/State_Err.gif"><br/>E'' necessario eseguire il comando "Verifica Informazioni"'

			----tolgo i dati in chiaro per la sezione dei totali del vecchio documento
			----exec AFS_CRYPT_DATI 'CTL_DOC_Value' ,'idHeader'  ,  @idDoc ,'OFFERTA_TESTATA_TOTALI','idrow, idHeader, DSE_ID, Row, DZT_Name ','dse_id=''TOTALI'''	
			--exec AFS_CRYPTED_CLEAN 'CTL_DOC_Value' ,  'idHeader'  ,  @idDoc   ,'OFFERTA_TESTATA_TOTALI'  ,'idrow, idHeader, DSE_ID, Row, DZT_Name ','dse_id=''TOTALI'''

			----cifro la sezione dei totali sul nuovo documento
			--exec AFS_CRYPT_DATI 'CTL_DOC_Value' ,'idHeader'  ,  @newId ,'OFFERTA_TESTATA_TOTALI','idrow, idHeader, DSE_ID, Row, DZT_Name ','dse_id=''TOTALI'''	

		--END
		--ELSE
		IF EXISTS (Select * from ctl_doc with(nolock) where id=@idDoc and @tipodoc not in ('OFFERTA','MANIFESTAZIONE_INTERESSE','DOMANDA_PARTECIPAZIONE','RISPOSTA_CONCORSO') )
		BEGIN

			--recupero il documento che sto creando
			select @documento=case when ISNULL(@tipodocNew,'') <> '' then @tipodocNew else TipoDoc end  from ctl_doc with(nolock) where id=@idDoc

			--RIPORTO SOLO LE SEZIONI PRESENTI SUL DOCUMENTO DI DESTINAZIONE
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
				select @newId as IdHeader, CV.DSE_ID, Row, CV.DZT_Name, Value 
					from CTL_DOC_Value CV with(nolock)
						inner join LIB_DocumentSections LS with(nolock) on DSE_DOC_ID=@documento and CV.DSE_ID=LS.DSE_ID
							where CV.IdHeader = @idDoc

			--KPF 553181 tolgo dalla nuova offerta eventuali flag di letta busta frutto di riapertura termini post PDA
			delete from ctl_doc_value 
				where idheader=@newId and dse_id in ('BUSTA_ECONOMICA','BUSTA_DOCUMENTAZIONE','OFFERTA_BUSTA_TEC') 
					and dzt_name in ('richiesta_apertura_busta','LettaBusta')
		END
	

		--AGGIORNA LA SEZIONE DOCUMENTAZIONE CON QUELLA PRESENTE SUL BANDO, IN CASO DI CAMBIAMENTI VIENE AGGIORNATA, 
		--PROVANDO A RIPRENDERE GLI ALLEGATI INSERITI SULLA PRECEDENTE A PARITA' DI NOME ALLEGATO
		if @TipoDoc  like 'ISTANZA_Albo%' or @TipoDoc like 'ISTANZA_SDA%' 
		BEGIN
			declare @Allegato varchar(1000)
			declare @AnagDoc varchar(1000)
			declare @Descrizione nvarchar(4000)
			declare @idRow int
			declare @NotEditable varchar(400)
			declare @Obbligatorio int
			declare @TipoEstensione varchar(4000)
			declare @TipoFile varchar(4000)
			declare @richiediFirma varchar(400)

	

			declare @riga int
			set @riga = 0
			set @richiediFirma = '0'

			delete from CTL_DOC_Value where idheader=@newId and DSE_ID='DOCUMENTAZIONE'
	
			IF @TipoDoc like 'ISTANZA_Albo%'
			BEGIN
			DECLARE cur1 CURSOR STATIC FOR
				select isnull(Allegato,''), isnull(AnagDoc,''), isnull(Descrizione,''), isnull(idRow,''), isnull(NotEditable,''), isnull(Obbligatorio,''), isnull(TipoEstensione,''), isnull(TipoFile,''), isnull(richiediFirma,'')
					from ISTANZA_AlboOperaEco_DOCUMENTAZIONE_FROM_BANDO where id_from = @idOrigin		
			END
			IF @TipoDoc like 'ISTANZA_SDA%'
			BEGIN
			DECLARE cur1 CURSOR STATIC FOR
				select isnull(Allegato,''), isnull(AnagDoc,''), isnull(Descrizione,''), isnull(idRow,''), isnull(NotEditable,''), isnull(Obbligatorio,''), isnull(TipoEstensione,''), isnull(TipoFile,''), isnull(richiediFirma,'')
					from ISTANZA_SDA_FARMACI_DOCUMENTAZIONE_FROM_BANDO_SDA where id_from = @idOrigin		
			END
			OPEN cur1 
			FETCH NEXT FROM cur1 INTO @Allegato,@AnagDoc,@Descrizione,@idRow,@NotEditable,@Obbligatorio,@TipoEstensione,@TipoFile, @richiediFirma


				BEGIN TRY
        
					WHILE @@FETCH_STATUS = 0   
					BEGIN
        		
						INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
							VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'Allegato', @Allegato)

						INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
							VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'AnagDoc', @AnagDoc)

						INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
							VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'Descrizione', @Descrizione)

						INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
							VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'idRow', cast(@idRow as varchar(10)))

						INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
							VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'NotEditable', @NotEditable)

						INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
							VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'Obbligatorio', @Obbligatorio)

						INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
							VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'TipoEstensione', @TipoEstensione)

						INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
							VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'TipoFile', @TipoFile)

						INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
							VALUES (@newId, 'DOCUMENTAZIONE', @riga, 'RichiediFirma', @richiediFirma)

						set @riga = @riga + 1

						FETCH NEXT FROM cur1 INTO @Allegato,@AnagDoc,@Descrizione,@idRow,@NotEditable,@Obbligatorio,@TipoEstensione,@TipoFile, @richiediFirma

					END

				END TRY
				BEGIN CATCH
					--set @errore = @@ERROR
					raiserror ('Errore popolamento DOCUMENTAZIONE  ', 16, 1 ) --, CAST(@@ERROR AS NVARCHAR(4000)))
					--rollback tran
					return 99
				END CATCH

			CLOSE cur1
			DEALLOCATE cur1

			--PROVA A POPOLARE GLI ALLEGATI CON QUELLI CHE TROVA SULLA PRECEDENTE A PARITA' DI NOME
			---RECUPERO I NOMI DEGLI ALLEGATI CHE NON HANNO CAMBIATO DESCRIZIONE TRA LA NUOVA E LA PRECEDENTE

			---RIGHE CHE HANNO LE DESCRIZIONI UGUALI TRA VECCHIA ISTANZA E NUOVA
			select C2.Row as ROW ,C2.Value into #tmp_ALLEGATI_IST
				from ctl_doc_value C with(nolock)
						inner join ctl_doc_value C2 with(nolock) on c2.idheader=@idDoc and  C2.DSE_ID='DOCUMENTAZIONE'  and C2.DZT_Name='Descrizione'  and C.Value=C2.Value
				where  C.idheader=@newId and  C.DSE_ID='DOCUMENTAZIONE' and C.DZT_Name='Descrizione'

			


			update CTL_DOC_Value 
					set Value=C.value 
				from (Select * from  CTL_DOC_Value with(nolock) ) as C
						inner join ctl_doc_value C2 with(nolock) on C2.idheader=@newId and C2.DSE_ID='DOCUMENTAZIONE' and C2.DZT_Name='Allegato'  and C.Row=c2.Row
						inner join #tmp_ALLEGATI_IST T on C.Row=T.ROW
				where c.idheader=@idDoc and  C.DSE_ID='DOCUMENTAZIONE'  and C.DZT_Name='Allegato' 

			drop table #tmp_ALLEGATI_IST

		END
		-------------------------------------------------------------------------------------------------------------------------------------

		
		

		--se sto copiando il documento OFFERTA devo fare la decrypt e poi la crypt dei dati
		--IF EXISTS (Select * from ctl_doc with(nolock) where tipodoc='OFFERTA' and id=@idDoc)
		--BEGIN
			
			----decript prima di copiare
			--exec AFS_DECRYPT_DATI  @idPfu ,  'CTL_DOC_ALLEGATI' , 'DOCUMENTAZIONE' ,  'idHeader'  ,  @idDoc   ,'OFFERTA_ALLEGATI' , 'idrow, idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile, DataScadenza, DSE_ID, EvidenzaPubblica, RichiediFirma' , '' , 1 
			--Insert into CTL_DOC_ALLEGATI ( idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile,RichiediFirma )
			--	select  @newId as  idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile,RichiediFirma 
			--		from CTL_DOC_ALLEGATI with(nolock)
			--		where IdHeader = @idDoc

			----cripto di nuovo la precedente
			--exec AFS_CRYPT_DATI 'CTL_DOC_ALLEGATI' ,'idHeader'  ,  @idDoc ,'OFFERTA_ALLEGATI','idrow, idHeader',''	
	   
			----cripto la nuova
			--exec AFS_CRYPT_DATI 'CTL_DOC_ALLEGATI' ,'idHeader'  ,  @newId ,'OFFERTA_ALLEGATI','idrow, idHeader',''	


			------COPIA i PRODOTTI DALLA PRECEDENTE OFFERTA
			----decript prima di copiare
			--exec START_OFFERTA_CHECK_PRODUCT @idDoc , @idPfu



			--declare @Filter as varchar(500)
			--declare @DestListField as varchar(500)

			--set @Filter = ' Tipodoc=''OFFERTA'' '
			--set @DestListField = ' ''OFFERTA'' as TipoDoc, '''' as EsitoRiga '
			--exec INSERT_RECORD_NEW 'Document_MicroLotti_Dettagli', @idDoc, @newId, 'IdHeader', 
			--				  ' Id,IdHeader,TipoDoc,EsitoRiga,idheaderlotto ', 
			--				  @Filter, 
			--				  ' TipoDoc, EsitoRiga ', 
			--				  @DestListField,
			--				  ' id '


			----cripto di nuovo la precedente
			--exec END_OFFERTA_CHECK_PRODUCT @idDoc , @idPfu
			-----CRIPTO LA NUOVA
			--exec END_OFFERTA_CHECK_PRODUCT @newId , @idPfu

			--exec AFS_OFFERTA_CRYPT @newId , @idPfu
	   
		--END
		--ELSE
		IF EXISTS (Select * from ctl_doc with(nolock) where  id=@idDoc and @tipodoc not in ('OFFERTA','MANIFESTAZIONE_INTERESSE','DOMANDA_PARTECIPAZIONE','RISPOSTA_CONCORSO') )
		BEGIN
			insert into CTL_DOC_ALLEGATI ( idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile )
				select  @newId as  idHeader, Descrizione, Allegato, Obbligatorio, AnagDoc, DataEmissione, Interno, Modified, NotEditable, TipoFile 
					from CTL_DOC_ALLEGATI with(nolock)
						where IdHeader = @idDoc
		END


		--per ISTANZA_AlboProf_2 non devo riportare eventuali modelli dinamici, servivano solo per la vecchia versione
		--IF  @TipoDoc not in ( 'ISTANZA_AlboProf_2' , 'ISTANZA_AlboProf_3','ISTANZA_AlboProf_BIM')
		if ( @TipoDoc not like 'ISTANZA_%' )   --NON SERVE PER LE ISTANZE, DOVE ABBIAMO MESSO UN MODELLO DINAMICO ERA PER FARE UNA VERSIONE
		begin
			insert into CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
				select  @newId as  idHeader, CM.DSE_ID, MOD_Name
					from 
						CTL_DOC_SECTION_MODEL CM with(nolock)
							inner join LIB_DocumentSections with(nolock) on DSE_DOC_ID=@TipoDoc and DSE_Param like '%DYNAMIC_MODEL=yes%'						
						where IdHeader = @idDoc and CM.DSE_ID=LIB_DocumentSections.DSE_ID

		end



		

		exec DGUE_COPY_FROM_DOC @idDoc, @idpfu, @newId

		--------------------FINE COPIA DGUE-----------------------------------------------------------------
		


		declare @Stored as varchar(200)
		set @Stored='ISTANZA_COPY_FROM_'+@TipoDoc
		IF  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE='PROCEDURE' AND ROUTINE_NAME=@Stored ) 
		BEGIN
			Exec @Stored @newId ,@idDoc,-20
		END

		---Chiamo la stored che mi fa sostituire le informazioni dell'utente con i dati dell'utente collegato
		---spostata perchè nella stored specifica venivano recuperari i campi dalla dm attributi
		IF @idPfu > 0 
		BEGIN
			Exec UPDATE_DATI_UTENTE_COLLEGATO_ISTANZA @newId , @idPfu
		END	

		
		delete from CTL_DOC_Value where idheader = @newId and DSE_ID = 'SCADENZA_ISTANZA' and DZT_Name = 'DataScadenzaIstanza'
	
		--aggiorno il RuoloRapLeg per l'utente che sta facendo l'istanza
		delete from CTL_DOC_Value where idheader = @newId and DSE_ID = 'TESTATA' and DZT_Name = 'RuoloRapLeg'
	
		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
			select @newId as IdHeader, 'TESTATA', 0 , 'RuoloRapLeg' , pfuRuoloAziendale
				from ProfiliUtente with(nolock)
					where idpfu=@idpfu


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

		--Enrico a cosa serve?
		select  db.TipoBando  ,d1.id 
				from ctl_doc d1 with(nolock)
						inner join Document_Bando db with(nolock) on d1.LinkedDoc = DB.idheader
				where D1.ID = @newId



	END -- fine IF di test sull'errore
	ELSE
	BEGIN

		select 'Errore' as id , @Errore as Errore

	END

end









































GO
