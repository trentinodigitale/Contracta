USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_GARE_CAL]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









--Versione=1&data=2015-04-28&Attivita=73949&Nominativo=Enrico
CREATE view [dbo].[OLD_DASHBOARD_VIEW_GARE_CAL] as 

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

			----scadenza GARE  bandi FU e RDP
			--select 
			--	left(TMF.ExpiryDate	,10) as id
			
			--	,case 
			--		when ISDATE(TMF.ExpiryDate)=1 then 
			--			convert(datetime,left(TMF.ExpiryDate	,10)) 
			--		else null
			--	end AS 	DataRiferimento
			
			--	,'Gare' as Descrizione
			--	FROM TAB_MESSAGGI as T with(nolock)
			--		inner join TAB_UTENTI_MESSAGGI TU with(nolock) on T.idmsg=TU.umidmsg
			--			inner join TAB_MESSAGGI_FIELDS as TMF with(nolock) on TMF.idmsg=TU.umidmsg
			--	WHERE 
			--		   msgItype = 55
			--		   and msgisubtype in (167,68)
			--		   AND umInput = 0
			--		   AND umStato = 0
			--		   AND umIdPfu <> -10
			--		   and TMF.stato=2 and ( TMF.advancedstate='0' or TMF.advancedstate='')
			--		    and ISDATE(TMF.ExpiryDate)=1	
		
			-- DataAperturaOfferte GARE bandi FU e RDP
			--union all
			--select 
			--	left(TMF.DataAperturaOfferte	,10) as id
			--	,case 
			--		when ISDATE(TMF.DataAperturaOfferte)=1 then 
			--			convert(datetime,left(TMF.DataAperturaOfferte	,10)) 
			--		else null
			--	end AS 	DataRiferimento
			--	,'Gare' as Descrizione
		
			--	FROM TAB_MESSAGGI as T with(nolock)
			--		inner join TAB_UTENTI_MESSAGGI TU with(nolock) on T.idmsg=TU.umidmsg
			--			 inner join TAB_MESSAGGI_FIELDS as TMF with(nolock) on TMF.idmsg=TU.umidmsg
			--	WHERE 
			--		   msgItype = 55
			--		   and msgisubtype in (167,68)
			--		   AND umInput = 0
			--		   AND umStato = 0
			--		   AND umIdPfu <> -10
			--		   and TMF.stato=2 and ( TMF.advancedstate='0' or TMF.advancedstate='')
			--		   and isnull(TMF.DataAperturaOfferte,'')<>''
				   
		
			----TermineRichiestaQuesiti bandi FU e RDP
			--union all
			--select 
			--	left(TMF.TermineRichiestaQuesiti	,10) as id
			
			--	,case 
			--		when ISDATE(TMF.TermineRichiestaQuesiti)=1 then 
			--			convert(datetime,left(TMF.TermineRichiestaQuesiti	,10)) 
			--		else null
			--	end AS 	DataRiferimento
			
			--	,'Gare' as Descrizione
			
			--	FROM TAB_MESSAGGI as T with(nolock)
			--		inner join TAB_UTENTI_MESSAGGI TU with(nolock) on T.idmsg=TU.umidmsg
			--			 inner join TAB_MESSAGGI_FIELDS as TMF with(nolock) on TMF.idmsg=TU.umidmsg
			--	WHERE 
			--		   msgItype = 55
			--		   and msgisubtype in (167,68)
			--		   AND umInput = 0
			--		   AND umStato = 0
			--		   AND umIdPfu <> -10
			--		   and TMF.stato=2 and  ( TMF.advancedstate='0' or TMF.advancedstate='')
			--		   and isnull(TMF.TermineRichiestaQuesiti,'')<>''
			--		   and ISDATE(TMF.TermineRichiestaQuesiti)=1
				   
			----scadenze bando_gara e bando_semplificato
			--union all
			select 

				convert(varchar(10),DataScadenzaOfferta, 126 )  as id
				, convert( datetime, convert(varchar(10),DataScadenzaOfferta, 126 ))  as DataRiferimento
				,'Termine Presentazione' as Descrizione
				, case when d.tipodoc = 'BANDO_CONSULTAZIONE' then 'Consultazione Preliminare di Mercato' else dbo.GetDescTipoProcedura ( d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara , TipoBandoGara)  end as DescTipoProcedura
				, Azienda as AZI_Ente
				FROM 
					ctl_doc d with(nolock)
					inner join document_bando with(nolock) on id=idheader
				WHERE 
					tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO','BANDO_CONSULTAZIONE')
				   AND d.deleted = 0
				   AND d.statodoc = 'sended'		

			--DataAperturaOfferte bando_gara e bando_semplificato
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
					tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO')
				   AND d.deleted = 0
				   AND d.statodoc = 'sended'		
	
		
			--DataTermineQuesiti bando_gara e bando_semplificato
			union all
			select 

				convert(varchar(10),DataTermineQuesiti, 126 )  as id
				, convert( datetime, convert(varchar(10),DataTermineQuesiti, 126 ))  as DataRiferimento
				,'Termine quesiti' as Descrizione
				, case when d.tipodoc = 'BANDO_CONSULTAZIONE' then 'Consultazione Preliminare di Mercato' else dbo.GetDescTipoProcedura ( d.Tipodoc , TipoProceduraCaratteristica , ProceduraGara , TipoBandoGara) end  as DescTipoProcedura
				, Azienda as AZI_Ente
				FROM 
					ctl_doc d with(nolock)
					inner join document_bando with(nolock) on id=idheader
				WHERE 
					tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO','BANDO_CONSULTAZIONE')
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



		--select * from DASHBOARD_VIEW_GARE_CAL





GO
