USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[eCertisElaboraCriterion]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eCertisElaboraCriterion] ( @idChiamata INT = -1, @idpfu INT = -20 )
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @criterionId				VARCHAR(100) 
	DECLARE @versionId					INT
	DECLARE @nationalEntity				VARCHAR(5)
	DECLARE @nation						VARCHAR(500)
	DECLARE @startDate					DATE
	DECLARE @endDate					DATE
	DECLARE @nome						VARCHAR(500)
	DECLARE @descr						NVARCHAR(MAX)
	DECLARE @parentCriterionId			VARCHAR(100)
	DECLARE @parentCriterionVersionId	INT

	DECLARE @new	INT
	DECLARE @id		INT

	DECLARE @totInseriti   INT = 0
	DECLARE @totModificati INT = 0
	DECLARE @totCancellati INT = 0

	----------------------------------------------------------------------------------------------
	-- AGGIORNO LA DATA DI ULTIMO PASSAGGIO DEL SERVIZIO PER I CRITERI CHE STIAMO PER LAVORARE   -
	----------------------------------------------------------------------------------------------

	UPDATE Document_eCertis_criterion
			set lastUpdate = getdate()
		FROM Document_eCertis_criterion f
				INNER JOIN Document_eCertis_criterion_lavoro l ON f.criterionId = l.criterionId and f.versionId = l.versionId 
		WHERE f.deleted = 0

	DECLARE curs CURSOR STATIC FOR
		select f.id, l.[criterionId], l.[versionId], l.[nationalEntity], l.[nation], l.[startDate], l.[endDate], l.[name], l.[description], l.[parentCriterionId], l.[parentCriterionVersionId]
					, case when f.id is null then 1 else 0 end as new
		from Document_eCertis_criterion_lavoro l with(nolock) 
				LEFT JOIN Document_eCertis_criterion f with(nolock) ON f.criterionId = l.criterionId and f.versionId = l.versionId and f.deleted = 0
		where l.idPfu = @idpfu

	OPEN curs 
	FETCH NEXT FROM curs INTO @id,@criterionId,@versionId,@nationalEntity,@nation,@startDate,@endDate,@nome,@descr,@parentCriterionId,@parentCriterionVersionId, @new

	WHILE @@FETCH_STATUS = 0   
	BEGIN

		IF @new = 1
		BEGIN

			-- SE STIAMO CICLANDO SU UN NUOVO CRITERION INSERIAMO E BASTA
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
				 VALUES(@idChiamata
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
		ELSE
		BEGIN

			EXEC eCertisModificaCriterion @idChiamata, @id,@criterionId,@versionId,@nationalEntity,@nation,@startDate,@endDate,@nome,@descr,@parentCriterionId,@parentCriterionVersionId,@totInseriti OUTPUT,@totModificati	OUTPUT,@totCancellati OUTPUT

		END
		

		FETCH NEXT FROM curs INTO @id,@criterionId,@versionId,@nationalEntity,@nation,@startDate,@endDate,@nome,@descr,@parentCriterionId,@parentCriterionVersionId, @new

	END  


	CLOSE curs   
	DEALLOCATE curs
	
	----------------------------------------------------------------
	-- AGGIORNO I CONTATORI PER POI UTILIZZARLI NELL'ALERTING MAIL -
	----------------------------------------------------------------
	UPDATE Document_eCertis_log
			set totCancellati = @totCancellati,
				totModificati = @totModificati,
				totInseriti = @totInseriti
		where id = @idChiamata


END


GO
