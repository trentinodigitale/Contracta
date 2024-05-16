USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CHIARIMENTI_ELENCO_BANDO_NEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CHIARIMENTI_ELENCO_BANDO_NEW]  AS
	SELECT  a.* , 'DETAIL_CHIARIMENTI_BANDO' as ELENCOGrid_OPEN_DOC_NAME, a.id as ELENCOGrid_ID_DOC ,
	 case isnull(a.chiarimentoevaso,0)
		WHEN 0 THEN ''
	
		else ' ChiarimentoEvaso '
	  END AS Not_Editable
	  --, isnull(band.TipoProceduraCaratteristica,'') as TipoGara
	from document_chiarimenti a
			left join CTL_DOC c WITH(NOLOCK)  ON a.id_origin=c.id
			--left outer join CTL_DOC c ON a.id_origin=c.id and ISNULL(a.Document,'') <> '' -- Documento nuovo
			--LEFT OUTER JOIN Document_bando band ON c.id = band.idheader
	where a.protocol <> '' and a.protocol is not null and ISNULL(a.Document,'')<>''
	AND C.TipoDoc <> 'BANDO_CONCORSO'
GO
