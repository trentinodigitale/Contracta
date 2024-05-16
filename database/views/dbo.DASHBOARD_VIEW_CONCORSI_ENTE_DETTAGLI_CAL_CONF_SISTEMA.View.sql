USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_CONCORSI_ENTE_DETTAGLI_CAL_CONF_SISTEMA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









--DASHBOARD_VIEW_GARE_ENTE_DETTAGLI_CAL

CREATE view [dbo].[DASHBOARD_VIEW_CONCORSI_ENTE_DETTAGLI_CAL_CONF_SISTEMA] as 

select 

			*
	from 

		(

				--scadenze BANDO_CONCORSO
				select 
			
					id 
					, convert( datetime, convert(varchar(10),DataScadenzaOfferta, 126 ))  as DataRiferimento
					,convert(varchar(10),DataScadenzaOfferta, 126 )  as linkeddoc
					,'' as CAL_Ora
					,substring(convert(varchar(18),DataScadenzaOfferta, 126 ),12,5) as CAL_OraFine

					--,'Scadenza Gara' as Descrizione
					,'Termine Presentazione' as Descrizione
					, 'Termine Presentazione' as Tipo_DataScadenza
					,CIG
					,aziragionesociale
			
					,DataScadenzaOfferta AS 	DataRiferimentoCompleta
					,DataScadenzaOfferta AS 	DataRiferimentoCompletaAl
					, azienda as AZI_Ente
					, dbo.GetDescTipoProcedura ( d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara, TipoBandoGara )  as DescTipoProcedura
					,TipoDoc as  OPEN_DOC_NAME
					,Titolo
					, protocollo 
					, aziE_Mail 
					
				FROM 
					ctl_doc d inner join document_bando on id=idheader
						inner join aziende on azienda = idazi
					WHERE 
						   tipodoc in ('BANDO_CONCORSO')
						   AND d.deleted = 0
						   AND d.statodoc = 'sended'	
	
				union all 

				--DataAperturaOfferte BANDO_CONCORSO
				select 
			
					id 
					, convert( datetime, convert(varchar(10),DataAperturaOfferte, 126 ))  as DataRiferimento
					,convert(varchar(10),DataAperturaOfferte, 126 )  as linkeddoc
			
					,substring(convert(varchar(18),DataAperturaOfferte, 126 ),12,5) as CAL_Ora
					,'' as CAL_OraFine

					--,'Aperura Offerte' as Descrizione
					,'Data Prima Seduta' as Descrizione
					, 'Data Prima Seduta' as Tipo_DataScadenza
					,CIG
					,aziragionesociale
					,DataAperturaOfferte AS 	DataRiferimentoCompleta
					,DataAperturaOfferte AS 	DataRiferimentoCompletaAl

					, azienda as AZI_Ente
					, dbo.GetDescTipoProcedura ( d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara , TipoBandoGara)  as DescTipoProcedura
					,TipoDoc as  OPEN_DOC_NAME
					,Titolo
					, protocollo 
					, aziE_Mail 
				FROM 
					ctl_doc d  inner join document_bando on id=idheader
						inner join aziende on azienda = idazi
					WHERE 
						   tipodoc in ('BANDO_CONCORSO')
						   AND d.deleted = 0
						   AND d.statodoc = 'sended'	
		

				union all
		
				--DataTermineQuesiti BANDO_CONCORSO
				select 
			
					id 
					, convert( datetime, convert(varchar(10),DataTermineQuesiti, 126 ))  as DataRiferimento
					,convert(varchar(10),DataTermineQuesiti, 126 )  as linkeddoc
					,'' as CAL_Ora
					,substring(convert(varchar(18),DataTermineQuesiti, 126 ),12,5) as CAL_OraFine

					,--'Scadenza Gara'
					'Termine Quesiti' as Descrizione
					, 'Termine Quesiti' as Tipo_DataScadenza
					,CIG
					,aziragionesociale
					,DataTermineQuesiti AS 	DataRiferimentoCompleta
					,DataTermineQuesiti AS 	DataRiferimentoCompletaAl

					, azienda as AZI_Ente
					, dbo.GetDescTipoProcedura ( d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara, TipoBandoGara )  as DescTipoProcedura
					,TipoDoc as  OPEN_DOC_NAME
					,Titolo
					, protocollo 
					, aziE_Mail 
				FROM 
					ctl_doc d inner join document_bando on id=idheader
						inner join aziende on azienda = idazi
					WHERE 
						   tipodoc in ('BANDO_CONCORSO')
						   AND d.deleted = 0
						   AND d.statodoc = 'sended'			

			--fermo sistema (devo prendere tutti i giornicheintercorrono tra datainizio e datafine)
			union all
			select 


					id 
					, convert( datetime, convert(varchar(10),dateadd ( day , giorno  , DataInizio ), 126 ))  as DataRiferimento
					, convert( datetime, convert(varchar(10),dateadd ( day , giorno  , DataInizio ), 126 ))  as   linkeddoc
					,case when giorno = 0 then substring(convert(varchar(18),DataInizio, 126 ),12,5) else '' end  as CAL_Ora
					,
						case when convert(varchar(10),dateadd ( day , giorno , DataInizio ), 126 ) = convert(varchar(10),DataFine, 126 ) 
						then substring(convert(varchar(18),DataFine, 126 ),12,5) else '' end  as CAL_OraFine

					,--'Scadenza Gara'
					'Fermo Sistema' as Descrizione
					, 'Fermo Sistema' as Tipo_DataScadenza

					,'' as CIG
					,'' as aziragionesociale
					,dateadd ( day , giorno  , DataInizio ) AS 	DataRiferimentoCompleta
					,dateadd ( day , giorno  , DataInizio ) AS 	DataRiferimentoCompletaAl

					--, null  as AZI_Ente
					,cast(A.IdAzi as varchar(500)) as AZI_Ente
					, ''  as DescTipoProcedura
					,TipoDoc as  OPEN_DOC_NAME
					,Titolo
					, protocollo 
					, aziE_Mail 
				FROM
					ctl_doc 
					inner join Document_FermoSistema on id=idheader
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
GO
