USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_OFFERTA_TESTATA_FROM_TEMPLATE_GARA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_OFFERTA_TESTATA_FROM_TEMPLATE_GARA]
AS
SELECT d.id AS ID_FROM
  , d.id AS LinkedDoc
  , d.id
  , d.Titolo
  , d.Body
  , p.pfuidazi AS Azienda
  , d.StrutturaAziendale
  , b.DataScadenzaOfferta AS DataScadenza
  , d.Protocollo AS ProtocolloRiferimento
  , d.Fascicolo
  , d.Azienda AS Destinatario_Azi
  , d.idpfu AS Destinatario_User
  , p.idpfu
  , d.RichiestaFirma
  , b.CIG
  , 'OFFERTA' AS TipoDoc
  , b.ProtocolloBando
  , TipoBando
  , CriterioAggiudicazioneGara
  , Conformita
  , TipoBandoGara
  , ProceduraGara
  , 'TEMPLATE_GARA' AS JumpCheck
  , ClausolaFideiussoria
  , dbo.ISPBMInstalled() AS ISPBMInstalled
  , b.Divisione_lotti
FROM CTL_DOC d
     INNER JOIN Document_Bando b ON d.id = b.idHeader
     CROSS JOIN profiliutente p
WHERE Deleted = 0
GO
