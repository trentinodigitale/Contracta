USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CHIARIMENTI_ELENCO_BANDO_NEW_FORN_BANDO_FORN_QF]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CHIARIMENTI_ELENCO_BANDO_NEW_FORN_BANDO_FORN_QF]  AS

SELECT  a.* , 'DETAIL_CHIARIMENTI_BANDO' as ELENCOGrid_OPEN_DOC_NAME, a.id as ELENCOGrid_ID_DOC ,
 case isnull(a.chiarimentoevaso,0)
	WHEN 0 THEN ''
	
	else ' ChiarimentoEvaso '
  END AS Not_Editable,
  a.id_origin as ID_FROM,
  a.utentedomanda as idpfu
from document_chiarimenti a
   
where 
    a.protocol <> '' and a.protocol is not null and ISNULL(a.Document,'')='BANDO_QF'    
    and a.ChiarimentoPubblico=0
    
union all

SELECT  a.* , 'DETAIL_CHIARIMENTI_BANDO' as ELENCOGrid_OPEN_DOC_NAME, a.id as ELENCOGrid_ID_DOC ,
 case isnull(a.chiarimentoevaso,0)
	WHEN 0 THEN ''
	
	else ' ChiarimentoEvaso '
  END AS Not_Editable,
  a.id_origin as ID_FROM,
  idpfu
from document_chiarimenti a,profiliutente
   
where 
    a.protocol <> '' and a.protocol is not null and ISNULL(a.Document,'')='BANDO_QF'    
    and a.ChiarimentoPubblico=1 and pfuidazi<>35152001
    
    
    
    --and a.id_origin = 102 and a.utentedomanda=36199
    
    
    



GO
