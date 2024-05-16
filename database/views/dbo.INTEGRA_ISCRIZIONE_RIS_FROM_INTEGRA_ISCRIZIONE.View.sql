USE [AFLink_TND]
GO
/****** Object:  View [dbo].[INTEGRA_ISCRIZIONE_RIS_FROM_INTEGRA_ISCRIZIONE]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[INTEGRA_ISCRIZIONE_RIS_FROM_INTEGRA_ISCRIZIONE] as
select 
	d.id as ID_FROM
	,d.ProtocolloRiferimento
	,d.Destinatario_Azi as Azienda
	,d.Azienda as Destinatario_Azi
	,d.Fascicolo
	,d.Id as LinkedDoc
	,i.Protocollo as ProtocolloOfferta
	,d.StrutturaAziendale
	,d.Body
	,d.Note
	,d.IdPfu AS Destinatario_User
	,'InLavorazione' as StatoFunzionale
from CTL_DOC  d
	inner join CTL_DOC i on d.LinkedDoc = i.id



GO
