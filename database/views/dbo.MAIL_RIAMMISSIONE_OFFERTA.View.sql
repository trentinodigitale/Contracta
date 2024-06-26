USE [AFLink_TND]
GO
/****** Object:  View [dbo].[MAIL_RIAMMISSIONE_OFFERTA]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  view [dbo].[MAIL_RIAMMISSIONE_OFFERTA] as
select
	
	  d.id as iddoc
	, lngSuffisso as LNG
	, b.CIG
	, bando.protocollo as ProtocolloRiferimento
	, a.aziRagionesociale as RagioneSociale
	, d.TipoDoc as TipoDocumento

from ctl_doc d with(NOLOCK)
	cross join Lingue with(NOLOCK)
	inner join CTL_DOC_Value CV1 with(NOLOCK) on CV1.idHeader=d.id and CV1.DSE_ID='FORNITORE' and CV1.DZT_Name='AZI_Dest' and CV1.Row=0 
	inner join aziende a on a.idazi = CV1.Value
	inner join document_bando B on B.idheader=d.linkeddoc
	inner join ctl_doc bando with(NOLOCK) on bando.id=d.LinkedDoc
	where d.TipoDoc='RIAMMISSIONE_OFFERTA'	
	
GO
