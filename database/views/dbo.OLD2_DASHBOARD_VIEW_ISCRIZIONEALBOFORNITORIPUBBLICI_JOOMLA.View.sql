USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORIPUBBLICI_JOOMLA]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[OLD2_DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORIPUBBLICI_JOOMLA] as

	SELECT [IdMsg]
		  ,[IdPfu]
		  ,[msgIType]
		  ,[msgISubType]
		  ,[Name]
		  ,[ProtocolloBando]
		  ,[ProtocolloOfferta]
		  ,[ReceivedDataMsg]
		  ,[Oggetto]
		  ,[Tipologia]
		  ,dbo.GETDATEDDMMYYYY ( convert( VARCHAR(50) , ExpiryDate, 121)) AS ScadenzaBando
		  ,[ExpiryDate]
		  ,[ExpiryDate] as DtScadenzaBandoTecnical
		  ,[ImportoBaseAsta]
		  ,[tipoprocedura]
		  ,[StatoGD]
		  ,[Fascicolo]
		  ,[CriterioAggiudicazione]
		  ,[CriterioFormulazioneOfferta]
		  ,[DOCUMENT]
		  ,[IDDOCR]
		  ,[Precisazioni]
		  -- , 0 as bScaduto
		    , CASE WHEN ExpiryDate < CONVERT(VARCHAR(50), GETDATE(), 126) 
                    THEN 1 
                    ELSE 0 
            END AS bScaduto
		  , case 

				when isnull(document,'') <> '' then 'BANDO'
				else '55;11'				
			end   as tipo
		  
		  ,'' as Contratto
		  ,  case 

				when isnull(document,'') <> '' then 'XSLT_BANDO_ISCRIZIONE_ALBO'
				else 'XSLT_55;11'
				
		     end  as xslt
		   
		  , DtPubblicazione
		  , DtPubblicazioneTecnical
		  ,jumpcheck
		  , StatoFunzionale
	  FROM [dbo].[DASHBOARD_VIEW_ISCRIZIONEALBOFORNITORIPUBBLICI]



GO
