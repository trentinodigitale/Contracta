USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_CTL_EVENT_LOG_REPORT]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[OLD_DASHBOARD_CTL_EVENT_LOG_REPORT] as 


	select TipologiaErrore as 'id', TipologiaErrore,descrizione_tipologia as Descrizione, SUM(isnull(Num_U3Mesi,0)) as Num_U3Mesi,SUM(isnull(Num_UMese,0)) as Num_UMese,SUM(isnull(Num_USettimana,0)) as Num_USettimana,
		SUM(isnull(Num_Oggi,0)) as Num_Oggi
		,Data_Notifica_U3Mesi, Data_Notifica_UMese,Data_Notifica_USettimana,Data_Notifica_Oggi
	from
		
		Document_Configurazione_Monitor_Tipologie with (nolock) 
		 
			inner join Ctl_Event_Log_Report with (nolock) on '###' + Titolo_Tipologia + '###' like TipologiaErrore 
		where deleted=0
		group by TipologiaErrore,descrizione_tipologia,Data_Notifica_U3Mesi, Data_Notifica_UMese,Data_Notifica_USettimana,Data_Notifica_Oggi
GO
