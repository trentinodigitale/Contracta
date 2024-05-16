USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_E_CERTIS_CRITERIA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[DASHBOARD_SP_E_CERTIS_CRITERIA]
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
	declare @Data as varchar(1500)
	declare @Descrizione as varchar(1500)
	
	
	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	
	set @Data			= dbo.GetParam( 'Data'		, @Param ,1)

	
	--costruisco select da eseguire
	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	
	--ricavo la condizone di where di base basata sulle colonne della vista  da cui tolgo l'ambito per gestirlo separatamente
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_E_CERTIS_CRITERIA' , 'V', @AttrName   ,  @AttrValue ,  @AttrOp )

	set @SQLCmd =  'select c.* from DASHBOARD_VIEW_E_CERTIS_CRITERIA c '
	
	
	if 	@SQLWhere <> ''
		set   @SQLCmd = @SQLCmd +  ' where ' + @SQLWhere
	

	if @Data  <> ''
	begin
		if 	@SQLWhere <> ''
			set   @SQLCmd = @SQLCmd + ' and '
		else
			set   @SQLCmd = @SQLCmd + ' where '

		set   @SQLCmd = @SQLCmd + ' convert( varchar(10) , startDate , 121 ) <= ''' + left( @Data , 10 ) + ''' and ''' + left( @Data , 10 ) + ''' <= convert( varchar(10) , endDate , 121 ) '

	end


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
