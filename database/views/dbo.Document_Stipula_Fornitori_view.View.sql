USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_Stipula_Fornitori_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[Document_Stipula_Fornitori_view] as
select 
	id, DataCreazione, ID_MSG_PDA, ID_MSG_BANDO, StatoEsclusione, Document_EsitoGara.Oggetto, DataAperturaOfferte, DataIISeduta, Segretario_Contratto, Protocol, Document_EsitoGara.idAggiudicatrice, 
	importoBaseAsta, NRDeterminazione, DataDetermina, Document_EsitoGara.ValutazioneEconomica , 
	idRow, idHeader, 
	case when Document_EsitoGara_Fornitori.ProtocolloGenerale_Contratto IS NULL 
		THEN Document_EsitoGara.ProtocolloGenerale_Contratto 
		ELSE Document_EsitoGara_Fornitori.ProtocolloGenerale_Contratto 
	END as ProtocolloGenerale_Contratto, 
	Document_EsitoGara.DataInvio, Fornitore, Motivazione, Stato, ID_MSG_OFFERTA, 
	case when Document_EsitoGara_Fornitori.DataProt_Contratto IS NULL 
		THEN Document_EsitoGara.DataProt_Contratto 
		ELSE Document_EsitoGara_Fornitori.DataProt_Contratto 
	END as DataProt_Contratto,
	idRow as DETTAGLIGrid_ID_DOC , 'COM_STIPULA_CONTRATTO' as DETTAGLIGrid_OPEN_DOC_NAME ,isATI
	, Rep , DataStipula ,
	Document_EsitoGara_Fornitori.DataInvioStipula,
	Document_EsitoGara_Fornitori.ProtocolloStipula,
	Document_EsitoGara_Fornitori.StatoStipula,
	Document_EsitoGara_Fornitori.idpfu,
	Document_EsitoGara_Fornitori.TitoloStipula,
	'yes' as UpdParent
from Document_EsitoGara inner join Document_EsitoGara_Fornitori  on id = idheader
inner join Document_Repertorio on Protocol = ProtocolloBando
GO
