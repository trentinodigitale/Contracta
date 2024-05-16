USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[INIT_STRUTTURA_PCP_DOCUMENTO]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[INIT_STRUTTURA_PCP_DOCUMENTO]  ( @IdDoc int , @Idpfu int, @TipoDocSource as varchar(100) )
AS
BEGIN
	
	declare @TipoSceltaContraente as varchar(200)
	declare @idAziEnte INT = 0
	declare @IdaziMaster as int
	declare @idPfuAOO int

	set @TipoSceltaContraente = ''

	select  @TipoSceltaContraente = isnull(TipoSceltaContraente,'') , 
			@idAziEnte = azienda ,
			@idPfuAOO = IdPfu 
		from CTL_DOC with (nolock)
				left join document_bando  with (nolock)  on idHeader = id
		where id=@IdDoc

   	-- attività 544634 - nuova tabella sotto la sezione caption per l'interoperabilità/e-forms
	IF NOT EXISTS(select a.idRow from Document_E_FORM_CONTRACT_NOTICE a with(nolock) where a.idheader = @IdDoc )
	BEGIN
		
		DECLARE @urlAtti nvarchar(1000) = ''

		--questa sys sarà vuota come default e verrà specializzata per cliente
		SELECT @urlAtti = a.DZT_ValueDef from LIB_Dictionary a with(nolock) where DZT_Name = 'SYS_TED_DOCUMENTI_GARA'

		INSERT INTO Document_E_FORM_CONTRACT_NOTICE ( idHeader, cn16_CallForTendersDocumentReference_ExternalRef)
			VALUES (  @IdDoc, @urlAtti )

		--generazione uid dopo l'insert 
		DECLARE @CONTRACT_FOLDER_ID nvarchar(500) = ''
		SET @CONTRACT_FOLDER_ID = lower(newid())

		update Document_E_FORM_CONTRACT_NOTICE
				set CN16_CODICE_APPALTO = @CONTRACT_FOLDER_ID
					, cn16_ContractingSystemTypeCode_framework = case when ISNULL(@TipoSceltaContraente,'') = 'ACCORDOQUADRO' then 'true' else 'false' end
			where idHeader = @IdDoc

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
			WHERE idazi = @idAziEnte and bDeleted = 0

		--se non c'è il record per l'idazi della gara provo con l'azimaster
		--DUBBBIO azimaster fisso o lo recupero dalla tabella  marketplace ?
		set @IdaziMaster = 0
		select @IdaziMaster=isnull(mpIdAziMaster,0)  from MarketPlace where mpLog='PA'
		if @IdaziMaster=0 
		begin
			set @IdaziMaster = 35152001
		end

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
				FROM Document_Organismo_Ricorso WITH(NOLOCK)
				WHERE idazi = @IdaziMaster and bDeleted = 0

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
			WHERE idHeader = @IdDoc

	END

	   	
	IF NOT EXISTS(select a.idRow from Document_PCP_Appalto a with(nolock) where a.idheader = @IdDoc )
	BEGIN
			
		--chiamo una SP che inizializza i campi della scheda PCP
		exec INIT_SCHEDA_PCP_DOCUMENTO @IdDoc, @idPfuAOO , @TipoDocSource

	END

END
GO
