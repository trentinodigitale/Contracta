USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CAMBIO_UTENTE_FROM_BANDO]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  view [dbo].[CAMBIO_UTENTE_FROM_BANDO]  as
--Versione=2&data=2014-02-14&Attvita=52864&Nominativo=enrico
SELECT distinct  
	IdMsg as ID_FROM ,
	ProtocolloBando as ProtocolloRiferimento,
	IdMsg as LinkedDoc,
	Oggetto as Body,
	--umIdPfu as Utente
	IdPfu as Utente	
	,OPEN_DOC_NAME as JumpCheck                  
FROM 
	DASHBOARD_VIEW_BANDOUNICO 	
    --inner join TAB_UTENTI_MESSAGGI on umidmsg=IdMsg

--union 

--select * from DASHBOARD_VIEW_BANDOUNICO




GO
