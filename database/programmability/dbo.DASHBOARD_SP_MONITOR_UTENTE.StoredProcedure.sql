USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_MONITOR_UTENTE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[DASHBOARD_SP_MONITOR_UTENTE]
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

	declare @pfulogin varchar(2000)
	declare @aziLog varchar(2000)
	declare @NumRighe INT

	declare @idpfu_log INT

	set nocount on

	set @Param = Replace(@AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp,' ','')
	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp

	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)

	set @pfulogin	=  dbo.GetParam( 'pfulogin' , @Param,0)

	set @pfulogin	=replace(@pfulogin ,'''','')
	set @pfulogin	=replace(@pfulogin ,'%','')

	set @aziLog     = dbo.GetParam( 'aziLog' , @Param,0) 

	set @aziLog	=replace(@aziLog ,'''','')
	set @aziLog	=replace(@aziLog ,'%','')

	set @NumRighe   = cast( dbo.GetParam( 'NumRighe' , @Param,0) as INT )
	

	select @idpfu_log = pfu.idpfu 
		from profiliutente pfu with(nolock) 
				inner join aziende azi with(nolock) ON azi.idazi = pfu.pfuidazi and azi.aziLog = @aziLog 
	where pfulogin = @pfulogin
	

	select top(@NumRighe) id,ip, idpfu, datalog, paginaDiArrivo, paginaDiPartenza, querystring, form, browserUsato, descrizione, sessionID INTO #TMP_EXTRACT_LOG_UTENTE 
		from ctl_log_utente with(nolock) 
		where idpfu = @idpfu_log and querystring not in ('TRACE-INFO')
		order by id desc 

	-- carico nella ctl log utente lavoro i record non ancora presenti
	INSERT INTO CTL_LOG_UTENTE_LAVORO ( id,ip, idpfu, datalog, paginaDiArrivo, paginaDiPartenza, querystring, form, browserUsato, descrizione, sessionID)
			SELECT A.id,A.ip, A.idpfu, A.datalog, A.paginaDiArrivo, A.paginaDiPartenza, A.querystring, A.form, A.browserUsato, A.descrizione, A.sessionID 
			from #TMP_EXTRACT_LOG_UTENTE A
					left join CTL_LOG_UTENTE_LAVORO B ON a.id = B.id 
			where b.id is null

	--DECODIFICO LOG
	declare @idrow INT
	declare CurProg Cursor static for select id from #TMP_EXTRACT_LOG_UTENTE

	open CurProg

	FETCH NEXT FROM CurProg INTO @idrow

	WHILE @@FETCH_STATUS = 0
	BEGIN

		exec DECODIFICA_LOG @idrow

		FETCH NEXT FROM CurProg INTO @idrow

	END 

	CLOSE CurProg
	DEALLOCATE CurProg	
			

	select top(@NumRighe) A.*
		from CTL_LOG_UTENTE_LAVORO A with(nolock)
				inner join #TMP_EXTRACT_LOG_UTENTE B ON A.id = B.id




GO
