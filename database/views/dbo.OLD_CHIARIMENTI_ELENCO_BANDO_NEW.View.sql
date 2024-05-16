USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_CHIARIMENTI_ELENCO_BANDO_NEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_CHIARIMENTI_ELENCO_BANDO_NEW]  AS
SELECT  * , 'DETAIL_CHIARIMENTI_BANDO' as ELENCOGrid_OPEN_DOC_NAME, id as ELENCOGrid_ID_DOC ,
 case isnull(chiarimentoevaso,0)
	WHEN 0 THEN ''
	
	else ' ChiarimentoEvaso '
  END AS Not_Editable
from 
document_chiarimenti
where protocol <> '' and protocol is not null and ISNULL(Document,'')<>''


GO
