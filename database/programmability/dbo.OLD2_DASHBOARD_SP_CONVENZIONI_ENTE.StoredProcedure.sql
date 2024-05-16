USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DASHBOARD_SP_CONVENZIONI_ENTE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[OLD2_DASHBOARD_SP_CONVENZIONI_ENTE]
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
	
	
	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	
	set @Ambito			= dbo.GetParam( 'Ambito'		, @Param ,1)
	set @Descrizione	= dbo.GetParam( 'Descrizione'	, @Param ,1)

	
	--costruisco select da eseguire
	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	
	--ricavo la condizone di where di base basata sulle colonne della vista  da cui tolgo l'ambito per gestirlo separatamente
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_CONVENZIONI_ENTE' , 'V',replace(  @AttrName , 'Ambito' , '' ) ,  @AttrValue ,  @AttrOp )

	set @SQLCmd =  'select c.* from DASHBOARD_VIEW_CONVENZIONI_ENTE c '
	
	if @Descrizione <> '' 
	begin
		set @SQLCmd = @SQLCmd + ' inner join ( select distinct idheader from document_microlotti_dettagli d with(nolock) where d.tipodoc = ''CONVENZIONE'' and d.DESCRIZIONE_CODICE_REGIONALE like ''%' + replace ( @Descrizione  , '''' , '''''' ) + '%'' ) as D on d.idheader = C.id '
	end
	
	set @SQLCmd = @SQLCmd + ' where owner = ' + cast( @IdPfu as varchar(10))

	if 	@SQLWhere <> ''
		set   @SQLCmd = @SQLCmd +  ' and ' + @SQLWhere
	

	if @Ambito  <> ''
		set   @SQLCmd = @SQLCmd + ' and Ambito in ( ''' + replace( @Ambito , '###' , ''',''' ) + ''' )  '
	
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
