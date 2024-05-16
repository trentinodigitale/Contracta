USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_EsitoGara_Fornitori_view]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[Document_EsitoGara_Fornitori_view] as
select   E.id, E.DataCreazione, E.ID_MSG_PDA, E.ID_MSG_BANDO, E.StatoEsclusione, E.Oggetto, 
	E.DataAperturaOfferte, E.DataIISeduta, E.Segretario, E.Protocol, E.idAggiudicatrice, 
    E.importoBaseAsta, E.NRDeterminazione, E.DataDetermina, E.ValutazioneEconomica  , 
    EF.idRow, EF.idHeader, case when EF.ProtocolloGenerale IS NULL THEN E.ProtocolloGenerale ELSE EF.ProtocolloGenerale END as ProtocolloGenerale, 
	EF.DataInvio, EF.Protocollo,Fornitore, EF.Motivazione, EF.Stato, EF.ID_MSG_OFFERTA, case when EF.DataProt IS NULL THEN E.DataProt ELSE EF.DataProt END as DataProt,
	EF.idRow as DETTAGLIGrid_ID_DOC , 'COM_ESITO_GARA' as DETTAGLIGrid_OPEN_DOC_NAME ,isATI,EF.titolo,
	T.protocolBg as Fascicolo
from Document_EsitoGara E , Document_EsitoGara_Fornitori EF , tab_messaggi_fields T
where id = idheader and ID_MSG_BANDO=idmsg
GO
