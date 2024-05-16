USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_TED_AGGIUDICATARI_LOTTO_XML]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VIEW_TED_AGGIUDICATARI_LOTTO_XML] AS
	SELECT ag.idHeader, --idrow della Document_TED_Aggiudicazione

			--Aggiudicatari ( 0..N )
			isnull(ag.[TED_AWARDED_IS_SME],'') as TED_AWARDED_IS_SME, --Obbligatorio, FlagSNType ( Il contraente è una PMI? )
			isnull(ag.[TED_NATIONALID],'') as TED_NATIONALID, --Obbligatorio
			isnull(ag.[TED_NUTS],'') as TED_NUTS, --Obbligatorio
			isnull(ag.[TED_E_MAIL], '') as TED_E_MAIL, --Facoltativo
			dbo.TED_CONVERT_PHONE_NUMBER(ag.[TED_PHONE],0) as TED_PHONE, --Facoltativo
			isnull(ag.[TED_URL],'') as TED_URL, --Facoltativo
			dbo.TED_CONVERT_PHONE_NUMBER(ag.[TED_FAX],0) as TED_FAX --Facoltativo

		FROM Document_TED_Aggiudicatari ag WITH(NOLOCK) --ON ag.idHeader = a.idRow
GO
