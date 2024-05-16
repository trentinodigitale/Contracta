USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CONFERMA_ISCRIZIONE_FROM_ISTANZA_AlboOperaEco]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------
--vista per creare la conferma partendo dall'istanza
---------------------------------------------------------------

CREATE  view [dbo].[CONFERMA_ISCRIZIONE_FROM_ISTANZA_AlboOperaEco] as
select 
	id as ID_FROM
	,ProtocolloRiferimento
	,pfuIdAzi as Azienda
	,Azienda as Destinatario_Azi
	,Azienda as LegalPub
	,Fascicolo
	,Id as LinkedDoc
	,Protocollo as ProtocolloOfferta
	,StrutturaAziendale
	,Value as ClasseIscriz
	,CTL_DOC.IdPfu AS Destinatario_User
from CTL_DOC
	inner join profiliutente p on Destinatario_User = p.idpfu
	inner join CTL_DOC_Value v on id = idheader and DZT_Name = 'ClasseIscriz'



GO
