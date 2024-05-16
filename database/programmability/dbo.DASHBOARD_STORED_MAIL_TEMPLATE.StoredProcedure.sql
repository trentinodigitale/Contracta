USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_STORED_MAIL_TEMPLATE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE proc [dbo].[DASHBOARD_STORED_MAIL_TEMPLATE]
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

	--filtro sul MP
	declare @mp varchar(100)

	set @mp=''

	select @mp=@mp + '(MP like ''%' + mplog + '%'') OR ' from marketplace order by idmp

	set @mp = substring(@mp, 1, len(@mp)-3)
	set @mp = '( ' + @mp + ' )'

	declare @CrLf varchar (10)
	set @CrLf = ''
	
	set @SQLCmd =  'select a.* from CTL_MAIL_TEMPLATE a'

	if rtrim( @Oggetto ) <> ''
		set @SQLCmd =  @SQLCmd + ' left outer join LIB_Multilinguismo obj on a.ML_KEY_OGGETTO=obj.ml_key and obj.ML_LNG=''I'' and obj.ML_Description like ' + @Oggetto + @CrLf  
	
	if rtrim( @Body ) <> ''
		set @SQLCmd =  @SQLCmd + ' left outer join LIB_Multilinguismo body on a.ml_key=body.ml_key and body.ML_LNG=''I'' and body.ML_Description like ' + @Body + @CrLf  
	
	if rtrim( @Multi_Doc ) <> ''
		set @SQLWhere =@SQLWhere + ' and Multi_Doc like ''%' + @Multi_Doc + '%'''+@CrLf  

	if rtrim( @Descrizione ) <> '' --and rtrim( @Multi_Doc ) <> '' 
		set @SQLWhere = @SQLWhere + ' and Descrizione  like ' + @Descrizione +   @CrLf  		

	if rtrim( @Oggetto ) <> ''
		set @SQLWhere = @SQLWhere + ' and ( obj.id is not null or dbo.CNV(a.ML_KEY_OGGETTO ,''I'')  like ' + @Oggetto + ')' + @CrLf  

	if rtrim( @Body ) <> ''
		set @SQLWhere = @SQLWhere + ' and (body.id is not null or dbo.CNV(a.ML_KEY ,''I'')  like ' + @Body + ')' + @CrLf 

	if rtrim( @ID ) <> ''
		set @SQLWhere = @SQLWhere + ' and a.ID =  ' + @ID + @CrLf 
	
	set @SQLCmd = @SQLCmd + ' where deleted=0' 

	if @SQLWhere <> ''
		set @SQLCmd = @SQLCmd + @SQLWhere

	if	@mp <> ''
		set @SQLCmd = @SQLCmd + ' AND ' +  @mp

	if @Sort <> ''
		set @SQLCmd = @SQLCmd + ' order by ' + replace(@Sort , 'id', 'a.id')
	
	
	exec (@SQLCmd)
	
	
	--print @SQLCmd

GO
