USE [AFLink_TND]
GO
/****** Object:  View [dbo].[AFV_Elenco_Bandi_ME]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[AFV_Elenco_Bandi_ME] as

	SELECT  
			d.id as idBando 
			,d.Protocollo as RegistroBando 
			,d.Body as DescrizioneBando

			, StatoFunzionale as StatoBando
			, coalesce( [ML_Description] , [DMV_DescML] , statofunzionale ) as StatoBandoDescrizione
	
		FROM CTL_Doc d WITH (NOLOCK)
	  
			--inner join Document_Bando db WITH (NOLOCK) on d.id = db.idheader
			left join LIB_DomainValues dd1 with (nolock) on dd1.DMV_DM_ID = 'statoFunzionale' 
															and dd1.DMV_Cod = statofunzionale
			left join lib_multilinguismo m with(nolock) on m.[ML_KEY] = dd1.[DMV_DescML] and m.[ML_LNG] = 'I' and m.[ML_Context] = 0
		 WHERE d.tipodoc in ( 'BANDO' )   
					AND d.deleted = 0
					and d.StatoFunzionale <> 'InLavorazione'
					and isnull ( d.jumpcheck , '' ) = ''

				
GO
