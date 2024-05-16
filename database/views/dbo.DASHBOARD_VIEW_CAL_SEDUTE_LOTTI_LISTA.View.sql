USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CAL_SEDUTE_LOTTI_LISTA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DASHBOARD_VIEW_CAL_SEDUTE_LOTTI_LISTA] as
select 
	datepart( dw , isnull(a.data , cast( g.data as datetime))) as CAL_Giorno,
	isnull(a.data , cast( g.data as datetime)) as data , 
	day(isnull(a.data , cast( g.data as datetime)) ) as CAL_Day ,
	case when a.data is null then '' else substring( convert( varchar , isnull(a.data , cast( g.data as datetime)) , 121) , 12 , 5 ) end as CAL_Ora ,
	substring( g.data , 6 ,2  ) as CAL_Mese, 
	left( g.data , 7 ) as MeseCalendar , 
	isnull( OPEN_DOC_NAME , 'NODOC' ) as OPEN_DOC_NAME  ,
	Referente , 
	Protocollo , 
	NumeroSeduta , 
	isnull( id , 0 ) as id ,
	Descrizione
from 
	Document_Giorni g left outer join
		(
			select 
					
					'SCHEDA_PROGETTO' as OPEN_DOC_NAME ,  a.IdRow  as id,  ReferenteUffAppalti as Referente , 
					ProtocolloBando  as Protocollo,  NumeroSeduta  , DataSeduta as Data , 
					DescrizioneSeduta as Descrizione
				
			from DASHBOARD_VIEW_PROSPETTO_APPALTI a
						inner join Document_lotti_Sedute  b on a.IdRow = b.IdRow

			union
			select 
					
					'EVENTO.800.300' as OPEN_DOC_NAME , id , Referente  , Protocollo  , '' , Data , 
					Descrizione
				from Document_Notes where deleted = 0
		) as a on left( convert( varchar , a.Data , 121) , 10 ) = g.data

GO
