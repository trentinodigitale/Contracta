USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PCP_ORGANISMO_RICORSO_UPDATE_DEFAULT]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PCP_ORGANISMO_RICORSO_UPDATE_DEFAULT]  ( @IdGara int  )
AS
BEGIN

	---------------------------------------------------------
	-- GESTIONE DATI DI DEFAULT DELL'ORGANISMO DI RICORSO  --
	---------------------------------------------------------
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
	DECLARE @idAziEnte INT = 0
	DECLARE @IdaziMaster as int

	-- SE NON HO I DATI DELL'ORGANISMO DI RICORSO PROVO A CARICARE I DEFAULT PRESENTI A SISTEMA
	IF EXISTS ( select idrow from Document_E_FORM_CONTRACT_NOTICE with(nolock) WHERE idHeader = @IdGara and isnull(cn16_OrgRicorso_Name,'') = '' ) 
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
			WHERE idazi = @idAziEnte and bDeleted = 0

		IF isnull(@cn16_OrgRicorso_CompanyID,'') = ''
		BEGIN

			--se non c'è il record per l'idazi della gara provo con l'azimaster
			--set @IdaziMaster = 35152001
			select top 1 @IdaziMaster = mpIdAziMaster from Marketplace with(nolock) where mpLog = 'PA' and mpDeleted = 0		

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
			WHERE idHeader = @IdGara

	END

END






GO
