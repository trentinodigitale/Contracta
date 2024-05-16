USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_SP_CONVENZIONI_MONITOR_XSLX]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[OLD_DASHBOARD_SP_CONVENZIONI_MONITOR_XSLX]
(
	 @Filter                        varchar(8000)
)
as
begin

	declare @AttrName						varchar(8000)
	declare @AttrValue						varchar(8000)
	declare @AttrOp 						varchar(8000)

	declare @Descrizione as varchar(1500)

	set @AttrName	= dbo.GetPos(@Filter , '#~#'  , 1 )
	set @AttrValue	= dbo.GetPos(@Filter , '#~#'  , 2 )
	set @AttrOp		= dbo.GetPos(@Filter , '#~#'  , 3 )

	declare @Cnt int 


	declare @Param varchar(8000)
	declare @Profilo as varchar(1500)
	declare @Ambito as varchar(1500)
	declare @Macro_Convenzione as varchar(max) 
	
	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	set @Ambito			= dbo.GetParam( 'Ambito'		, @Param ,1)
	set @Descrizione	= dbo.GetParam( 'Descrizione'	, @Param ,1)	
	set @Macro_Convenzione	= dbo.GetParam( 'Macro_Convenzione'	, @Param ,1)	

	set @Macro_Convenzione = replace ( @Macro_Convenzione , '''' , '' )
	--print @Macro_Convenzione
	
	--costruisco select da eseguire
	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	
	--ricavo la condizone di where di base basata sulle colonne della vista  da cui tolgo l'ambito per gestirlo separatamente
	set @SQLWhere = dbo.GetWhere( 'XLSX_ESPORTA_LISTINI_VIEW' , 'V',replace( replace(  @AttrName , 'Ambito' , '' ) , 'Macro_Convenzione' , '' )  ,  @AttrValue ,  @AttrOp )

	set @SQLCmd =  'select C.* from XLSX_ESPORTA_LISTINI_VIEW C '
	if @Descrizione <> '' 
	begin
		set @SQLCmd = @SQLCmd + ' inner join ( select distinct idheader from document_microlotti_dettagli d with(nolock) where d.tipodoc = ''CONVENZIONE'' and d.DESCRIZIONE_CODICE_REGIONALE like ''%' + replace ( @Descrizione  , '''' , '''''' ) + '%'' ) as D on d.idheader = C.id '
	end
	
	if 	@SQLWhere <> ''
		set   @SQLCmd = @SQLCmd + ' WHERE ' + @SQLWhere
	else
		set   @SQLCmd = @SQLCmd + ' WHERE 1 = 1 '

	if @Ambito  <> ''
		set   @SQLCmd = @SQLCmd + ' and Ambito in ( ''' + replace( @Ambito , '###' , ''',''' ) + ''' )  '
	

	if @Macro_Convenzione <> ''
			set   @SQLCmd = @SQLCmd + ' and ''' +  @Macro_Convenzione +   ''' like ''%###'' + Macro_Convenzione + ''###%''  '


--		set   @SQLCmd = @SQLCmd + ' and Macro_Convenzione in ( ''' + replace( @Macro_Convenzione , '###' , ''',''' ) + ''' )  '


	--if @Filter <> ''
	--	set   @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) '
	
	--if rtrim( @Sort ) <> ''
	--	set @SQLCmd=@SQLCmd + ' order by ' + @Sort




	--print @SQLCmd
	exec (@SQLCmd)

	--select @cnt = count(*) from #temp
	--set @cnt = @@rowcount



end





GO
