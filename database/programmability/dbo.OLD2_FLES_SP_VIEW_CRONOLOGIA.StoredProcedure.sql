USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_FLES_SP_VIEW_CRONOLOGIA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE               proc [dbo].[OLD2_FLES_SP_VIEW_CRONOLOGIA]
(@IdDoc							int,
 @TipoScheda                    varchar(8000),
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
			set @SQLOrder = ' order by DataInvio desc'
		end
	
	set @SQLCmd = 'select srvIntReq.DataInvio, srvIntReq.Utente,  LEFT(srvIntReq.Scheda,CASE WHEN CHARINDEX(''@'', srvIntReq.Scheda) = 0 THEN LEN(srvIntReq.Scheda) ELSE
        CHARINDEX(''@'', srvIntReq.Scheda) - 1 END) as scheda, srvIntReq.Esito, srvIntReq.DettaglioScheda, srvIntReq.DettaglioEsito, ROW_NUMBER() OVER (' + @SQLOrder + ') as RowNumber into #TempTable from FLES_VIEW_SERVICES_INTEGRATION_REQUEST srvIntReq 
	 where srvIntReq.Scheda like ''I1%'' or 
		srvIntReq.Scheda like ''SA1%'' or 
		srvIntReq.Scheda like ''CO1%'' or 
		srvIntReq.Scheda like ''M1%'' or 
		srvIntReq.Scheda like ''M2%'' or 
		srvIntReq.Scheda like ''CO2%'' or 
		srvIntReq.Scheda like ''RSU1%'' or 
		srvIntReq.Scheda like ''ES1%'' or 
		srvIntReq.Scheda like ''CS1%'' and srvIntReq.idRichiesta = ' + cast( @IdDoc as varchar(10)) 

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
