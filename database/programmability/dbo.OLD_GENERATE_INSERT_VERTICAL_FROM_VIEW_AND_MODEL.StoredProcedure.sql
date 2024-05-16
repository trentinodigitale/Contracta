USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_GENERATE_INSERT_VERTICAL_FROM_VIEW_AND_MODEL]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROC [dbo].[OLD_GENERATE_INSERT_VERTICAL_FROM_VIEW_AND_MODEL]( 
		@nome_vista as varchar(1000),
		@modello_di_salvataggio as varchar(1000),
		@idHeader as int,
		@idOrigin as int,
		@nomeSezione as varchar(1000),
		@FROM_USER_FIELD as VARCHAR(400),
		@idPfu as int,
		@output as nvarchar(max) OUTPUT )

AS
BEGIN

	SET NOCOUNT ON

	declare @debug as int

	set @debug = 0

	declare @nomeColonna as varchar(1000)
	declare @insertSql as nvarchar(max)
	declare @value as nvarchar(max)

	set @output = ''
	set @insertSql = ''
	set @value = ''

	DECLARE curs CURSOR STATIC FOR     
		SELECT Column_name
			FROM	INFORMATION_SCHEMA.COLUMNS (NOLOCK) 
			WHERE 	TABLE_NAME = @nome_vista 



	CREATE TABLE #values
	(
		colonna nvarchar(4000),
		valore nvarchar(max)
	)

	OPEN curs 
	FETCH NEXT FROM curs INTO @nomeColonna


	WHILE @@FETCH_STATUS = 0   
	BEGIN

		

		-- se la colonna ritornata dalla vista esiste sul modello di salvataggio
		if exists ( 
				select top 1 MA_DZT_Name
					from LIB_Models model
							INNER JOIN LIB_ModelAttributes attr ON model.mod_id = attr.ma_mod_id
					where model.mod_id = @modello_di_salvataggio and attr.ma_dzt_name = @nomeColonna
				  )

		BEGIN


			set @insertSql = 'insert into #values select ''' + @nomeColonna + ''' as colonna,' + @nomeColonna + ' as valore from ' + @nome_vista + ' where id_from = ' + cast(@idOrigin as varchar(100))

			IF ( isnull(@FROM_USER_FIELD,'') <> '' )
			BEGIN
				set @insertSql = @insertSql + ' and ' + @FROM_USER_FIELD + ' = ' + cast(@idPfu as varchar(10))
			END
			--print @insertSql
			exec( @insertSql )

			IF @@ERROR <> 0 
			BEGIN

				raiserror ('Errore insert in #values. ', 16, 1)
				
				CLOSE curs   
				DEALLOCATE curs
				drop table #values

				return 99
			END 

			select @value = isnull(valore,'') from #values where colonna = @nomeColonna

			IF ( @debug = 1 )
			BEGIN

				print 'idHeader:' + cast(@idHeader as varchar(10))
				print 'nomeSezione:' + @nomeSezione
				print 'nomeColonna:' + @nomeColonna
				print 'value:' + @value
			
			END

			set @insertSql = 'INSERT INTO CTL_DOC_Value(IdHeader,DSE_ID,Row,DZT_Name,Value) 
							VALUES (' + cast(@idHeader as varchar(10)) + ',''' + @nomeSezione + ''',0,''' + @nomeColonna + ''',''' + replace( @value ,'''','''''') + ''')'

			IF @@ERROR <> 0 
			BEGIN

				raiserror ('Errore creazione script di inserti in  ctl_doc_value. ', 16, 1)
				
				CLOSE curs   
				DEALLOCATE curs
				drop table #values

				return 99
			END 
			
			set @insertSql = @insertSql + '
'


			if ( @debug = 1 )
				print @insertSql

			set @output = @output  + @insertSql

		END
		
		FETCH NEXT FROM curs INTO @nomeColonna

	END

	-- print 'output:' + cast(len(@output) as varchar(400))
	
	CLOSE curs   
	DEALLOCATE curs

	drop table #values

END 


GO
