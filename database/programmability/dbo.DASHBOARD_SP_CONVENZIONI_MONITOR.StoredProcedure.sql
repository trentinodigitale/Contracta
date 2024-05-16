USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_CONVENZIONI_MONITOR]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE proc [dbo].[DASHBOARD_SP_CONVENZIONI_MONITOR]
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)
as
begin

	declare @Param varchar(8000)
	declare @Profilo as varchar(1500)
	declare @Ambito as varchar(1500)
	declare @Descrizione as varchar(1500)
	declare @DOC_Name as varchar(1500)
	declare @dm_id as nvarchar(500) 
    declare @dm_query as nvarchar(max) 
    declare @Sql_Insert_Dinamici  nvarchar(max)
	declare @FormatDinamici as varchar(100)
	declare @Lng as varchar(10)
	declare @NomiColonneFrom as nvarchar(max)
    declare @LeftJoinDomain as nvarchar(max)
    declare @Cont as int
	declare @ListComunVista as varchar(max)
	declare @Macro_Convenzione as varchar(max) 
	declare @MakeExcel as int

	set nocount on
	
	set @MakeExcel=0
	set @Lng='I'

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	set @Ambito			= dbo.GetParam( 'Ambito'		, @Param ,1)
	set @Descrizione	= dbo.GetParam( 'Descrizione'	, @Param ,1)	
	set @Macro_Convenzione	= dbo.GetParam( 'Macro_Convenzione'	, @Param ,1)	
	

	--se nella FILTER alla fine è presente ~XSLX allora sto facendo excel e risolvo i domini chiusi 
	if @Filter<>''
	begin
		if RIGHT(ltrim(rtrim(@Filter)),5)='~XLSX'
		begin
			
			set @MakeExcel = 1

			set @Filter= replace (@Filter,'~XLSX','')

			--mi preparo per la codifica dei domini chiusi

			--creo tabella temporanea con i domini e con le codifiche dei codici
			CREATE TABLE #Codifiche_Codici_Dominio 
				(
					Dominio varchar(200) COLLATE database_default,
					codice varchar(600) COLLATE database_default,
					codifica nvarchar(max) COLLATE database_default
				)

	   
			--creo un indice sulla tabella temporanea per dominio e codice
			CREATE INDEX IXTEMP ON #Codifiche_Codici_Dominio(Dominio,codice)
	
			--creo tabella temporanea con gli attributi da decodificare
			CREATE TABLE #Model_Temp
				(
					MA_DZT_Name varchar(100) COLLATE database_default,
					Format_DZT_name varchar(500) COLLATE database_default
				)
	
			INSERT INTO #Model_Temp ( MA_DZT_Name, Format_DZT_name )
			select
				L.DZT_Name , L.DZT_Format  
				from 
					LIB_Dictionary L  with (nolock) 
				where   L.DZT_Name in ('IdentificativoIniziativa','Ambito','AZI_Dest','Macro_Convenzione', 'IdPfu')

	
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
						inner join LIB_Domain D  with (nolock)on D.DM_ID=L.DZT_DM_ID and isnull(cast(D.DM_Query as nvarchar(max)),'')=''	
						left JOIN LIB_DomainValues DV  with (nolock)on DV.DMV_DM_ID = D.DM_ID
						left outer join dbo.LIB_Multilinguismo mlg  with (nolock) on DMV_DescML = ML_KEY and ML_LNG='I'


				--costruisco la insert dimanica per codificare i domini che hanno una query dinamica
				DECLARE crsDinamici CURSOR STATIC FOR 
 					select 
						dm_id,cast(dm_query as nvarchar(max)),Format_DZT_name
						from 
						#Model_Temp M  with (nolock) 
						inner join LIB_Dictionary L with (nolock) on L.DZT_Name = M.MA_DZT_Name and L.dzt_type in ( 4,5,8 )
						--left join CTL_ModelAttributeProperties MP on MP.MAP_MA_MOD_ID=M.MA_MOD_ID and Mp.MAP_MA_DZT_Name='Format'
						inner join LIB_Domain D with (nolock) on D.DM_ID=L.DZT_DM_ID and isnull(cast(D.DM_Query as nvarchar(max)),'')<>''	
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

					set @dm_query = replace(@dm_query,'#LNG#','I')


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
								when CHARINDEX( ''D'', ''' + @FormatDinamici + ''' ) > 0 and CHARINDEX( ''C'', ''' + @FormatDinamici + ''' ) > 0 then isnull(DMV_CodExt,'''') + '' - '' +  cast( DMV_DescML as nvarchar( max)) 
			 
								else
									cast( DMV_DescML as nvarchar( max)) 

							end as Codifica_Codice_Dominio
							from 
								( '  + @dm_query + ' ) as DMV
								left  outer join #Codifiche_Codici_Dominio CONTR  with (nolock)  on CONTR.Dominio=''' + @dm_id + '''
								where CONTR.Dominio IS NULL
								'
			    	
		
    			--print 	@Sql_Insert_Dinamici
				
				exec(@Sql_Insert_Dinamici)

				FETCH NEXT FROM crsDinamici INTO @dm_id, @dm_query, @FormatDinamici

			END

			CLOSE crsDinamici 
			DEALLOCATE crsDinamici 
	
	

	
			--costruisco dinamicamente le colonne per la select e le left join sulla tabella dei domini temporanea da aggiungere alla tabella base per ogni attributo a dominio
			set @Cont=0
			set @LeftJoinDomain=''
			set @NomiColonneFrom=''
			--print @NomiColonneFrom

			select 
					@NomiColonneFrom = @NomiColonneFrom  + ',' + 
					case
						--when  L.dzt_type = 18 then ' dbo.getpos (' + Ma_DZT_Name + ',''*'',1) as ' + Ma_DZT_Name 
						when L.DZT_Type in (4,5,8) then ' Cod_'	+  cast(@Cont as varchar) + '.codifica as ' + Ma_DZT_Name 

						--else '[' + Ma_DZT_Name + ']'

					end 
			
					,@LeftJoinDomain = @LeftJoinDomain +
					case
						when L.DZT_Type in (4,5,8) then  ' left join #Codifiche_Codici_Dominio Cod_' +  cast(@Cont as varchar) + ' on  Cod_' +  cast(@Cont as varchar) + '.Dominio=''' + L.DZT_DM_ID + ''' and Cod_' +  cast(@Cont as varchar) + '.Codice=' + MA.ma_dzt_name + char(13) + char(10)
						else ''
					end	
			  
					,@Cont = @Cont +1
		  	 
					from #Model_Temp MA	 with (nolock) 
							inner join LIB_Dictionary L  with (nolock)  on L.DZT_Name = MA.MA_DZT_Name 
					where L.dzt_name in ('IdentificativoIniziativa','Ambito','AZI_Dest','Macro_Convenzione', 'IdPfu')
					order by ma_dzt_name

		 
				--tologo la ',' iniziale
			set @NomiColonneFrom = SUBSTRING ( @NomiColonneFrom ,2 , len(@NomiColonneFrom) )  


		end
	end

	
	--costruisco select da eseguire
	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	
	--ricavo la condizone di where di base basata sulle colonne della vista  da cui tolgo l'ambito per gestirlo separatamente
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_CONVENZIONI_MONITOR' , 'V',replace( replace(  @AttrName , 'Ambito' , '' ) , 'Macro_Convenzione' , '' ) ,  @AttrValue ,  @AttrOp )

	--recupero listra colonne DASHBOARD_VIEW_CONVENZIONI_MONITOR
	set @ListComunVista=''

	select  @ListComunVista = @ListComunVista + + ',' + a.name
	  from syscolumns a, sysobjects b
	 where a.id = b.id
	   and b.name = 'DASHBOARD_VIEW_CONVENZIONI_MONITOR' 
	
	
	--set @ListComunVista = LOWER(@ListComunVista)
	
	--se sto facendo esporta exce tolgo le colonne decodificate altrimenti sono duplicate
	if    @MakeExcel = '1'
	begin
		
		set @ListComunVista = @ListComunVista + ','

		set @ListComunVista = replace (@ListComunVista, ',ambito,',',')  
		set @ListComunVista = replace (@ListComunVista, ',azi_dest,',',')  
		set @ListComunVista = replace (@ListComunVista, ',Macro_Convenzione,',',')  
		set @ListComunVista = replace (@ListComunVista, ',IdentificativoIniziativa,',',')  
		set @ListComunVista = replace (@ListComunVista, ',Idpfu,',',')  
		

		set @ListComunVista = @ListComunVista + @NomiColonneFrom

	end

	
	--print @ListComunVista

	--tolgo la , iniziale
	set @ListComunVista = SUBSTRING ( @ListComunVista ,2 , len(@ListComunVista) )  

	set @SQLCmd =  'select ' + @ListComunVista + ' from DASHBOARD_VIEW_CONVENZIONI_MONITOR C '

	--nel caso di excel aggiungo left join per risolvere gli attributi a dominio
	if @MakeExcel='1'
	begin
		set @SQLCmd = @SQLCmd +
					'			' + @LeftJoinDomain +  char(13) + char(10) 
	end

	if @Descrizione <> '' 
	begin
		set @SQLCmd = @SQLCmd + ' inner join ( select distinct idheader from document_microlotti_dettagli d with(nolock) where d.tipodoc = ''CONVENZIONE'' and d.DESCRIZIONE_CODICE_REGIONALE like ''%' + replace ( @Descrizione  , '''' , '''''' ) + '%'' ) as D on d.idheader = C.id '
	end
	
	if 	@SQLWhere <> ''
		set   @SQLCmd = @SQLCmd + ' WHERE ' + @SQLWhere
	else
		set   @SQLCmd = @SQLCmd + ' WHERE 1 = 1 ' 
	
	--se è presente la colonna owner sulla vista DASHBOARD_VIEW_CONVENZIONI_MONITOR applico 
	--filtro per owner
	IF COL_LENGTH('DASHBOARD_VIEW_CONVENZIONI_MONITOR','owner') IS NOT NULL
	BEGIN
 		set @SQLCmd = @SQLCmd + ' and owner=' + cast(@IdPfu as varchar(50))
	END	
	
	if @Ambito  <> ''
		set   @SQLCmd = @SQLCmd + ' and Ambito in ( ''' + replace( @Ambito , '###' , ''',''' ) + ''' )  '

	--if @Macro_Convenzione <> ''
	--	set   @SQLCmd = @SQLCmd + ' and Macro_Convenzione in ( ''' + replace( @Macro_Convenzione , '###' , ''',''' ) + ''' )  '

	if @Macro_Convenzione <> ''
			set   @SQLCmd = @SQLCmd + ' and ''' +  @Macro_Convenzione +   ''' like ''%###'' + Macro_Convenzione + ''###%''  '


	
	if @Filter <> ''
		set   @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) '
	
	if rtrim( @Sort ) <> ''
		set @SQLCmd=@SQLCmd + ' order by ' + @Sort




	--print @SQLCmd
	exec (@SQLCmd)

	--select @cnt = count(*) from #temp
	--set @cnt = @@rowcount

end






GO
