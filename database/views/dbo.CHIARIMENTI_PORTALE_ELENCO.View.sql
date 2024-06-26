USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CHIARIMENTI_PORTALE_ELENCO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[CHIARIMENTI_PORTALE_ELENCO]  AS
SELECT  a.id,b.id_origin,b.DataCreazione,b.Domanda,b.Risposta,b.Allegato
from      Document_Chiarimenti a ,Document_Chiarimenti b
where a.id_origin=b.id_origin
and b.risposta is not null and rtrim(b.risposta)<>''
and b.chiarimentopubblico=1

GO
