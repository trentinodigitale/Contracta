USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_E_FORMS_CN16_DATI_ENTE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD2_E_FORMS_CN16_DATI_ENTE] ( @idProc int , @idUser int = 0, @extraParams nvarchar(4000) = '' )
AS
BEGIN

	SET NOCOUNT ON

	-- MANTENERE LE COLONNE DI OUTPUT DI QUESTA SELECT ALLINEATE CON QUELLE DELLA STORED E_FORMS_CAN29_OE_PARTECIPANTI. ENTRAMBE PRODUCONO ORGANIZATIONS

	-----------------------------
	-- DICHIARAZIONE VARIBILI ---
	-----------------------------

	declare @idAziEnte INT

	--* ID — Acquirente (OPT-300-Procedure-Buyer)
	--* Numero di registrazione (BT-501-Organization-Company) 
	--		Codice fiscale dell'ente
	declare @cfEnte varchar(100)

	--* Nome ufficiale (BT-500-Organization-Company). max 400 caratteri.
	--		Ragione sociale dell'ente
	declare @ragSocEnte nvarchar(400)

	--* Località (BT-513-Organization-Company)
	--		Sede legale ente
	declare @sedeLegaleEnte nvarchar(400)

	--* Paese (BT-514-Organization-Company) - default ITA
	declare @statoEnte varchar(100) = 'ITA'

	--* Telefono (BT-503-Organization-Company)
	declare @telefonoEnte varchar(100)

	--* E-mail (BT-506-Organization-Company)
	declare @emailEnte varchar(500)

	--* BT-512 - Codice postale
	declare @postalCode varchar(500)

	--* Forma giuridica del committente (BT-11-Procedure-Buyer)
	--	va sul nostro campo 'TIPO_AMM_ER' - vedi MappingBT-11 
	--	UTILIZZARE RELAZIONE EFORMS_TIPO_AMM_ER_TO_BT11_E_BT10
	declare @formaGiuridicaEnte varchar(500)
	declare @tipoAmm varchar(100)

	--* Attività dell'amministrazione aggiudicatrice (BT-10-Procedure-Buyer) 
	--	va sempre su 'TIPO_AMM_ER' - vedi MappingBT-10 e sulla relazione EFORMS_TIPO_AMM_ER_TO_BT11_E_BT10
	declare @attivitaAmmEnte varchar(500)
	
	declare @telefax varchar(500) = ''
	declare @aziSitoWeb nvarchar(1000) = ''

	declare @orgID varchar(100) = 'ORG-0001'
	declare @orgRicorsoID varchar(100) = 'ORG-0002'
	declare @orgANAC varchar(100) = 'ORG-0003'

	declare @cfRUP varchar(100) = NULL --BT 502
	declare @idPfuRUP varchar(10) = ''
	declare @tipoDoc varchar(100) = ''
	declare @nominativoRUP nvarchar(1000) = NULL --BT 502

	declare @aziLocalitaLeg2 varchar(100) = ''
	declare @codiceNUTS varchar(100) = ''

	-- dati organismo di ricorso
	DECLARE @cn16_OrgRicorso_Name NVARCHAR(2000) = null
	DECLARE @cn16_OrgRicorso_CompanyID varchar(100) = null
	DECLARE @cn16_OrgRicorso_CityName nvarchar(1000) = null
	DECLARE @cn16_OrgRicorso_countryCode varchar(10) = null
	DECLARE @cn16_OrgRicorso_ElectronicMail nvarchar(1000) = null
	DECLARE @cn16_OrgRicorso_Telephone varchar(200) = null
	DECLARE @cn16_OrgRicorso_CAP varchar(100) = null
	DECLARE @cn16_OrgRicorso_NUTS varchar(100) = null

	--FIX URGENTE : PER EVTIARE DI CREARE PROBLEMI NELLE STORED SUCCESSIVE A CAUSA DI INCONGRUENZE DI DATI PREGRESSI, RIPRENDO LE ORGANIZZAZIONI CANCELLANDO LE PRECEDENTI ( INSERITE PER ES.DAL CN16 )
	delete from Document_E_FORM_ORGANIZATION where idHeader = @idProc and recordType in ( 'ente', 'ricorso' )

	select  @idAziEnte = azienda,
			@tipoDoc = TipoDoc
		from ctl_doc gara with(nolock) 
		where id = @idProc

	--------------------
	-- RECUPERO DATI ---
	--------------------
	IF @extraParams like '%GET_ORG=YES%'
		-- VISTA LA DELETE PRECEDENTE QUESTE SELECT NON SERVONO PIU', NON ENTREREMO MAI NEL BLOCCO IF, VERIFICARE E TOGLIERE
		AND EXISTS ( select idRow from Document_E_FORM_ORGANIZATION with(nolock) where idHeader = @idProc and recordType = 'ente' )
		AND EXISTS ( select idRow from Document_E_FORM_ORGANIZATION with(nolock) where idHeader = @idProc and recordType = 'ricorso' )
	BEGIN

		-- Se proveniamo da un giro di GET ( qualsiasi giro successivo al Contrac Notice - cn16 )
		--		invece di recuperare i dati da zero per poi salvarli, li recuperiamo già dalla tabella Document_E_FORM_ORGANIZATION.
		--		questa lettura "ex novo" avviene anche in assenza di record sulla Document_E_FORM_ORGANIZATION

		select  @orgID = a.PartyIdentification,
				@cfEnte = a.fiscalNumber,
				@ragSocEnte = a.PartyName,
				@sedeLegaleEnte = a.CityName,
				@telefonoEnte = a.Telephone,
				@emailEnte = a.ElectronicMail,
				@statoEnte = a.Country,
				@formaGiuridicaEnte = a.formaGiuridica,
				@attivitaAmmEnte = a.attivitaAmm,
				@telefax = a.telefax,
				@postalCode = a.postalCode,
				@aziSitoWeb = a.BuyerProfileURI,
				@cfRUP = a.ContactName
			from Document_E_FORM_ORGANIZATION a with(nolock) 
			where idHeader = @idProc and recordType = 'ente' 

		select  @orgRicorsoID = a.PartyIdentification,
				@cn16_OrgRicorso_CompanyID = a.fiscalNumber,
				@cn16_OrgRicorso_Name = a.PartyName,
				@cn16_OrgRicorso_CityName = a.CityName,
				@cn16_OrgRicorso_Telephone = a.Telephone,
				@cn16_OrgRicorso_ElectronicMail = a.ElectronicMail,
				@cn16_OrgRicorso_countryCode = a.Country,
				@cn16_OrgRicorso_CAP = a.postalCode
			from Document_E_FORM_ORGANIZATION a with(nolock) 
			where idHeader = @idProc and recordType = 'ricorso' 

	END
	ELSE
	BEGIN

		select @cfEnte = vatValore_FT from DM_Attributi with(nolock) where dztnome = 'codicefiscale' and lnk = @idAziEnte

		select @idPfuRUP = [Value] from ctl_doc_value with(nolock) where idheader = @idProc and dse_id = 'InfoTec_comune' and dzt_name = 'UserRUP' 
		
		IF ISNULL(@idPfuRUP,'') <> '' and ISNUMERIC(@idPfuRUP) = 1
		BEGIN

			select  @cfRUP = pfuCodiceFiscale, 
					@nominativoRUP = pfuNome
				from profiliutente a with(nolock) 
				where a.IdPfu = cast(@idPfuRUP as int)

		END

		select  @ragSocEnte = left(aziRagioneSociale,400), 
				@sedeLegaleEnte = left(aziLocalitaLeg,400),
				@telefonoEnte = aziTelefono1,
				@emailEnte = aziE_Mail,
				@telefax = aziFAX,
				@postalCode = aziCAPLeg,
				@aziSitoWeb = aziSitoWeb,
				@aziLocalitaLeg2 = aziLocalitaLeg2
			from aziende with(nolock) 
			where idazi = @idAziEnte

		set @codiceNUTS = dbo.GetColumnValue( @aziLocalitaLeg2,'-', 7)	-- prendiamo il nuts della provincia 

		--default su roma. non dovrebbe succedere mai
		if isnull(@codiceNUTS,'') = ''
			set @codiceNUTS = 'ITI43'

		select @tipoAmm = vatValore_FT from DM_Attributi with(nolock) where dztnome = 'TIPO_AMM_ER' and lnk = @idAziEnte and idApp = 1

		set @formaGiuridicaEnte = 'body-pl' -- default ? confrontarsi. non dovrebbe mai mancare un match di transcodifica
		set @attivitaAmmEnte = 'gen-pub' -- default ? confrontarsi. non dovrebbe mai mancare un match di transcodifica

		select REL_ValueOutput into #codici_bt10_bt11 from CTL_Relations a with(nolock) where a.REL_Type = 'EFORMS_TIPO_AMM_ER_TO_BT11_E_BT10' and REL_ValueInput = @tipoAmm

		IF EXISTS ( select * from #codici_bt10_bt11 )
		BEGIN

			-- transcodifica di TIPO_AMM_ER con un valore presente nella tipologica buyer-legal-type.gc
			select @formaGiuridicaEnte = dbo.GetPos(REL_ValueOutput, '@@@', 1) from #codici_bt10_bt11 

			-- transcodifica di TIPO_AMM_ER con un valore presente nella tipologica main-activity.html
			select @attivitaAmmEnte = dbo.GetPos(REL_ValueOutput, '@@@', 2) from #codici_bt10_bt11

		END

		drop table #codici_bt10_bt11

		--RECUPERO DATI DELL'ORGANISMO DI RICORSO DALLA GARA
		select @cn16_OrgRicorso_CityName = cn16_OrgRicorso_CityName,
				@cn16_OrgRicorso_CompanyID = cn16_OrgRicorso_CompanyID,
				@cn16_OrgRicorso_countryCode = cn16_OrgRicorso_countryCode,
				@cn16_OrgRicorso_ElectronicMail = cn16_OrgRicorso_ElectronicMail,
				@cn16_OrgRicorso_Name = cn16_OrgRicorso_Name,
				@cn16_OrgRicorso_Telephone = cn16_OrgRicorso_Telephone,
				@cn16_OrgRicorso_CAP = cn16_OrgRicorso_CAP,
				@cn16_OrgRicorso_NUTS = cn16_OrgRicorso_codnuts
			from Document_E_FORM_CONTRACT_NOTICE a with(nolock)
			where idheader = @idProc

		--nota : andrebbe aggiunto anche il codice nuts sulla tabella Document_E_FORM_ORGANIZATION, ma per ora non serve recuperarlo altrove

		-- dopo aver recupero tutti i dati dell'organizzazione li staticizziamo sulla tabelle delle organizzazioni, collegandole alla gara.
		--		aggiungere qui il recupero dei dati dell'organismo di ricorso salvarli sulla stessa tabella ma con un record tye differente, così da poterlo
		--		recuperare più avanti in modo puntuale

		IF NOT EXISTS ( select idRow from Document_E_FORM_ORGANIZATION with(nolock) where idHeader = @idProc and recordType = 'ente' and PartyIdentification = @cfEnte  )
		BEGIN

			INSERT INTO Document_E_FORM_ORGANIZATION (idHeader, idAzi, recordType, PartyIdentification,fiscalNumber,PartyName,CityName,Telephone,ElectronicMail,Country,formaGiuridica,attivitaAmm,telefax, postalCode, BuyerProfileURI, ContactName )
											values ( @idProc, @idAziEnte, 'ente', @orgID, @cfEnte, @ragSocEnte, @sedeLegaleEnte, @telefonoEnte, @emailEnte, @statoEnte, @formaGiuridicaEnte, @attivitaAmmEnte, @telefax, @postalCode, @aziSitoWeb, @cfRUP )

		END

		IF NOT EXISTS ( select idRow from Document_E_FORM_ORGANIZATION with(nolock) where idHeader = @idProc and recordType = 'ricorso' and PartyIdentification = @cn16_OrgRicorso_CompanyID  )
		BEGIN

			INSERT INTO Document_E_FORM_ORGANIZATION (idHeader, idAzi, recordType, PartyIdentification,fiscalNumber,PartyName,CityName,Telephone,ElectronicMail,
											Country,ContactName, postalCode )
										values ( @idProc, @idAziEnte, 'ricorso', @orgRicorsoID, @cn16_OrgRicorso_CompanyID, @cn16_OrgRicorso_Name, @cn16_OrgRicorso_CityName, @cn16_OrgRicorso_Telephone, @cn16_OrgRicorso_ElectronicMail, 
											@cn16_OrgRicorso_countryCode, @cn16_OrgRicorso_Name, @cn16_OrgRicorso_CAP )

		END

	END

	declare @vbcrlf varchar(10) = '
'

	-------------
	-- OUTPUT ---
	-------------
	-- MANTENERE LE COLONNE DI OUTPUT DI QUESTA SELECT ALLINEATE CON QUELLE DELLA STORED E_FORMS_CAN29_OE_PARTECIPANTI. ENTRAMBE PRODUCONO ORGANIZATIONS

	select  --@cfEnte as ENTE_ID, --OPT-300-Procedure-Buyer
			@orgID as ENTE_ID, --OPT-300-Procedure-Buyer
			@cfEnte as ENTE_NUMERO_REG, --BT-501-Organization-Company
			isnull(@ragSocEnte,'') AS ENTE_RAG_SOC , --BT-500-Organization-Company
			isnull(@sedeLegaleEnte,'') AS ENTE_LOCAL, --BT-513-Organization-Company
			isnull(@telefonoEnte,'') AS ENTE_TEL, --BT-503-Organization-Company
			isnull(@emailEnte,'') AS ENTE_EMAIL, --BT-506-Organization-Company
			isnull(@statoEnte,'') AS ENTE_PAESE, --BT-514-Organization-Company

			isnull(@formaGiuridicaEnte,'') as ENTE_FORM_GIUR, --BT-11-Procedure-Buyer
			isnull(@attivitaAmmEnte,'') as ENTE_ATT_AMM, --BT-10-Procedure-Buyer

			coalesce(@nominativoRUP,@cfRUP,@ragSocEnte) as ENTE_CONTACT_NAME, --BT-502

			case when @telefax <> '' then '<!-- BT-739 - Fax -->' + @vbcrlf + '<cbc:Telefax>' + dbo.HTML_Encode(@telefax) + '</cbc:Telefax>' else '' end AS ENTE_NO_ENCODE_FAX,
			
			case when @postalCode <> '' then '
					<!-- BT-512 - Codice Postale -->
					<cbc:PostalZone>' + dbo.HTML_Encode(@postalCode) + '</cbc:PostalZone>
					<!-- BT-507 - NUTS -->
				    <cbc:CountrySubentityCode listName="nuts">' + @codiceNUTS + '</cbc:CountrySubentityCode>' 
				else '' 
			end AS ENTE_NO_ENCODE_POSTAL_ZONE,

			case when @aziSitoWeb <> '' then '<!-- BT-508 - Buyer Profile URL -->' + @vbcrlf + '<cbc:BuyerProfileURI>' + LTRIM(RTRIM(LEFT(dbo.HTML_Encode(@aziSitoWeb),400))) + ' </cbc:BuyerProfileURI>' else '' end AS ENTE_NO_ENCODE_BUYERPROFILEURI,

			'' as OE_NO_ENCODE_WINNER,
			'' as OE_NO_ENCODE_WINNER_SIZE,
			case when @tipoDoc = 'BANDO_SEMPLIFICATO' then '<efbc:AwardingCPBIndicator>true</efbc:AwardingCPBIndicator>' else '' end AS ENTE_NO_ENCODE_AWARDINGCPBINDICATOR

	UNION --dati dell'organismo di ricorso

	select  @orgRicorsoID as ENTE_ID,
			@cn16_OrgRicorso_CompanyID as ENTE_NUMERO_REG,
			isnull(@cn16_OrgRicorso_Name,'') AS ENTE_RAG_SOC ,
			isnull(@cn16_OrgRicorso_CityName,'') AS ENTE_LOCAL,
			isnull(@cn16_OrgRicorso_Telephone,'') AS ENTE_TEL,
			isnull(@cn16_OrgRicorso_ElectronicMail,'') AS ENTE_EMAIL,
			isnull(@cn16_OrgRicorso_countryCode,'') AS ENTE_PAESE, 

			'' as ENTE_FORM_GIUR,
			'' as ENTE_ATT_AMM, 

			isnull(@cn16_OrgRicorso_Name,'') as ENTE_CONTACT_NAME, 

			'' AS ENTE_NO_ENCODE_FAX,

			case when @cn16_OrgRicorso_CAP <> '' then '
					<!-- BT-512 - Codice Postale -->
					<cbc:PostalZone>' + dbo.HTML_Encode(@cn16_OrgRicorso_CAP) + '</cbc:PostalZone>
					<!-- BT-507 - NUTS -->
				    <cbc:CountrySubentityCode listName="nuts">' + @cn16_OrgRicorso_NUTS + '</cbc:CountrySubentityCode>' 
				 else '' 
			end AS ENTE_NO_ENCODE_POSTAL_ZONE,

			'' AS ENTE_NO_ENCODE_BUYERPROFILEURI,
			'' as OE_NO_ENCODE_WINNER,
			'' as OE_NO_ENCODE_WINNER_SIZE,
			'' AS ENTE_NO_ENCODE_AWARDINGCPBINDICATOR

	UNION --dati anac

	select  @orgANAC as ENTE_ID,
			'97584460584' as ENTE_NUMERO_REG,
			'ANAC AUTORITA NAZIONALE ANTICORRUZIONE' AS ENTE_RAG_SOC ,
			'Roma' AS ENTE_LOCAL,
			--'0636723781' AS ENTE_TEL,
			'06367231' AS ENTE_TEL,
			'protocollo@pec.anticorruzione.it' AS ENTE_EMAIL,
			'ITA' AS ENTE_PAESE, 
			'' as ENTE_FORM_GIUR,
			'' as ENTE_ATT_AMM, 
			'ANAC AUTORITA NAZIONALE ANTICORRUZIONE' as ENTE_CONTACT_NAME, 
			'' AS ENTE_NO_ENCODE_FAX,
			'' AS ENTE_NO_ENCODE_POSTAL_ZONE,
			'' AS ENTE_NO_ENCODE_BUYERPROFILEURI,
			'' as OE_NO_ENCODE_WINNER,
			'' as OE_NO_ENCODE_WINNER_SIZE,
			'' AS ENTE_NO_ENCODE_AWARDINGCPBINDICATOR

END
GO
