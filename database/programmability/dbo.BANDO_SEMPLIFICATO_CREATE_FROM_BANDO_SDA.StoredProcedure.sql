USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[BANDO_SEMPLIFICATO_CREATE_FROM_BANDO_SDA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE PROCEDURE [dbo].[BANDO_SEMPLIFICATO_CREATE_FROM_BANDO_SDA] ( @idRow int  , @idUser int )
AS
BEGIN
	
	declare @IdDoc as int
	declare @id int
	declare @GG_OffIndicativa as int
	declare @Azienda as int

	declare @idx int
	declare @Modello varchar(500)
	declare @CodiceModello varchar(500)
	declare @MOD_BandoSempl varchar(500)
	declare @Errore as nvarchar(2000)
	declare @Azi_Abilitata_RCig as int
	declare @Lista_Enti_abilitati_RCig as varchar (4000)
	declare @TipoSceltaContraente as varchar(100)
	declare @IdaziMaster as int

	set @TipoSceltaContraente = ''

	set @Azi_Abilitata_RCig = 1

	set @Errore = ''

	set @Id = 0

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--recupero id del bando_sda e id azienda
	select @IdDoc=IdHeader,@Azienda=value from CTL_DOC_Value with (nolock) where idrow=@idRow

	-- cerca una versione precedente del documento
	select @Id = id from CTL_DOC  with (nolock) where LinkedDoc = @IdDoc and TipoDoc = 'BANDO_SEMPLIFICATO' and deleted = 0 and StatoDoc = 'Saved' and idpfu=@idUser
	
	-- cerca utenti di riferimento
	IF NOT EXISTS (Select * from ELENCO_RESPONSABILI where idpfu =  @idUser and RUOLO in ('RUP_PDG'))
	BEGIN
		set @Errore='Per poter attivare la funzione e necessaria la presenza di un utente di riferimento responsabile a cui inviare il documento in approvazione'
	END

	-- se non viene trovato allora si crea il nuovo documento
	--if isnull(@Id , 0 ) = 0 
	if @Errore=''
	begin

		declare @identifIniziativa varchar(500)

		set @identifIniziativa = NULL

		-- se l'utente che sta creando la convenzione non è dell'agenzia
		if not exists ( select idpfu from profiliutente with(Nolock) where idpfu = @IdUser and pfuIdAzi = 35152001 )
		begin

			set @identifIniziativa = '9999'

		end
		
		-- genero la testata del documento
		insert into CTL_DOC (   IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda, StrutturaAziendale, 
								ProtocolloRiferimento,  Fascicolo, LinkedDoc, StatoFunzionale, Versione )
			
			select  @idUser as IdPfu ,  'BANDO_SEMPLIFICATO' , 'Saved' , 'Senza Titolo' ,'' /* kpf 429468 d.Body*/ , @Azienda , 
					cast( P.pfuidazi as varchar) + '#' + '\0000\0000' as StrutturaAziendale 
					, d.Protocollo  ,  '' as Fascicolo  ,  Id  ,'InLavorazione' /*'NEW_SEMPLIFICATO'*/
					, '2'
				from CTL_DOC d with(nolock)
						inner join document_Bando b with(nolock) on d.id = b.idheader
						inner join ProfiliUtente P with(nolock) on P.IdPfu=@idUser
				where Id = @IdDoc

		set @Id = SCOPE_IDENTITY()
		

		--recupero GG_OffIndicativa  @GG_OffIndicativa
		set @GG_OffIndicativa=null
		select @GG_OffIndicativa=NumGiorniPresentazioneDomande 
			from Document_Parametri_SDA with(nolock)
				where deleted = 0
						and isnull( DataInizio , getdate())<= getdate ()
						and  isnull( DataFine  , getdate()) >= getdate()
						and idheader = @IdDoc

		--se azienda corrente non è tra gli enti abilitati setto @richiestaCIG a no
		select  @Lista_Enti_abilitati_RCig= dbo.PARAMETRI('GROUP_SIMOG','ENTI_ABILITATI','DefaultValue','',-1)
		if @Lista_Enti_abilitati_RCig <> '' and CHARINDEX (',' + cast(@Azienda as varchar(20)) + ',', ',' + @Lista_Enti_abilitati_RCig + ',') = 0
			set @Azi_Abilitata_RCig = 0				

		---- inserico i dati base del bando
		insert into Document_Bando ( idHeader, TipoBando,ProceduraGara, TipoBandoGara , TipoAppaltoGara, GG_OffIndicativa ,EvidenzaPubblica, IdentificativoIniziativa , Divisione_lotti, RichiestaCigSimog,EnteProponente,RupProponente)
			select  @Id    ,  '' /*TipoBando*/,ProceduraGara, 3,TipoAppaltoGara, @GG_OffIndicativa,'0',@identifIniziativa , 2 as Divisione_lotti, 
				case 
					when dbo.attivoSimog() = '1' and @Azi_Abilitata_RCig = 1  and dbo.attivoPCP() <> 1 then 'si'
					else 'no'
				end ,
				cast(@Azienda as varchar(50))+ '#\0000\0000',''
				from document_bando f with(nolock)
					where f.idHeader = @IdDoc
		

		

		-- inserisoc il record nella document_protocollo
		insert into Document_dati_protocollo ( idHeader)
			values (  @Id )
		
		--popolo la testata dei prodotti
		insert into ctl_doc_value (IdHeader, DSE_ID, Row, DZT_Name, Value	)
			select 	@Id, DSE_ID, Row, DZT_Name, Value	
			from ctl_doc_value with(nolock)
			where idheader=@IdDoc and DSE_ID = 'TESTATA_PRODOTTI'
		
		--aggiorno il value di allegatorichiesto della sezione
		update ctl_doc_value 
				set value=(select value from ctl_doc_value with(nolock) where idheader=@IdDoc and dzt_name='Allegato')
			where idheader=@Id and dzt_name='AllegatoRichiesto'
		

		--AGGIUNGO LA GESTIONE PER LA PCP

		IF exists (SELECT * FROM sys.objects  WHERE name='Document_E_FORM_PAYLOADS' and type='U' )
		BEGIN	

   			-- attività 544634 - nuova tabella sotto la sezione caption per l'interoperabilità/e-forms
			IF NOT EXISTS(select a.idRow from Document_E_FORM_CONTRACT_NOTICE a with(nolock) where a.idheader = @Id )
			BEGIN
			
				DECLARE @urlAtti nvarchar(1000) = ''

				SELECT @urlAtti = a.DZT_ValueDef from LIB_Dictionary a with(nolock) where DZT_Name = 'SYS_TED_DOCUMENTI_GARA'

				INSERT INTO Document_E_FORM_CONTRACT_NOTICE ( idHeader, cn16_CallForTendersDocumentReference_ExternalRef)
					VALUES (  @Id, @urlAtti )

				----questa sys sarà vuota come default e verrà specializzata per cliente
				--if dbo.PARAMETRI('BANDO_GARA','URL_BT15','ATTIVO','NO','-1') = 'YES'
				--begin
				--	--nuova gestione 
				--	--Indirizzo documenti di gara - prepopolare il campo con il dettaglio del bando
				--	set @urlAtti = dbo.GetUrlDettagliBandoByID(@Id)

				--	INSERT INTO Document_E_FORM_CONTRACT_NOTICE ( idHeader, cn16_CallForTendersDocumentReference_ExternalRef)
				--	VALUES (  @Id, @urlAtti )
				--end
				--else
				--begin
				--	SELECT @urlAtti = a.DZT_ValueDef from LIB_Dictionary a with(nolock) where DZT_Name = 'SYS_TED_DOCUMENTI_GARA'

				--	INSERT INTO Document_E_FORM_CONTRACT_NOTICE ( idHeader, cn16_CallForTendersDocumentReference_ExternalRef)
				--	VALUES (  @Id, @urlAtti )
				--end				

				--generazione uid dopo l'insert 
				DECLARE @CONTRACT_FOLDER_ID nvarchar(500) = ''
				SET @CONTRACT_FOLDER_ID = lower(newid())

				update Document_E_FORM_CONTRACT_NOTICE
						set CN16_CODICE_APPALTO = @CONTRACT_FOLDER_ID
							, cn16_ContractingSystemTypeCode_framework = case when ISNULL(@TipoSceltaContraente,'') = 'ACCORDOQUADRO' then 'true' else 'false' end
					where idHeader = @Id

				--retrocompatibile per installare questa stored anche senza la tabella Document_Organismo_Ricorso
				IF exists (SELECT * FROM sys.objects  WHERE name='Document_Organismo_Ricorso' and type='U' )
				BEGIN	

					------------------------------------
					-- GESTIONE ORGANISMO DI RICORSO  --
					------------------------------------
					-- 1. Cerco i dati dell'org di ricorso per l'ente che ha creato la gara
					-- 2. In assenza dei dati specifici dell'ente passo a cercarli per l'aziMaster
					-- 3. In assenza anche di questi lasciamo i campi vuoti così da farli imputare tutti all'utente

					DECLARE @cn16_OrgRicorso_Name NVARCHAR(2000) = null
					DECLARE @cn16_OrgRicorso_CompanyID varchar(100) = null
					DECLARE @cn16_OrgRicorso_CityName nvarchar(1000) = null
					DECLARE @cn16_OrgRicorso_countryCode varchar(10) = null
					DECLARE @cn16_OrgRicorso_ElectronicMail nvarchar(1000) = null
					DECLARE @cn16_OrgRicorso_Telephone varchar(200) = null
					DECLARE @cn16_OrgRicorso_NUTS varchar(200) = null
					DECLARE @cn16_OrgRicorso_CAP varchar(200) = null

					SELECT  @cn16_OrgRicorso_Name = [Name],
							@cn16_OrgRicorso_CompanyID = CompanyID,
							@cn16_OrgRicorso_CityName = CityName,
							@cn16_OrgRicorso_countryCode = countryCode,
							@cn16_OrgRicorso_ElectronicMail = ElectronicMail,
							@cn16_OrgRicorso_Telephone = Telephone,
							@cn16_OrgRicorso_NUTS = codNuts,
							@cn16_OrgRicorso_CAP = postalCode
						FROM Document_Organismo_Ricorso WITH(NOLOCK)
						WHERE idazi = @Azienda and bDeleted = 0

					--se non c'è il record per l'idazi della gara provo con l'azimaster
					--DUBBBIO azimaster fisso o lo recupero dalla tabella  marketplace ?
					set @IdaziMaster = 35152001

					IF isnull(@cn16_OrgRicorso_CompanyID,'') = ''
					BEGIN

						SELECT  @cn16_OrgRicorso_Name = [Name],
								@cn16_OrgRicorso_CompanyID = CompanyID,
								@cn16_OrgRicorso_CityName = CityName,
								@cn16_OrgRicorso_countryCode = countryCode,
								@cn16_OrgRicorso_ElectronicMail = ElectronicMail,
								@cn16_OrgRicorso_Telephone = Telephone,
								@cn16_OrgRicorso_NUTS = codNuts,
								@cn16_OrgRicorso_CAP = postalCode
							FROM 
								Document_Organismo_Ricorso WITH(NOLOCK)
							WHERE 
								idazi = @IdaziMaster and bDeleted = 0

					END

					UPDATE Document_E_FORM_CONTRACT_NOTICE
							SET cn16_OrgRicorso_CityName = @cn16_OrgRicorso_CityName,
								cn16_OrgRicorso_CompanyID = @cn16_OrgRicorso_CompanyID,
								cn16_OrgRicorso_countryCode = @cn16_OrgRicorso_countryCode,
								cn16_OrgRicorso_ElectronicMail = @cn16_OrgRicorso_ElectronicMail,
								cn16_OrgRicorso_Name = @cn16_OrgRicorso_Name,
								cn16_OrgRicorso_Telephone = @cn16_OrgRicorso_Telephone,
								cn16_OrgRicorso_codnuts = @cn16_OrgRicorso_NUTS,
								cn16_OrgRicorso_cap = @cn16_OrgRicorso_CAP
						WHERE idHeader = @Id

				END --IF exists (SELECT * FROM sys.objects  WHERE name='Document_Organismo_Ricorso' and type='U' )

			END

		END


		--con quest IF rendiamo retrocompatibile la modifica. può essere installata questa stored anche senza la tabella Document_E_FORM_CONTRACT_NOTICE
		IF exists (SELECT * FROM sys.objects  WHERE name='Document_PCP_Appalto' and type='U' )
		BEGIN	

			IF NOT EXISTS(select a.idRow from Document_PCP_Appalto a with(nolock) where a.idheader = @Id )
			BEGIN
			
				--chiamo una SP che inizializza i campi della scheda PCP
				exec INIT_SCHEDA_PCP_GARA @Id, @idUser
			

			END

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
	

END













GO
