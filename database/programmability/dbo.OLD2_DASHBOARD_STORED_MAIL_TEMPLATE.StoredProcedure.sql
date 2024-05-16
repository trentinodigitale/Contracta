USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DASHBOARD_STORED_MAIL_TEMPLATE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[OLD2_DASHBOARD_STORED_MAIL_TEMPLATE]
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
	declare @Param varchar(8000)

	declare @ML_KEY varchar(200)
	declare @Descrizione varchar(8000)
	declare @Multi_Doc varchar(8000)
	declare @dgLivello varchar(200)
	declare @dgCodiceEsterno varchar(200)
	declare @dgCodiceInterno varchar(200)
	declare @Oggetto varchar(MAX)
	declare @Body varchar(MAX)
	declare @ID varchar(200)
	
	
	declare @LNG varchar(10)
	
	select @LNG=lngSuffisso from Lingue where idlng=(select pfuIdLng from Profiliutente where idpfu=@IdPfu)




	set nocount on

	--set @Param = Replace(@AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp,' ','')
	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	
    
	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	set @SQLWhere=''
	
	--set @SQLWhere = dbo.GetWhere( 'DominiGerarchici' , 'U', @AttrName ,  @AttrValue ,  @AttrOp )
	
	-- criteri di ricerca
	set @ML_KEY	= dbo.GetParam( 'ML_KEY' , @Param,0) 
	set @Descrizione=dbo.GetParam( 'Descrizione' , @Param,0) 
	set @Multi_Doc=Replace(dbo.GetParam( 'Multi_Doc_filtro' , @Param,0),'''','') 	
	set @Oggetto=dbo.GetParam( 'Oggetto' , @Param,0) 
	set @Body=dbo.GetParam( 'Body' , @Param,0) 
	set @ID=dbo.GetParam( 'ID' , @Param,0) 


	declare @CrLf varchar (10)
	set @CrLf = ''
	
	set @SQLCmd =  'select * from CTL_MAIL_TEMPLATE'
	
	
	if rtrim( @Multi_Doc ) <> ''
		set @SQLWhere =@SQLWhere + ' and Multi_Doc like ''%' + @Multi_Doc + '%'''+@CrLf  

	if rtrim( @Descrizione ) <> '' --and rtrim( @Multi_Doc ) <> '' 
		set @SQLWhere = @SQLWhere + ' and Descrizione  like ' + @Descrizione +   @CrLf  		

	if rtrim( @Oggetto ) <> ''
		set @SQLWhere = @SQLWhere + ' and dbo.CNV(ML_KEY_OGGETTO ,''I'')  like ' + @Oggetto + @CrLf  

	if rtrim( @Body ) <> ''
		set @SQLWhere = @SQLWhere + ' and dbo.CNV(ML_KEY ,''I'')  like ' + @Body + @CrLf 

	if rtrim( @ID ) <> ''
		set @SQLWhere = @SQLWhere + ' and ID =  ' + @ID + @CrLf 
	
	set @SQLCmd = @SQLCmd + ' where deleted=0' 

	if @SQLWhere <> ''
		set @SQLCmd = @SQLCmd + @SQLWhere


	if @Sort <> ''
		set @SQLCmd = @SQLCmd + ' order by ' + @Sort 
	
	
	exec (@SQLCmd)
	
	
	--print @SQLCmd


GO
