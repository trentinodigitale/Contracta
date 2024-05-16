USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[eCertisModificaCriterion]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[eCertisModificaCriterion] ( 
		 @logID						INT
		,@idCrit					INT
		,@criterionId				VARCHAR(100) 
		,@versionId					INT
		,@nationalEntity			VARCHAR(5)
		,@nation					VARCHAR(500)
		,@startDate					DATE
		,@endDate					DATE
		,@nome						VARCHAR(500)
		,@descr						NVARCHAR(MAX)
		,@parentCriterionId			VARCHAR(100)
		,@parentCriterionVersionId	INT

		,@totInseriti				INT OUTPUT
		,@totModificati				INT OUTPUT
		,@totCancellati				INT OUTPUT
	 )
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @c_criterionId				VARCHAR(100) 
	DECLARE @c_versionId				INT
	DECLARE @c_nationalEntity			VARCHAR(5)
	DECLARE @c_nation					VARCHAR(500)
	DECLARE @c_startDate				DATE
	DECLARE @c_endDate					DATE
	DECLARE @c_nome						VARCHAR(500)
	DECLARE @c_descr					NVARCHAR(MAX)
	DECLARE @c_parentCriterionId		VARCHAR(100)
	DECLARE @c_parentCriterionVersionId	INT

	DECLARE @change_criterionId					INT = 0
	DECLARE @change_versionId					INT = 0
	DECLARE @change_nationalEntity				INT = 0
	DECLARE @change_nation						INT = 0
	DECLARE @change_startDate					INT = 0
	DECLARE @change_endDate						INT = 0
	DECLARE @change_nome						INT = 0
	DECLARE @change_descr						INT = 0
	DECLARE @change_parentCriterionId			INT = 0
	DECLARE @change_parentCriterionVersionId	INT = 0

	DECLARE @note VARCHAR(4000) = ''
	DECLARE @totModifiche INT = 0

	SELECT	  @c_criterionId				= a.criterionId		
			 ,@c_versionId					= a.versionId
			 ,@c_nationalEntity				= a.nationalEntity
			 ,@c_nation						= a.nation
			 ,@c_startDate					= a.startDate
			 ,@c_endDate					= a.endDate
			 ,@c_nome						= a.[name]
			 ,@c_descr						= a.[description]
			 ,@c_parentCriterionId			= a.parentCriterionId
			 ,@c_parentCriterionVersionId	= a.parentCriterionVersionId
		FROM Document_eCertis_criterion a WITH(NOLOCK)
		WHERE id = @idCrit

	-- 1. SE NON E' CAMBIATO NIENTE LASCIO TUTTO COM'E'
	-- 2. SE E' CAMBIATA SOLO LA DATA FINE, LA AGGIORNO SUL CRITERION ORIGINALE E BASTA
	-- 3. SE E' CAMBIATO QUALCOS'ALTRO OLTRE LA DATA FINE E' UN ANOMALIA, QUINDI SEGNO COSA E' CAMBIATO NELLE NOTE E VALORIZZO LA DATA FINE CON LA DATA DI ELABORAZIONE

	IF isnull(@criterionId,'') <> isnull(@c_criterionId,'')
	BEGIN
		SET @change_criterionId = 1
		SET @note = @note + ' criterionId,'
	END

	IF isnull(@versionId,-1) <> isnull(@c_versionId,-1)
	BEGIN
		SET @change_versionId = 1
		SET @note = @note + ' versionId,'
	END

	IF isnull(@nationalEntity,'') <> isnull(@c_nationalEntity,'')
	BEGIN
		SET @change_nationalEntity = 1
		SET @note = @note + ' nationalEntity,'
	END

	IF isnull(@nation,'') <> isnull(@c_nation,'')
	BEGIN
		SET @change_nation = 1
		SET @note = @note + ' nation,'
	END

	IF isnull(@startDate,getdate()) <> isnull(@c_startDate,getdate())
	BEGIN
		SET @change_startDate = 1
		SET @note = @note + ' startDate,'
	END

	IF isnull(@endDate,getDate()) <> isnull(@c_endDate,getDate())
	BEGIN
		SET @change_endDate = 1
		SET @note = @note + ' endDate,'
	END

	IF isnull(@nome,'') <> isnull(@c_nome,'')
	BEGIN
		SET @change_nome = 1
		SET @note = @note + ' nome,'
	END

	IF isnull(@descr,'') <> isnull(@c_descr,'')
	BEGIN
		SET @change_descr = 1
		SET @note = @note + ' descr,'
	END

	IF isnull(@parentCriterionId,'') <> isnull(@c_parentCriterionId,'')
	BEGIN
		SET @change_parentCriterionId = 1
		SET @note = @note + ' parentCriterionId,'
	END

	IF isnull(@parentCriterionVersionId,'') <> isnull(@c_parentCriterionVersionId,'')
	BEGIN
		SET @change_parentCriterionVersionId = 1
		SET @note = @note + ' parentCriterionVersionId,'
	END

	SET @totModifiche = @change_criterionId + @change_versionId + @change_nationalEntity + @change_nation + @change_startDate + @change_endDate + @change_nome + @change_descr + @change_parentCriterionId + @change_parentCriterionVersionId

	-- SE LA SOMMA DA ZERO VUOL DIRE CHE NON E' CAMBIATO NIENTE
	IF ( @totModifiche > 0) 
	BEGIN

		IF ( @change_endDate = 1 and @totModifiche = 1 )
		BEGIN
			
			UPDATE Document_eCertis_criterion
					SET endDate = isnull(@endDate, getdate()), 
						lastUpdate = getdate()
				WHERE id = @idCrit

			SET @totModificati = @totModificati + 1

		END
		ELSE
		BEGIN

			-- se c'è ALMENO una modifica e questa modifica non è sull'endDate ( o non solo )
			UPDATE Document_eCertis_criterion
					SET   note = 'ANOMALIA. Dati variati : ' + LEFT( @note, LEN(@NOTE)-1)
						, deleted = 1
						, lastUpdate = getdate()
				WHERE id = @idCrit

			SET @totCancellati = @totCancellati + 1

			-- AVENDO TROVATO UN CRITERIO ANOMALO, INSERISCO QUELLO NUOVO DAI DATI APPENA RECUPERATI
			INSERT INTO [Document_eCertis_criterion]
					   ([idHeader]
					   ,[criterionId]
					   ,[versionId]
					   ,[nationalEntity]
					   ,[nation]
					   ,[startDate]
					   ,[endDate]
					   ,[name]
					   ,[description]
					   ,[parentCriterionId]
					   ,[parentCriterionVersionId])
				 VALUES(@logID
					   ,@criterionId
					   ,@versionId
					   ,@nationalEntity
					   ,@nation
					   ,@startDate
					   ,@endDate
					   ,@nome
					   ,@descr
					   ,@parentCriterionId
					   ,@parentCriterionVersionId)

			SET @totInseriti = @totInseriti + 1

		END

	END


END

GO
