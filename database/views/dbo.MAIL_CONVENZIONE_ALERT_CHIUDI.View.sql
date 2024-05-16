USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_CONVENZIONE_ALERT_CHIUDI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[MAIL_CONVENZIONE_ALERT_CHIUDI] as

select 
	 DC.id as iddoc
	,'I' as LNG	
	,C2.Protocollo 
	,NumOrd as numeroconvenzione	
	,DescrizioneEstesa as OggettoConvenzione
	,convert( varchar ,DC.DataFine,103) as DataFine
	,convert( varchar ,Dateadd(day,cast(P.NumGiorni as int),DC.DataFine),103) as DataChiusuraAutomatica
	
from
	Document_convenzione DC
		inner join CTL_DOC C2 on C2.id=DC.id and C2.tipodoc='CONVENZIONE'
		cross join PARAMETRI_CONVENZIONE_TESTATA_VIEW P
	where P.StatoFunzionale='Confermato'
		and DC.Deleted = 0 
		AND DC.StatoConvenzione = 'Pubblicato' 
GO
