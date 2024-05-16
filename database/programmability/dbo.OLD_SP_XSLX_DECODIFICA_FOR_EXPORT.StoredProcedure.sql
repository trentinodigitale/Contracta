USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SP_XSLX_DECODIFICA_FOR_EXPORT]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[OLD_SP_XSLX_DECODIFICA_FOR_EXPORT] ( @Table as nvarchar(max),@Model as varchar(500), @SqlWhere as nvarchar(max),@Lng as varchar(10),@Idpfu as int,@HideCols as nvarchar(max) , @UseCols as nvarchar(max) = '' , @OrderBy as nvarchar(max) = ''  , @Extracol as nvarchar(max) = '', @ShowAttach as varchar(10)='SI' ) 

AS

	--declare @Table as nvarchar(500)
 --   declare @Model as varchar(500)
 --   declare @SqlWhere as nvarchar(max)
 --   declare @Lng as varchar(10)
 --   declare @Idpfu as int
 --   declare @HideCols as nvarchar(max)
	--declare  @UseCols as nvarchar(max)
	--declare @OrderBy as nvarchar(max) 	--declare  @Extracol as nvarchar(max) 

	
    
 --   set @Table='DASHBOARD_VIEW_ODC_ALL'
 --   set @Model='DASHBOARD_VIEW_TestataOrdiniGriglia'
 --   set @SqlWhere = 'StatoDoc in (''Sended'') or (rda_stato=''Saved'' and fuoripiattaforma=''si'') '
 --   set @Lng = 'I'
 --   set @HideCols = ',,IDROW,ID,ESITORIGA,NOTEDITABLE,TIPODOC,FNZ_DEL,FNZ_UDP,FNZ_ADD,OPEN_DOC_NAME,FNZ_OPEN,Object,RDA_ID,'
	--set @UseCols = ''
	--set @OrderBy = 'RDA_DataCreazione , RDA_ID desc'
	--set @Extracol = ''

    declare @Sql  nvarchar(max)
    declare @NomiColonneFrom as nvarchar(max)
    declare @LeftJoinDomain as nvarchar(max)
    declare @Cont as int
    declare @dm_id as nvarchar(500) 
    declare @dm_query as nvarchar(max) 
    declare @Sql_Insert_Dinamici  nvarchar(max)
    declare @FormatDinamici as varchar(100)
    declare @TableModel as varchar(100)
    declare @TableModelProp as varchar(100)
	
    set @Cont=0

    declare @crlf varchar(20)
    set @crlf = ''


	--conservo le colonne ritorante dalla tabella/vista in una tabella temporanea
	select column_name into #Column_Of_Table from information_schema.columns where table_name = replace( @Table , '#' , '' )

	
    if @Model='' and @UseCols = ''
    begin
		

		set @Sql = 'select * from ' + @Table 

		if @SqlWhere <> ''
			set @Sql = @Sql +' where ' + @SqlWhere

		if @OrderBy <> ''
			set @Sql = @Sql + '  Order by ' + @OrderBy

	end
    else
    begin

		--creo tabella temporanea con i domini e con le codifiche dei codici
		CREATE TABLE #Codifiche_Codici_Dominio 
			(
				Dominio varchar(200) COLLATE database_default,
				codice varchar(600) COLLATE database_default,
				codifica nvarchar(max) COLLATE database_default
			)

	   
		--creo un indice sulla tabella temporanea per dominio e codice
		CREATE INDEX IXTEMP ON #Codifiche_Codici_Dominio(Dominio,codice)

		--creo tabella temporanea con gli attributi del modello
		CREATE TABLE #Model_Temp
			(
				MA_DZT_Name varchar(100) COLLATE database_default,
				Format_DZT_name varchar(500) COLLATE database_default
			)

				
		if @UseCols <> '' 
		begin

			INSERT INTO #Model_Temp ( MA_DZT_Name, Format_DZT_name )
				select
					L.DZT_Name , L.DZT_Format  
					from 
						dbo.Split( @UseCols , ',' )  M
						inner join LIB_Dictionary L on L.DZT_Name = M.items --and L.dzt_type in ( 4,5,8 )
					where   charindex(  ',' + M.items + ',' , @HideCols ) = 0	 
			
		end
		else
		begin

			--recupero gli attributi del MODELLO in input dalle CTL oppure dalle LIB
			IF EXISTS (SELECT * from CTL_Models with(nolock) where MOD_ID=@Model)
			begin

				INSERT INTO #Model_Temp ( MA_DZT_Name, Format_DZT_name )
					select 
						L.DZT_Name , isnull( MP.MAP_Value,L.DZT_Format ) 
						from 
							CTL_ModelAttributes M with (nolock)
							inner join LIB_Dictionary L with (nolock) on L.DZT_Name = M.MA_DZT_Name --and L.dzt_type in ( 4,5,8 )
							left join CTL_ModelAttributeProperties MP with (nolock) on MP.MAP_MA_MOD_ID=M.MA_MOD_ID and Mp.MAP_MA_DZT_Name=M.MA_DZT_Name and MP.MAP_Propety ='Format'
							left join CTL_ModelAttributeProperties MP1 with (nolock) on MP1.MAP_MA_MOD_ID=M.MA_MOD_ID and Mp1.MAP_MA_DZT_Name=M.MA_DZT_Name and MP1.MAP_Propety ='Hide'
							inner join #Column_Of_Table with (nolock) on column_name= M.MA_DZT_Name
						where M.MA_MOD_ID = @Model and  charindex(  ',' + M.MA_DZT_Name + ',' , @HideCols ) = 0	 and ISNULL(MP1.MAP_Value,'0')='0' 

			end
			else
			begin
		  
				INSERT INTO #Model_Temp ( MA_DZT_Name, Format_DZT_name )
					select 
						L.DZT_Name , isnull( MP.MAP_Value,L.DZT_Format )
						from 
							LIB_ModelAttributes M with (nolock)
							inner join LIB_Dictionary L with (nolock) on L.DZT_Name = M.MA_DZT_Name --and L.dzt_type in ( 4,5,8 )
							left join LIB_ModelAttributeProperties MP with (nolock) on MP.MAP_MA_MOD_ID=M.MA_MOD_ID and Mp.MAP_MA_DZT_Name=M.MA_DZT_Name and MP.MAP_Propety ='Format'
							left join LIB_ModelAttributeProperties MP1 with (nolock) on MP1.MAP_MA_MOD_ID=M.MA_MOD_ID and Mp1.MAP_MA_DZT_Name=M.MA_DZT_Name and MP1.MAP_Propety ='Hide'
							left join CTL_Parametri CP with(nolock) on CP.Contesto=M.MA_MOD_ID and CP.oggetto=M.MA_DZT_Name and CP.Proprieta='Hide'
							inner join #Column_Of_Table with (nolock) on column_name= M.MA_DZT_Name
						where M.MA_MOD_ID = @Model and charindex(  ',' + M.MA_DZT_Name + ',' , @HideCols ) = 0	  and COALESCE( CP.Valore,MP1.MAP_Value,'0')='0' 
	   
			end
		end

		--inserisco le codifiche dei domini senza query nella tabella temporanea #Codifiche_Codici_Dominio
		INSERT INTO #Codifiche_Codici_Dominio ( Dominio, codice, codifica )
			select distinct 
					DV.DMV_DM_ID,	 DV.DMV_Cod ,
					case
						when Format_DZT_name = '' then isnull( cast( ML_Description as nvarchar(max)), cast( DMV_DescML as nvarchar( max))) 
						--solo il codice esterno
						when CHARINDEX( 'D', Format_DZT_name )=0 and CHARINDEX( 'C', Format_DZT_name ) > 0 then isnull(DMV_CodExt,'') 
						--solo la desc
						when CHARINDEX( 'D', Format_DZT_name )>0 and CHARINDEX( 'C', Format_DZT_name ) =0 then isnull( cast( ML_Description as nvarchar(max)), cast( DMV_DescML as nvarchar( max))) 
						--codice esterno e desc
						when CHARINDEX( 'D',Format_DZT_name ) >0 and CHARINDEX( 'C', Format_DZT_name ) > 0 then isnull(DMV_CodExt,'') + ' - ' + isnull( cast( ML_Description as nvarchar(max)), cast( DMV_DescML as nvarchar( max))) 
			 
						else
						isnull( cast( ML_Description as nvarchar(max)), cast( DMV_DescML as nvarchar( max))) 

					end as Codifica_Codice_Dominio

				from 
					#Model_Temp M with (nolock)
					inner join LIB_Dictionary L with (nolock) on L.DZT_Name = M.MA_DZT_Name and L.dzt_type in ( 4,5,8 )
					--left join CTL_ModelAttributeProperties MP on MP.MAP_MA_MOD_ID=M.MA_MOD_ID and Mp.MAP_MA_DZT_Name='Format'
					inner join LIB_Domain D  with (nolock) on D.DM_ID=L.DZT_DM_ID and isnull(cast(D.DM_Query as nvarchar(max)),'')=''	
					left JOIN LIB_DomainValues DV  with (nolock)  on DV.DMV_DM_ID = D.DM_ID
					left outer join dbo.LIB_Multilinguismo mlg  with (nolock)  on DMV_DescML = ML_KEY and ML_LNG=@Lng

				--where M.MA_MOD_ID = @Model and charindex(  ',' + M.MA_DZT_Name + ',' , @HideCols ) = 0

		  
		  --costruisco la insert dimanica per codificare i domini che hanno una query dinamica
		  DECLARE crsDinamici CURSOR STATIC FOR 
 			  select distinct
				 dm_id,cast(dm_query as nvarchar(max)),Format_DZT_name
				 from 
					#Model_Temp M with (nolock) 
					inner join LIB_Dictionary L  with (nolock) on L.DZT_Name = M.MA_DZT_Name and L.dzt_type in ( 4,5,8 )
					--left join CTL_ModelAttributeProperties MP on MP.MAP_MA_MOD_ID=M.MA_MOD_ID and Mp.MAP_MA_DZT_Name='Format'
					inner join LIB_Domain D  with (nolock) on D.DM_ID=L.DZT_DM_ID and isnull(cast(D.DM_Query as nvarchar(max)),'')<>''	
				 --where M.MA_MOD_ID = @Model and charindex(  ',' + M.MA_DZT_Name + ',' , @HideCols ) = 0

		  OPEN crsDinamici

		  FETCH NEXT FROM crsDinamici INTO @dm_id, @dm_query, @FormatDinamici
		  WHILE @@FETCH_STATUS = 0
		  BEGIN
			 
			 
			 if charindex( ' order by' , @dm_query ) > 0 
			 begin 
				set @dm_query = left( @dm_query , charindex( ' order by' , @dm_query ) )
			 end

			 if charindex( 'order by' , @dm_query ) > 0 
			 begin 
				set @dm_query = left( @dm_query , charindex( 'order by' , @dm_query )-1 )
			 end

			 --sostutisco la lingua per avere le desc in lingua
			 set @dm_query = replace(@dm_query,'#LNG#',@Lng)


			 set @Sql_Insert_Dinamici = '

				INSERT INTO #Codifiche_Codici_Dominio ( Dominio, codice, codifica )
			
				select 
				    ''' + @dm_id + ''',	 DMV.DMV_Cod ,
				    
					   case
						  when ''' + @FormatDinamici + ''' ='''' then cast( DMV_DescML as nvarchar( max)) 
						  --solo il codice esterno
						  when CHARINDEX( ''D'', ''' + @FormatDinamici + ''' ) = 0 and CHARINDEX( ''C'', ''' + @FormatDinamici + ''' ) > 0 then isnull(DMV_CodExt,'''') 
						  --solo la desc
						  when CHARINDEX( ''D'', ''' + @FormatDinamici + ''' ) > 0 and CHARINDEX( ''C'', ''' + @FormatDinamici + ''' ) = 0 then cast( DMV_DescML as nvarchar( max)) 
						  --codice esterno e desc
						  when CHARINDEX( ''D'', ''' + @FormatDinamici + ''' ) > 0 and CHARINDEX( ''C'', ''' + @FormatDinamici + ''' ) > 0 then isnull(DMV_CodExt,'''') + '' - '' + cast( DMV_DescML as nvarchar( max)) 
			 
						  else
							 cast( DMV_DescML as nvarchar( max)) 

					   end as Codifica_Codice_Dominio
					   from 
						  ( '  + @dm_query + ' ) as DMV
						   left  outer join #Codifiche_Codici_Dominio CONTR with (nolock) on CONTR.Dominio=''' + @dm_id + '''
						   where CONTR.Dominio IS NULL
						   '
			    	
			--print  @Sql_Insert_Dinamici
    				
			exec(@Sql_Insert_Dinamici)

			FETCH NEXT FROM crsDinamici INTO @dm_id, @dm_query, @FormatDinamici

		END

		CLOSE crsDinamici 
		DEALLOCATE crsDinamici 

		  
		--costruisco dinamicamente le colonne per la select e le left join sulla tabella dei domini temporanea da aggiungere alla tabella base per ogni attributo a dominio
		set @Cont=0
		set @LeftJoinDomain=''
		set @NomiColonneFrom=@Extracol
		
		
		select 
				 @NomiColonneFrom = @NomiColonneFrom  + ',' + 
					case
						when  L.dzt_type = 18 then ' dbo.getpos (' + Ma_DZT_Name + ',''*'',1) as ' + Ma_DZT_Name 
						when L.DZT_Type in (4,5,8) then ' ISNULL(Cod_'	+  cast(@Cont as varchar) + '.codifica,' + Ma_DZT_Name + ') as ' + Ma_DZT_Name 
						--aggiunto parametro @table avanti alla colonna perchè nell'esecuzione finale andava in errore Ambiguous column 
						else case when OBJECT_ID (@table, N'U') IS NOT NULL or OBJECT_ID (@table, N'V')  IS NOT NULL then @table + '.' else '' end +'[' + Ma_DZT_Name + ']'
					end 
			
				 ,@LeftJoinDomain = @LeftJoinDomain +
					case
						when L.DZT_Type in (4,5,8) then  ' left join #Codifiche_Codici_Dominio Cod_' +  cast(@Cont as varchar) + ' on  Cod_' +  cast(@Cont as varchar) + '.Dominio=''' + L.DZT_DM_ID + ''' and Cod_' +  cast(@Cont as varchar) + '.Codice=' + MA.ma_dzt_name + char(13) + char(10)
						else ''
					end	
			  
				 ,@Cont = @Cont +1
		  	 
			from #Model_Temp MA	
				inner join LIB_Dictionary L with (nolock) on L.DZT_Name = MA.MA_DZT_Name and  
				(
					(@ShowAttach='SI')
					or
					(L.dzt_type <> 18 and @ShowAttach='NO')

				)
				 -- esclusi gli allegati
			 --where 
			 --   MA_MOD_ID=@Model and charindex(  ',' + MA.MA_DZT_Name + ',' , @HideCols ) = 0
			order by ma_dzt_name
		
		 
		 --tologo la ',' iniziale
		set @NomiColonneFrom = SUBSTRING ( @NomiColonneFrom ,2 , len(@NomiColonneFrom) )  

		 --print (@NomiColonneFrom)
		 --print (@LeftJoinDomain)
		 --print @NomiColonneFrom

		IF ltrim(rtrim(@NomiColonneFrom)) = ''
			SET @NomiColonneFrom = ' * '

		 --compongo la query finale
		set @Sql = 'select ' + @NomiColonneFrom + 
				    '  from ' + @Table +  char(13) + char(10) + '  '   -- tolta la clausola 
				    
		
		if exists( select o.xtype from sysobjects o where 	o.name = @Table and o.xtype = 'U' )
			set @Sql = @Sql + ' with( nolock ) '
	
		set @Sql = @Sql + '         ' + @LeftJoinDomain +  char(13) + char(10) 

				
		if  @SqlWhere <> '' 
			set @Sql = @Sql + '  where ' + @SqlWhere

		--set @Sql = @Sql + '  and NumOrd=''00000425'' '

		if @OrderBy <> ''
			set @Sql = @Sql + '  Order by ' + @OrderBy

	    
    end

	--select @Sql
    exec (@Sql)

    
    drop table #Codifiche_Codici_Dominio
    drop table #Model_Temp















GO
