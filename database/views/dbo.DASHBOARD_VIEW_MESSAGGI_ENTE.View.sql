USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DASHBOARD_VIEW_MESSAGGI_ENTE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DASHBOARD_VIEW_MESSAGGI_ENTE]
AS
SELECT 
		idmittente,
		aziragionesociale,
		azipartitaiva,
		idazi,
		DM_1.vatValore_FT as codicefiscale,
		idmsg as Id,
		rtrim(ltrim(Stato)) as StatoGD,
		Ragsoc,Name,ProtocolloOfferta,
		case isnull(ValoreOfferta,'')
			when '' then null
			else cast(ValoreOfferta as float) 
		end as ValoreOfferta
		,ReceivedDataMsg
		,ProtocolBG
		,isubtype
		,itype	
		,umstato
	FROM
		tab_utenti_messaggi ,
		TAB_MESSAGGI_FIELDS ,
		profiliutente ,
		Aziende
		left outer join DM_Attributi AS DM_1 ON Aziende.IdAzi = DM_1.lnk AND DM_1.idApp = 1 AND DM_1.dztNome = 'CodiceFiscale'
	WHERE  
		umIdMsg = IdMsg 
		and idmittente=idpfu
		and pfuidazi=idazi
GO
