USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_AFS_DECRYPT_DATI]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--drop procedure [AFS_DECRYPT_DATI]
--go
--alter  PROCEDURE [dbo].[AFS_DECRYPT_DATI]( @idPfu int ,  @TableName varchar(500) ,  @Section varchar(200) , @fieldKeyDoc as varchar(200) ,  @ValueKeyDoc  as varchar(100)  ,@ModelName as varchar(200) , @AttrEccezzioni  as varchar(1000) , @FilterRow as varchar(1000) , @Allegati as int , @dzt_type_decrypt varchar(max) = '')
----WITH ENCRYPTION
--as
--BEGIN
--	-- SET NOCOUNT ON added to prevent extra result sets from
--    SET NOCOUNT ON;


--	exec AFS_DECRYPT_DATI_VER_0  @idPfu ,  @TableName  ,  @Section  , @fieldKeyDoc  ,  @ValueKeyDoc    ,@ModelName  , @AttrEccezzioni   , @FilterRow  , @Allegati , @dzt_type_decrypt 

--end

---- ============================================
-- Author:		Sabato
-- Create date: 07-05-2020

-- stored per decifrare i valori e riposizionare i valori nelle colonne ( tabella , modello , colonna , riferimento , campi eccezzione , allegati s/n) - da usare per decifrare una busta
--         se su un record è presente un allegato questo decifrerà anche l allegato se richiesto dal parametro ( da fare ) 
-- =============================================
CREATE PROCEDURE [dbo].[OLD_AFS_DECRYPT_DATI]( @idPfu int ,  @TableName varchar(500) ,  @Section varchar(200) , @fieldKeyDoc as varchar(200) ,  @ValueKeyDoc  as varchar(100)  ,@ModelName as varchar(200) , @AttrEccezzioni  as varchar(1000) , @FilterRow as varchar(1000) , @Allegati as int , @dzt_type_decrypt varchar(max) = '')
--WITH ENCRYPTION
as
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
    SET NOCOUNT ON;
    SET ARITHABORT on 
	
    --DECLARE @Col2XML as varchar(max)
    DECLARE @SQL_UPD as nvarchar(max)
    DECLARE @Colonna   as varchar(max)
    DECLARE @Valore as nvarchar(max)
    declare @identity as varchar(200)
    declare @xml nvarchar(max)
    declare @x xml
    declare @Select  nvarchar(max)
    declare @SQL_TESTA as nvarchar(max)

    -- dichiaro le variabili tabelle
    declare @TempValori2  table ( Colonna  varchar(1000) , Valore  nvarchar(max)) 
    declare @TempValori  table ( Colonna  varchar(1000) , Valore  nvarchar(max) , DZT_Type int )  
    declare @Temp  table ( IdRow  int , afs_crypted ntext , idheader  int) 
    declare @TempColonne  table ( DZT_Name varchar(50) , DZT_Type int ) ;

	declare @DZT_Type as  int

	-- recupero la colnna identity della tabella 
	select @identity = c.name 
		from syscolumns c
			inner join sysobjects o on o.id = c.id
		where 
			o.name = @TableName
			and  columnproperty(object_id(o.name),c.name ,'IsIdentity') = 1
			--and c.colstat = 1


	-- traccia nel log della decifratura dei dati in chiaro sul DB
	declare @pfulogin nvarchar(500)
	select @pfulogin = pfulogin from profiliutente where idpfu = @idPfu
	insert into CTL_LOG_UTENTE ( idpfu , paginaDiArrivo, paginaDiPartenza , querystring )
		values( @idPfu  , 'APERTURA BUSTA [' + @Section + ']' , '' , 'Utente :' + @pfulogin + ' - Riferimento : ' + @ValueKeyDoc + ' - Filtro : ' + @FilterRow )



	declare @idRow varchar(100)
	declare @Filtro varchar(100)
	set @Filtro = ''
	if  @FilterRow <> '' 
		set @Filtro = ' and ' + @FilterRow

	-- per ogni record che deve essere decifrato
	--CREATE TABLE #Temp  ( IdRow  int , afs_crypted ntext collate DATABASE_DEFAULT, idheader  int) ;
	--CREATE TABLE #TempColonne  ( DZT_Name varchar(50) collate DATABASE_DEFAULT, DZT_Type int ) ;
	delete @Temp
	delete @TempColonne
	delete @TempValori
	delete @TempValori2

	-- recupero i dati da decifrare
	set @Select = 'select ' + @identity + ' as IdRow  , ' + @fieldKeyDoc + ' from ' + @TableName + ' with (nolock) where ' + @fieldKeyDoc + ' = ' + @ValueKeyDoc + @Filtro 
	insert into  @temp (afs_crypted  ,IdRow , idheader)
		
		exec AFS_DECRYPT @idPfu , @Section ,  @fieldKeyDoc  ,  @Select , @TableName , @identity
	
	-- dichiaro ed apro il cursore per gestire tutti i record
	declare CurProg Cursor FAST_FORWARD for 
		Select IdRow , afs_crypted from @Temp
		 	
	open CurProg

	FETCH NEXT FROM CurProg  INTO @idrow , @xml

	-- se ci sono record da decifrare recupero le colonne utili
	if @@FETCH_STATUS = 0 
	begin

		if @TableName = 'CTL_DOC_VALUE' 
		begin

			insert into @TempColonne ( DZT_Name  , DZT_Type ) values( 'Value' , 2 )

		end
		else
		begin

			-- recupero dal sistema le colonne sulle quali basare il recupero dei dati
			if exists ( select MOD_ID from LIB_Models WITH(NOLOCK) where MOD_ID = @ModelName )
			begin
				-- prendo solo le colonne definite dal modello
				insert into @TempColonne ( DZT_Name  , DZT_Type )
					SELECT  d.DZT_Name  , d.DZT_Type 
						FROM  LIB_ModelAttributes WITH(NOLOCK)
							inner join syscolumns c on c.name = MA_DZT_Name
							inner join sysobjects o on o.id = c.id and o.name = @TableName
							inner join LIB_Dictionary d WITH(NOLOCK) on d.DZT_Name = MA_DZT_Name
						WHERE
								MA_MOD_ID =  @ModelName  
								and charindex( ',' + MA_DZT_Name +',' , ',' +  @AttrEccezzioni + ',' ) = 0 
								and MA_DZT_Name <> @fieldKeyDoc 
								and MA_DZT_Name <> @identity

			end
			else 
			begin
				-- recupero dal sistema le colonne sulle quali basare il recupero dei dati
				if exists ( select MOD_ID from CTL_Models WITH(NOLOCK) where MOD_ID = @ModelName )
				begin

					-- prendo solo le colonne definite dal modello
					insert into @TempColonne ( DZT_Name  , DZT_Type )
					SELECT  d.DZT_Name  , d.DZT_Type 
						FROM  CTL_ModelAttributes WITH(NOLOCK)
							inner join syscolumns c on c.name = MA_DZT_Name
							inner join sysobjects o on o.id = c.id and o.name = @TableName
							inner join LIB_Dictionary  d WITH(NOLOCK) on d.DZT_Name = MA_DZT_Name
						WHERE
								MA_MOD_ID =  @ModelName  
								and charindex( ',' + MA_DZT_Name +',' , ',' +  @AttrEccezzioni + ',' ) = 0 
								and MA_DZT_Name <> @fieldKeyDoc 
								and MA_DZT_Name <> @identity

				end
			end
		end
	end					

	--RIMUOVO DALL'ELENCO I TIPI NON INDICATI NEL PARAMETRO OPZIONALE PASSATO ALLA STORED
	if @dzt_type_decrypt <> ''
		delete from @TempColonne where DZT_Type not in (18) or  charindex( ',' + DZT_Name +',' , ',' +  @dzt_type_decrypt + ',' ) > 0 
		--delete from @TempColonne where DZT_Type not in (@dzt_type_decrypt)

	-- ciclo su tutti i record
	WHILE @@FETCH_STATUS = 0
	BEGIN

		set @x = @xml
		
		delete @tempValori2
          delete @tempValori

		-- recupero elenco colonna valore dal documento XML
		insert into @tempValori2
		SELECT  
				T.n.value('localname[1]', 'nvarchar(max)') AS Colonna
				,T.n.value('value[1]', 'nvarchar(max)') AS Valore
				--into @TempValori2
			FROM    ( SELECT   
							@x.query('
								for $node in /descendant::node()[local-name() != ""] 
								return <node>
										<localname>{ local-name($node) }</localname>
										<value>{ ($node) }</value>
										</node>') AS nodes
          
				) q1
				CROSS APPLY q1.nodes.nodes('/node') AS T ( n )
			where T.n.value('localname[1]', 'nvarchar(max)') <> 'row'
			 OPTION(OPTIMIZE FOR (@x=NULL))

		--CREATE TABLE #TempValori  ( Colonna  varchar(1000) collate DATABASE_DEFAULT, Valore  nvarchar(max) collate DATABASE_DEFAULT, DZT_Type int ) 

		

		-- recupero solo le colonne necessarie
		insert into @TempValori (  Colonna , Valore , DZT_Type ) 
			SELECT Colonna , Valore , DZT_Type
				FROM  @TempValori2
					inner join @TempColonne on  Colonna = DZT_Name
                        --inner join @TempColonne on  Colonna COLLATE Latin1_General_CI_AS = DZT_Name COLLATE Latin1_General_CI_AS					
				WHERE
						charindex( ',' + DZT_Name +',' , ',' +  @AttrEccezzioni + ',' ) = 0 
						and DZT_Name <> @fieldKeyDoc 
						and DZT_Name <> @identity
					 

		---- Per ogni coppia valore si esegue un aggiornamento sulla tabella
		--declare CurUpdate Cursor FAST_FORWARD for 
		--	Select Colonna , Valore  from @TempValori

		--open CurUpdate


		--FETCH NEXT FROM CurUpdate  INTO @Colonna , @Valore 
		--WHILE @@FETCH_STATUS = 0
		--BEGIN

		--	set @SQL_UPD = 'update ' + @TableName + ' set ' + @Colonna + ' = ''' + replace( @Valore , '''' , '''''' ) + ''' where ' + @identity + ' = ' + @idrow
		--	exec ( @SQL_UPD )
			

		--	FETCH NEXT FROM CurUpdate  INTO @Colonna , @Valore

		--END 
		--CLOSE CurUpdate
		--DEALLOCATE CurUpdate

		-- ottimizzazione por fare un unico update per riga con tutte le colonne coinvolte
		SET @SQL_TESTA = 'update ' + @TableName + ' set '

		-- Per ogni coppia valore si esegue un aggiornamento sulla tabella
		declare CurUpdate Cursor FAST_FORWARD for 
			Select Colonna , Valore, DZT_Type  from @tempValori

		open CurUpdate

		set @SQL_UPD=''

		FETCH NEXT FROM CurUpdate  INTO @Colonna , @Valore ,@DZT_Type
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			if @DZT_Type in (2,7,6,22) 
			begin
				--per inumeri  e le date come prima
				set @SQL_UPD = @SQL_UPD + @Colonna + ' = ''' + replace( @Valore , '''' , '''''' ) + ''',' 
			end
			else
			begin
				--per i campi testo applico la direttiva per NVARCHAR
				set @SQL_UPD = @SQL_UPD + @Colonna + ' = N''' + replace( @Valore , '''' , '''''' ) + ''',' 
			end
            
			FETCH NEXT FROM CurUpdate  INTO @Colonna , @Valore, @DZT_Type

		END 
		CLOSE CurUpdate
		DEALLOCATE CurUpdate

		if @SQL_UPD <> ''
		begin  
			 SET @SQL_UPD = @SQL_TESTA + LEFT(@SQL_UPD, LEN(@SQL_UPD) -2) + ''' where ' + @identity + ' = ' + @idrow
		  	 exec ( @SQL_UPD )
			 --print @SQL_UPD
	     end

		-- se si è chiesto di decifrare gli allegati si popola la tabella che gestisce il servizio
		if @Allegati = 1
		begin

			declare CurAttach Cursor FAST_FORWARD for 
				Select Colonna , Valore  from @TempValori where   DZT_Type = 18

			open CurAttach


			FETCH NEXT FROM CurAttach  INTO @Colonna , @Valore 
			WHILE @@FETCH_STATUS = 0
			BEGIN

				
				exec AFS_DECRYPT_ATTACH  @idPfu , @Valore , @ValueKeyDoc 
			

				FETCH NEXT FROM CurAttach  INTO @Colonna , @Valore

			END 
			CLOSE CurAttach
			DEALLOCATE CurAttach


		end



		--DROP TABLE #TempValori
		--DROP TABLE #TempValori2




		FETCH NEXT FROM CurProg INTO @idrow , @xml

	END 
	CLOSE CurProg
	DEALLOCATE CurProg

	--DROP TABLE #temp
	--drop table #TempColonne


END






GO
