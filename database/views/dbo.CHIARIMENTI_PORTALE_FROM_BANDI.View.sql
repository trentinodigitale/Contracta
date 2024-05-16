USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CHIARIMENTI_PORTALE_FROM_BANDI]    Script Date: 5/16/2024 2:45:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[CHIARIMENTI_PORTALE_FROM_BANDI]  AS
	SELECT TM.IdMsg  as ID_From,TM.IdMsg  as ID_Origin,TMF.Object_Cover1 as Oggetto,
		umIdPfu AS IdPfu, msgIType, msgISubType, TMF.* 
	FROM tab_utenti_messaggi, tab_messaggi TM , tab_messaggi_fields TMF  
	WHERE umIdMsg = TM.IdMsg 
		AND TM.IdMsg = TMF.IdMsg 
		AND msgIType = 55 
		AND msgISubType in ( 10,24,34,48,167,78,179 )
		AND uminput = 0 AND umstato = 0



GO
