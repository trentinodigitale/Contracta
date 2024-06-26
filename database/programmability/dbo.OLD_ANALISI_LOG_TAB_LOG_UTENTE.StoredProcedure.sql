USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ANALISI_LOG_TAB_LOG_UTENTE]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







---------------------------------------------------------------
-- recupera i dati per la scheda di LOG_UTENTE
---------------------------------------------------------------
CREATE proc [dbo].[OLD_ANALISI_LOG_TAB_LOG_UTENTE]
(
	@idpfu int , 
	@DataInizio as datetime ,
	@DataFine as datetime 
)
as
begin
	set nocount on 	

	-- svuoto CTL_LOG_UTENTE_LAVORO da precedenti elaborazioni per evitare ridondanze
	--delete CTL_LOG_UTENTE_LAVORO where datalog >=@DataInizio and datalog <=@DataFine  and ( idpfu = @IdPfu or idpfu in  ( -1,-20 ) )

	--recupero il log mancante per i dati da decodificare
	insert into CTL_LOG_UTENTE_LAVORO (id, ip, idpfu, datalog, paginaDiArrivo, paginaDiPartenza, querystring, form, browserUsato, descrizione, sessionID)
		select l.id, l.ip, l.idpfu, l.datalog, l.paginaDiArrivo, l.paginaDiPartenza, l.querystring, 'DESC=' + l.descrizione + '&FORM=' +cast(l.form as nvarchar(max)), l.browserUsato, null, l.sessionID 
			from CTL_LOG_UTENTE l with (nolock)
				left outer join CTL_LOG_UTENTE_LAVORO w with( nolock )   on w.id = l.id
			where w.id is null
				and l.datalog >=@DataInizio and l.datalog <=@DataFine and l.idpfu = @IdPfu --and ( l.idpfu = @IdPfu or l.idpfu in  ( -1,-20 ) )
			order by l.datalog





	--DECODIFICO LOG mancante
	declare @idrow INT
	declare CurProg Cursor static for 
		select l.id from dbo.CTL_LOG_UTENTE_LAVORO l with(nolock) 
			where l.descrizione is null and l.datalog >=@DataInizio and l.datalog <=@DataFine  
			
	open CurProg

	FETCH NEXT FROM CurProg INTO @idrow
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		exec DECODIFICA_LOG @idrow
		FETCH NEXT FROM CurProg INTO @idrow

	END 

	CLOSE CurProg
	DEALLOCATE CurProg					



	select id,  case when l.idpfu not in (- 20,-1,-10) then p.pfunome else 'BackOffice' end as pfunome  , datalog,descrizione, paginaDiArrivo, paginaDiPartenza, querystring, form, browserUsato,  sessionID, ip
		from CTL_LOG_UTENTE_LAVORO l with(nolock)
			left join profiliutente p with(nolock) on p.idpfu = l.idpfu
		where l.datalog >=@DataInizio and l.datalog <=@DataFine  and l.idpfu = @IdPfu --and ( l.idpfu = @IdPfu or l.idpfu in  ( -1,-20 ) )
		order by datalog
end
GO
