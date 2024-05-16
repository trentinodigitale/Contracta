USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CHIARIMENTI_ELENCO_BANDO_NEW_FORN]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[CHIARIMENTI_ELENCO_BANDO_NEW_FORN]  AS
SELECT  * , 'DETAIL_CHIARIMENTI_BANDO' as ELENCOGrid_OPEN_DOC_NAME, id as ELENCOGrid_ID_DOC ,
 case isnull(chiarimentoevaso,0)
	WHEN 0 THEN ''
	
	else ' ChiarimentoEvaso '
  END AS Not_Editable,
  id_origin as ID_FROM
from 
document_chiarimenti
where protocol <> '' and protocol is not null and ISNULL(Document,'')='BANDO_QF'








GO
