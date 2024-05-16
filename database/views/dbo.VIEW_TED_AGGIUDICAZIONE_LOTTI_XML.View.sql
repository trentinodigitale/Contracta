USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_TED_AGGIUDICAZIONE_LOTTI_XML]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[VIEW_TED_AGGIUDICAZIONE_LOTTI_XML] AS
	SELECT a.idHeader,
			a.idrow, --da utilizzare come input per la vista [VIEW_TED_AGGIUDICATARI_LOTTO_XML]

			isnull(a.[TED_CIG_AGG],'') as TED_CIG_AGG, --Obbligatorio
			isnull(a.[TED_AWARDED_CONTRACT],'') as [TED_AWARDED_CONTRACT], --Obbligatorio
			isnull(a.[TED_PROCUREMENT_UNSUCCESSFUL],'') as [TED_PROCUREMENT_UNSUCCESSFUL], --Obbligatorio se E1=N
			CAST( isnull(a.[TED_NB_TENDERS_RECEIVED_SME],'') AS VARCHAR) as TED_NB_TENDERS_RECEIVED_SME, --Facoltativo
			CAST( isnull(a.[TED_NB_TENDERS_RECEIVED_OTHER_EU],'') AS VARCHAR) as TED_NB_TENDERS_RECEIVED_OTHER_EU, --Facoltativo
			CAST( isnull(a.[TED_NB_TENDERS_RECEIVED_NON_EU],'') AS VARCHAR) as TED_NB_TENDERS_RECEIVED_NON_EU, --Facoltativo
			CAST( isnull(a.[TED_NB_TENDERS_RECEIVED_EMEANS],'') AS VARCHAR) as TED_NB_TENDERS_RECEIVED_EMEANS, --Facoltativo
			isnull(a.[TED_LIKELY_SUBCONTRACTED],'') as TED_LIKELY_SUBCONTRACTED, --Facoltativo
			STR(a.[TED_VAL_SUBCONTRACTING], 15,3) as TED_VAL_SUBCONTRACTING, --Obbligatorio se E14=S
			
			case 
				when a.[TED_PCT_SUBCONTRACTING] is null then ''
				else CAST( isnull(a.[TED_PCT_SUBCONTRACTING],'') AS VARCHAR) 
			end as TED_PCT_SUBCONTRACTING, --Facoltativo. Richiesto solo se E14=S

			isnull(a.[TED_INFO_ADD_SUBCONTRACTING],'') as [TED_INFO_ADD_SUBCONTRACTING], --Facoltativo. Richiesto solo se E14=S
			
			case 
				when a.[TED_DATE_CONCLUSION_CONTRACT] is null then ''
				else CONVERT(VARCHAR, a.[TED_DATE_CONCLUSION_CONTRACT],126) 
			end as TED_DATE_CONCLUSION_CONTRACT --Obbligatorio se E1=S. Deve essere uguale o antecedente alla data corrente


		FROM Document_TED_Aggiudicazione a WITH(NOLOCK)



GO
