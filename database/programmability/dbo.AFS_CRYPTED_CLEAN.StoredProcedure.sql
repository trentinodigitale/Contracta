USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AFS_CRYPTED_CLEAN]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Sabato
-- Create date: 23-4-2015
-- =============================================
CREATE  PROCEDURE [dbo].[AFS_CRYPTED_CLEAN]( @TableName varchar(500) , @fieldKeyDoc as varchar(200) ,  @ValueKeyDoc  as varchar(100)  ,@ModelName as varchar(200) , @AttrEccezzioni  as varchar(1000) , @FilterRow as varchar(1000))
as
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @Col2XML as varchar(max)
	DECLARE @Col2UPD as varchar(max)
	DECLARE @Query2XML as varchar(max)
	DECLARE @Statemet2UPD as varchar(max)
	declare @identity as varchar(200)


	set @Col2XML = ''
	set @Col2UPD = ''


	-- recupero la colnna identity della tabella 
	select @identity = c.name 
		from syscolumns c
			inner join sysobjects o on o.id = c.id
		where 
			o.name = @TableName
			and c.colstat = 1


	-- recupero dal sistema le colonne sulle quali basare il recupero dei dati
	if exists ( select MOD_ID from LIB_Models where MOD_ID = @ModelName )
	begin

		-- conpongo la query il cui risultato è XML + lo stament per cancellare dal record gli stessi valori
		SELECT  @Col2UPD = @Col2UPD + MA_DZT_Name + ' = null ,'
			FROM LIB_ModelAttributes 
				inner join syscolumns c on c.name = MA_DZT_Name
				inner join sysobjects o on o.id = c.id and o.name = @TableName
			WHERE MA_MOD_ID =  @ModelName  
					and charindex( ',' + MA_DZT_Name +',' , ',' +  @AttrEccezzioni + ',' ) = 0 
					and MA_DZT_Name <> @fieldKeyDoc 
					and MA_DZT_Name <> @identity
			ORDER BY MA_Order

	end
	else 
	begin
		-- recupero dal sistema le colonne sulle quali basare il recupero dei dati
		if exists ( select MOD_ID from CTL_Models where MOD_ID = @ModelName )
		begin


			-- conpongo la query il cui risultato è XML + lo stament per cancellare dal record gli stessi valori
			SELECT  @Col2UPD = @Col2UPD + MA_DZT_Name + ' = null ,'
				FROM CTL_ModelAttributes 
					inner join syscolumns c on c.name = MA_DZT_Name
					inner join sysobjects o on o.id = c.id and o.name = @TableName
				WHERE MA_MOD_ID = @ModelName  
					and charindex( ',' + MA_DZT_Name +',' , ',' +  @AttrEccezzioni + ',' ) = 0 
					and MA_DZT_Name <> @fieldKeyDoc 
					and MA_DZT_Name <> @identity
				ORDER BY MA_Order

		end
	end



	if @Col2UPD <> ''
	begin
		set @Col2UPD = left ( @Col2UPD , len(@Col2UPD ) - 1 ) 



		-- estraggo i dati dati in XML e li memorizzo nella colonna da cifrare
		declare @idRow varchar(100)
		declare @Filtro varchar(100)
		set @Filtro = ''
		if  @FilterRow <> '' 
			set @Filtro = ' and ' + @FilterRow

		-- preparo l'elenco dele righe che devono essere cifrato
		
		CREATE TABLE #Temp  ( IdRow  int ) ;
		exec ( 'insert into #temp (IdRow )  select ' + @identity + ' as IdRow   from ' + @TableName + ' where ' + @fieldKeyDoc + ' = ' + @ValueKeyDoc + @Filtro  )


		declare CurProg Cursor STATIC for 
		Select IdRow from #Temp 	
		open CurProg

		FETCH NEXT FROM CurProg  INTO @idrow
		WHILE @@FETCH_STATUS = 0
		BEGIN

			-- cancello i campi spostati
			set @Statemet2UPD = ' update  ' + @TableName + '  set ' + @Col2UPD + '  WHERE ' + @identity + ' = ' + @idrow
			exec ( @Statemet2UPD )


			FETCH NEXT FROM CurProg INTO @idrow

		END 
		CLOSE CurProg
		DEALLOCATE CurProg
		DROP TABLE #temp


	end

END



GO
