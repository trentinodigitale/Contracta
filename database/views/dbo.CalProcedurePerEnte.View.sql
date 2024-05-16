USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CalProcedurePerEnte]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  view [dbo].[CalProcedurePerEnte] as 
		
		select 

			convert(varchar(10),
				case 
					when Dt = 'DataScadenzaOfferta' then DataScadenzaOfferta
					when Dt = 'DataAperturaOfferte' then DataAperturaOfferte
					when Dt = 'DataTermineQuesiti' then DataTermineQuesiti
				end , 126 )  as id

			, convert( datetime, convert(varchar(10),
				case 
					when Dt = 'DataScadenzaOfferta' then DataScadenzaOfferta
					when Dt = 'DataAperturaOfferte' then DataAperturaOfferte
					when Dt = 'DataTermineQuesiti' then DataTermineQuesiti
				end  , 126 ))  as DataRiferimento

			, dbo.GetDescTipoProcedura( Tipodoc , TipoProceduraCaratteristica , ProceduraGara , TipoBandoGara)  as Descrizione
			,Azienda
			,Dt as TipoData
			FROM 
				ctl_doc 
				inner join document_bando on id=idheader
				cross join ( select 'DataScadenzaOfferta' as Dt union all select 'DataAperturaOfferte' as dt union all select 'DataTermineQuesiti' as Dt ) as D
			WHERE 
				tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
				and statodoc='Sended'
				and deleted = 0 
		

		union all


			select 
				convert(varchar(10),dateadd ( day , N , DataInizio ), 126 )  as id
				, convert( datetime, convert(varchar(10),dateadd ( day , N , DataInizio ), 126 ))  as DataRiferimento
				,'Fermo Sistema' as Descrizione
				, '-20' AS Azienda
				, 'DataFermoSistema'  as TipoData
			FROM
				ctl_doc 
				inner join Document_FermoSistema on id=idheader
				cross join ( select 0 as N union all select 1 as N  union all select 2 as N  union all select 3 as N  union all select 4 as N  union all select 5 as N  union all select 6 as N  union all select 7 as N ) as G

			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'			
				and convert(varchar(10),dateadd ( day , N , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )			



GO
