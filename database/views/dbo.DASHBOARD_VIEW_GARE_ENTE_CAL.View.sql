USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_GARE_ENTE_CAL]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[DASHBOARD_VIEW_GARE_ENTE_CAL] as 

select V.idpfu ,V.id,V.Descrizione , V.DataRiferimento, count(*) as Num from 
	(
		select 
			
			p1.idpfu
			--,T.idmsg as id
			,left(TMF.ExpiryDate	,10) as id
			--,convert(datetime,left(TMF.ExpiryDate	,10)) as DataRiferimento
			
			,case 
				when ISDATE(TMF.ExpiryDate)=1 then 
					convert(datetime,left(TMF.ExpiryDate	,10)) 
				else null
			end AS 	DataRiferimento
			
			
			,left(TMF.ExpiryDate	,10) as linkeddoc
			,'' as CAL_Ora
			,substring(TMF.ExpiryDate,12,5) as CAL_OraFine
			--,'Scadenza Gara' as Descrizione
			,'Gare' as Descrizione
			,CIG
			,aziragionesociale
			, 'DOCUMENTO_GENERICO' as OPEN_DOC_NAME
			, object_cover1 as Oggetto
		FROM TAB_MESSAGGI as T with(nolock)
			 inner join TAB_UTENTI_MESSAGGI TU with(nolock) on T.idmsg=TU.umidmsg
					 inner join TAB_MESSAGGI_FIELDS as TMF with(nolock) on TMF.idmsg=TU.umidmsg
						inner join profiliutente p on p.idpfu=idmittente
							inner join aziende on pfuidazi=idazi
								inner join profiliutente p1 on p1.pfuidazi=p.pfuidazi and p1.pfudeleted=0
			WHERE 
				   msgItype = 55
				   and msgisubtype in (167,68)
				   AND umInput = 0
				   AND umStato = 0
				   AND umIdPfu <> -10
				   and TMF.stato=2 and ( TMF.advancedstate='0' or TMF.advancedstate='')
				   and p1.idpfu>0

		union all
	
		-- DataAperturaOfferte GARE bandi FU e RDP
		select 
			
			p1.idpfu
			--,T.idmsg as id
			,left(TMF.DataAperturaOfferte	,10) as id
			--,convert(datetime,left(TMF.DataAperturaOfferte	,10)) as DataRiferimento
			
			,case 
				when ISDATE(TMF.DataAperturaOfferte)=1 then 
					convert(datetime,left(TMF.DataAperturaOfferte	,10)) 
				else null
			end AS 	DataRiferimento
			
			,left(TMF.DataAperturaOfferte	,10) as linkeddoc
			,substring(TMF.DataAperturaOfferte,12,5) as CAL_Ora
			,'' as CAL_OraFine
			--,'Aperura Offerte' as Descrizione
			,'Gare' as Descrizione
			,CIG
			,aziragionesociale
			, 'DOCUMENTO_GENERICO' as OPEN_DOC_NAME
			, object_cover1 as Oggetto
		FROM TAB_MESSAGGI as T with(nolock)
			 inner join TAB_UTENTI_MESSAGGI TU with(nolock) on T.idmsg=TU.umidmsg
					 inner join TAB_MESSAGGI_FIELDS as TMF with(nolock) on TMF.idmsg=TU.umidmsg
						inner join profiliutente p on p.idpfu=idmittente
							inner join aziende on pfuidazi=idazi
								inner join profiliutente p1 on p1.pfuidazi=p.pfuidazi and p1.pfudeleted=0	
			WHERE 
				   msgItype = 55
				   and msgisubtype in (167,68)
				   AND umInput = 0
				   AND umStato = 0
				   AND umIdPfu <> -10
				   and TMF.stato=2 and ( TMF.advancedstate='0' or TMF.advancedstate='')
				   and isnull(TMF.DataAperturaOfferte,'')<>''
				   and p1.idpfu>0

		union all
		
		-- TermineRichiestaQuesiti bandi FU e RDP
		select 

			p1.idpfu
			--,T.idmsg as id
			,left(TMF.TermineRichiestaQuesiti	,10) as id
			--,convert(datetime,left(TMF.TermineRichiestaQuesiti	,10)) as DataRiferimento
			
			,case 
				when ISDATE(TMF.TermineRichiestaQuesiti)=1 then 
					convert(datetime,left(TMF.TermineRichiestaQuesiti	,10)) 
				else null
			end AS 	DataRiferimento
			
			,left(TMF.TermineRichiestaQuesiti	,10) as linkeddoc
			
			,'' as CAL_Ora
			,substring(TMF.TermineRichiestaQuesiti,12,5) as CAL_OraFine

			--,'Scadenza Quesiti' as Descrizione
			,'Gare' as Descrizione
			,CIG
			,aziragionesociale
			, 'DOCUMENTO_GENERICO' as OPEN_DOC_NAME
			, object_cover1 as Oggetto
		FROM TAB_MESSAGGI as T with(nolock)
			 inner join TAB_UTENTI_MESSAGGI TU with(nolock) on T.idmsg=TU.umidmsg
					 inner join TAB_MESSAGGI_FIELDS as TMF with(nolock) on TMF.idmsg=TU.umidmsg
					  inner join profiliutente p on p.idpfu=idmittente
						inner join aziende on pfuidazi=idazi
							inner join profiliutente p1 on p1.pfuidazi=p.pfuidazi and p1.pfudeleted=0
			WHERE 
				   msgItype = 55
				   and msgisubtype in (167,68)
				   AND umInput = 0
				   AND umStato = 0
				   AND umIdPfu <> -10
				   and TMF.stato=2 and  ( TMF.advancedstate='0' or TMF.advancedstate='')
				   and isnull(TMF.TermineRichiestaQuesiti,'')<>''
				   and p1.idpfu>0
		union all
		
		--scadenze bando_gara e bando_semplificato
		select 
			
			p.idpfu
			--,id 
			, convert(varchar(10),DataScadenzaOfferta, 126 )  as id
			, convert( datetime, convert(varchar(10),DataScadenzaOfferta, 126 ))  as DataRiferimento
			, convert(varchar(10),DataScadenzaOfferta, 126 )  as linkeddoc
			, '' as CAL_Ora
			, substring(convert(varchar(18),DataScadenzaOfferta, 126 ),12,5) as CAL_OraFine

			--,'Scadenza Gara' as Descrizione
			,'Gare' as Descrizione
			,CIG
			,aziragionesociale
			, TipoDoc as OPEN_DOC_NAME
			, Body as Oggetto
		FROM 
			ctl_doc inner join document_bando on id=idheader
				inner join aziende on azienda = idazi
					inner join profiliutente p on pfuidazi=idazi and pfuDeleted=0
			WHERE 
				   tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
				   and StatoFunzionale='Pubblicato'
				   and p.idpfu>0

		union all 
		--DataAperturaOfferte bando_gara e bando_semplificato
		select 

			p.idpfu
			--, id 
			,convert(varchar(10),DataAperturaOfferte, 126 )  as id
			, convert( datetime, convert(varchar(10),DataAperturaOfferte, 126 ))  as DataRiferimento
			, convert(varchar(10),DataAperturaOfferte, 126 )  as linkeddoc
			
			,substring(convert(varchar(18),DataAperturaOfferte, 126 ),12,5) as CAL_Ora
			,'' as CAL_OraFine

			--,'Aperura Offerte' as Descrizione
			,'Gare' as Descrizione
			,CIG
			,aziragionesociale
			, TipoDoc as OPEN_DOC_NAME
			, Body as Oggetto
		FROM 
			ctl_doc inner join document_bando on id=idheader
				inner join aziende on azienda = idazi
					inner join profiliutente p on pfuidazi=idazi and pfuDeleted=0	
					
			WHERE 
				   tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
				   and StatoFunzionale='Pubblicato'
				   and p.idpfu>0
		

		union all
		
		--DataTermineQuesiti bando_gara e bando_semplificato
		select 
		
			p.idpfu
			--,id 
			,convert(varchar(10),DataTermineQuesiti, 126 )  as id
			, convert( datetime, convert(varchar(10),DataTermineQuesiti, 126 ))  as DataRiferimento
			,convert(varchar(10),DataTermineQuesiti, 126 )  as linkeddoc
			,'' as CAL_Ora
			,substring(convert(varchar(18),DataTermineQuesiti, 126 ),12,5) as CAL_OraFine

			--,'Scadenza Gara' as Descrizione
			,'Gare' as Descrizione
			,CIG
			,aziragionesociale
			, TipoDoc as OPEN_DOC_NAME
			, Body as Oggetto
		FROM 
			ctl_doc inner join document_bando on id=idheader
				inner join aziende on azienda = idazi
					inner join profiliutente p on pfuidazi=idazi and pfuDeleted=0	
			WHERE 
				   tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
				   and StatoFunzionale='Pubblicato'
				   and p.idpfu>0
		

		--fermo sistema
		union all
		select 

			p.idpfu
			--,id
			, convert(varchar(10),DataInizio, 126 )  as id
			, convert( datetime, convert(varchar(10),DataInizio, 126 ))  as DataRiferimento
			,convert(varchar(10),DataInizio, 126 )  as linkeddoc
			
			,substring(convert(varchar(18),DataInizio, 126 ),12,5) as CAL_Ora
			--,substring(convert(varchar(18),DataFine, 126 ),12,5) as CAL_OraFine
			, case 
				when convert( datetime, convert(varchar(10),DataInizio, 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
					substring(convert(varchar(18),DataFine, 126 ),12,5) 
				else
					'24:00'
			
				end as  CAL_OraFine

			--,substring(convert(varchar(18),DataInizio, 126 ),12,5) + '-' + substring(convert(varchar(18),DataFine, 126 ),12,5) + ' Fermo Sistema' as Descrizione
				
				--case
				--	when convert( datetime, convert(varchar(10),DataInizio, 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
				--		substring(convert(varchar(18),DataInizio, 126 ),12,5) + '-' + substring(convert(varchar(18),DataFine, 126 ),12,5) + ' Fermo Sistema' 
				--	else
				--		substring(convert(varchar(18),DataInizio, 126 ),12,5) + '-24:00 Fermo Sistema'
				
				--end as  Descrizione
			
			,'Fermo Sistema' as Descrizione

			,'' as CIG
			,aziragionesociale
			, TipoDoc as OPEN_DOC_NAME
			, '' as Oggetto
			FROM
				ctl_doc inner join Document_FermoSistema on id=idheader
					inner join aziende on azienda = idazi
						inner join profiliutente p on pfuvenditore=0
			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		

		union all
		select 

			p.idpfu
			--,id
			, convert(varchar(10),dateadd ( day , 1 , DataInizio ), 126 )  as id
			, convert( datetime, convert(varchar(10),dateadd ( day , 1 , DataInizio ), 126 ))  as DataRiferimento
			,convert(varchar(10),dateadd ( day , 1 , DataInizio ), 126 )  as linkeddoc
			
			--,substring(convert(varchar(18),DataInizio, 126 ),12,5) as CAL_Ora
			--,substring(convert(varchar(18),DataFine, 126 ),12,5) as CAL_OraFine
			
			, '00:00' CAL_Ora
			,case 
				when convert( datetime, convert(varchar(10),dateadd ( day , 1 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
					substring(convert(varchar(18),DataFine, 126 ),12,5) 
				else
					'24:00'
			
			end as  CAL_OraFine


			
			--case
			--		when convert( datetime, convert(varchar(10),dateadd ( day , 1 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
			--			'00:00-' + substring(convert(varchar(18),DataFine, 126 ),12,5) + ' Fermo Sistema' 
			--		else
			--			'00:00-24:00 Fermo Sistema'
				
			--end as  Descrizione

			,'Fermo Sistema' as Descrizione

			,'' as CIG
			,aziragionesociale
			, TipoDoc as OPEN_DOC_NAME
			, '' as Oggetto
			FROM
				ctl_doc inner join Document_FermoSistema on id=idheader
					inner join aziende on azienda = idazi
						inner join profiliutente p on pfuvenditore=0
			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'	
				and convert(varchar(10),dateadd ( day , 1 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )

		union all
		select 

			p.idpfu
			--,id
			,convert(varchar(10),dateadd ( day , 2 , DataInizio ), 126 )  as id
			, convert( datetime, convert(varchar(10),dateadd ( day , 2 , DataInizio ), 126 ))  as DataRiferimento
			,convert(varchar(10),dateadd ( day , 2 , DataInizio ), 126 )  as linkeddoc
			
			--,substring(convert(varchar(18),DataInizio, 126 ),12,5) as CAL_Ora
			--,substring(convert(varchar(18),DataFine, 126 ),12,5) as CAL_OraFine
			
			, '00:00' CAL_Ora
			,case 
				when convert( datetime, convert(varchar(10),dateadd ( day , 2 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
					substring(convert(varchar(18),DataFine, 126 ),12,5) 
				else
					'24:00'
			
			end as  CAL_OraFine


			
			--case
			--		when convert( datetime, convert(varchar(10),dateadd ( day , 2 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
			--			'00:00-' + substring(convert(varchar(18),DataFine, 126 ),12,5) + ' Fermo Sistema' 
			--		else
			--			'00:00-24:00 Fermo Sistema'
				
			--end as  Descrizione

			,'Fermo Sistema' as Descrizione

			,'' as CIG
			,aziragionesociale
			, TipoDoc as OPEN_DOC_NAME
			, '' as Oggetto
			FROM
				ctl_doc inner join Document_FermoSistema on id=idheader
					inner join aziende on azienda = idazi
						inner join profiliutente p on pfuvenditore=0
			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'	
				and convert(varchar(10),dateadd ( day , 2 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )		
		
		union all
		select 

			p.idpfu
			--,id
			, convert(varchar(10),dateadd ( day , 3 , DataInizio ), 126 )  as id
			, convert( datetime, convert(varchar(10),dateadd ( day , 3 , DataInizio ), 126 ))  as DataRiferimento
			,convert(varchar(10),dateadd ( day , 3 , DataInizio ), 126 )  as linkeddoc
			
			--,substring(convert(varchar(18),DataInizio, 126 ),12,5) as CAL_Ora
			--,substring(convert(varchar(18),DataFine, 126 ),12,5) as CAL_OraFine
			
			, '00:00' CAL_Ora
			,case 
				when convert( datetime, convert(varchar(10),dateadd ( day , 3 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
					substring(convert(varchar(18),DataFine, 126 ),12,5) 
				else
					'24:00'
			
			end as  CAL_OraFine


			
			--case
			--		when convert( datetime, convert(varchar(10),dateadd ( day , 3 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
			--			'00:00-' + substring(convert(varchar(18),DataFine, 126 ),12,5) + ' Fermo Sistema' 
			--		else
			--			'00:00-24:00 Fermo Sistema'
				
			--end as  Descrizione
			,'Fermo Sistema' as Descrizione
			
			,'' as CIG
			,aziragionesociale
			, TipoDoc as OPEN_DOC_NAME
			, '' as Oggetto
			FROM
				ctl_doc inner join Document_FermoSistema on id=idheader
					inner join aziende on azienda = idazi
						inner join profiliutente p on pfuvenditore=0
			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'	
				and convert(varchar(10),dateadd ( day , 3 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )	
		
		union all
		select 

			p.idpfu
			--,id
			, convert(varchar(10),dateadd ( day , 4 , DataInizio ), 126 )  as id
			, convert( datetime, convert(varchar(10),dateadd ( day , 4 , DataInizio ), 126 ))  as DataRiferimento
			,convert(varchar(10),dateadd ( day , 4 , DataInizio ), 126 )  as linkeddoc
			
			--,substring(convert(varchar(18),DataInizio, 126 ),12,5) as CAL_Ora
			--,substring(convert(varchar(18),DataFine, 126 ),12,5) as CAL_OraFine
			
			, '00:00' CAL_Ora
			,case 
				when convert( datetime, convert(varchar(10),dateadd ( day , 4 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
					substring(convert(varchar(18),DataFine, 126 ),12,5) 
				else
					'24:00'
			
			end as  CAL_OraFine


			
			--case
			--		when convert( datetime, convert(varchar(10),dateadd ( day , 4 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
			--			'00:00-' + substring(convert(varchar(18),DataFine, 126 ),12,5) + ' Fermo Sistema' 
			--		else
			--			'00:00-24:00 Fermo Sistema'
				
			--end as  Descrizione

			,'Fermo Sistema' as Descrizione
			,'' as CIG
			,aziragionesociale
			, TipoDoc as OPEN_DOC_NAME
			, '' as Oggetto
			FROM
				ctl_doc inner join Document_FermoSistema on id=idheader
					inner join aziende on azienda = idazi
						inner join profiliutente p on pfuvenditore=0
			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'	
				and convert(varchar(10),dateadd ( day , 4 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )

		union all
		select 

			p.idpfu
			--,id
			, convert(varchar(10),dateadd ( day , 5 , DataInizio ), 126 )  as id
			, convert( datetime, convert(varchar(10),dateadd ( day , 5 , DataInizio ), 126 ))  as DataRiferimento
			,convert(varchar(10),dateadd ( day , 5 , DataInizio ), 126 )  as linkeddoc
			
			--,substring(convert(varchar(18),DataInizio, 126 ),12,5) as CAL_Ora
			--,substring(convert(varchar(18),DataFine, 126 ),12,5) as CAL_OraFine
			
			, '00:00' CAL_Ora
			,case 
				when convert( datetime, convert(varchar(10),dateadd ( day , 5 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
					substring(convert(varchar(18),DataFine, 126 ),12,5) 
				else
					'24:00'
			
			end as  CAL_OraFine


			
			--case
			--		when convert( datetime, convert(varchar(10),dateadd ( day , 5 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
			--			'00:00-' + substring(convert(varchar(18),DataFine, 126 ),12,5) + ' Fermo Sistema' 
			--		else
			--			'00:00-24:00 Fermo Sistema'
				
			--end as  Descrizione

			,'Fermo Sistema' as Descrizione
			,'' as CIG
			,aziragionesociale
			, TipoDoc as OPEN_DOC_NAME
			, '' as Oggetto
			FROM
				ctl_doc inner join Document_FermoSistema on id=idheader
					inner join aziende on azienda = idazi
						inner join profiliutente p on pfuvenditore=0
			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'	
				and convert(varchar(10),dateadd ( day , 5 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )

		union all
		select 

			p.idpfu
			--,id
			, convert(varchar(10),dateadd ( day , 6 , DataInizio ), 126 )  as id
			, convert( datetime, convert(varchar(10),dateadd ( day , 6 , DataInizio ), 126 ))  as DataRiferimento
			,convert(varchar(10),dateadd ( day , 6 , DataInizio ), 126 )  as linkeddoc
			
			--,substring(convert(varchar(18),DataInizio, 126 ),12,5) as CAL_Ora
			--,substring(convert(varchar(18),DataFine, 126 ),12,5) as CAL_OraFine
			
			, '00:00' CAL_Ora
			,case 
				when convert( datetime, convert(varchar(10),dateadd ( day , 6 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
					substring(convert(varchar(18),DataFine, 126 ),12,5) 
				else
					'24:00'
			
			end as  CAL_OraFine


			
			--case
			--		when convert( datetime, convert(varchar(10),dateadd ( day , 6 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
			--			'00:00-' + substring(convert(varchar(18),DataFine, 126 ),12,5) + ' Fermo Sistema' 
			--		else
			--			'00:00-24:00 Fermo Sistema'
				
			--end as  Descrizione
			,'Fermo Sistema' as Descrizione
			
			,'' as CIG
			,aziragionesociale
			, TipoDoc as OPEN_DOC_NAME
			, '' as Oggetto
			FROM
				ctl_doc inner join Document_FermoSistema on id=idheader
					inner join aziende on azienda = idazi
						inner join profiliutente p on pfuvenditore=0
			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'	
				and convert(varchar(10),dateadd ( day , 6 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )

	union all
		select 

			p.idpfu
			--,id
			, convert(varchar(10),dateadd ( day , 7 , DataInizio ), 126 )  as id
			, convert( datetime, convert(varchar(10),dateadd ( day , 7 , DataInizio ), 126 ))  as DataRiferimento
			,convert(varchar(10),dateadd ( day , 7 , DataInizio ), 126 )  as linkeddoc
			
			--,substring(convert(varchar(18),DataInizio, 126 ),12,5) as CAL_Ora
			--,substring(convert(varchar(18),DataFine, 126 ),12,5) as CAL_OraFine
			
			, '00:00' CAL_Ora
			,case 
				when convert( datetime, convert(varchar(10),dateadd ( day ,7 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
					substring(convert(varchar(18),DataFine, 126 ),12,5) 
				else
					'24:00'
			
			end as  CAL_OraFine


			
			--case
			--		when convert( datetime, convert(varchar(10),dateadd ( day , 7 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
			--			'00:00-' + substring(convert(varchar(18),DataFine, 126 ),12,5) + ' Fermo Sistema' 
			--		else
			--			'00:00-24:00 Fermo Sistema'
				
			--end as  Descrizione
			,'Fermo Sistema' as Descrizione
			
			,'' as CIG
			,aziragionesociale
			, TipoDoc as OPEN_DOC_NAME
			, '' as Oggetto
			FROM
				ctl_doc inner join Document_FermoSistema on id=idheader
					inner join aziende on azienda = idazi
						inner join profiliutente p on pfuvenditore=0
			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'	
				and convert(varchar(10),dateadd ( day , 7 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )

	) V
	where V.idpfu >0 and isnull(id,'')<>''
	group by 	V.idpfu,V.id,V.Descrizione,V.DataRiferimento



GO
