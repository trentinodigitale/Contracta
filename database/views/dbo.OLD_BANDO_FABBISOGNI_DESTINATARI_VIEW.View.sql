USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_BANDO_FABBISOGNI_DESTINATARI_VIEW]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[OLD_BANDO_FABBISOGNI_DESTINATARI_VIEW] as
select 
	idrow, 
	idHeader, 
	ISNULL(CD.StatoIscrizione,'In Attesa')   as StatoIscrizione,
	Cd.IdPfu, 
	IdAzi, 
	aziRagioneSociale, 
	aziPartitaIVA, 
	aziE_Mail, 
	aziIndirizzoLeg, 
	aziLocalitaLeg, 
	aziProvinciaLeg, 
	aziStatoLeg, 
	aziCAPLeg, 
	aziTelefono1, 
	aziFAX, 
	aziDBNumber, 
	aziSitoWeb, 
	CDDStato, 
	Seleziona, 
	NumRiga, 
	CodiceFiscale, 
	DataIscrizione, 
	DataScadenzaIscrizione, 
	DataSollecito, 
	Id_Doc,
	C1.Tipodoc /*'QUESTIONARIO_FABBISOGNI' */ as DESTINATARIGrid_OPEN_DOC_NAME,
	c1.id as DESTINATARIGrid_ID_DOC
from CTL_DOC_Destinatari CD
	left join ctl_doc C1 on C1.LinkedDoc=CD.idHeader and C1.Azienda=CD.IdAzi and TipoDoc like 'QUESTIONARIO_%' and C1.StatoFunzionale <> 'InLavorazione'




GO
