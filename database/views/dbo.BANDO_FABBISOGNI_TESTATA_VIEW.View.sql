USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_FABBISOGNI_TESTATA_VIEW]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[BANDO_FABBISOGNI_TESTATA_VIEW] as 

select 
	b.* 
	, d.Azienda 
	, d.richiestafirma
	, d.Body
	
	
from CTL_DOC d
	left join Document_Bando b on d.id = b.idheader
--where d.tipodoc='BANDO_FABBISOGNI' and deleted=0

GO
