USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_MODIFICA_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE  PROCEDURE [dbo].[BANDO_MODIFICA_CREATE_FROM_BANDO] 
	( @idDoc int , @IdUser int , @forzaCopia int = 0, @idOUT int = 0 out)
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @Role varchar(50)
	declare @Errore as nvarchar(2000)
	declare @IdPfu as INT

	set @Id=0
	set @Errore = ''

	IF @forzaCopia = 0
	BEGIN
	-- controllo se esiste una modifica in corso
		select @Id=id from CTL_DOC where linkedDoc = @idDoc and Tipodoc='BANDO_MODIFICA' and StatoFunzionale IN ( 'InLavorazione', 'InAttesaTed' )  and deleted=0
	END

	if ( @id IS NULL or @id=0 )
	begin 

		-- controlla che l'utente è un riferimento valido per creare la modifica
		if not exists( select * from Document_Bando_Riferimenti  where idHeader = @idDoc and idpfu=@Iduser ) 
			and not exists( select * from Document_Bando_Commissione  where idHeader = @idDoc and idpfu=@Iduser )
			and  not exists( select * from ctl_doc where id = @idDoc and idpfu=@Iduser )
			and  not exists( select userrup from CTL_DOC_VIEW where id = @idDoc and userrup =@Iduser )
			--QUANDO NON RDO UTENTE URP può creare il documento
			--and not exists ( select idpfu from  ProfiliUtente P where P.IdPfu=@idUser  and SUBSTRING(P.pfuFunzionalita,150,1) = '1' and 'RDO'<>(Select TipoProceduraCaratteristica from Document_Bando where idheader=@idDoc))
			and not ( 
					exists ( select idpfu from  ProfiliUtente P where P.IdPfu=@idUser  and SUBSTRING(P.pfuFunzionalita,150,1) = '1'   )
					and
					exists ( Select TipoProceduraCaratteristica from Document_Bando where idheader=@idDoc and isnull( TipoProceduraCaratteristica ,'')  <> 'RDO' )
				) and @forzaCopia=0
			
			and not exists ( select idpfu from  ProfiliUtente P where P.IdPfu=@idUser  and SUBSTRING(P.pfuFunzionalita,465,1) = '1'   )


		begin
		
			set @Errore = 'La modifica del bando e'' consentita soltanto agli utenti abilitati'
		
		end
		else
		begin

		
			Insert into CTL_DOC (idpfu,Titolo,idPfuInCharge,tipodoc,Body,LinkedDoc,ProtocolloRiferimento,VersioneLinkedDoc,Note,azienda)
				Select  @IdUser as idpfu ,'Modifica Bando',@IdUser as idPfuInCharge ,'BANDO_MODIFICA',Body,@idDoc  as LinkedDoc,Protocollo,
				case 
					when isnull(jumpcheck,'')='BANDO_ALBO_LAVORI' then 'BANDO_ALBO_LAVORI'
					else tipodoc
				end
				,Note,azienda	
				from CTL_DOC where id=@idDoc and deleted=0

				set @id = SCOPE_IDENTITY()  --@@IDENTITY	

			--inserisco la cronologia
			set @Role = null
		
			select top 1 @Role = attvalue 
				from profiliutenteattrib 
				where idpfu = @IdUser and dztnome = 'UserRoleDefault'

			insert into CTL_ApprovalSteps ( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
				values( 'BANDO_MODIFICA' , @id  , 'Compiled' , '', @IdUser     , @Role       , 1         , getdate() )
		
			--travaso sul documento di modifica gli utenti della commissione
			insert into document_bando_commissione (idheader,Idpfu,RuoloCommissione)
				select @id,Idpfu,RuoloCommissione
					from document_bando_commissione
					where idheader=@idDoc

			--travaso sul documento di modifica gli utenti dei riferimenti
			insert into document_bando_riferimenti (idheader,Idpfu,RuoloRiferimenti)
				select @id,Idpfu,RuoloRiferimenti
					from document_bando_riferimenti
					where idheader=@idDoc

			--travaso sul documento di modifica le nuove sezioni per il tab 'Informazioni tecniche'
			insert into ctl_doc_value( IdHeader, DSE_ID, DZT_Name,Row, Value)
				select @id, dse_id, DZT_Name,row,value 
					from ctl_doc_value 
					where IdHeader = @idDoc and DSE_ID in ( 'InfoTec_comune', 'InfoTec_3comune', 'InfoTec_DatePub','InfoTec_2DatePub','InfoTec_3DatePub','InfoTec_2comune' )

			 ---valorizzo la sezione OGGETTO con l'oggetto del bando
			 insert into ctl_doc_value( IdHeader, DSE_ID, DZT_Name, Value)
				 select @id,'OGGETTO','Oggetto',body
					 from ctl_doc where id=@idDoc

			 ---valorizzo la sezione OGGETTO con titolo del bando
			 insert into ctl_doc_value( IdHeader, DSE_ID, DZT_Name, Value)
				 select @id,'OGGETTO','Titolo',titolo
					 from ctl_doc where id=@idDoc

			 insert into ctl_doc_value( IdHeader, DSE_ID, DZT_Name, Value)
				 select @id,'TITOLO','Titolo_OLD',titolo
					 from ctl_doc where id=@idDoc


			  ---valorizzo la sezione TESTATA 
			 insert into ctl_doc_value( IdHeader, DSE_ID, DZT_Name, Value)
				select @id,'TESTATA','TipoSedutaGara',TipoSedutaGara
					from Document_Bando where idHeader=@idDoc
			
			insert into ctl_doc_value( IdHeader, DSE_ID, DZT_Name, Value)
				select @id,'TESTATA','OLD_TipoSedutaGara',TipoSedutaGara
					from Document_Bando where idHeader=@idDoc

			insert into ctl_doc_value( IdHeader, DSE_ID, DZT_Name, Value)
				select @id,'TESTATA','Scelta_Seduta_Virtuale',case when TipoSedutaGara='virtuale' then 'si' else 'no' end
					from Document_Bando where idHeader=@idDoc

			 insert into ctl_doc_value( IdHeader, DSE_ID, DZT_Name, Value)
				select @id,'TESTATA','OLD_Scelta_Seduta_Virtuale',case when TipoSedutaGara='virtuale' then 'si' else 'no' end
					from Document_Bando where idHeader=@idDoc


			  ---valorizzo la sezione TESTA_ME_SDA  
			 insert into ctl_doc_value( IdHeader, DSE_ID, DZT_Name, Value)
				select @id,'TESTA_ME_SDA','Riferimento_Gazzetta', Riferimento_Gazzetta
					from Document_Bando where idHeader=@idDoc
			
			insert into ctl_doc_value( IdHeader, DSE_ID, DZT_Name, Value)
				select @id,'TESTA_ME_SDA','OLD_NumeroBando', Riferimento_Gazzetta
					from Document_Bando where idHeader=@idDoc


			 insert into ctl_doc_value( IdHeader, DSE_ID, DZT_Name, Value)
				select @id,'TESTA_ME_SDA','Data_Pubblicazione_Gazzetta', convert(varchar(19),Data_Pubblicazione_Gazzetta,126)
					from Document_Bando where idHeader=@idDoc
			
			insert into ctl_doc_value( IdHeader, DSE_ID, DZT_Name, Value)
				select @id,'TESTA_ME_SDA','OLD_Data_Pubblicazione_Gazzetta', convert(varchar(19),Data_Pubblicazione_Gazzetta,126)
					from Document_Bando where idHeader=@idDoc



			 --Recupero gli atti di gara del Bando e li inserisco nella rettifica
				insert into Document_Atti_Rettifica ( idHeader , Allegato_OLD,Descrizione_OLD,EvidenzaPubblica_OLD,AnagDoc)
						select @id,Allegato,Descrizione,EvidenzaPubblica,AnagDoc
						from CTL_DOC_ALLEGATI
						where idHEader=@idDoc

			--travaso sul documento di modifica gli enti
			insert into ctl_doc_value( IdHeader, DSE_ID, DZT_Name,Row, Value)
				select distinct @id, dse_id, DZT_Name,row,value 
				from ctl_doc_value 
				where IdHeader = @idDoc and DSE_ID in ( 'ENTI' ) and DZT_Name='AZI_Ente'
			
			insert into ctl_doc_value( IdHeader, DSE_ID, DZT_Name,Row, Value)
			select @id,'ENTI','Not_Editable',Row,' AZI_Ente '
				from ctl_doc_value 
				where IdHeader = @id and DSE_ID in ( 'ENTI' ) and DZT_Name ='AZI_Ente'

			insert into ctl_doc_value( IdHeader, DSE_ID, DZT_Name,Row, Value)
				select @id,'ENTI','Eliminato',Row,''
					from ctl_doc_value 
					where IdHeader = @id and DSE_ID in ( 'ENTI' ) and DZT_Name ='AZI_Ente'
			
			-- Insert sulla sezione InfoTec_DefinizionePremi_griglia

			INSERT INTO [dbo].[CTL_DOC_Value]
			   ([IdHeader],[DSE_ID],[Row],[DZT_Name],[Value])

				select @id as [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] 
				from CTL_DOC_Value 
				where [IdHeader] = @idDoc and DSE_ID = 'InfoTec_DefinizionePremi_griglia'

		end
		--PER BANDO_SDA e BANDO riporto la documentazione presente sul bando
		IF EXISTS (select * from CTL_DOC where Id=@idDoc and TipoDoc in ('BANDO','BANDO_SDA'))
		BEGIN
			-- travaso gli allegati richiesti nella controparte di rettifica per permetterne la modifica
			insert into Document_Bando_DocumentazioneRichiesta ([idHeader], [TipoInterventoDocumentazione], [LineaDocumentazione], [DescrizioneRichiesta], [AllegatoRichiesto], [Obbligatorio], [TipoFile], [AnagDoc], [NotEditable], [RichiediFirma])
				select @id,TipoInterventoDocumentazione, LineaDocumentazione, DescrizioneRichiesta, AllegatoRichiesto, Obbligatorio, TipoFile, AnagDoc, NotEditable, RichiediFirma 
					from Document_Bando_DocumentazioneRichiesta with(nolock)
						where idHEader=@idDoc

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



	end

   

	-- verifico se esiste un documento collegato di tipo diverso dalla conferma per segnalare un errore
	

	IF @forzaCopia = 0
	BEGIN
		if @Errore = ''
		begin
			-- rirorna l'id della Commissione
			select @Id as id
	
		end
		else
		begin
			-- rirorna l'errore
			select 'Errore' as id , @Errore as Errore
		end
	END
	ELSE
		SET @idOUT = @id
	
	
	
END
























GO
