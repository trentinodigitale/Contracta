USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_RIEPILOGO_ANOMALIE_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[PDA_RIEPILOGO_ANOMALIE_VIEW] 
as
select 
	O.*,
	P.ProtocolloRiferimento,
	P.Fascicolo,
	P.StrutturaAziendale,
	importoBaseAsta,
	importoBaseAsta2,
	CriterioAggiudicazioneGara,
	OffAnomale,
	ModalitadiPartecipazione,
	CriterioFormulazioneOfferte,
	CIG,
	CUP,
	NumeroIndizione,
	DataIndizione,
	Oggetto
	 
from 
	document_pda_offerte O
	inner join ctl_doc P on O.idheader=P.id
	inner join document_pda_testata PT on PT.idHeader=P.id
where 
	P.TipoDoc='PDA_MICROLOTTI'

--PDA_MICROLOTTI_VIEW_TESTATA
GO
