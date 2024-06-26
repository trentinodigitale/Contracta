USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_SEMPLIFICATO_TESTATA_BANDO_SDA_ADERENTE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_BANDO_SEMPLIFICATO_TESTATA_BANDO_SDA_ADERENTE] as
select 
	b.IdRow as ID_FROM 
	, d.Id as LinkedDoc
	, b.Value as Azienda
	, d.Protocollo as ProtocolloRiferimento
	, d.Body as DescrizioneRichiesta
	, '' as Fascicolo
	, s.TipoBando
	, s.TipoBandoGara
	, s.ProceduraGara
	, s.TipoAppaltoGara

	, p.NumGiorniPresentazioneDomande as GG_OffIndicativa

from CTL_DOC  d 
		inner join dbo.Document_Bando s on id = idheader
		inner join CTL_DOC_Value b on b.IdHeader = d.id and DSE_ID = 'ENTI' and DZT_Name = 'AZI_Ente' 

		left outer join Document_Parametri_SDA p
					on p.deleted = 0
					and isnull( p.DataInizio , getdate())<= getdate ()
					and  isnull( p.DataFine  , getdate()) >= getdate()

where d.deleted = 0 and TipoDoc in ( 'BANDO_SDA' )
GO
