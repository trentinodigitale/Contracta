USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_CLASSE_ISCRIZ_DOMG]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[DASHBOARD_SP_CLASSE_ISCRIZ_DOMG]
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

	declare @Descrizione varchar(200)
	declare @dgLivello varchar(200)
	declare @dgCodiceEsterno varchar(200)
	declare @dgCodiceInterno varchar(200)
	
	
	declare @LNG varchar(10)
	
	select @LNG=lngSuffisso from Lingue where idlng=(select pfuIdLng from Profiliutente where idpfu=@IdPfu)




	set nocount on

	-- set @Param = Replace(@AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp,' ','')
	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
    
	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	
	set @SQLWhere = dbo.GetWhere( 'DominiGerarchici' , 'U', @AttrName ,  @AttrValue ,  @AttrOp )

	declare @CrLf varchar (10)
	set @CrLf = '
'
   
	-- criteri di ricerca
	set @Descrizione	= replace( dbo.GetParam( 'Descrizione' , @Param ,1) ,'''%','%')
	

	set @SQLCmd =  '
	select a.*,a.dgCodiceInterno as ID
	from DominiGerarchici a 
	'
	
	if @Descrizione <> ''
	begin
		set @SQLCmd =  @SQLCmd + ' inner join Descs' + @LNG + ' as L on L.iddsc = a.dgIdDsc  and dscTesto like ''' + replace(@Descrizione,'''','''''') + ''' '
	end
	
	if rtrim( @SQLWhere ) = '' and @Descrizione <> ''
	set @SQLCmd = @SQLCmd + 'and  dgDeleted = 0 and dgTipoGerarchia=(select dztIdTid from dbo.DizionarioAttributi where dztNome=''ClasseIscriz'') ' + @CrLf
	if rtrim( @SQLWhere ) = '' and @Descrizione=''
	   set @SQLCmd = @SQLCmd + 'where  dgDeleted = 0 and dgTipoGerarchia=(select dztIdTid from dbo.DizionarioAttributi where dztNome=''ClasseIscriz'') ' + @CrLf
	if rtrim( @SQLWhere ) <> '' 
		set @SQLCmd = @SQLCmd + ' where   dgDeleted = 0 and dgTipoGerarchia=(select dztIdTid from dbo.DizionarioAttributi where dztNome=''ClasseIscriz'') and' + @SQLWhere + @CrLf


    
	set @SQLCmd=@SQLCmd + ' order by dgPath asc'
	exec (@SQLCmd)
	
	--print @SQLCmd

	--set @cnt = @@rowcount





GO
