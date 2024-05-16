USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_ELENCO_AQ]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DASHBOARD_VIEW_ELENCO_AQ] AS
--Tutti gl AQ che: (  Sono Attivati (  presente il documento  ATTIVA_AQ. Confermato ) ) AND (. che non sono scaduti  	) 
--sono negli enti aderenti 
	select 
		D.Protocollo,
		D.Id,
		'BANDO_GARA_AQ_ENTE' as OPEN_DOC_NAME,	
		DB.ProtocolloBando as ProtocolloBando ,
		D.Id as idmsg,
		D.titolo as Name,
		cast( D.body as nvarchar(4000)) as Oggetto,
		DB.DataRiferimentoFine,
		DB.importoBaseAsta,
		P.IdPfu as Owner
		from CTL_DOC D WiTH(nolock)
			inner join Document_Bando DB with(nolock) on DB.idHeader=D.id			
			inner join CTL_DOC C with(nolock) on C.LinkedDoc=D.id and C.TipoDoc='ATTIVA_AQ' and C.StatoFunzionale='Confermato'
			inner join CTL_DOC_Value CV with(nolock) on CV.IdHeader=DB.idHeader and CV.DSE_ID='ENTI' and CV.DZT_Name='AZI_Ente'
			inner join ProfiliUtente P with(nolock) on P.pfuIdAzi=CV.Value
		where D.TipoDoc='BANDO_GARA' and D.Deleted=0 and 
			 TipoSceltaContraente = 'ACCORDOQUADRO' and TipoProceduraCaratteristica <> 'RDO'
			 --VERICA CHE GLI AQ NON SONO SCADUTI
			 and DATEDIFF(DAY, DB.DataRiferimentoFine, GETDATE()) < 0
			 

UNION

--è senza quote e senza enti aderenti
	select 
		D.Protocollo,
		D.Id,
		'BANDO_GARA_AQ_ENTE' as OPEN_DOC_NAME,	
		DB.ProtocolloBando as ProtocolloBando ,
		D.Id as idmsg,
		D.titolo as Name,
		cast( D.body as nvarchar(4000)) as Oggetto,
		DB.DataRiferimentoFine,
		DB.importoBaseAsta,
		P.IdPfu as Owner
		from CTL_DOC D WiTH(nolock)
			inner join Document_Bando DB with(nolock) on DB.idHeader=D.id			
			inner join CTL_DOC C with(nolock) on C.LinkedDoc=D.id and C.TipoDoc='ATTIVA_AQ' and C.StatoFunzionale='Confermato'
			left join CTL_DOC_Value CV with(nolock) on CV.IdHeader=DB.idHeader and CV.DSE_ID='ENTI' and CV.DZT_Name='AZI_Ente'
			cross join ProfiliUtente P with(nolock)
		where D.TipoDoc='BANDO_GARA' and D.Deleted=0 and 
			 TipoSceltaContraente = 'ACCORDOQUADRO' and TipoProceduraCaratteristica <> 'RDO'
			 --VERICA CHE GLI AQ NON SONO SCADUTI
			 and DATEDIFF(DAY, DB.DataRiferimentoFine, GETDATE()) < 0
			 --è senza quote e senza enti aderenti
			 and DB.GestioneQuote = 'senzaquote' and CV.IdHeader IS NULL			 

UNION
--Quote Richieste	
	select 
		D.Protocollo,
		D.Id,
		'BANDO_GARA_AQ_ENTE' as OPEN_DOC_NAME,	
		DB.ProtocolloBando as ProtocolloBando ,
		D.Id as idmsg,
		D.titolo as Name,
		cast( D.body as nvarchar(4000)) as Oggetto,
		DB.DataRiferimentoFine,
		DB.importoBaseAsta,
		P.IdPfu as Owner
		from CTL_DOC D WiTH(nolock)
			inner join Document_Bando DB with(nolock) on DB.idHeader=D.id			
			inner join CTL_DOC C with(nolock) on C.LinkedDoc=D.id and C.TipoDoc='ATTIVA_AQ' and C.StatoFunzionale='Confermato'			
			cross join ProfiliUtente P with(nolock)
		where D.TipoDoc='BANDO_GARA' and D.Deleted=0 and 
			 TipoSceltaContraente = 'ACCORDOQUADRO' and TipoProceduraCaratteristica <> 'RDO'
			 --VERICA CHE GLI AQ NON SONO SCADUTI
			 and DATEDIFF(DAY, DB.DataRiferimentoFine, GETDATE()) < 0			 
			 --Quote Richieste	
			 and DB.GestioneQuote = 'quoterichieste' 
GO
