USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_AFS_CRYPT_DATI_VER_0]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- =============================================
-- Author:		Sabato
-- Create date: 07-05-2020
-- =============================================
CREATE PROCEDURE [dbo].[OLD_AFS_CRYPT_DATI_VER_0]( @TableName varchar(500) , @fieldKeyDoc as varchar(200) ,  @ValueKeyDoc  as varchar(100)  ,@ModelName as varchar(200) , @AttrEccezzioni  as varchar(1000) , @FilterRow as varchar(1000))
--WITH ENCRYPTION
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


	declare @KeyCrypt varchar(200)
	declare @KeyName varchar(200)
	declare @KeyCryptAPP varchar(200)
	declare @KEY_ROW nvarchar(800)

	declare @SQLCrypt varchar(max)


	set @Col2XML = ''
	set @Col2UPD = ''


	-- recupero la colonna identity della tabella 
	select @identity = c.name 
		from syscolumns c
			inner join sysobjects o on o.id = c.id
		where 
			o.name = @TableName 
			and  columnproperty(object_id(o.name),c.name ,'IsIdentity') = 1
--			and c.colstat = 1

	-- recupero la chiave per critografia
	select  @KeyCrypt = reverse( substring(  cast( [GUID] as varchar(100)) ,  id % 33  + 2 + 2, 36))  + substring(  cast( [GUID] as varchar(100)) , 2 , id % 33 + 2) ,
			@KeyName = + reverse( substring( cast( [GUID] as varchar(100)) ,  id % 6 , 5 ) + cast( id as varchar(10)))  
		 from ctl_doc with(nolock) where id = @ValueKeyDoc
	
	set @KeyCrypt =  convert(varchar(200) ,  HASHBYTES( 'MD5' , @KeyCrypt ) , 2 ) + '-' + convert( varchar(200) ,  HASHBYTES( 'SHA1' , @KeyCrypt ) ,2)
	set @KeyName ='KEY_' + convert(varchar(200) ,  HASHBYTES( 'SHA1' , @KeyName )  ,2)


	-- preparo per la cifratura
	IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
		CREATE MASTER KEY ENCRYPTION BY 
			PASSWORD = '448F91E9-8B75-4668-9485-3937ACE4B095-E12BBFE8-70A7-4F65-A04D-3984FCA0A15A#BA0429E1-55B4-47F1-93A8-8757E368352B'
	
	if not exists( select * from sys.symmetric_keys where name = @KeyName )
	begin
		-- creo una nuova chiave per il documento se non esiste
		set @SQLCrypt = 'CREATE SYMMETRIC KEY ' + @KeyName + '
					WITH ALGORITHM = AES_256
					ENCRYPTION BY PASSWORD = ''' + @KeyCrypt + ''' '
		
		exec( @SQLCrypt )
	end

	-- apro la chiave per la cifratura
	set @SQLCrypt = 'OPEN SYMMETRIC KEY ' + @KeyName + ' DECRYPTION BY  PASSWORD = ''' + @KeyCrypt + ''' '
	--print @SQLCrypt
	exec( @SQLCrypt )



	-- se la tabella dove cifrare i dati è la CTL_DOC_VALUE si cifra solo la colonna value altrimenti ci guida il modello
	if @TableName = 'CTL_DOC_Value'
	begin

			set @Col2XML = 'Value' + ',' 
			set @Col2UPD = 'Value' + ' = null ,'

	end
	else
	begin

		-- recupero dal sistema le colonne sulle quali basare il recupero dei dati
		if exists ( select MOD_ID from LIB_Models with(nolock) where MOD_ID = @ModelName )
		begin

			-- conpongo la query il cui risultato è XML + lo stament per cancellare dal record gli stessi valori
			SELECT @Col2XML = @Col2XML + MA_DZT_Name + ',' , @Col2UPD = @Col2UPD + MA_DZT_Name + ' = null ,'
				FROM LIB_ModelAttributes  with(nolock)
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
			if exists ( select MOD_ID from CTL_Models with(nolock) where MOD_ID = @ModelName )
			begin


				-- conpongo la query il cui risultato è XML + lo stament per cancellare dal record gli stessi valori
				SELECT @Col2XML = @Col2XML + MA_DZT_Name + ',' , @Col2UPD = @Col2UPD + MA_DZT_Name + ' = null ,'
					FROM CTL_ModelAttributes with(nolock)
						inner join syscolumns c on c.name = MA_DZT_Name
						inner join sysobjects o on o.id = c.id and o.name = @TableName
					WHERE MA_MOD_ID = @ModelName  
						and charindex( ',' + MA_DZT_Name +',' , ',' +  @AttrEccezzioni + ',' ) = 0 
						and MA_DZT_Name <> @fieldKeyDoc 
						and MA_DZT_Name <> @identity
					ORDER BY MA_Order

			end
		end

	end



	if @Col2XML <> ''
	begin
		set @Col2XML = left ( @Col2XML , len(@Col2XML ) - 1 ) 
		set @Col2UPD = left ( @Col2UPD , len(@Col2UPD ) - 1 ) 



		-- estraggo i dati dati in XML e li memorizzo nella colonna da cifrare
		declare @idRow varchar(100)
		declare @Filtro varchar(100)
		set @Filtro = ''
		if  @FilterRow <> '' 
			set @Filtro = ' and ' + @FilterRow

		-- preparo l'elenco dele righe che devono essere cifrato
		
		CREATE TABLE #Temp  ( IdRow  int ) ;
		exec ( 'insert into #temp (IdRow )  select ' + @identity + ' as IdRow   from ' + @TableName + ' with(nolock) where ' + @fieldKeyDoc + ' = ' + @ValueKeyDoc + @Filtro  )


		declare CurProg Cursor FAST_FORWARD for 
		Select IdRow from #Temp 	
		open CurProg

		FETCH NEXT FROM CurProg  INTO @idrow
		WHILE @@FETCH_STATUS = 0
		BEGIN

			-- sposto i dati nel campo XML
			--set @Query2XML = ' update  ' + @TableName + '  set AFS_CRYPTED = ( select ' + @Col2XML + ' from ' +  @TableName + ' where ' + @identity + ' = ' + @idrow + ' FOR XML PATH  ) WHERE ' + @identity + ' = ' + @idrow
			--print @Query2XML 
			--exec ( @Query2XML )

			--DELETE FROM CTL_DATI_CIFRATI WHERE TableName =  @TableName AND idx = @idrow

			declare @xml nvarchar(max)
			CREATE TABLE #TempXML  ( AFS_CRYPTED nvarchar(max) collate database_default ) ;
			--set @Query2XML = ' update  #TempXML  set AFS_CRYPTED = ( select ' + @Col2XML + ' from ' +  @TableName + ' where ' + @identity + ' = ' + @idrow + ' FOR XML PATH  ) WHERE ' + @identity + ' = ' + @idrow
			set @Query2XML = ' insert into #TempXML  ( AFS_CRYPTED ) select ( select ' + @Col2XML + ' from ' +  @TableName + ' with(nolock) where ' + @identity + ' = ' + @idrow + ' FOR XML PATH  ) as a '
			exec( @Query2XML  )
			select @xml = AFS_CRYPTED from #TempXML
			drop table #TempXML


			-- compole il valore per agganciare i dati cifrati al documento
			set @KEY_ROW =  dbo.EncryptValore(   @TableName + '_' + cast(  @idrow as varchar(20)) ) 
			DELETE FROM CTL_DATI_CIFRATI WHERE KEY_ROW =  @KEY_ROW

			
			-- spacchetto i dati cifrandoli 
			declare @pacchetto nvarchar(max)
			declare @ix int
			set @ix = 0
			set @pacchetto = substring( @xml , @ix * 3000 + 1 , 3000 )
			while @pacchetto <> ''
			begin
				--insert into CTL_DATI_CIFRATI ( TableName,  idx, row, Dati , KEY_ROW) 
				--	values( @TableName , @idrow , @ix , EncryptByKey(Key_GUID(  @KeyName ), @pacchetto ) , @KEY_ROW  )
				insert into CTL_DATI_CIFRATI (  row, Dati , KEY_ROW) 
					values( @ix , EncryptByKey(Key_GUID(  @KeyName ), @pacchetto ) , @KEY_ROW  )

				set @ix = @ix + 1
				set @pacchetto = substring( @xml , @ix * 3000 + 1 , 3000 )

			end


			-- cancello i campi spostati
			set @Statemet2UPD = ' update  ' + @TableName + '  set ' + @Col2UPD + '  WHERE ' + @identity + ' = ' + @idrow
			exec ( @Statemet2UPD )


			-- Cifro i dati della colonna XML

			--set @SQLCrypt = ' UPDATE  ' + @TableName + ' SET AFS_CRYPTED = cast(  EncryptByKey(Key_GUID(''' + @KeyName + '''), cast( AFS_CRYPTED as nvarchar(4000)))  as nvarchar(max))   WHERE ' + @identity + ' = ' + @idrow
			--print @SQLCrypt 
			--exec ( @SQLCrypt )



			FETCH NEXT FROM CurProg INTO @idrow

		END 
		CLOSE CurProg
		DEALLOCATE CurProg
		DROP TABLE #temp

		set @SQLCrypt =  'CLOSE SYMMETRIC KEY  ' + @KeyName  
		exec( @SQLCrypt ) 

	end

END















GO
