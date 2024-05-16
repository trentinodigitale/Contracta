USE [AFLink_TND]
GO
/****** Object:  View [dbo].[RICHIESTA_ATTI_GARA_TESTATA_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[RICHIESTA_ATTI_GARA_TESTATA_VIEW]
AS
SELECT     dbo.CTL_DOC.Id, dbo.CTL_DOC.IdPfu, dbo.CTL_DOC.IdDoc, dbo.CTL_DOC.TipoDoc, dbo.CTL_DOC.StatoDoc, 
                      dbo.CTL_DOC.StatoDoc AS StatoRichiestaAtti, dbo.CTL_DOC.Data, dbo.CTL_DOC.Protocollo, dbo.CTL_DOC.PrevDoc, dbo.CTL_DOC.Deleted, 
                      dbo.CTL_DOC.Titolo, dbo.CTL_DOC.Body, dbo.CTL_DOC.Azienda, dbo.CTL_DOC.StrutturaAziendale, dbo.CTL_DOC.DataInvio, 
                      dbo.CTL_DOC.DataScadenza, dbo.CTL_DOC.ProtocolloRiferimento, dbo.CTL_DOC.ProtocolloGenerale, dbo.CTL_DOC.Fascicolo, dbo.CTL_DOC.Note, 
                      dbo.CTL_DOC.DataProtocolloGenerale, dbo.CTL_DOC.LinkedDoc, dbo.CTL_DOC.SIGN_HASH, dbo.CTL_DOC.SIGN_ATTACH, 
                      dbo.CTL_DOC.SIGN_LOCK, dbo.Document_Richiesta_Atti.idRow, dbo.Document_Richiesta_Atti.idHeader, dbo.Document_Richiesta_Atti.Nome, 
                      dbo.Document_Richiesta_Atti.ComuneNascitaPF, dbo.Document_Richiesta_Atti.DataNascitaPF, dbo.Document_Richiesta_Atti.PAIndirizzoOp, 
                      dbo.Document_Richiesta_Atti.Indirizzo, dbo.Document_Richiesta_Atti.NomeRapLeg, dbo.Document_Richiesta_Atti.SedeEdile, 
                      dbo.Document_Richiesta_Atti.IndirizzoEdile, dbo.Document_Richiesta_Atti.PartitaIva, dbo.Document_Richiesta_Atti.codicefiscale, 
                      dbo.Document_Richiesta_Atti.ControlliEffettuati, dbo.Document_Richiesta_Atti.Offerta, dbo.Document_Richiesta_Atti.DomandaPar, 
                      dbo.Document_Richiesta_Atti.Altro, dbo.Document_Richiesta_Atti.Tipo_Appalto, dbo.Document_Richiesta_Atti.Motivo, 
                      dbo.Document_Richiesta_Atti.Allegato, dbo.Document_Richiesta_Atti.aziRagioneSociale, Document_Richiesta_Atti.CIG , Document_Richiesta_Atti.RuoloRapLeg
FROM dbo.CTL_DOC 
	LEFT OUTER JOIN dbo.Document_Richiesta_Atti ON dbo.CTL_DOC.Id = dbo.Document_Richiesta_Atti.idHeader





GO
