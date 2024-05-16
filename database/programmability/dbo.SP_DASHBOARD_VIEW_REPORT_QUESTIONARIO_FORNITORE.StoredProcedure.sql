USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_DASHBOARD_VIEW_REPORT_QUESTIONARIO_FORNITORE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[SP_DASHBOARD_VIEW_REPORT_QUESTIONARIO_FORNITORE] 
			(
				 @IdPfu							int,
				 @AttrName						varchar(8000),
				 @AttrValue						varchar(8000),
				 @AttrOp 						varchar(8000),
				 @Filter                        varchar(8000),
				 @Sort                          varchar(8000),
				 @Top                           int,
				 @Cnt                           int output
			)
	as

	set nocount on

	declare @Param varchar(8000)
	declare @Operatore as varchar(10)
	declare @AreaGeograficaAlbo			varchar(5000)
	declare @Merc			varchar(5000)
	declare @SQLAZI			varchar(max)
	declare @SQLRESTRICTAZI		varchar(max)
	declare @SQLWhere			varchar(max)
	--declare @owner  varchar(50)

	set @SQLRESTRICTAZI = ''	

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
	declare @CrLf varchar (10)
	set @CrLf = '
'
	declare @SQLCmd			varchar(max)
	declare @SQLCmdFilter	varchar(max)
	declare @SQLFilterT		varchar(max)

	set @SQLCmdFilter = ''

	set @AreaGeograficaAlbo			= replace( dbo.GetParam( 'AreaGeograficaAlbo' , @Param ,1) ,'''','''''')
	
	set @Merc = replace( dbo.GetParam( 'MercForn' , @Param ,1) ,'''','''''')

	set @AttrName= replace( @AttrName, 'MercForn' ,'MercForn_XXX' )

	set @Filter = dbo.GetWhere( 'DASHBOARD_VIEW_REPORT_QUESTIONARIO_FORNITORE' ,'v', @AttrName , @AttrValue , @AttrOp)

	--set @owner = dbo.GetParam( 'OWNER' , @Param ,1)

	--insert into CTL_DOC_Value (IdHeader,value) values (-777777,@Filter)
	--insert into CTL_DOC_Value (IdHeader,value) values (-125819,@AreaGeograficaAlbo)
	--insert into CTL_DOC_Value (IdHeader,value) values (-777777,@Merc)
	--insert into CTL_DOC_Value (IdHeader,value) values (-125819,@AttrName)
	--insert into CTL_DOC_Value (IdHeader,value) values (-125819,@AttrValue)
	--insert into CTL_DOC_Value (IdHeader,value) values (-125819,@AttrOp)

	if @AreaGeograficaAlbo <> ''
	begin	
		
		select top 0 DMV_Father as ColPath 
			into #temp_AreaGeograficaAlbo 
				from lib_domainvalues  WITH (NOLOCK)

		exec recuperaPathDaDominio 'AreaGeograficaAlbo', @AreaGeograficaAlbo
		
	end 
	



	if @AreaGeograficaAlbo <> '' 
	begin 
		
		--SOLITAMENTE NEI FILTRI ANDIAMO PER OR
		--NEL CASO GESTIRE AND CON IL CURSORE
		set @Operatore = 'OR'
		-----------------------------
		---- RECUPERARE PARAMETRO @Operatore
		-----------------------------
		IF EXISTS ( select * from CTL_RELATIONS  WITH (NOLOCK) where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' and REL_VALUEINPUT='AreaGeograficaAlbo' )
		BEGIN
			 select top 1 @Operatore=REL_VALUEOUTPUT 
				from CTL_RELATIONS  WITH (NOLOCK) 
					where REL_TYPE='DASHBOARD_SP_DOSSIER_AZI' 
									and REL_VALUEINPUT='AreaGeograficaAlbo'
		END

		--LAVORA IN SALITA
		--Nella ricerca se cerco per una regione vuole significare che cerco un OE che 
		--è in grado di coprire tutta la regione, quindi mi usciranno OE 
		--che hanno selezionato quella regione oppure  l'italia 
		declare @navigaAlberoAreaGeograficaAlbo as nvarchar(max)
		
		set @navigaAlberoAreaGeograficaAlbo = ' inner join #temp_AreaGeograficaAlbo d on ( left( d.ColPath , len (  dm.dmv_father )) =   dm.dmv_father) '

			
		-- se il path della @AreaGeograficaAlbo sull'azienda è contenuto nel path ricercato oppure
		-- se il pathCercato è contenuto nel path dell'azienda (quindi gestiamo salita e discesa del gerarchico)
		set @SQLAZI = '  select a.idazi into #TempAzi_19 from  aziende a WITH (NOLOCK) inner join  dm_attributi c WITH (NOLOCK) on c.idapp= 1 and c.lnk = a.idazi and c.dztnome = ''AreaGeograficaAlbo''									
									inner join GESTIONE_DOMINIO_AreaGeograficaAlbo dm WITH (NOLOCK) on dm.dmv_cod=vatvalore_ft ' + @CrLf + @navigaAlberoAreaGeograficaAlbo + @CrLf + 
									' inner join #TempResulAziende t on t.idazi = a.IdAzi 
									where   azideleted=0 and dm.dmv_father <> '''' 


		truncate table   #TempResulAziende
		insert into #TempResulAziende ( idAzi ) select distinct idAzi    from #TempAzi_19	
		drop table #TempAzi_19
		' 
		
		set @SQLRESTRICTAZI = @SQLRESTRICTAZI + @CrLf + @SQLAZI
		

	end

	declare @FilterMerc varchar(max)

	set @FilterMerc = ''

	if @Merc <> ''
	begin
		
		select @FilterMerc = 'MercForn like ''%###' +  items + '###%'' OR ' + @FilterMerc  
					from dbo.split(@Merc,'###')

		if len(@FilterMerc) > 4
			set @FilterMerc = SUBSTRING( @FilterMerc, 1, len(@FilterMerc)-3 ) 

		if @Filter = ''
			set @Filter =  ' ( ' + @FilterMerc + ' ) '
		else
			set @Filter = @Filter + ' AND ( ' + @FilterMerc + ' )'


	end

	---insert into CTL_DOC_Value (IdHeader,value) values (-777777,@Filter)
	
	--------------------------- QUERY ------------------------------
	set @SQLCmd =  ''
	
	
		set @SQLCmd = 'create table  #TempResulAziende ( idAzi  Int )
		insert into #TempResulAziende select idazi from aziende ' + @Crlf + @SQLRESTRICTAZI  + @Crlf

	

	set @SQLCmd = @SQLCmd + '
		select d.* 
			from DASHBOARD_VIEW_REPORT_QUESTIONARIO_FORNITORE d
			where 1=1 ' + @CrLf

	--if @owner <> ''
		--set @SQLCmd = @SQLCmd + ' and ' +  @owner + ' = ' + cast(@idpfu as varchar(10)) + ' '
		set @SQLCmd = @SQLCmd + ' and idpfu = ' + cast(@idpfu as varchar(10)) + ' '
	
		set @SQLCmd = @SQLCmd + ' and idazi in ( select idazi from #TempResulAziende ) '

	


	if @Filter <> '' 
		set @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) ' + @CrLf


	if @Sort <> ''
		set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort  + @CrLf


	
		set @SQLCmd = @SQLCmd + ' drop table  #TempResulAziende '
	

	--insert into CTL_DOC_Value (IdHeader,value) values (-12581,@SQLCmd)

	exec (@SQLCmd)
	--print @SQLCmd
	
	--set @cnt = @@rowcount



GO
