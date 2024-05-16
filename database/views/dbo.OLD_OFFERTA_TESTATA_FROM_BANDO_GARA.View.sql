USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_OFFERTA_TESTATA_FROM_BANDO_GARA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  view [dbo].[OLD_OFFERTA_TESTATA_FROM_BANDO_GARA] as
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
	, TipoBandoGara
	, ProceduraGara
	,'BANDO_GARA' as JumpCheck
	,ClausolaFideiussoria
	, dbo.ISPBMInstalled() as ISPBMInstalled
	,b.Divisione_lotti
from CTL_DOC d 
	inner join Document_Bando  b on d.id = b.idHeader
	cross join profiliutente p 
where Deleted = 0






GO
