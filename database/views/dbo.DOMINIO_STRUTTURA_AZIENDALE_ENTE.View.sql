USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOMINIO_STRUTTURA_AZIENDALE_ENTE]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DOMINIO_STRUTTURA_AZIENDALE_ENTE] as 
	
	select 
		b.dmv_cod as Codice 
		, b.dmv_father as Path
		, b.dmv_level as Livello
		, b.DMV_DescML as Descrizione 
		, isnull( b.DMV_Deleted , 0 ) as Cancellato
	
		from lib_domainvalues b with(nolock) 


		where b.dmv_dm_id = 'TIPO_AMM_ER'

	union all

	select 
		cast( a.aziLog as varchar( 100)) as Codice 
		, d.vatValore_FT + '-' + cast( idazi  as varchar(20)) + '-' as Path
		, 3  as Livello
		, aziRagioneSociale as Descrizione 
		, isnull( aziDeleted , 0 ) as Cancellato

		from aziende a with(nolock) 
			inner join dm_attributi d with(nolock) on d.idapp = 1 and d.dztnome = 'TIPO_AMM_ER' and d.lnk = a.idazi

	union all 

	select 
		+ cast( idazi  as varchar(20)) + '#'  + s.Path as Codice 
		, d.vatValore_FT + '-' + cast( idazi  as varchar(20)) + '-'  + s.Path + '-' as Path
		, (LEN(path) / 5)  + 1 as Livello
		, Descrizione 
		, isnull( s.Deleted , 0 ) as Cancellato

		from aziende a with(nolock) 
			inner join dm_attributi d with(nolock) on d.idapp = 1 and d.dztnome = 'TIPO_AMM_ER' and d.lnk = a.idazi
			inner join AZ_STRUTTURA s with(nolock) on s.IdAz = a.idazi and Path not in ( '\0000\0000' , '\0000')
GO
