USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_OFFERTA_TESTATA_FROM_BANDO_SEMPLIFICATO]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  view [dbo].[OLD2_OFFERTA_TESTATA_FROM_BANDO_SEMPLIFICATO] as
select 
	d.id as ID_FROM
	,d.id as LinkedDoc
	,d.id
	,d.Titolo
	,d.Body
	,p.pfuidazi as Azienda
	,d.StrutturaAziendale
	,b.DataScadenzaOfferta as DataScadenza
	,d.Protocollo as ProtocolloRiferimento
	,d.Fascicolo
	,d.Azienda as Destinatario_Azi
	,d.idpfu as Destinatario_User
	,p.idpfu
	,d.RichiestaFirma
	,b.CIG
	,'OFFERTA' as TipoDoc 
	,b.ProtocolloBando
	,TipoBando
	, CriterioAggiudicazioneGara
	, Conformita
	,ClausolaFideiussoria
	, dbo.ISPBMInstalled() as ISPBMInstalled
from CTL_DOC d 
	inner join Document_Bando  b on d.id = b.idHeader
	cross join profiliutente p 
where Deleted = 0





GO
