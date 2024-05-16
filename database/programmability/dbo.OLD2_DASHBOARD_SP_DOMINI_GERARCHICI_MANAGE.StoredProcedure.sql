USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DASHBOARD_SP_DOMINI_GERARCHICI_MANAGE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[OLD2_DASHBOARD_SP_DOMINI_GERARCHICI_MANAGE]
(@IdPfu					  int,
 @AttrName				  varchar(8000),
 @AttrValue				  varchar(8000),
 @AttrOp 					  varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)
as

--Versione=1&data=2015-02-12&Attivita=69685&Nominativo=Francesco


	declare @Param varchar(8000)


	--sostituisco in attrname azideleted con dmv_deleted

	set @AttrName = replace(@AttrName,'aziDeleted','dmv_deleted')

	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp


	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	declare @idRiga			varchar(500)
	declare @DMV_DM_ID		varchar(500)
	declare @DMV_Father		varchar(500)

	declare @Minimolivello	varchar(20)

	set @SQLWhere = dbo.GetWhere( 'LIB_DomainValues' , 'U', @AttrName ,  @AttrValue ,  @AttrOp )

	declare @CrLf varchar (10)
	set @CrLf = '
'

	set @idRiga	=''


	if charindex(   ' and ' , @Filter ) > 0 
	begin
		set @idRiga = substring( @Filter , charindex(   ' and ' , @Filter ) + 5  , 100 )
		set @Filter = left( @Filter , charindex(   ' and ' , @Filter )  )
	end


	-- criteri di ricerca
	--set @idRiga				= replace( dbo.GetParam( 'ID_RIGA' , @Param ,1) ,'''','''''')


	-- se è selezionata una riga si visualizza la gerarchia da quella riga
	if @idRiga <> ''
	begin
		select  top 1 @Minimolivello = DMV_Level + 1,  @DMV_Father = DMV_Father  
			from LIB_DomainValues 
			where id = @idRiga
			
	end
	else
	-- altrimenti dalla root
	begin


		select  top 1 @Minimolivello = DMV_Level + 1 ,  @DMV_Father = DMV_Father  
			from LIB_DomainValues 
			where DMV_DM_ID = @Filter and isnull(DMV_Deleted ,0)= 0
			order by DMV_Father

	end

	
-------------------------------------------------------------------
-- creo la query di estrazione
-------------------------------------------------------------------


	set @SQLCmd =  'select * from  (
	select a.id, DMV_DM_ID, DMV_Cod, DMV_Father, DMV_Level, 
		
		REPLICATE( ''<img alt="" src="../CTL_Library/images/domain/nodisegno.gif"/>'' , DMV_Level ) +
		dbo.GetImgFolderNode( DMV_DM_ID , DMV_Cod , DMV_Father ) as FolderImg,

		REPLICATE( ''<img alt="" src="../CTL_Library/images/domain/nodisegno.gif"/>'' , DMV_Level ) +
		dbo.GetImgFolderNode( DMV_DM_ID , DMV_Cod , DMV_Father ) +
		  cast( isnull( ML_Description , DMV_DescML ) as varchar(4000)) as Descrizione, 
		  cast( isnull( ML_Description , DMV_DescML ) as varchar(4000)) as DMV_DescML, 

		DMV_Image, DMV_Sort, DMV_CodExt, DMV_Module, DMV_Deleted

		,  cast( isnull( ML_Description , DMV_DescML ) as varchar(4000)) as CampoTesto 
		, isnull(DMV_Deleted , 0 )  as azideleted
	from LIB_DomainValues a 
		inner join profiliutente on idpfu = ' + cast( @IdPfu as varchar(20)) + '
		inner join lingue on IdLng = pfuIdLng
		left outer join LIB_Multilinguismo on ML_LNG = lngSuffisso and DMV_DescML = ML_KEY
		
	where 
		 DMV_DM_ID = ''' + @Filter + '''
	) as a

	--where  isnull(DMV_Deleted , 0 ) = 0 
	where  1=1
	
'
	-- se è presente un filtro si visualizza tutto il dominio
	if rtrim( isnull(@SQLWhere ,'')) <> '' and @idRiga = ''
	begin
		set @SQLCmd = @SQLCmd + ' and ' + @SQLWhere + @CrLf


		if @Sort <> ''
			set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort  + @CrLf

	end
	else
	-- altrimenti si visualizza solo la gerarchia interessata
	begin
		set @SQLCmd = @SQLCmd + '
		and (
				left( DMV_Father , len( ''' + replace(@DMV_Father,'''','''''') + ''' )) = ''' + @DMV_Father + ''' and DMV_Level = ' + @Minimolivello + '
				or
				left( ''' + replace(@DMV_Father,'''','''''') + ''' , len( DMV_Father )) = DMV_Father
		)
		order by DMV_Father
		' + @CrLf

	end


	

	exec (@SQLCmd)
	--print @SQLCmd






GO
