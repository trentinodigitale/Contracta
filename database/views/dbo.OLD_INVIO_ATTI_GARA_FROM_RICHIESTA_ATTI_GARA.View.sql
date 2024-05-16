USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_INVIO_ATTI_GARA_FROM_RICHIESTA_ATTI_GARA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OLD_INVIO_ATTI_GARA_FROM_RICHIESTA_ATTI_GARA]
AS
SELECT     l.Id AS ID_FROM, l.IdPfu, l.IdDoc, 'Riscontro richiesta di accesso agli atti' AS Titolo, 'Bando n. ' + isnull(l.ProtocolloRiferimento,'') +  '. ' + cast(isnull(l.Body,'') as nvarchar(4000)) as Body, l.Azienda, l.StrutturaAziendale, l.DataScadenza, 
                      l.ProtocolloRiferimento, l.ProtocolloGenerale, l.Fascicolo, l.Note, l.DataProtocolloGenerale, l.Id AS LinkedDoc, z.Nome, z.ComuneNascitaPF, 
                      z.DataNascitaPF, z.PAIndirizzoOp, z.Indirizzo, z.NomeRapLeg, z.SedeEdile, z.IndirizzoEdile, z.PartitaIva, z.codicefiscale, z.ControlliEffettuati, 
                      z.Offerta, z.DomandaPar, z.Altro, z.Tipo_Appalto, z.Motivo, z.aziRagioneSociale, z.Allegato, g.Descrizione
FROM         dbo.CTL_DOC l LEFT OUTER JOIN
                      dbo.Document_Richiesta_Atti z ON l.Id = z.idHeader 
						left outer JOIN	dbo.CTL_DOC_ALLEGATI g ON l.Id = g.idHeader



GO
