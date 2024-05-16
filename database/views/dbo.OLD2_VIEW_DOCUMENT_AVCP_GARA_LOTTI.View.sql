USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_VIEW_DOCUMENT_AVCP_GARA_LOTTI]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[OLD2_VIEW_DOCUMENT_AVCP_GARA_LOTTI] as
select 
	C1.tipodoc as OPEN_DOC_NAME,
	Cig,
	Oggetto,
	C1.LinkedDoc,
	Oggetto as Descrizione,	
	C1.id as idheader,
	idrow,
	C1.id,
	C1.StatoFunzionale ,
	case when C1.StatoFunzionale = 'Pubblicato' then '../toolbar/Delete_Light.GIF' else '../toolbar/ripristina.png' end as FNZ_DEL
from CTL_DOC C1
	 inner join document_AVCP_lotti on idheader = C1.Id
WHERE C1.TipoDoc='AVCP_LOTTO' and C1.deleted=0 

GO
