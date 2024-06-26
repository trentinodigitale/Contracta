USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_CONFIG_MODELLI_MERC_ADDITIONAL_INFO_CREATE_FROM_MODIFICA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD_CONFIG_MODELLI_MERC_ADDITIONAL_INFO_CREATE_FROM_MODIFICA] ( @iddoc int , @IdUser int  )
AS
BEGIN

	-- QUESTA STORED COPIA IL MODELLO DI TIPO 'CONFIG_MODELLI_MERC_ADDITIONAL_INFO' PRENDENDO I DATI DA QUELLO SUL QUALE E' STATO ESEGUITO IL COMANDO
	-- E VIENE LEGATO (CON PREVDOC) ALL'ULTIMO MODELLO DELLA CATENA. 

	SET NOCOUNT ON;

	declare @Id INT
	declare @LastId INT
	declare @out INT
	DECLARE @NewTitolo varchar(4000)
	declare @oldPrevDoc INT
	declare @Errore nvarchar(2000)
	declare @lastPrevDoc int

	set @Errore=''
	set @Id = 0

	set @LastId = @idDoc
	set @lastPrevDoc = @idDoc

	-- RESTO NEL CICLO FINCHÈ MANTENGO VERA LA RELAZIONE PREVDOC
	WHILE @lastPrevDoc <> 0
	BEGIN

		SET @lastPrevDoc = 0

		select  @LastId = id,
				@lastPrevDoc = isnull(PrevDoc,0)
			from ctl_doc with(nolock) 
			where prevdoc = @LastId and tipodoc = 'CONFIG_MODELLI_MERC_ADDITIONAL_INFO' and deleted = 0 and StatoFunzionale = 'Pubblicato'

	END

	--- Se esiste già un CONFIG_MODELLI_MERC_ADDITIONAL_INFO che ha come prevDoc l'idDoc richiesto. Apro quello
	select @Id=id 
		from CTL_DOC with(nolock) 
		where PrevDoc = @LastId and TipoDoc = 'CONFIG_MODELLI_MERC_ADDITIONAL_INFO' and StatoFunzionale = 'InLavorazione' and Deleted = 0

	IF @Id = 0
	BEGIN

		declare @numeroOccorrenze int
		declare @progressivo int
		declare @nomeModNuovo varchar(4000)
		declare @nomeModVecchio varchar(4000)

		select  @nomeModVecchio = titolo,
				@oldPrevDoc = isnull(PrevDoc,0)
			from ctl_doc with(nolock)
			where id = @LastId


		set @nomeModNuovo = @nomeModVecchio

		-- Modifico il titolo del precedente modello per accodarci un incrementale
		IF @oldPrevDoc <> 0
		BEGIN
					
			BEGIN TRY

				set @numeroOccorrenze = len(@nomeModVecchio) - len(replace(@nomeModVecchio, '_', ''))

				if @numeroOccorrenze > 0
				begin
					set @progressivo = cast(  dbo.GetPos(@nomeModVecchio, '_',@numeroOccorrenze+1) as int )
					set @nomeModNuovo = replace( @nomeModVecchio, '_' + cast(@progressivo as varchar), '_' + cast( (@progressivo + 1) as varchar) )
				end
				else
				begin
					set @nomeModNuovo = @nomeModVecchio + '_1'
				end

			END TRY  
			BEGIN CATCH
				set @nomeModNuovo = @nomeModVecchio + '_1'
			END CATCH


		END
		ELSE
		BEGIN

			set @nomeModNuovo = @nomeModVecchio + '_1'

		END


		INSERT INTO CTL_DOC (StatoDoc,data, deleted, titolo,body, statofunzionale, tipodoc,IdPfu,LinkedDoc,Azienda, PrevDoc)
			select 'Saved', getdate(),0, @nomeModNuovo, body, 'InLavorazione', tipodoc, @IdUser,0,Azienda, @LastId
			from CTL_DOC with(nolock)
			where Id = @LastId

		set @Id = SCOPE_IDENTITY()

		INSERT INTO CTL_DOC_Value ( DSE_ID,IdHeader,Row,DZT_Name,Value )
			select DSE_ID,@Id,Row,DZT_Name,Value 
			from CTL_DOC_Value with(nolock)
			where IdHeader = @iddoc	-- La struttura del modello la copia da quello dal quale si stà partendo. non dall'ultimo della catena

	END


	if @Errore = ''
	begin

		-- rirorna l'id del doc appena creato o quello del doc in lavorazione
		select @Id as id
	
	end
	else
	begin

		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore

	end
	
END



GO
