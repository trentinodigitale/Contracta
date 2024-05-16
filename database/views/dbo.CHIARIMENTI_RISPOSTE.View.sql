USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CHIARIMENTI_RISPOSTE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CHIARIMENTI_RISPOSTE] as
select 
	A.id,B.domanda,B.protocolrispostaquesito ,B.risposta,B.datarisposta,B.allegato ,B.id as RISPOSTEGrid_ID_DOC, 'DETAIL_CHIARIMENTI' as RISPOSTEGrid_OPEN_DOC_NAME
from 
	document_chiarimenti A , document_chiarimenti B
where A.protocol=B.protocol and A.id<>b.id

GO
