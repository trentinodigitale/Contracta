USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[FLES_SP_VIEW_SA1_STATI_AVANZAMENTO]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE                 proc [dbo].[FLES_SP_VIEW_SA1_STATI_AVANZAMENTO]
(@IdDoc							int,
 @Sort                          varchar(8000),
 @PageNumber					int = 1, 
 @PageSize						int = 2147483647,
 @Cnt                           int output
)
as
begin
	
	set nocount on
	
	declare @SQLCmd			nvarchar(max)
	declare @SQLOrder		nvarchar(max)

	--costruisco order
	set @SQLOrder = ''
	if rtrim(@Sort) <> ''
		begin
			set @SQLOrder = ' order by ' + @Sort
		end
	else
		begin
			set @SQLOrder = ' order by dataInvioScheda desc'
		end

	set @SQLCmd = 'select c.*, ROW_NUMBER() OVER (' + @SQLOrder + ') as RowNumber into #TempTable from FLES_VIEW_FLES_TBL_SCHEDA_SA1 c where c.IDDOC = ' + cast( @IdDoc as varchar(10)) + ' and LOWER(c.stato_bozza) in (''inviato'', ''ok'', ''errore'')'

	
	set @SQLCmd = @SQLCmd + @SQLOrder

	set @SQLCmd = @SQLCmd + '
	SELECT @Cnt = COUNT(*) FROM #TempTable
	SET @Cnt = @Cnt
	SELECT *, @Cnt AS Cnt FROM #TempTable
	WHERE RowNumber between (@PageNumber - 1) * @PageSize + 1 and @PageNumber * @PageSize
	DROP TABLE #TempTable'

	print(@SQLCmd)
	print(@PageNumber)
	print(@PageSize)

	EXEC sp_executesql @SQLCmd, N'@Cnt int, @PageNumber int, @PageSize int', @Cnt, @PageNumber, @PageSize;

end

GO
