USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_FLES_SP_VIEW_CONTRATTO_FLUSSO_ESECUZIONE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE               proc [dbo].[OLD2_FLES_SP_VIEW_CONTRATTO_FLUSSO_ESECUZIONE]
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Sort                          varchar(8000),
 @status						varchar(8000),
 @typeDoc						varchar(8000),
 @PageNumber					int = 1, 
 @PageSize						int = 2147483647,
 @Cnt                           int output
)
as
begin
	
	set nocount on
	
	declare @SQLCmd			nvarchar(max)
	declare @SQLWhere		nvarchar(max)
	declare @SQLOrder		nvarchar(max)

	--costruisco order
	set @SQLOrder = ''
	if rtrim(@Sort) <> ''
		begin
			set @SQLOrder = ' order by ' + @Sort
		end
	else
		begin
			set @SQLOrder = ' order by Id'
		end

	--costruisco select da eseguire
	set @SQLWhere = dbo.FLES_FND_NORMALIZE_CONDITION(@AttrName,@AttrValue,@AttrOp)

	if @typeDoc = 'Contratto Stipulato'
		begin
			set @SQLCmd = 'select c.*, ROW_NUMBER() OVER (' + @SQLOrder + ') as RowNumber into #TempTable from FLES_VIEW_CONTRATTO_STIPULATO c 
				left join (
					-- estendo la visualizzazione a tutti gli utenti nei riferimenti della gara come BANDO
					select distinct idPfu, idheader as idBando from Document_Bando_Riferimenti r with(nolock) where r.RuoloRiferimenti = ''Bando'' and idpfu = ' + cast(@IdPfu as varchar(10)) + '
				) as v on v.idBando = c.idBando'
			set @SQLCmd = @SQLCmd + ' where (c.idPfuInCharge = ' + cast( @IdPfu as varchar(10)) + ' or c.idpfu = ' + cast(@IdPfu as varchar(10)) + ' or c.UserRUP = ' + cast(@IdPfu as varchar(10)) + ' or c.IdPfu_Firmatario = ' + cast(@IdPfu as varchar(10)) + ') and UPPER(c.StatoFunzionale) = ''' + cast(@status as varchar(20)) + ''' and c.idAppalto is not null'
		end
	else if @typeDoc = 'Contratto RDO'
		set @SQLCmd = 'select c.*, ROW_NUMBER() OVER (' + @SQLOrder + ') as RowNumber into #TempTable from FLES_VIEW_CONTRATTO_RDO c where (c.idPfuInCharge = ' + cast( @IdPfu as varchar(10)) + ' or c.idpfu = ' + cast(@IdPfu as varchar(10)) + ' or c.UserRUP = ' + cast(@IdPfu as varchar(10)) + ') and UPPER(c.StatoFunzionale) = ''' + cast(@status as varchar(20)) + ''' and c.idAppalto is not null'

	if @SQLWhere <> ''
		set @SQLCmd = @SQLCmd + @SQLWhere
	
	set @SQLCmd = @SQLCmd + @SQLOrder

	set @SQLCmd = @SQLCmd + '
	SELECT @Cnt = COUNT(*) FROM #TempTable
	SET @Cnt = @Cnt
	SELECT *, @Cnt AS Cnt FROM #TempTable
	WHERE RowNumber between (@PageNumber - 1) * @PageSize + 1 and @PageNumber * @PageSize
	DROP TABLE #TempTable'

	--print(@SQLCmd)
	--print(@PageNumber)
	--print(@PageSize)

	EXEC sp_executesql @SQLCmd, N'@Cnt int, @PageNumber int, @PageSize int', @Cnt, @PageNumber, @PageSize;

end

GO
