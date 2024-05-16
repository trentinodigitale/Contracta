USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CHIARIMENTI_PORTALE_ELENCO_FROM_BANDI]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[CHIARIMENTI_PORTALE_ELENCO_FROM_BANDI]  AS
SELECT b.ID_FROM ,a.*
from      Document_Chiarimenti a,CHIARIMENTI_PORTALE_FROM_BANDI b
where risposta is not null and rtrim(risposta)<>''
and a.id_origin=b.ID_FROM and chiarimentopubblico=1



GO
