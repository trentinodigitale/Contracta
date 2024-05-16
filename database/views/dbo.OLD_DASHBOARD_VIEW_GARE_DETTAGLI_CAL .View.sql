USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_GARE_DETTAGLI_CAL ]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










--DASHBOARD_VIEW_GARE_ENTE_DETTAGLI_CAL

CREATE view [dbo].[OLD_DASHBOARD_VIEW_GARE_DETTAGLI_CAL ] as 

select 

			*
	from 

		(

				--scadenze bando_gara e bando_semplificato
				select 
			
					id 
					, convert( datetime, convert(varchar(10),DataScadenzaOfferta, 126 ))  as DataRiferimento
					,convert(varchar(10),DataScadenzaOfferta, 126 )  as linkeddoc
					,'' as CAL_Ora
					,substring(convert(varchar(18),DataScadenzaOfferta, 126 ),12,5) as CAL_OraFine

					--,'Scadenza Gara' as Descrizione
					,'Termine Presentazione' as Descrizione
					,CIG
					,aziragionesociale
			
					,DataScadenzaOfferta AS 	DataRiferimentoCompleta

					, azienda as AZI_Ente
					, dbo.GetDescTipoProcedura ( d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara )  as DescTipoProcedura
					,TipoDoc as  OPEN_DOC_NAME
					,Titolo

				FROM 
					ctl_doc d inner join document_bando on id=idheader
						inner join aziende on azienda = idazi
					WHERE 
						   tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
						   AND d.deleted = 0
						   AND d.statodoc = 'sended'	
	
				union all 

				--DataAperturaOfferte bando_gara e bando_semplificato
				select 
			
					id 
					, convert( datetime, convert(varchar(10),DataAperturaOfferte, 126 ))  as DataRiferimento
					,convert(varchar(10),DataAperturaOfferte, 126 )  as linkeddoc
			
					,substring(convert(varchar(18),DataAperturaOfferte, 126 ),12,5) as CAL_Ora
					,'' as CAL_OraFine

					--,'Aperura Offerte' as Descrizione
					,'Data Prima Seduta' as Descrizione
					,CIG
					,aziragionesociale
					,DataAperturaOfferte AS 	DataRiferimentoCompleta

					, azienda as AZI_Ente
					, dbo.GetDescTipoProcedura ( d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara )  as DescTipoProcedura
					,TipoDoc as  OPEN_DOC_NAME
					,Titolo
				FROM 
					ctl_doc d  inner join document_bando on id=idheader
						inner join aziende on azienda = idazi
					WHERE 
						   tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
						   AND d.deleted = 0
						   AND d.statodoc = 'sended'	
		

				union all
		
				--DataTermineQuesiti bando_gara e bando_semplificato
				select 
			
					id 
					, convert( datetime, convert(varchar(10),DataTermineQuesiti, 126 ))  as DataRiferimento
					,convert(varchar(10),DataTermineQuesiti, 126 )  as linkeddoc
					,'' as CAL_Ora
					,substring(convert(varchar(18),DataTermineQuesiti, 126 ),12,5) as CAL_OraFine

					,--'Scadenza Gara'
					'Termine quesiti' as Descrizione
					,CIG
					,aziragionesociale
					,DataTermineQuesiti AS 	DataRiferimentoCompleta

					, azienda as AZI_Ente
					, dbo.GetDescTipoProcedura ( d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara )  as DescTipoProcedura
					,TipoDoc as  OPEN_DOC_NAME
					,Titolo

				FROM 
					ctl_doc d inner join document_bando on id=idheader
						inner join aziende on azienda = idazi
					WHERE 
						   tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
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
					,'' as CIG
					,'' as aziragionesociale
					,dateadd ( day , giorno  , DataInizio ) AS 	DataRiferimentoCompleta

					, null  as AZI_Ente
					--,cast(A.IdAzi as varchar(500)) as AZI_Ente
					, ''  as DescTipoProcedura
					,TipoDoc as  OPEN_DOC_NAME
					,Titolo
		
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
					--cross join Aziende A with(nolock)
				WHERE
				
					tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'			
					and convert(varchar(10),dateadd ( day , giorno , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )			
		

		) V






		----select 
		----	T.idmsg as id
		----	--,convert(datetime,left(TMF.ExpiryDate	,10)) as DataRiferimento
		----	,case 
		----		when ISDATE(TMF.ExpiryDate)=1 then 
		----			convert(datetime,left(TMF.ExpiryDate	,10)) 
		----		else null
		----	end AS 	DataRiferimento
			
		----	,left(TMF.ExpiryDate	,10) as linkeddoc
		----	,'' as CAL_Ora
		----	,substring(TMF.ExpiryDate,12,5) as CAL_OraFine
		----	,'Scadenza Gara' as Descrizione
		----	,CIG
		----	,aziragionesociale
		----	,case 
		----		when ISDATE(TMF.ExpiryDate)=1 then 
		----			convert(datetime,TMF.ExpiryDate) 
		----		else null
		----	end AS 	DataRiferimentoCompleta

		----FROM TAB_MESSAGGI as T with(nolock)
		----	 inner join TAB_UTENTI_MESSAGGI TU with(nolock) on T.idmsg=TU.umidmsg
		----			 inner join TAB_MESSAGGI_FIELDS as TMF with(nolock) on TMF.idmsg=TU.umidmsg
		----				inner join profiliutente on idpfu=idmittente
		----				inner join aziende on pfuidazi=idazi
		----	WHERE 
		----		   msgItype = 55
		----		   and msgisubtype in (167,68)
		----		   AND umInput = 0
		----		   AND umStato = 0
		----		   AND umIdPfu <> -10
		----		   and TMF.stato=2 and ( TMF.advancedstate='0' or TMF.advancedstate='')

		----union all
	
		------ DataAperturaOfferte GARE bandi FU e RDP
		----select 
		----	T.idmsg as id
		----	--,convert(datetime,left(TMF.DataAperturaOfferte	,10)) as DataRiferimento
			
		----	,case 
		----		when ISDATE(TMF.DataAperturaOfferte)=1 then 
		----			convert(datetime,left(TMF.DataAperturaOfferte	,10)) 
		----		else null
		----	end AS 	DataRiferimento
			
		----	,left(TMF.DataAperturaOfferte	,10) as linkeddoc
		----	,substring(TMF.DataAperturaOfferte,12,5) as CAL_Ora
		----	,'' as CAL_OraFine
		----	,'Aperura Offerte' as Descrizione
		----	,CIG
		----	,aziragionesociale
			
		----	,case 
		----		when ISDATE(TMF.DataAperturaOfferte)=1 then 
		----			convert(datetime,TMF.DataAperturaOfferte) 
		----		else null
		----	end AS 	DataRiferimentoCompleta

		----FROM TAB_MESSAGGI as T with(nolock)
		----	 inner join TAB_UTENTI_MESSAGGI TU with(nolock) on T.idmsg=TU.umidmsg
		----			 inner join TAB_MESSAGGI_FIELDS as TMF with(nolock) on TMF.idmsg=TU.umidmsg
		----			 inner join profiliutente on idpfu=idmittente
		----				inner join aziende on pfuidazi=idazi
		----	WHERE 
		----		   msgItype = 55
		----		   and msgisubtype in (167,68)
		----		   AND umInput = 0
		----		   AND umStato = 0
		----		   AND umIdPfu <> -10
		----		   and TMF.stato=2 and ( TMF.advancedstate='0' or TMF.advancedstate='')
		----		   and isnull(TMF.DataAperturaOfferte,'')<>''
				   	

		----union all
		
		------ TermineRichiestaQuesiti bandi FU e RDP
		----select 
		----	T.idmsg as id
		----	--,convert(datetime,left(TMF.TermineRichiestaQuesiti	,10)) as DataRiferimento
		----	,case 
		----		when ISDATE(TMF.TermineRichiestaQuesiti)=1 then 
		----			convert(datetime,left(TMF.TermineRichiestaQuesiti	,10)) 
		----		else null
		----	end AS 	DataRiferimento
			
		----	,left(TMF.TermineRichiestaQuesiti	,10) as linkeddoc
			
		----	,'' as CAL_Ora
		----	,substring(TMF.TermineRichiestaQuesiti,12,5) as CAL_OraFine

		----	,'Scadenza Quesiti' as Descrizione
		----	,CIG
		----	,aziragionesociale
		----	,case 
		----		when ISDATE(TMF.TermineRichiestaQuesiti)=1 then 
		----			convert(datetime,TMF.TermineRichiestaQuesiti) 
		----		else null
		----	end AS 	DataRiferimentoCompleta

		----FROM TAB_MESSAGGI as T with(nolock)
		----	 inner join TAB_UTENTI_MESSAGGI TU with(nolock) on T.idmsg=TU.umidmsg
		----			 inner join TAB_MESSAGGI_FIELDS as TMF with(nolock) on TMF.idmsg=TU.umidmsg
		----			  inner join profiliutente on idpfu=idmittente
		----				inner join aziende on pfuidazi=idazi
		----	WHERE 
		----		   msgItype = 55
		----		   and msgisubtype in (167,68)
		----		   AND umInput = 0
		----		   AND umStato = 0
		----		   AND umIdPfu <> -10
		----		   and TMF.stato=2 and  ( TMF.advancedstate='0' or TMF.advancedstate='')
		----		   and isnull(TMF.TermineRichiestaQuesiti,'')<>''

		----union all
		
		----scadenze bando_gara e bando_semplificato
		--select 
			
		--	id 
		--	, convert( datetime, convert(varchar(10),DataScadenzaOfferta, 126 ))  as DataRiferimento
		--	,convert(varchar(10),DataScadenzaOfferta, 126 )  as linkeddoc
		--	,'' as CAL_Ora
		--	,substring(convert(varchar(18),DataScadenzaOfferta, 126 ),12,5) as CAL_OraFine

		--	,'Scadenza Gara' as Descrizione
		--	,CIG
		--	,aziragionesociale
			
		--	,DataScadenzaOfferta AS 	DataRiferimentoCompleta

		--FROM 
		--	ctl_doc inner join document_bando on id=idheader
		--		inner join aziende on azienda = idazi
		--	WHERE 
		--		   tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
		--		   and StatoFunzionale='Pubblicato'
	
		--union all 
		----DataAperturaOfferte bando_gara e bando_semplificato
		--select 
			
		--	id 
		--	, convert( datetime, convert(varchar(10),DataAperturaOfferte, 126 ))  as DataRiferimento
		--	,convert(varchar(10),DataAperturaOfferte, 126 )  as linkeddoc
			
		--	,substring(convert(varchar(18),DataAperturaOfferte, 126 ),12,5) as CAL_Ora
		--	,'' as CAL_OraFine

		--	,'Aperura Offerte' as Descrizione
		--	,CIG
		--	,aziragionesociale
		--	,DataAperturaOfferte AS 	DataRiferimentoCompleta

		--FROM 
		--	ctl_doc inner join document_bando on id=idheader
		--		inner join aziende on azienda = idazi
		--	WHERE 
		--		   tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
		--		   and StatoFunzionale='Pubblicato'

		

		--union all
		
		----DataTermineQuesiti bando_gara e bando_semplificato
		--select 
			
		--	id 
		--	, convert( datetime, convert(varchar(10),DataTermineQuesiti, 126 ))  as DataRiferimento
		--	,convert(varchar(10),DataTermineQuesiti, 126 )  as linkeddoc
		--	,'' as CAL_Ora
		--	,substring(convert(varchar(18),DataTermineQuesiti, 126 ),12,5) as CAL_OraFine

		--	,'Scadenza Gara' as Descrizione
		--	,CIG
		--	,aziragionesociale
		--	,DataTermineQuesiti AS 	DataRiferimentoCompleta

		--FROM 
		--	ctl_doc inner join document_bando on id=idheader
		--		inner join aziende on azienda = idazi
		--	WHERE 
		--		   tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
		--		   and StatoFunzionale='Pubblicato'

		

		----fermo sistema
		--union all
		
		--select 
		--	id
		--	, convert( datetime, convert(varchar(10),DataInizio, 126 ))  as DataRiferimento
		--	,convert(varchar(10),DataInizio, 126 )  as linkeddoc
		--	,substring(convert(varchar(18),DataInizio, 126 ),12,5) as CAL_Ora
		--	, case 
		--		when convert( datetime, convert(varchar(10),DataInizio, 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
		--			substring(convert(varchar(18),DataFine, 126 ),12,5) 
		--		else
		--			'24:00'
			
		--		end as  CAL_OraFine

		--	,'Fermo Sistema' as Descrizione
		--	,'' as CIG
		--	,aziragionesociale
		--	,DataInizio AS 	DataRiferimentoCompleta

		--	FROM
		--		ctl_doc inner join Document_FermoSistema on id=idheader
		--			inner join aziende on azienda = idazi
		--	WHERE
				
		--		tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		
		
		--union all 
		
		--select 
		--	id
		--	, convert( datetime, convert(varchar(10),dateadd ( day , 1 , DataInizio ), 126 ))  as DataRiferimento
		--	,convert(varchar(10),dateadd ( day , 1 , DataInizio ), 126 )  as linkeddoc
		--	, '00:00' CAL_Ora
		--	,case 
		--		when convert( datetime, convert(varchar(10),dateadd ( day , 1 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
		--			substring(convert(varchar(18),DataFine, 126 ),12,5) 
		--		else
		--			'24:00'
			
		--		end as  CAL_OraFine
		--	,'Fermo Sistema' as Descrizione
		--	,'' as CIG
		--	,aziragionesociale
		--	,dateadd ( day , 1 , DataInizio ) AS 	DataRiferimentoCompleta

		--	FROM
		--		ctl_doc inner join Document_FermoSistema on id=idheader
		--			inner join aziende on azienda = idazi
		--	WHERE
				
		--		tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		
		--	and convert(varchar(10),dateadd ( day , 1 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )
	
		--union all 
		--select 
		--	id
		--	, convert( datetime, convert(varchar(10),dateadd ( day , 2 , DataInizio ), 126 ))  as DataRiferimento
		--	,convert(varchar(10),dateadd ( day , 2 , DataInizio ), 126 )  as linkeddoc
		--	, '00:00' CAL_Ora
		--	,case 
		--		when convert( datetime, convert(varchar(10),dateadd ( day , 2 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
		--			substring(convert(varchar(18),DataFine, 126 ),12,5) 
		--		else
		--			'24:00'
			
		--		end as  CAL_OraFine
		--	,'Fermo Sistema' as Descrizione
		--	,'' as CIG
		--	,aziragionesociale
		--	,dateadd ( day , 2 , DataInizio ) AS 	DataRiferimentoCompleta
		--	FROM
		--		ctl_doc inner join Document_FermoSistema on id=idheader
		--			inner join aziende on azienda = idazi
		--	WHERE
				
		--		tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		
		--	and convert(varchar(10),dateadd ( day , 2 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )
		
		--union all 
		--select 
		--	id
		--	, convert( datetime, convert(varchar(10),dateadd ( day , 3 , DataInizio ), 126 ))  as DataRiferimento
		--	,convert(varchar(10),dateadd ( day , 3 , DataInizio ), 126 )  as linkeddoc
		--	, '00:00' CAL_Ora
		--	,case 
		--		when convert( datetime, convert(varchar(10),dateadd ( day , 3 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
		--			substring(convert(varchar(18),DataFine, 126 ),12,5) 
		--		else
		--			'24:00'
			
		--		end as  CAL_OraFine
		--	,'Fermo Sistema' as Descrizione
		--	,'' as CIG
		--	,aziragionesociale
		--	,dateadd ( day , 3 , DataInizio ) AS 	DataRiferimentoCompleta
		--	FROM
		--		ctl_doc inner join Document_FermoSistema on id=idheader
		--			inner join aziende on azienda = idazi
		--	WHERE
				
		--		tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		
		--	and convert(varchar(10),dateadd ( day , 3 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )
		
		--union all 
		--select 
		--	id
		--	, convert( datetime, convert(varchar(10),dateadd ( day , 4 , DataInizio ), 126 ))  as DataRiferimento
		--	,convert(varchar(10),dateadd ( day ,4 , DataInizio ), 126 )  as linkeddoc
		--	, '00:00' CAL_Ora
		--	,case 
		--		when convert( datetime, convert(varchar(10),dateadd ( day , 4 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
		--			substring(convert(varchar(18),DataFine, 126 ),12,5) 
		--		else
		--			'24:00'
			
		--		end as  CAL_OraFine
		--	,'Fermo Sistema' as Descrizione
		--	,'' as CIG
		--	,aziragionesociale
		--	,dateadd ( day , 4 , DataInizio ) AS 	DataRiferimentoCompleta
		--	FROM
		--		ctl_doc inner join Document_FermoSistema on id=idheader
		--			inner join aziende on azienda = idazi
		--	WHERE
				
		--		tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		
		--	and convert(varchar(10),dateadd ( day , 4, DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )

		--union all 
		--select 
		--	id
		--	, convert( datetime, convert(varchar(10),dateadd ( day , 5 , DataInizio ), 126 ))  as DataRiferimento
		--	,convert(varchar(10),dateadd ( day , 5 , DataInizio ), 126 )  as linkeddoc
		--	, '00:00' CAL_Ora
		--	,case 
		--		when convert( datetime, convert(varchar(10),dateadd ( day , 5 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
		--			substring(convert(varchar(18),DataFine, 126 ),12,5) 
		--		else
		--			'24:00'
			
		--		end as  CAL_OraFine
		--	,'Fermo Sistema' as Descrizione
		--	,'' as CIG
		--	,aziragionesociale
		--	,dateadd ( day , 5 , DataInizio ) AS 	DataRiferimentoCompleta
		--	FROM
		--		ctl_doc inner join Document_FermoSistema on id=idheader
		--			inner join aziende on azienda = idazi
		--	WHERE
				
		--		tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		
		--	and convert(varchar(10),dateadd ( day , 5 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )
		
		--union all		
		--select 
		--	id
		--	, convert( datetime, convert(varchar(10),dateadd ( day , 6 , DataInizio ), 126 ))  as DataRiferimento
		--	,convert(varchar(10),dateadd ( day , 6 , DataInizio ), 126 )  as linkeddoc
		--	, '00:00' CAL_Ora
		--	,case 
		--		when convert( datetime, convert(varchar(10),dateadd ( day , 6 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
		--			substring(convert(varchar(18),DataFine, 126 ),12,5) 
		--		else
		--			'24:00'
			
		--		end as  CAL_OraFine
		--	,'Fermo Sistema' as Descrizione
		--	,'' as CIG
		--	,aziragionesociale
		--	,dateadd ( day , 6 , DataInizio ) AS 	DataRiferimentoCompleta
		--	FROM
		--		ctl_doc inner join Document_FermoSistema on id=idheader
		--			inner join aziende on azienda = idazi
		--	WHERE
				
		--		tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		
		--	and convert(varchar(10),dateadd ( day , 6 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )
		
		--union all
		--select 
		--	id
		--	, convert( datetime, convert(varchar(10),dateadd ( day , 7 , DataInizio ), 126 ))  as DataRiferimento
		--	,convert(varchar(10),dateadd ( day , 7 , DataInizio ), 126 )  as linkeddoc
		--	, '00:00' CAL_Ora
		--	,case 
		--		when convert( datetime, convert(varchar(10),dateadd ( day , 7 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
		--			substring(convert(varchar(18),DataFine, 126 ),12,5) 
		--		else
		--			'24:00'
			
		--		end as  CAL_OraFine
		--	,'Fermo Sistema' as Descrizione
		--	,'' as CIG
		--	,aziragionesociale
		--	,dateadd ( day , 7 , DataInizio ) AS 	DataRiferimentoCompleta
		--	FROM
		--		ctl_doc inner join Document_FermoSistema on id=idheader
		--			inner join aziende on azienda = idazi
		--	WHERE
				
		--		tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		
		--	and convert(varchar(10),dateadd ( day , 7 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )






GO
