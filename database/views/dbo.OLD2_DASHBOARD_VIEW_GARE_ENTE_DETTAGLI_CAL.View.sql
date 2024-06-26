USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_GARE_ENTE_DETTAGLI_CAL]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[OLD2_DASHBOARD_VIEW_GARE_ENTE_DETTAGLI_CAL] as 


		select 
			p1.idpfu,
			T.idmsg as id
			--,convert(datetime,left(TMF.ExpiryDate	,10)) as DataRiferimento
			,case 
				when ISDATE(TMF.ExpiryDate)=1 then 
					convert(datetime,left(TMF.ExpiryDate	,10)) 
				else null
			end AS 	DataRiferimento
			
			,left(TMF.ExpiryDate	,10) as linkeddoc
			,'' as CAL_Ora
			,substring(TMF.ExpiryDate,12,5) as CAL_OraFine
			,'Scadenza Gara' as Descrizione
			,CIG
			,aziragionesociale
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

		union all
	
		-- DataAperturaOfferte GARE bandi FU e RDP
		select 
			p1.idpfu,
			T.idmsg as id
			--,convert(datetime,left(TMF.DataAperturaOfferte	,10)) as DataRiferimento
			
			,case 
				when ISDATE(TMF.DataAperturaOfferte)=1 then 
					convert(datetime,left(TMF.DataAperturaOfferte	,10)) 
				else null
			end AS 	DataRiferimento
			
			,left(TMF.DataAperturaOfferte	,10) as linkeddoc
			,substring(TMF.DataAperturaOfferte,12,5) as CAL_Ora
			,'' as CAL_OraFine
			,'Aperura Offerte' as Descrizione
			,CIG
			,aziragionesociale
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
				   	

		union all
		
		-- TermineRichiestaQuesiti bandi FU e RDP
		select 
			p1.idpfu,
			T.idmsg as id
			--,convert(datetime,left(TMF.TermineRichiestaQuesiti	,10)) as DataRiferimento
			,case 
				when ISDATE(TMF.TermineRichiestaQuesiti)=1 then 
					convert(datetime,left(TMF.TermineRichiestaQuesiti	,10)) 
				else null
			end AS 	DataRiferimento
			
			,left(TMF.TermineRichiestaQuesiti	,10) as linkeddoc
			
			,'' as CAL_Ora
			,substring(TMF.TermineRichiestaQuesiti,12,5) as CAL_OraFine

			,'Scadenza Quesiti' as Descrizione
			,CIG
			,aziragionesociale
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

		union all
		
		--scadenze bando_gara e bando_semplificato
		select 
			p.idpfu,
			id 
			, convert( datetime, convert(varchar(10),DataScadenzaOfferta, 126 ))  as DataRiferimento
			,convert(varchar(10),DataScadenzaOfferta, 126 )  as linkeddoc
			,'' as CAL_Ora
			,substring(convert(varchar(18),DataScadenzaOfferta, 126 ),12,5) as CAL_OraFine

			,'Scadenza Gara' as Descrizione
			,CIG
			,aziragionesociale
		FROM 
			ctl_doc inner join document_bando on id=idheader
				inner join aziende on azienda = idazi
					inner join profiliutente p on pfuidazi=idazi and pfuDeleted=0
			WHERE 
				   tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
				   and StatoFunzionale='Pubblicato'
	
		union all 

		--DataAperturaOfferte bando_gara e bando_semplificato
		select 
			p.idpfu,
			id 
			, convert( datetime, convert(varchar(10),DataAperturaOfferte, 126 ))  as DataRiferimento
			,convert(varchar(10),DataAperturaOfferte, 126 )  as linkeddoc
			
			,substring(convert(varchar(18),DataAperturaOfferte, 126 ),12,5) as CAL_Ora
			,'' as CAL_OraFine

			,'Aperura Offerte' as Descrizione
			,CIG
			,aziragionesociale
		FROM 
			ctl_doc inner join document_bando on id=idheader
				inner join aziende on azienda = idazi
					inner join profiliutente p on pfuidazi=idazi and pfuDeleted=0
			WHERE 
				   tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
				   and StatoFunzionale='Pubblicato'

		

		union all
		
		--DataTermineQuesiti bando_gara e bando_semplificato
		select 
			p.idpfu,
			id 
			, convert( datetime, convert(varchar(10),DataTermineQuesiti, 126 ))  as DataRiferimento
			,convert(varchar(10),DataTermineQuesiti, 126 )  as linkeddoc
			,'' as CAL_Ora
			,substring(convert(varchar(18),DataTermineQuesiti, 126 ),12,5) as CAL_OraFine

			,'Scadenza Gara' as Descrizione
			,CIG
			,aziragionesociale
		FROM 
			ctl_doc inner join document_bando on id=idheader
				inner join aziende on azienda = idazi
					inner join profiliutente p on pfuidazi=idazi and pfuDeleted=0
			WHERE 
				   tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
				   and StatoFunzionale='Pubblicato'

		

		--fermo sistema
		union all
		
		select 
			p.idpfu,
			id
			, convert( datetime, convert(varchar(10),DataInizio, 126 ))  as DataRiferimento
			,convert(varchar(10),DataInizio, 126 )  as linkeddoc
			,substring(convert(varchar(18),DataInizio, 126 ),12,5) as CAL_Ora
			, case 
				when convert( datetime, convert(varchar(10),DataInizio, 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
					substring(convert(varchar(18),DataFine, 126 ),12,5) 
				else
					'24:00'
			
				end as  CAL_OraFine

			,'Fermo Sistema' as Descrizione
			,'' as CIG
			,aziragionesociale
			FROM
				ctl_doc inner join Document_FermoSistema on id=idheader
					inner join aziende on azienda = idazi
						inner join profiliutente p on pfuvenditore=0
			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		
		
		union all 
		
		select 
			p.idpfu,
			id
			, convert( datetime, convert(varchar(10),dateadd ( day , 1 , DataInizio ), 126 ))  as DataRiferimento
			,convert(varchar(10),dateadd ( day , 1 , DataInizio ), 126 )  as linkeddoc
			, '00:00' CAL_Ora
			,case 
				when convert( datetime, convert(varchar(10),dateadd ( day , 1 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
					substring(convert(varchar(18),DataFine, 126 ),12,5) 
				else
					'24:00'
			
				end as  CAL_OraFine
			,'Fermo Sistema' as Descrizione
			,'' as CIG
			,aziragionesociale
			FROM
				ctl_doc inner join Document_FermoSistema on id=idheader
					inner join aziende on azienda = idazi
						inner join profiliutente p on pfuvenditore=0
			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		
			and convert(varchar(10),dateadd ( day , 1 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )
	
		union all 
		select 
			p.IdPfu,
			id
			, convert( datetime, convert(varchar(10),dateadd ( day , 2 , DataInizio ), 126 ))  as DataRiferimento
			,convert(varchar(10),dateadd ( day , 2 , DataInizio ), 126 )  as linkeddoc
			, '00:00' CAL_Ora
			,case 
				when convert( datetime, convert(varchar(10),dateadd ( day , 2 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
					substring(convert(varchar(18),DataFine, 126 ),12,5) 
				else
					'24:00'
			
				end as  CAL_OraFine
			,'Fermo Sistema' as Descrizione
			,'' as CIG
			,aziragionesociale
			FROM
				ctl_doc inner join Document_FermoSistema on id=idheader
					inner join aziende on azienda = idazi
						inner join profiliutente p on pfuvenditore=0
			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		
			and convert(varchar(10),dateadd ( day , 2 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )
		
		union all 
		select 
			p.idpfu,
			id
			, convert( datetime, convert(varchar(10),dateadd ( day , 3 , DataInizio ), 126 ))  as DataRiferimento
			,convert(varchar(10),dateadd ( day , 3 , DataInizio ), 126 )  as linkeddoc
			, '00:00' CAL_Ora
			,case 
				when convert( datetime, convert(varchar(10),dateadd ( day , 3 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
					substring(convert(varchar(18),DataFine, 126 ),12,5) 
				else
					'24:00'
			
				end as  CAL_OraFine
			,'Fermo Sistema' as Descrizione
			,'' as CIG
			,aziragionesociale
			FROM
				ctl_doc inner join Document_FermoSistema on id=idheader
					inner join aziende on azienda = idazi
						inner join profiliutente p on pfuvenditore=0
			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		
			and convert(varchar(10),dateadd ( day , 3 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )
		
		union all 
		select 
			p.idpfu,
			id
			, convert( datetime, convert(varchar(10),dateadd ( day , 4 , DataInizio ), 126 ))  as DataRiferimento
			,convert(varchar(10),dateadd ( day ,4 , DataInizio ), 126 )  as linkeddoc
			, '00:00' CAL_Ora
			,case 
				when convert( datetime, convert(varchar(10),dateadd ( day , 4 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
					substring(convert(varchar(18),DataFine, 126 ),12,5) 
				else
					'24:00'
			
				end as  CAL_OraFine
			,'Fermo Sistema' as Descrizione
			,'' as CIG
			,aziragionesociale
			FROM
				ctl_doc inner join Document_FermoSistema on id=idheader
					inner join aziende on azienda = idazi
						inner join profiliutente p on pfuvenditore=0
			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		
			and convert(varchar(10),dateadd ( day , 4, DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )

		union all 
		select 
			p.idpfu,
			id
			, convert( datetime, convert(varchar(10),dateadd ( day , 5 , DataInizio ), 126 ))  as DataRiferimento
			,convert(varchar(10),dateadd ( day , 5 , DataInizio ), 126 )  as linkeddoc
			, '00:00' CAL_Ora
			,case 
				when convert( datetime, convert(varchar(10),dateadd ( day , 5 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
					substring(convert(varchar(18),DataFine, 126 ),12,5) 
				else
					'24:00'
			
				end as  CAL_OraFine
			,'Fermo Sistema' as Descrizione
			,'' as CIG
			,aziragionesociale
			FROM
				ctl_doc inner join Document_FermoSistema on id=idheader
					inner join aziende on azienda = idazi
						inner join profiliutente p on pfuvenditore=0
			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		
			and convert(varchar(10),dateadd ( day , 5 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )
		
		union all		
		select 
			p.idpfu,
			id
			, convert( datetime, convert(varchar(10),dateadd ( day , 6 , DataInizio ), 126 ))  as DataRiferimento
			,convert(varchar(10),dateadd ( day , 6 , DataInizio ), 126 )  as linkeddoc
			, '00:00' CAL_Ora
			,case 
				when convert( datetime, convert(varchar(10),dateadd ( day , 6 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
					substring(convert(varchar(18),DataFine, 126 ),12,5) 
				else
					'24:00'
			
				end as  CAL_OraFine
			,'Fermo Sistema' as Descrizione
			,'' as CIG
			,aziragionesociale
			FROM
				ctl_doc inner join Document_FermoSistema on id=idheader
					inner join aziende on azienda = idazi
						inner join profiliutente p on pfuvenditore=0
			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		
			and convert(varchar(10),dateadd ( day , 6 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )
		
		union all
		select 
			p.idpfu,
			id
			, convert( datetime, convert(varchar(10),dateadd ( day , 7 , DataInizio ), 126 ))  as DataRiferimento
			,convert(varchar(10),dateadd ( day , 7 , DataInizio ), 126 )  as linkeddoc
			, '00:00' CAL_Ora
			,case 
				when convert( datetime, convert(varchar(10),dateadd ( day , 7 , DataInizio ), 126 ))=convert( datetime, convert(varchar(10),DataFine, 126 )) then 
					substring(convert(varchar(18),DataFine, 126 ),12,5) 
				else
					'24:00'
			
				end as  CAL_OraFine
			,'Fermo Sistema' as Descrizione
			,'' as CIG
			,aziragionesociale
			FROM
				ctl_doc inner join Document_FermoSistema on id=idheader
					inner join aziende on azienda = idazi
						inner join profiliutente p on pfuvenditore=0
			WHERE
				
				tipodoc='FERMOSISTEMA' and statofunzionale='CONFERMATO'		
			and convert(varchar(10),dateadd ( day , 7 , DataInizio ), 126 ) <= convert(varchar(10),DataFine, 126 )




GO
