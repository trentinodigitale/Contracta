USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_MONITOR_EVENTI_ALERTING]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[MAIL_MONITOR_EVENTI_ALERTING]AS

SELECT  
'I' as lng ,
IdRow as iddoc,
*,
case
	when U3Mesi > isnull(Soglia_Ultimi_3Mesi,0) then 
			'Soglia ultimi 3 mesi: <strong>' + cast(Soglia_Ultimi_3Mesi as varchar) + '</strong><br> N. errori ultimi 3 mesi: <strong>' + cast(U3Mesi as varchar) + '</strong>'
			+ '<br>Arco temporale: dalla data <strong>' +   convert( varchar(10) , dateadd(month,-3,altro), 103  ) + ' ' + convert( varchar(10) , dateadd(month,-3,altro), 108  ) + ' </strong> alla data <strong>' +
				 convert( varchar(10) , cast(Altro as datetime), 103  ) + ' ' + convert( varchar(10) , cast(Altro as datetime), 108  ) + '</strong>'
	else ''
end as Riepilogo3Mesi
,case
	when UMese > isnull(Soglia_Ultimo_Mese,0) then 
		'Soglia ultimo mese: <strong>' + cast(Soglia_Ultimo_Mese as varchar) + '</strong><br>N. errori ultimo mese: <strong>' + cast(UMese as varchar)+ '</strong>'
		+ '<br>Arco temporale: dalla data <strong>' +   convert( varchar(10) , dateadd(month,-1,altro), 103  ) + ' ' + convert( varchar(10) , dateadd(month,-1,altro), 108  ) + ' </strong> alla data <strong>' +
				 convert( varchar(10) , cast(Altro as datetime), 103  ) + ' ' + convert( varchar(10) , cast(Altro as datetime), 108  ) + '</strong>'
	else ''

end as Riepilogo1Mese
,case
	when USettimana > isnull(Soglia_Ultima_Settimana,0) then 
		'Soglia ultima settimana: <strong>' + cast(Soglia_Ultima_Settimana as varchar) + '</strong><br>N. errori ultima settimana: <strong>' + cast(USettimana as varchar)+ '</strong>'
		+ '<br>Arco temporale: dalla data <strong>' +   convert( varchar(10) , dateadd(WEEK,-1,altro), 103  ) + ' ' + convert( varchar(10) , dateadd(WEEK,-1,altro), 108  ) + ' </strong> alla data <strong>' +
				 convert( varchar(10) , cast(Altro as datetime), 103  ) + ' ' + convert( varchar(10) , cast(Altro as datetime), 108  ) + '</strong>'
	else ''
end as RiepilogoUSettimana
,case
	when Oggi> isnull(Soglia_Oggi,0) then 'Soglia oggi: <strong>' + cast(Soglia_Oggi as varchar) + '</strong><br>N. errori oggi: <strong>' + cast(Oggi as varchar)+ '</strong>'
	+ '<br>Arco temporale: dalla data <strong>' +   convert( varchar(10) , cast(Altro as datetime), 103  ) + ' 00:00:00  </strong> alla data <strong>' +
				 convert( varchar(10) , cast(Altro as datetime), 103  ) + ' ' + convert( varchar(10) , cast(Altro as datetime), 108  ) + '</strong>'
	else ''
end as RiepilogoOggi,

replace(tipologiaerrore,'###','') as V_TipologiaErrore

FROM         
	 
	 Document_Configurazione_Monitor_Tipologie with (nolock)
		inner join 
			( 
				select 
					TipologiaErrore,SUM(isnull(Num_U3Mesi,0)) as U3Mesi,SUM(isnull(Num_UMese,0)) as UMese,SUM(isnull(Num_USettimana,0)) as USettimana,SUM(isnull(Num_Oggi,0)) as Oggi
					from 
						Ctl_Event_Log_Report with (nolock)
				group by TipologiaErrore
			) V on  '###' + Titolo_Tipologia + '###' like TipologiaErrore 
				and ( 
					(U3Mesi > Soglia_Ultimi_3Mesi and Soglia_Ultimi_3Mesi>0 )
					or 
					(UMese > Soglia_Ultimo_Mese and Soglia_Ultimo_Mese>0 )
					or 
					(USettimana > Soglia_Ultima_Settimana and Soglia_Ultima_Settimana>0 )
					or 
					(Oggi > Soglia_Oggi and Soglia_Oggi>0 )
					)
				and mailto<>''
			inner join 
				CTL_Counters with (nolock) on Name ='DATE_LAST_ELAB_REPORT_MONITOR_EVENTI'
			
where Deleted=0
			

			
GO
