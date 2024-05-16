USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_SP_DOMINI_GERARCHICI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD_DASHBOARD_SP_DOMINI_GERARCHICI]
(@IdPfu					  int,
 @AttrName				  varchar(8000),
 @AttrValue				  varchar(8000),
 @AttrOp					varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output,
 @maxLevel int = NULL,					   --parametro opzionale per indicare il livello massimo in cui cercare,
 @codiciDaEscludere  varchar(8000) = NULL  --parametro opzionale per indicare un filtro contenente i codice da escludere
)
as

--Versione=1&data=2013-09-23&Attivita=46453&Nominativo=Sabato
--Versione=2&data=2014-06-23&Attivita=58910&Nominativo=Federico

	declare @Param varchar(8000)


	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp


--	*** SCRIPT PER AGGIORNARE LA DOMAIN VALUES CON LE IMMAGINI CORRETTE PER IL DOMINIO GEO A SECONDA
--  SE IL RECORD è UNA FOGLIA O  MENO
--select l1.id, l1.DMV_Cod , l1.DMV_Level 
-- into #Temp3
-- from LIB_DomainValues l1 
--  left outer join LIB_DomainValues  l2 on l2.DMV_Level = l1.DMV_Level + 1 and  
--				  l1.DMV_Father = left( l2.DMV_Father , len ( l1.DMV_Father))
--				   and  l2.DMV_DM_ID =  'GEO' and l1.DMV_Cod <> l2.DMV_Cod
-- where l2.DMV_Cod is null and l1.DMV_DM_ID = 'GEO'
 
-- update LIB_DomainValues 
-- set dmv_image = '/CTL_Library/images/domain/node.gif'
-- where DMV_DM_ID =  'GEO' and id in ( select id from #Temp3 ) 
 
-- update LIB_DomainValues 
-- set dmv_image = '/CTL_Library/images/domain/folder.gif'
-- where DMV_DM_ID =  'GEO' and id not in ( select id from #Temp3 )

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
			from LIB_DomainValues with(nolock)
			where id = @idRiga
			
	end
	else
	-- altrimenti dalla root
	begin


		select  top 1 @Minimolivello = DMV_Level + 1 ,  @DMV_Father = DMV_Father  
			from LIB_DomainValues with(nolock)
			where DMV_DM_ID = @Filter --and isnull(DMV_Deleted ,0)= 0
			order by DMV_Father

	end

	
-------------------------------------------------------------------
-- creo la query di estrazione
-------------------------------------------------------------------


	set @SQLCmd =  'select * from  (
	select a.id, a.DMV_DM_ID, a.DMV_Cod, a.DMV_Father, a.DMV_Level, 
		
		REPLICATE( ''<img alt="" src="./CTL_Library/images/domain/nodisegno.gif"/>'' , a.DMV_Level )
			+ ''<img src=".'' + a.dmv_image + ''" alt=""/>'' as FolderImg,
			
		REPLICATE( ''<img alt="" src="../CTL_Library/images/domain/nodisegno.gif"/>'' , a.DMV_Level )
			+ ''<img src="..'' + a.dmv_image + ''" alt=""/>'' as FolderImg2,			

	
		REPLICATE( ''<img alt="" src="../CTL_Library/images/domain/nodisegno.gif"/>'' , a.DMV_Level )
		 + ''<img src="..'' + a.dmv_image + ''" alt=""/>'' +
		   cast( isnull( ML_Description , a.DMV_DescML ) as varchar(4000))  as Descrizione,
		 
		   cast( isnull( ML_Description , a.DMV_DescML ) as varchar(4000))  as DMV_DescML, 
		  
		 CASE
			WHEN a.dmv_image = ''/CTL_Library/images/domain/folder.gif'' THEN 0
			ELSE 1
		 END as isLeaf,

		a.DMV_Image, a.DMV_Sort, a.DMV_CodExt, a.DMV_Module, a.DMV_Deleted
	from LIB_DomainValues a with(nolock)
		inner join profiliutente with(nolock) on idpfu = ' + cast( @IdPfu as varchar(20)) + '
		inner join lingue with(nolock) on IdLng = pfuIdLng
		left outer join LIB_Multilinguismo with(nolock) on ML_LNG = lngSuffisso and DMV_DescML = ML_KEY
		
		-- LEFT OUTER JOIN LIB_DomainValues dmval ON dmval.DMV_DM_ID = a.DMV_DM_ID and dmval.DMV_Cod <> a.DMV_Cod and left( dmval.DMV_Father , len( a.DMV_Father )) = a.DMV_Father
		
	where 
		 a.DMV_DM_ID = ''' + @Filter + '''
		 '
	IF @maxLevel is not null
	BEGIN
		set @SQLCmd = @SQLCmd +	 ' and a.DMV_Level <= ' + cast( @maxLevel as varchar(20))
	END

	IF @codiciDaEscludere is not null
	BEGIN
		set @SQLCmd = @SQLCmd +	 ' and a.DMV_Cod not like ''' + @codiciDaEscludere + ''''
	END

	set @SQLCmd = @SQLCmd +	 '
	) as a

	where 1 = 1 
	
'
--where  isnull(DMV_Deleted , 0 ) = 0 

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
				left( DMV_Father , len( ''' + @DMV_Father + ''' )) = ''' + @DMV_Father + ''' and DMV_Level = ' + @Minimolivello + '
				or
				left( ''' + @DMV_Father + ''' , len( DMV_Father )) = DMV_Father
		)
		order by DMV_Father
		' + @CrLf

	end


	

exec (@SQLCmd)
--print @SQLCmd




GO
