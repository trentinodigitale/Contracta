USE [AFLink_TND]
GO
/****** Object:  View [dbo].[Document_ControlliGara_Fornitori_view]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[Document_ControlliGara_Fornitori_view] as
select 
		 h.Responsabile,
		 StatoPDA, 
		 idAziPartecipante, 
		 id, 
		 DataCreazione, 
		 ID_MSG_PDA, 
		 ID_MSG_BANDO, 
		 StatoEsclusione, 
		 Oggetto, 
		 DataAperturaOfferte, 
		 DataIISeduta, 
		 h.Segretario, 
		 Protocol, 
		 idAggiudicatrice,
		 importoBaseAsta, 
		 NRDeterminazione, 
		 DataDetermina, 
		 h.ValutazioneEconomica  , 
		 idRow, 
		 idHeader, 
		 ProtocolloGenerale, 
		 DataInvio, 
		 Fornitore, 
		 Motivazione, 
		 Stato, 
		 ID_MSG_OFFERTA, 
		 DataProt,
		 idRow as DETTAGLIGrid_ID_DOC , 
		 'COM_CONTROLLI_GARA' as DETTAGLIGrid_OPEN_DOC_NAME ,
		 isATI , 
	     Fornitore as LegalPub,
	     h.StatoNorm_Antimafia,
	     h.StatoCanc_Fallimentare,
	     h.StatoCas_Giudiz,
	     h.StatoEntrate,
	     h.StatoNorm_Disabile , 
	     ValoreContrattoOfferta,
	     h.StatoDURC , 
	     CANC_FALLIMENTARE_Esito,
		 CAS_GIUDIZ_Esito,
		 DURC_Esito,
		 ENTRATE_Esito,
		 NORM_ANTIMAFIA_Esito,
		 NORM_DISABILE_Esito,
		 NORM_ANTIMAFIA_DataScadenza, 
		 DURC_DataControllo

from Document_ControlliGara  
	inner join  Document_ControlliGara_Fornitori h on id = idheader 
	left outer join Document_Aziende_Comunicazioni_NORM_ANTIMAFIA  a on a.idDoc_ContGara_For  = idRow
	left outer join Document_Aziende_Comunicazioni_CANC_FALLIMENTARE    b on b.idDoc_ContGara_For  = idRow and b.canc_fallimentare_datacomunicazione is not null
	left outer join Document_Aziende_Comunicazioni_ENTRATE    c on c.idDoc_ContGara_For  = idRow
	left outer join Document_Aziende_Comunicazioni_NORM_DISABILE    d on d.idDoc_ContGara_For  = idRow
	left outer join Document_Aziende_Comunicazioni_CAS_GIUDIZ    e on e.idDoc_ContGara_For  = idRow
	left outer join Document_Aziende_Comunicazioni_DURC    f on f.idDoc_ContGara_For  = idRow





GO
