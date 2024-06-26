USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOCUMENT_AZIENDE_VIEW]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DOCUMENT_AZIENDE_VIEW]
AS
	SELECT   dbo.Document_Aziende.* ,
			 NomePF AS    NomePF2 ,
			 CognomePF AS CognomePF2,
			 case when ISNULL(d4.vatValore_FT ,'')='' then '' else ' PARTICIPANTID ' end as NotEditable
		FROM dbo.Document_Aziende
		left outer join dbo.DM_Attributi d4 on d4.lnk = idazi and d4.idApp = 1 and d4.dztNome = 'IDNOTIER'



GO
