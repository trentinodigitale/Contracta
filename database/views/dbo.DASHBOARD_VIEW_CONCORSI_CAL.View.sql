USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CONCORSI_CAL]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










--Versione=1&data=2015-04-28&Attivita=73949&Nominativo=Enrico
CREATE view [dbo].[DASHBOARD_VIEW_CONCORSI_CAL] as 

select 

	'' as idpfu, 
	V.id,
	V.Descrizione , 
	V.DataRiferimento, 
	DescTipoProcedura,
	AZI_Ente ,
	count(*) as Num 

	from 

		(
			select 

				convert(varchar(10),DataScadenzaOfferta, 126 )  as id
				, convert( datetime, convert(varchar(10),DataScadenzaOfferta, 126 ))  as DataRiferimento
				,'Termine Presentazione' as Descrizione
				, dbo.GetDescTipoProcedura (d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara , TipoBandoGara) as DescTipoProcedura -- Aggiunto nel case della  funzione il tipodoc BANDO_CONCORSO
				, Azienda as AZI_Ente
				FROM 
					ctl_doc d with(nolock)
					inner join document_bando with(nolock) on id=idheader
				WHERE 
					tipodoc in ('BANDO_CONCORSO')
				   AND d.deleted = 0
				   AND d.statodoc = 'sended'		

			--DataAperturaOfferte BANDO_CONCORSO
			union all
			select 

				convert(varchar(10),DataAperturaOfferte, 126 )  as id
				, convert( datetime, convert(varchar(10),DataAperturaOfferte, 126 ))  as DataRiferimento
				,'Data Prima Seduta' as Descrizione
				, dbo.GetDescTipoProcedura ( d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara , TipoBandoGara)  as DescTipoProcedura
				, Azienda as AZI_Ente
				FROM 
					ctl_doc d with(nolock)
					inner join document_bando with(nolock) on id=idheader
				WHERE 
					tipodoc in ('BANDO_CONCORSO')
				   AND d.deleted = 0
				   AND d.statodoc = 'sended'		
	
		
			--DataTermineQuesiti BANDO_CONCORSO e bando_semplificato
			union all
			select 

				convert(varchar(10),DataTermineQuesiti, 126 )  as id
				, convert( datetime, convert(varchar(10),DataTermineQuesiti, 126 ))  as DataRiferimento
				,'Termine quesiti' as Descrizione
				, dbo.GetDescTipoProcedura ( d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara , TipoBandoGara)  as DescTipoProcedura
				, Azienda as AZI_Ente
				FROM 
					ctl_doc d with(nolock)
					inner join document_bando with(nolock) on id=idheader
				WHERE 
					tipodoc in ('BANDO_CONCORSO')
				   AND d.deleted = 0
				   AND d.statodoc = 'sended'		
		

			--fermo sistema (devo prendere tutti i giornicheintercorrono tra datainizio e datafine)
			union all
			select 
				convert(varchar(10),dateadd ( day , giorno , DataInizio ), 126 )  as id
				, convert( datetime, convert(varchar(10),dateadd ( day , giorno  , DataInizio ), 126 ))  as DataRiferimento
				,'Fermo Sistema' as Descrizione
				,'' as DescTipoProcedura
				--, Azienda as AZI_Ente
				,cast(A.IdAzi as varchar(500)) as AZI_Ente
				
				FROM
					ctl_doc with(nolock)
					inner join Document_FermoSistema with(nolock) on id=idheader
					cross join ( select 0 as giorno 
								union all select 1 as giorno 
								union all select 2 as giorno 
								union all select 3 as giorno 
								union all select 4 as giorno 
								union all select 5 as giorno 
								union all select 6 as giorno 
								union all select 7 as giorno 
								) as g
					cross join Aziende A with(nolock)

				WHERE
				
					tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'			
					and convert(varchar(10),dateadd ( day , giorno , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )			
		

		) V

		group by 	V.id,V.Descrizione,V.DataRiferimento ,	DescTipoProcedura,	AZI_Ente 

GO
