USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_BANDO_RICHIESTA_CODIFICA_RAPIDA_DOCUMENT]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[VIEW_BANDO_RICHIESTA_CODIFICA_RAPIDA_DOCUMENT] as
select
	d.Id, 
	d.IdPfu, 
	d.IdDoc, 
	d.TipoDoc, 
	d.StatoDoc, 
	d.Data, 
	d.Protocollo, 
	d.PrevDoc, 
	d.Deleted, 
	d.Titolo, 
	d.Body, 
	d.Azienda, 
	d.StrutturaAziendale, 
	d.DataInvio, 
	d.DataScadenza, 
	d.ProtocolloRiferimento, 
	d.ProtocolloGenerale, 
	d.Fascicolo, 
	d.Note, 
	d.DataProtocolloGenerale, 
	d.LinkedDoc, 
	d.JumpCheck, 
	d.StatoFunzionale, 
	d.Destinatario_User, 
	d.Destinatario_Azi, 
	d.RichiestaFirma, 
	d.NumeroDocumento, 
	d.DataDocumento, 
	d.Versione, 
	d.[GUID], 
	d.idPfuInCharge, 
	d.CanaleNotifica, 
	d.URL_CLIENT, 
	d.Caption, 
	d.FascicoloGenerale,
	Divisione_lotti,
	ISNULL(Complex,0) as Complex,
	dbo.getCampi_Chiave_Codifica() as colonnatecnica ,
	GARE_IN_MODIFICA_O_RETTIFICA,
	G.StatoFunzionale as StatoFunzionaleGara

from ctl_doc d with(nolock)
	inner join Document_Bando b with(nolock) on b.idHeader=d.LinkedDoc 
	cross join ( select dbo.GetBandiInRettificaOModifica( ) as GARE_IN_MODIFICA_O_RETTIFICA ) as girm
	inner join ctl_doc G with(nolock)  on G.id = d.LinkedDoc 
where
	d.Tipodoc = 'BANDO_RICHIESTA_CODIFICA_RAPIDA'
	
GO
