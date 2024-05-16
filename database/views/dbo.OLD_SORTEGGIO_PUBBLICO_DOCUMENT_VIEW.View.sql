USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_SORTEGGIO_PUBBLICO_DOCUMENT_VIEW]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OLD_SORTEGGIO_PUBBLICO_DOCUMENT_VIEW] AS 
	select  a.Id, a.IdPfu, a.TipoDoc, a.StatoDoc, a.Data, a.Protocollo, a.PrevDoc, a.Deleted, a.Azienda, a.DataInvio, a.Fascicolo, 
			a.LinkedDoc, a.JumpCheck, a.StatoFunzionale, a.DataDocumento, a.idPfuInCharge, a.Caption,
			b.Titolo, b.Body, b.Protocollo as ProtocolloRiferimento
	from CTL_DOC a
			inner join CTL_DOC b ON b.Id = a.LinkedDoc
GO
