USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CALCOLO_OCCORRENZE_MONITOR_EVENTI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[OLD2_CALCOLO_OCCORRENZE_MONITOR_EVENTI] ( @IdUser as int ) 

AS

BEGIN
	
	set nocount on

	declare @Date_Last_Elab as datetime

	--recupero data ultimo operazione
	select @Date_Last_Elab=altro from CTL_Counters with (nolock) where Name='DATE_LAST_ELAB_REPORT_MONITOR_EVENTI'
	
	--recupero parametro che mi dice quali eventi recuperare dalla tabella CTL_EventLog
	-- ( default= "###Application-AFLink###") per filtrare per logname e providername
	declare @FiltroEventiLog as nvarchar(1000)

	select @FiltroEventiLog = dbo.PARAMETRI('CONFIGURAZIONE_MONITOR_EVENTI','FILTRO_EVENTI','DefaultValue','###Application-AFLink###',-1)
	--set @FiltroEventiLog=''
	--select dbo.PARAMETRI('CONFIGURAZIONE_MONITOR_EVENTI','FILTRO_EVENTI','DefaultValue','',-1)
	--select @Date_Last_Elab
	
	--drop table #temp
	--select * from CTL_EventLog order by TimeCreated desc

	--per recuperare la tipologia/e di un messaggio
	--dbo.Get_TipologiaErrore_FromMessaggio(Messaggio)

	--se la data non esiste oppure sono trascorsi più di 3 mesi 
	-- allora devo popolare la tabella Ctl_Event_Log_Report
	-- con tutti i messaggi di errore degli ultimi 3 mesi 
	if @Date_Last_Elab is null or datediff(MONTH,@Date_Last_Elab,GETDATE()) > 3
	begin

		--if @Date_Last_Elab is not null
		--begin
			--ripulisco la tabella dei report perchè sono trascorsi più di 3 mesi e quindi va rifatto il popolamento iniziale
		truncate table Ctl_Event_Log_Report
		--end
		--select top 1 * from CTL_EventLog
		--metto in una temp i messaggi di errore ripuliti dai numeri degli ultimi 3 mesi
		select dbo.NormStringPURGE(Message,'0123456789') as Message,TimeCreated , Message as Hash_Messaggio into #temp
				from 
					CTL_EventLog  with (nolock) 
				where 
					datediff(MONTH,TimeCreated,GETDATE()) <=3 and ISNULL(Message,'')<>''
					and	( '###' + LogName + '-' + ProviderName + '###' like @FiltroEventiLog  or @FiltroEventiLog='')
					and LevelDisplayName ='Error'


		--genero hash del messaggio nella temp
		update #temp set Hash_Messaggio = HASHBYTES ('SHA1',Message)
		--select * from #temp
		
		--inserisco nella tabella dei report i messaggi distinti compreso l'hash
		insert into Ctl_Event_Log_Report
			( [Messaggio], Hash_Messaggio)
			select distinct Message,Hash_Messaggio  from #temp
		
			
			
		--per ogni messaggio di errore recupero la tipologia/e dall'ultimo documento di configurazione
		update Ctl_Event_Log_Report
			set tipologiaerrore=dbo.Get_TipologiaErrore_FromMessaggio(Messaggio)

		--select * from Ctl_Event_Log_Report

		--conto gli errori per messaggio negli ultimi 3 mesi
		select Hash_Messaggio , COUNT(*) as Num_U3Mesi
			into #tempU3mesi
			from 
				#temp with (nolock)
			where datediff(MONTH,TimeCreated,GETDATE())  <= 3 
				group by Hash_Messaggio
		
		--aggiorno sulla tabella dei report le occorrenze degli ultimi 3 mesi
		update 
			A
			set A.Num_U3Mesi=B.Num_U3Mesi
			from
				Ctl_Event_Log_Report A
					inner join  #tempU3mesi B on A.Hash_Messaggio=B.Hash_Messaggio--A.Messaggio=B.Message
			
			

		--conto gli errori per messaggio negli ultimi 1 mesi
		select Hash_Messaggio , COUNT(*) as Num_UMese
			into #tempU1mese
			from 
				#temp with (nolock)
			where datediff(MONTH,TimeCreated,GETDATE()) <=1 
				group by Hash_Messaggio
		
		--aggiorno sulla tabella dei report le occorrenze degli ultimi 1 mesi
		update 
			A
			set A.Num_UMese=B.Num_UMese
			from
				Ctl_Event_Log_Report A
					inner join  #tempU1mese B on A.Hash_Messaggio=B.Hash_Messaggio
		
		--conto gli errori per messaggio Ultima Settimana
		select Hash_Messaggio , COUNT(*) as Num_USettimana
			into #tempUSett
			from 
				#temp with (nolock)
			where datediff(WEEK,TimeCreated,GETDATE()) <= 1 
				group by Hash_Messaggio
		
		--aggiorno sulla tabella dei report le occorrenze Ultima Settimana
		update 
			A
			set A.Num_USettimana=B.Num_USettimana
			from
				Ctl_Event_Log_Report A
					inner join  #tempUSett B on A.Hash_Messaggio=B.Hash_Messaggio
		
		--conto gli errori per messaggio di OGGI
		select Hash_Messaggio , COUNT(*) as Num_Oggi
			into #tempOggi
			from 
				#temp with (nolock)
			where --datediff(DAY,TimeCreated,GETDATE()) <=1 and ISNULL(Message,'')<>''
				TimeCreated >= convert(varchar(10),GETDATE(),121) and TimeCreated <=GETDATE()
				group by Hash_Messaggio
		
		
		--select * from  #temp 
		--	where --datediff(DAY,TimeCreated,GETDATE()) <=1 and ISNULL(Message,'')<>''
		--		 TimeCreated <=GETDATE() and 
		--		 TimeCreated >= convert(varchar(10),GETDATE(),121)
		--aggiorno sulla tabella dei report le occorrenze di OGGI
		update 
			A
			set A.Num_Oggi=B.Num_Oggi
			from
				Ctl_Event_Log_Report A
					inner join  #tempOggi B on A.Hash_Messaggio=B.Hash_Messaggio

		--select * from 	Ctl_Event_Log_Report	
		IF OBJECT_ID(N'tempdb..#tempU3mesi') IS NOT NULL
		BEGIN
			DROP TABLE #tempU3mesi
		END
		IF OBJECT_ID(N'tempdb..#tempU1mese') IS NOT NULL
		BEGIN
			DROP TABLE #tempU1mese
		END
		IF OBJECT_ID(N'tempdb..#tempUSett') IS NOT NULL
		BEGIN
			DROP TABLE #tempUSett
		END
		IF OBJECT_ID(N'tempdb..#tempOggi') IS NOT NULL
		BEGIN
			DROP TABLE #tempOggi
		END
		IF OBJECT_ID(N'tempdb..#temp') IS NOT NULL
		BEGIN
			DROP TABLE #temp
		END

		

		--select * from Ctl_Event_Log_Report

	end
	else
	begin

		--Quando esiste la data ultima elaborazione faccio questo ragionamento:
		--Consideriamo la colonna Ultimi 3 mesi
		--se la differenza da oggi maggiore di 3 mesi allora rifaccio il popolamento iniziale considerando gli ultimi 3 mesi
		--se la differenza da oggi minore di 3 mesi devo lavorare per il delta
		--quindi sottraggo il numero di occorrenze avute dalla 
		--data di elaborazione - 3 mesi fino alla
		--data di elaborazione - 3 mesi + delta
		--ed aggiungo il numero di occorrenze che si sono avute dalla data di elaborazione  fino alla data di elaborazione + delta
		--e così ragiono anche per gli altri archi temporali

		--Mi CALCOLO LE OCCORRENZE NEGATIVE DEL DELTA ( dalla data ultima elaborazione - 3 mesi fino al DELTA )
		declare @Delta as int
		set @Delta = datediff(s,@Date_Last_Elab,getdate())
		
		declare @StartDate as datetime
		declare @EndDate as datetime
		
		--COSTRUISCO IL DELTA NEGATIVO PER ARCO TEMPORALE 3 MESI
		--setto la data iniziale e finale per recuperare il delta negativo
		set @StartDate = dateadd(month,-3,@Date_Last_Elab)
		set @EndDate = dateadd(SECOND,@Delta,@StartDate)
		
		--select datediff(s,'2021-09-14 10:00:00',getdate())

		--select dateadd(m,-3,'2021-09-14 10:00:00')
		--select dateadd(s,84452,'2021-06-14 10:00:00.000')
		--metto in una temp i messaggi ripuliti da sottrarre al conteggio relativi al DELTA
		select dbo.NormStringPURGE(Message,'0123456789') as Message,TimeCreated ,Message as Hash_Messaggio into #temp_Delta_Negativo
			from 
				CTL_EventLog  with (nolock) 
			where 
				TimeCreated >= @StartDate and TimeCreated<=@EndDate	and ISNULL(Message,'')<>''
				and	( '###' + LogName + '-' + ProviderName + '###' like @FiltroEventiLog  or @FiltroEventiLog='')
				and LevelDisplayName ='Error'

		--genero hash del messaggio nella temp
		update #temp_Delta_Negativo set Hash_Messaggio = HASHBYTES ('SHA1',Message)

		--conto gli errori per messaggio negli ultimi 3 mesi nel DELTA negativo da sottrarre
		select Hash_Messaggio , COUNT(*) as Num_U3Mesi
			into #tempU3mesi_Delta_Negativo
			from 
				#temp_Delta_Negativo with (nolock)
			--where 
				--datediff(MONTH,TimeCreated,@Date_Last_Elab ) <=3 
				group by Hash_Messaggio
		
		--aggiorno sulla tabella dei report le occorrenze degli ultimi 3 mesi togliendo quelli del DELTA negativo
		update 
			A
			set A.Num_U3Mesi=A.Num_U3Mesi - B.Num_U3Mesi
			from
				Ctl_Event_Log_Report A
					inner join  #tempU3mesi_Delta_Negativo B on A.Hash_Messaggio=B.Hash_Messaggio
		

		--COSTRUISCO IL DELTA PER ULTIMO MESE
		set @StartDate = dateadd(month,-1,@Date_Last_Elab)
		set @EndDate = dateadd(SECOND,@Delta,@StartDate)

		
		IF OBJECT_ID(N'tempdb..#temp_Delta_Negativo') IS NOT NULL
		BEGIN
			DROP TABLE #temp_Delta_Negativo
		END


		select dbo.NormStringPURGE(Message,'0123456789') as Message,TimeCreated ,Message as Hash_Messaggio into #temp_Delta_Negativo1
			from 
				CTL_EventLog  with (nolock) 
			where 
				TimeCreated >= @StartDate and TimeCreated<=@EndDate	and ISNULL(Message,'')<>''
				and	( '###' + LogName + '-' + ProviderName + '###' like @FiltroEventiLog  or @FiltroEventiLog='')
				and LevelDisplayName ='Error'

		--genero hash del messaggio nella temp
		update #temp_Delta_Negativo1 set Hash_Messaggio = HASHBYTES ('SHA1',Message)


		--conto gli errori per messaggio ULTIMO MESO togliendo quelli del DELTA negativo
		select Hash_Messaggio , COUNT(*) as Num_UMese
			into #tempU1mese_Delta_Negativo
				from 
					#temp_Delta_Negativo1 with (nolock)
				--where datediff(MONTH,TimeCreated,@Date_Last_Elab) <=1 
				group by Hash_Messaggio
		
		--aggiorno sulla tabella dei report le occorrenze degli ultimi 1 mesi
		update 
			A
			set A.Num_UMese=A.Num_UMese - B.Num_UMese
			from
				Ctl_Event_Log_Report A
					inner join  #tempU1mese_Delta_Negativo B on A.Hash_Messaggio=B.Hash_Messaggio

		
		IF OBJECT_ID(N'tempdb..#temp_Delta_Negativo1') IS NOT NULL
		BEGIN
			DROP TABLE #temp_Delta_Negativo1
		END

		--COSTRUISCO IL DELTA PER UTLIMA SETTIMANA
		set @StartDate = dateadd(WEEK,-1,@Date_Last_Elab)
		set @EndDate = dateadd(SECOND,@Delta,@StartDate)

		
		
		select dbo.NormStringPURGE(Message,'0123456789') as Message,TimeCreated ,Message as Hash_Messaggio into #temp_Delta_Negativo2
			from 
				CTL_EventLog  with (nolock) 
			where 
				TimeCreated >= @StartDate and TimeCreated<=@EndDate	and ISNULL(Message,'')<>''
				and	( '###' + LogName + '-' + ProviderName + '###' like @FiltroEventiLog  or @FiltroEventiLog='')
				and LevelDisplayName ='Error'

		--genero hash del messaggio nella temp
		update #temp_Delta_Negativo2 set Hash_Messaggio = HASHBYTES ('SHA1',Message)


		--conto gli errori per messaggio Ultima Settimana
		select Hash_Messaggio , COUNT(*) as Num_USettimana
			into #tempUSett_Delta_Negativo
				from 
					#temp_Delta_Negativo2 with (nolock)
				--where datediff(WEEK,TimeCreated,@Date_Last_Elab) <=1 
					group by Hash_Messaggio
		
		--aggiorno sulla tabella dei report le occorrenze Ultima Settimana
		update 
			A
			set A.Num_USettimana=A.Num_USettimana - B.Num_USettimana
			from
				Ctl_Event_Log_Report A
					inner join  #tempUSett_Delta_Negativo B on A.Hash_Messaggio=B.Hash_Messaggio
		
		
		IF OBJECT_ID(N'tempdb..#temp_Delta_Negativo2') IS NOT NULL
		BEGIN
			DROP TABLE #temp_Delta_Negativo2
		END

		--se è scattato un nuovo giorno allora azzero i contatori per oggi
		--if datediff(day,@Date_Last_Elab,getdate())=1
		--begin
		--	update Ctl_Event_Log_Report set Num_Oggi=0			 
		--end
		--else
		begin

			--COSTRUISCO IL DELTA NEGATIVO PER OGGI
			set @StartDate = dateadd(DAY,-1,@Date_Last_Elab)
			set @EndDate = dateadd(SECOND,@Delta,@StartDate)
			
		
			select dbo.NormStringPURGE(Message,'0123456789') as Message,TimeCreated ,Message as Hash_Messaggio into #temp_Delta_Negativo3
				from 
					CTL_EventLog  with (nolock) 
				where 
					TimeCreated >= @StartDate and TimeCreated<=@EndDate	and ISNULL(Message,'')<>''
					and	( '###' + LogName + '-' + ProviderName + '###' like @FiltroEventiLog  or @FiltroEventiLog='')
					and LevelDisplayName ='Error'

			--genero hash del messaggio nella temp
			update #temp_Delta_Negativo3 set Hash_Messaggio = HASHBYTES ('SHA1',Message)

		
			--conto gli errori per messaggio di OGGI
			select Hash_Messaggio , COUNT(*) as Num_Oggi
				into #tempOggi_Delta_Negativo
					from 
						#temp_Delta_Negativo3 with (nolock)
					--where --datediff(DAY,TimeCreated,GETDATE()) <=1 and ISNULL(Message,'')<>''
					--	TimeCreated >= convert(varchar(10),@Date_Last_Elab,121) and TimeCreated <=@Date_Last_Elab
						group by Hash_Messaggio
		

			update 
				A
				set A.Num_Oggi=A.Num_Oggi - B.Num_Oggi
				from
					Ctl_Event_Log_Report A
						inner join  #tempOggi_Delta_Negativo B on A.Hash_Messaggio=B.Hash_Messaggio
		

		
		end

		IF OBJECT_ID(N'tempdb..#temp_Delta_Negativo3') IS NOT NULL
		BEGIN
			DROP TABLE #temp_Delta_Negativo3
		END
		
		IF OBJECT_ID(N'tempdb..#tempU3mesi_Delta_Negativo') IS NOT NULL
		BEGIN
			DROP TABLE #tempU3mesi_Delta_Negativo
		END
		
		IF OBJECT_ID(N'tempdb..#tempU1mese_Delta_Negativo') IS NOT NULL
		BEGIN
			DROP TABLE #tempU1mese_Delta_Negativo
		END

		IF OBJECT_ID(N'tempdb..#tempUSett_Delta_Negativo') IS NOT NULL
		BEGIN
			DROP TABLE #tempUSett_Delta_Negativo
		END

		IF OBJECT_ID(N'tempdb..#tempOggi_Delta_Negativo') IS NOT NULL
		BEGIN
			DROP TABLE #tempOggi_Delta_Negativo
		END
		
		
		

		--Mi CALCOLO LE OCCORRENZE POSITIVE CHE MANCANO DEL DELTA (dalla data ultima elaborazione ad oggi)

		--setto la data iniziale e finale per recuperare il delta Positivo
		set @StartDate = @Date_Last_Elab
		set @EndDate = GETDATE()
		
		--select datediff(s,'2021-09-14 10:00:00',getdate())

		--select dateadd(m,-3,'2021-09-14 10:00:00')
		--select dateadd(s,84452,'2021-06-14 10:00:00.000')
		--metto in una temp i messaggi ripuliti da sottrarre al conteggio relativi al DELTA
		select dbo.NormStringPURGE(Message,'0123456789') as Message,TimeCreated ,Message as Hash_Messaggio into #temp_Delta_Positivo
			from 
				CTL_EventLog  with (nolock) 
			where 
				TimeCreated >= @StartDate and TimeCreated<=@EndDate and ISNULL(Message,'')<>''
				and	( '###' + LogName + '-' + ProviderName + '###' like @FiltroEventiLog  or @FiltroEventiLog='')
				and LevelDisplayName ='Error'

		--genero hash del messaggio nella temp
		update #temp_Delta_Positivo set Hash_Messaggio = HASHBYTES ('SHA1',Message)

		--aggiungo eventuali messaggi di errori NUOVI non presenti nella tabella Ctl_Event_Log_Report
		insert into Ctl_Event_Log_Report
			(Messaggio,Hash_Messaggio,TipologiaErrore)
		select 
			Message as Messaggio, S.Hash_Messaggio, dbo.Get_TipologiaErrore_FromMessaggio(Message) as TipologiaErrore
			from 
				#temp_Delta_Positivo S
					left outer join Ctl_Event_Log_Report DEST on DEST.Hash_Messaggio = S.Hash_Messaggio
			 where DEST.id is null 

		--conto gli errori per messaggio  nel DELTA POSITIVO da AGGIUNGERE
		select Hash_Messaggio , COUNT(*) as Num_Errori
			into #tempU3mesi_Delta_Positivo
				from 
					#temp_Delta_Positivo with (nolock)
				--where datediff(MONTH,TimeCreated,@EndDate ) <=3 
					group by Hash_Messaggio
		
		--AGGIORNO TUTTI I CONTATORI 
		update 
			A
			set A.Num_U3Mesi=isnull(A.Num_U3Mesi,0) + Num_Errori,
				A.Num_UMese=isnull(A.Num_UMese,0) + Num_Errori,
				A.Num_USettimana=isnull(A.Num_USettimana,0) + Num_Errori,
				A.Num_Oggi=isnull(A.Num_Oggi,0) + Num_Errori
			from
				Ctl_Event_Log_Report A
					inner join  #tempU3mesi_Delta_Positivo B on A.Hash_Messaggio=B.Hash_Messaggio

		

		IF OBJECT_ID(N'tempdb..#tempU3mesi_Delta_Positivo') IS NOT NULL
		BEGIN
			DROP TABLE #tempU3mesi_Delta_Positivo
		END

		

	end


	--AGGIORNO DATA ULTIMA ELABORAZIONE
	--update CTL_Counters set Altro='2021-09-14 10:00:00' where Name='DATE_LAST_ELAB_REPORT_MONITOR_EVENTI'
	update CTL_Counters set Altro=CONVERT(varchar(19),GETDATE(),121) where Name='DATE_LAST_ELAB_REPORT_MONITOR_EVENTI'
	
	--select * from CTL_Counters with (nolock) where Name='DATE_LAST_ELAB_REPORT_MONITOR_EVENTI'
	



END





GO
