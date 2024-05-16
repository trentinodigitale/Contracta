USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SSO_GetGEO_FomComune]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD_SSO_GetGEO_FomComune] 
	(
		@codIstatComune  VARCHAR(500), 
		@descComune nvarchar(max),
		@descProvincia nvarchar(max),
		@descStato nvarchar(max),
		@LOCALITA_OUT                           VARCHAR(500) OUT, 
		@PROVINCIA_OUT                          VARCHAR(500) OUT, 
		@STATO_OUT                              VARCHAR(500) OUT, 
		@REGIONE_OUT                            VARCHAR(500) OUT,
		@LOCALITA_INT                           VARCHAR(500) OUT,
		@PROVINCIA_INT                          VARCHAR(500) OUT,
		@STATO_INT                              VARCHAR(500) OUT
	)
AS
BEGIN

	DECLARE @NOTE                                   VARCHAR(MAX)

	DECLARE @LOCALITA                               VARCHAR(255)
	DECLARE @PROVINCIA								VARCHAR(255)

	DECLARE @LOCALITA_CI                            VARCHAR(500) 
	
	DECLARE @REGIONE_INT                            VARCHAR(500) 
	DECLARE @TIPO_AMMINISTR_OUT                     VARCHAR(255)

	SET @LOCALITA_INT = NULL  
	SET @PROVINCIA_INT = NULL  
	SET @STATO_INT = NULL  
        
	-- AVVALORO LA LOCALITA' CON IL CODICE ISTAT
	SET @LOCALITA = @codIstatComune
	SET @descComune = isnull(@descComune,'')
	SET @LOCALITA_CI = ISNULL(@LOCALITA, 'EMPTY')

	IF @descComune = ''
	BEGIN
		set @descComune = 'EMPTY'
	END

	IF @codIstatComune <> '' 
	BEGIN

		SELECT	  @LOCALITA_INT = DMV_COD
				, @LOCALITA_OUT = DMV_DescML
			FROM LIB_DomainValues with(nolock)
			WHERE DMV_DM_ID = 'GEO' AND DMV_COD LIKE '%' + @LOCALITA_CI

	END
	ELSE
	BEGIN

		-- Se non ci viene ritornata la codifica istat del comune
		-- provo a recuperare le nostre cofiche a partire dalle descrizioni geografiche in input
		-- per ridurre al minimo situazioni di omonimia, parto dallo stato per poi scendere fino al comune
		-- andando ad aggiungere come prefisso il codice del livello superiore


			SELECT	 @STATO_INT = dmv_cod,
					 @STATO_OUT = DMV_DescML 
				FROM LIB_DomainValues with(nolock)
				WHERE DMV_DM_ID = 'GEO' and DMV_Level = 3 and DMV_DescML = @descStato 


			IF NOT @STATO_INT IS NULL
			BEGIN

				SELECT	  @PROVINCIA_INT = DMV_COD
						, @PROVINCIA_OUT = DMV_DescML
					FROM LIB_DomainValues with(nolock)
					WHERE DMV_DM_ID = 'GEO' and DMV_Level = 6 and dmv_cod like '' + @STATO_INT + '%' AND DMV_DescML = @descProvincia 

				IF NOT @PROVINCIA_INT IS NULL
				BEGIN

					SELECT	  @LOCALITA_INT = DMV_COD
							, @LOCALITA_OUT = DMV_DescML
						FROM LIB_DomainValues with(nolock)
						WHERE DMV_DM_ID = 'GEO' and DMV_Level = 7 and dmv_cod like '' + @PROVINCIA_INT + '%' AND DMV_DescML = @descComune  

				END

			END

	END
           
	IF NOT @LOCALITA_INT IS NULL
	BEGIN

			SELECT TOP 1 @PROVINCIA_INT = DMV_COD
					, @PROVINCIA_OUT = DMV_DescML
				FROM LIB_DomainValues with(nolock)
				WHERE DMV_DM_ID = 'GEO'
				AND DMV_Level = 6 AND @LOCALITA_INT LIKE DMV_COD + '%' 

			SELECT TOP 1 @STATO_INT = DMV_COD
					, @STATO_OUT = DMV_DescML
				FROM LIB_DomainValues with(nolock)
				WHERE DMV_DM_ID = 'GEO'
				AND DMV_Level = 3 AND @LOCALITA_INT LIKE DMV_COD + '%' 

			SELECT TOP 1 @REGIONE_INT = DMV_COD
					, @REGIONE_OUT = DMV_DescML
				FROM LIB_DomainValues with(nolock)
				WHERE DMV_DM_ID = 'GEO'
				AND DMV_Level = 5 AND @LOCALITA_INT LIKE DMV_COD + '%' 
	END

	IF @LOCALITA_INT IS NULL
	BEGIN
			SET @LOCALITA_OUT = NULL
			SET @STATO_OUT = 'ITALIA'
			SET @PROVINCIA_OUT = @PROVINCIA
	END

END


GO
