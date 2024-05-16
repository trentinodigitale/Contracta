USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_STORED_CONSULTAZIONE_LOG]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE proc [dbo].[OLD_DASHBOARD_STORED_CONSULTAZIONE_LOG]
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
	declare @Utente varchar(8000)
	declare @Fornitore varchar(50)
	--declare @giorno_da varchar(50)
	--declare @giorno_a varchar(50)
	declare @giorno_da datetime
	declare @giorno_a datetime
	declare @mostra_err varchar(2)
	declare @rigenera varchar(2)
	declare @Fascicolo varchar(50)
	declare @Protocollo varchar(50)
	
	declare @Errore as nvarchar(2000)

	set nocount on

	set @Param = Replace(@AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp,' ','')
	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
    --print @Param
	
    
	declare @SQLCmd			varchar(8000)
	declare @SQLWhere		varchar(8000)
	set @SQLWhere=''
	
	
	
	--criteri di ricerca
	--set @Utente	= dbo.GetParam( 'IdPfu' , @Param,1) 
	set @Utente	= dbo.GetParam( 'IdPfuLog' , @Param,1) 
	set @Fornitore=dbo.GetParam( 'Fornitore' , @Param,1) 
	set @giorno_da=left( replace( dbo.GetParam( 'datalogda' , @Param ,1) ,'''',''''''), 19 )
	
	--aggiungo il max come millesecondi perchè in base dati come datetime abbiamo anche i millisecondi
	set @giorno_a=left( replace( dbo.GetParam( 'dataloga' , @Param ,1) ,'''',''''''), 19 ) + '.999'
	set @mostra_err=dbo.GetParam( 'Mostra Errori' , @Param,0) 
	set @rigenera=dbo.GetParam( 'Rigenera' , @Param,0) 

	set @Fascicolo=dbo.GetParam( 'Fascicolo' , @Param,0)
	set @Protocollo=dbo.GetParam( 'Protocollo' , @Param,0)

	--recupero della variabile con la getparam
	
	
	set @Errore = ''

	-- controllo se le date sono coerenti
	if @giorno_da > @giorno_a
	begin 
		-- rirorna l'errore
		set @Errore = 'Operazione non consentita "Giorno Lavorativo da" non può essere superiore a "Giorno Lavorativo a" ' 
	end

	
	

	if @Utente = '' and  @Fornitore = '' and @Fascicolo = '' and @Protocollo = ''
	begin 
		-- rirorna l'errore
		set @Errore = 'Operazione non consentita selezionare sul filtro "Utente", "Fornitore" oppure il "Fascicolo" ' 
	end
	
	 --print @Utente
	 --print @Fornitore
	 -- print @giorno_da
	 -- print @giorno_a
	  --print @mostra_err
	  --print @rigenera
	IF @Errore = ''
	BEGIN
		declare @CrLf varchar (10)
		set @CrLf = ''	
		
		---se non ho messo un Utente specifico e selezionata 
		---un fornitore allora predispone il log per tutti gli utenti dell'azienda selezionata
		if rtrim( @Fornitore ) <> '' and rtrim( @Utente ) = ''
		BEGIN
			declare @idpfu2 INT
			set @Utente=''

			declare CurProg Cursor static for 
				select IdPfu from ProfiLiUtente with(nolock)
					where pfuidazi=@Fornitore and pfudeleted=0
			
			open CurProg

			FETCH NEXT FROM CurProg INTO @IdPfu2
			WHILE @@FETCH_STATUS = 0
			BEGIN	
				set @Utente= @Utente + cast(@IdPfu2 as varchar(50)) +','				
				FETCH NEXT FROM CurProg INTO @IdPfu2
			
			END 
			CLOSE CurProg
			DEALLOCATE CurProg
			if @Utente <> ''
				set @Utente=substring(@Utente,1,len(@Utente)-1)
		END 


		-- inserisco nella ctl_log utente tutte le righe necessarie mancanti


		--IF @mostra_err <> 1
		--	set @SQLCmd = 'select * from CTL_LOG_UTENTE_LAVORO with(nolock) where               idpfu in ( ' + @Utente + ' )  and ''' + @giorno_da + ''' <=  convert( varchar(19) , datalog , 121 ) and convert( varchar(19) , datalog , 121 ) <= '''+ @giorno_a +''''
		--ELSE
		--	set @SQLCmd = 'select * from CTL_LOG_UTENTE_LAVORO with(nolock) where ( idpfu<0 or idpfu in ( ' + @Utente + ' ) ) and ''' + @giorno_da + ''' <=  convert( varchar(19) , datalog , 121 ) and convert( varchar(19) , datalog , 121 ) <= '''+ @giorno_a +''''
		
		if @Fornitore <> '' or @Utente <> ''
		BEGIN

			select items as idpfu into #Utenti from dbo.split( @Utente , ',' )

			select l.id as idx into #T 
				from CTL_LOG_UTENTE l with(nolock) 
					left join #Utenti u on u.idpfu = l.idpfu  
				where --@giorno_da <=  convert( varchar(19) , datalog , 121 ) and convert( varchar(19) , datalog , 121 ) <= @giorno_a 
					@giorno_da <=  datalog  and datalog <= @giorno_a 
					and (
							( u.idpfu is not null )
							or
							--( @mostra_err = 1 and l.idpfu < 0)
							( @mostra_err = 1 and  l.idpfu in  ( -1,-20 ) )
						)



			-- inserisce tutte le righe mancanti nella tabella di lavoro e le decodifica
			insert into CTL_LOG_UTENTE_LAVORO ( id,ip, idpfu, datalog, paginaDiArrivo, paginaDiPartenza, querystring, form, browserUsato, descrizione, sessionID)
				select  l.id,l.ip, l.idpfu, l.datalog, l.paginaDiArrivo, l.paginaDiPartenza, l.querystring, l.form, l.browserUsato,  null , l.sessionID 
					from  CTL_LOG_UTENTE l with(nolock) 
						inner join #T t on t.idx = l.id
						left outer join CTL_LOG_UTENTE_LAVORO w with( nolock )   on w.id = t.idx
					where w.id is null


			--DECODIFICO LOG mancante
			declare @idrow INT
			declare CurProg Cursor static for 
				select l.id from dbo.CTL_LOG_UTENTE_LAVORO l with(nolock) 
					inner join #T t on t.idx = l.id
					where l.descrizione is null
			
			open CurProg

			FETCH NEXT FROM CurProg INTO @idrow
			WHILE @@FETCH_STATUS = 0
			BEGIN
	
				exec DECODIFICA_LOG @idrow
				FETCH NEXT FROM CurProg INTO @idrow

			END 

			CLOSE CurProg
			DEALLOCATE CurProg					



		
			--IF not ( EXISTS (Select * from CTL_LOG_UTENTE_LAVORO with(nolock) where charindex ( ',' + cast( idpfu as varchar(20) ) + ',' , ',' + @Utente + ',' ) > 0 and  convert( varchar(19) , datalog , 121 ) >= @giorno_da  and convert( varchar(19) , datalog , 121 ) <= @giorno_a ) and @rigenera <> 1 )
			--BEGIN
			--	---PULISCO LA TABELLA PER QUELL'UTENTE
			--	--Delete from CTL_LOG_UTENTE_LAVORO where  charindex ( ',' + cast( idpfu as varchar(20) ) + ',' , ',' + @Utente + ',' ) > 0 or idpfu<0

			--	---POPOLA LA TABELLA CTL_LOG_UTENTE_LAVORO e CHIAMO LA STORED PER FARE LA DECODIFICA
			--	if rtrim( @Fornitore ) <> '' and rtrim( @Utente ) = ''
			--	begin

			--		insert into CTL_LOG_UTENTE_LAVORO ( id,ip, idpfu, datalog, paginaDiArrivo, paginaDiPartenza, querystring, form, browserUsato, descrizione, sessionID)
			--			select  id,ip, l.idpfu, datalog, paginaDiArrivo, paginaDiPartenza, querystring, form, browserUsato, descrizione, sessionID 
			--				from  dbo.CTL_LOG_UTENTE l with(nolock) 
			--					left outer join profiliutente p with(nolock) on l.idpfu = p.idpfu
			--				where  ( p.pfuidazi = @Fornitore or ( l.idpfu<0 and @mostra_err = 1)) and  convert( varchar(19) , datalog , 121 ) >= @giorno_da and convert( varchar(19) , datalog , 121 ) <= @giorno_a
			--	end
			--	else
			--	begin

			--		insert into CTL_LOG_UTENTE_LAVORO ( id,ip, idpfu, datalog, paginaDiArrivo, paginaDiPartenza, querystring, form, browserUsato, descrizione, sessionID)
			--			select  id,ip, idpfu, datalog, paginaDiArrivo, paginaDiPartenza, querystring, form, browserUsato, descrizione, sessionID 
			--				from  dbo.CTL_LOG_UTENTE with(nolock) 
			--				where  ( idpfu = @Utente or ( idpfu<0 and @mostra_err = 1) ) and  convert( varchar(19) , datalog , 121 ) >= @giorno_da and convert( varchar(19) , datalog , 121 ) <= @giorno_a
			
			--	end
			
			--	--DECODIFICO LOG
			--	declare @idrow INT
			--	declare CurProg Cursor static for 
			--		select id from dbo.CTL_LOG_UTENTE_LAVORO with(nolock)
			--			where charindex ( ',' + cast( idpfu as varchar(20) ) + ',' , ',' + @Utente + ',' ) > 0 or  idpfu<0
			--			order by id
			
			--	open CurProg

			--	FETCH NEXT FROM CurProg INTO @idrow
			--	WHILE @@FETCH_STATUS = 0
			--	BEGIN
	
			--		exec DECODIFICA_LOG @idrow
			--		FETCH NEXT FROM CurProg INTO @idrow

			--	END 

			--	CLOSE CurProg
			--	DEALLOCATE CurProg	
			
			--END
		
			--if rtrim( @Descrizione ) <> '' and rtrim( @Multi_Doc ) = '' 
			--	set @SQLWhere = @SQLWhere + ' Descrizione  like ' + @Descrizione + @CrLf  	
			--set @SQLCmd = @SQLCmd + ' where deleted=0' 


			set @SQLCmd = 'select l.*,P.pfunome, convert(varchar(19),l.datalog,120) as datalog_visual from CTL_LOG_UTENTE_LAVORO l with(nolock) inner join profiliutente P with(nolock) on P.idpfu=l.idpfu inner join #T t on t.idx = l.id where 1 = 1 '

			
			if @SQLWhere <> ''
				set @SQLCmd = @SQLCmd + ' and ' + @SQLWhere
		
			--filtro sul fascicolo aggunto alla SQLCMD
			if isnull(@Fascicolo,'') <> ''
				set @SQLCmd = @SQLCmd + 'and l.Fascicolo like ' + @Fascicolo

			--filtro sul protocollo aggunto alla SQLCMD
			if isnull(@Protocollo,'') <> ''
				set @SQLCmd = @SQLCmd + 'and l.Protocollo like ' + @Protocollo

			--if @Sort <> ''
			--	set @SQLCmd = @SQLCmd + ' order by ' + @Sort
			--else
				set @SQLCmd = @SQLCmd + ' order by Id asc ' 

		END
		ELSE
		BEGIN
			--Nel caso di filtraggio solo per Fascicolo

			set @SQLCmd = 'select l.*,P.pfunome, convert(varchar(19),l.datalog,120) as datalog_visual from CTL_LOG_UTENTE_LAVORO l with(nolock) inner join profiliutente P with(nolock) on P.idpfu=l.idpfu where ''' + CONVERT(varchar, @giorno_da,120) + ''' <= datalog and datalog <= ''' + CONVERT(varchar, @giorno_a,120) + ''''
			
			if isnull(@Fascicolo,'') <> ''
				set @SQLCmd = @SQLCmd + ' and Fascicolo like ' + @Fascicolo


			if isnull(@Protocollo,'') <> ''
				set @SQLCmd = @SQLCmd + ' and Protocollo like ' + @Protocollo


			set @SQLCmd = @SQLCmd + ' order by Id asc ' 
 
		END

	END
		
	if @Errore = ''
	begin
		
		exec (@SQLCmd)	

		--print @SQLCmd

		--print @Param
		--print @utente

		--select * from #T
		--select * from #Utenti

	end
	else
	begin		

		-- rirorna l'errore
		select 'Errore' as id , @Errore as Descrizione

	end
	
	set nocount off
	












GO
