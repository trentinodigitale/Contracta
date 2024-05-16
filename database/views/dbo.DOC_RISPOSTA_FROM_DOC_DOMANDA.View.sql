USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOC_RISPOSTA_FROM_DOC_DOMANDA]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[DOC_RISPOSTA_FROM_DOC_DOMANDA] as
select 
	id as ID_FROM
	,ProtocolloRiferimento
	,Destinatario_Azi as Azienda
	,Azienda as Destinatario_Azi
	,Fascicolo
	,Id as LinkedDoc
--	,Protocollo as ProtocolloOfferta
	,StrutturaAziendale
from CTL_DOC
GO
