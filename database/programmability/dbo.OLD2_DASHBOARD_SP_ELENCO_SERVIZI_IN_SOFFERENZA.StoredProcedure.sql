USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DASHBOARD_SP_ELENCO_SERVIZI_IN_SOFFERENZA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[OLD2_DASHBOARD_SP_ELENCO_SERVIZI_IN_SOFFERENZA]
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
	
	set nocount ON			
	declare @SECONDI_SERVIZIO_DORMIENTE int
	declare @SRV_Id as int
	declare @SRV_Sql as nvarchar(max)
	select top 0 cast('' as nvarchar(max)) as sentinella into #tmp_sentinella

	select @SECONDI_SERVIZIO_DORMIENTE = dbo.parametri('MONITORAGGIO_SERVIZI','AFUpdate','SECONDI_SERVIZIO_DORMIENTE','3600',-1) 

	exec DASHBOARD_SP_ELENCO_SERVIZI -1 , '' , '' , '' , '' , ' asc , SRV_ID asc' , 100, 1 

	select 
			S.*,
			CTL.NumeroProcessiCoda,
			CTL.Descrizione,
			CTL.SRV_SecIntervalEsteso,
			CTL.DATA_APERTURA_ALERT ,
			CTL.DATA_CHIUSURA_ALERT ,
			case when ( CTL.NumeroProcessiCoda > ISNULL(S.SRV_SOGLIA,0) and S.SRV_SOGLIA IS not NULL ) then 'SOGLIA SUPERATA' 
				 else 'SERVIZIO DORMIENTE'
			end AS DETTAGLIO 
			
		into #tmp_work_services

		from CTL_MONITOR_LIB_SERVICES CTL
			inner join LIB_Services S on S.SRV_id = CTL.SRV_id and S.bdeleted=0
		where 
			--SE LA SOGLIA NON E' NULL CONFRONTO CON IL NUMERO DI PROCESSI IN CODA, SE INFERIORE ATTIVA ALERT
			( CTL.NumeroProcessiCoda > ISNULL(S.SRV_SOGLIA,0) and S.SRV_SOGLIA IS not NULL  )			
			or
			--CONTROLLO SE I SERVIZI STANNO GIRANDO
            --VIENE CONTROLLATTO SRV_LASTEXEC + intervallo SRV_INTERVAL + UNA SOGLIA IN SECONDI PRESI DALLA CTL_PARAMETRI > now() ATTIVA ALERT
			DATEDIFF(MINUTE,GETDATE(), DateAdd(SECOND,@SECONDI_SERVIZIO_DORMIENTE+S.SRV_SecInterval , S.SRV_LastExec ) ) < 0
		order by CTL.NumeroProcessiCoda desc


	--I SERVIZI CHE HANNO UN SQL_SCRIPT IN SRV_PARAM VENGONO RIMOSSI IN QUANTO IL CONTROLLO
	--VIENE FATTO CON LO SCRIPT DEDICATO PRESENTE IN SQL_SCRIPT		 
	DECLARE crsServ_Param CURSOR STATIC FOR 
		select  srv_id,dbo.GetValue('SQL_SCRIPT',SRV_PARAM) as S_SQL from LIB_Services with(nolock) where bDeleted=0  and dbo.GetValue('SQL_SCRIPT',SRV_PARAM) <> '' 
		
	OPEN crsServ_Param

	FETCH NEXT FROM crsServ_Param INTO @SRV_Id, @SRV_Sql
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--TOLGO DALLA TEMP IL SERVIZIO SE PER CASO E' PRESENTE PER VIA DELLA STORED DASHBOARD_SP_ELENCO_SERVIZI
		delete from  #tmp_work_services where srv_id=@SRV_Id

		--ESEGUE LO SCRIPT
		insert into #tmp_sentinella
			exec(@SRV_Sql)
			
		IF EXISTS ( select * from #tmp_sentinella where sentinella <> '' )
		BEGIN
			insert into #tmp_work_services ( [SRV_id], [SRV_Description], [SRV_DOC_ID], [SRV_DPR_ID], [SRV_SecInterval], [SRV_SQL], [SRV_LastExec], [SRV_Module], [bDeleted], [SRV_KEY], [SRV_PARAM], [SRV_SOGLIA],NumeroProcessiCoda,Descrizione,SRV_SecIntervalEsteso,DATA_APERTURA_ALERT,DATA_CHIUSURA_ALERT,DETTAGLIO)
				select S.*,0,sentinella,'',NULL,NULL,'SERVIZIO BLOCCATO'
					from LIB_Services S
						cross join #tmp_sentinella
						where SRV_id=@SRV_Id
		END
		truncate table #tmp_sentinella

		FETCH NEXT FROM crsServ_Param INTO  @SRV_Id, @SRV_Sql
	END

	CLOSE crsServ_Param 
	DEALLOCATE crsServ_Param 

	select * from #tmp_work_services
	--select  DateDiff(second,GETDATE(),DateAdd(SECOND,100 + 10 , '2020-02-13 09:10:19.297') )


	  --strcause = "Update per aggiornare DATA_APERTURA_ALERT sulla tabella CTL_MONITOR_LIB_SERVICES sentinella"
   --                 Call insertTrace(strcause, ambiente)
   --                 If SRV_ID_STRING <> "" Then
   --                     '-- PER ID IN AFFANNO SEGNO DATA_APERTURA_ALERT SE NON PRESENTE
   --                     SRV_ID_STRING = SRV_ID_STRING.Substring(0, SRV_ID_STRING.Length - 1)
   --                     strSql = "update CTL_MONITOR_LIB_SERVICES set DATA_APERTURA_ALERT=getdate(), DATA_CHIUSURA_ALERT = NULL where srv_id in ( " & SRV_ID_STRING & ")  and ( DATA_APERTURA_ALERT is null or DATA_CHIUSURA_ALERT is not null )"
   --                     db.execSQL(strSql)
   --                 End If

   --                 strcause = "Update per aggiornare DATA_CHIUSURA_ALERT sulla tabella CTL_MONITOR_LIB_SERVICES sentinella"
   --                 Call insertTrace(strcause, ambiente)

   --                 If SRV_ID_STRING <> "" Then
   --                     SRV_ID_STRING = SRV_ID_STRING.Substring(0, SRV_ID_STRING.Length - 1)
   --                     strSql = "update CTL_MONITOR_LIB_SERVICES set  DATA_CHIUSURA_ALERT = getdate() where srv_id not in ( " & SRV_ID_STRING & ")  and DATA_APERTURA_ALERT is not null"
   --                     db.execSQL(strSql)
   --                 Else
   --                     strSql = "update CTL_MONITOR_LIB_SERVICES set  DATA_CHIUSURA_ALERT = getdate() where  DATA_APERTURA_ALERT is not null"
   --                     db.execSQL(strSql)
   --                 End If



GO
