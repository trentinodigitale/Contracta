USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_GARE_ESTRAZIONE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[DASHBOARD_VIEW_GARE_ESTRAZIONE] as 

select 

	*
	, dbo.Get_Ruoli_Utenti_Gara(id,idpfu) as RuoloUtente

	from 

	(
		select 
	
			G.* 
			,pfunome
			,pfuE_Mail
			, idpfu 
			from 
		
				DASHBOARD_VIEW_GARE_ENTE_DETTAGLI_CAL_CONF_SISTEMA G
					inner join ctl_doc_value DG with (nolock) on DG.idheader = id  and dg.dse_id='InfoTec_comune' and dzt_name='UserRUP'
					inner join profiliutente P1 with (nolock) on DG.value=idpfu
			
		union 
			select 
	
				G.* 
				,pfunome
				,pfuE_Mail
				, p.idpfu 
				from 
		
					DASHBOARD_VIEW_GARE_ENTE_DETTAGLI_CAL_CONF_SISTEMA G
						inner join document_bando_riferimenti R with (nolock) on R.idheader = id
						inner join profiliutente P with (nolock) on P.idPfu = R.idpfu
		) V 
	
		
GO
