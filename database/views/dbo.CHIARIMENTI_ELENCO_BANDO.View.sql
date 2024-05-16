USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CHIARIMENTI_ELENCO_BANDO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CHIARIMENTI_ELENCO_BANDO]  AS
SELECT  * , 'DETAIL_CHIARIMENTI' as ELENCOGrid_OPEN_DOC_NAME, id as ELENCOGrid_ID_DOC ,'no' as ELENCOGrid_UpdParent,
 case isnull(chiarimentoevaso,0)
	WHEN 0 THEN ''
	
	else ' ChiarimentoEvaso '
  END AS Not_Editable
from 
document_chiarimenti
where protocol <> '' and protocol is not null


GO
