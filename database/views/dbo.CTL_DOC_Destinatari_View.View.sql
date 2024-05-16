USE [AFLink_TND]
GO
/****** Object:  View [dbo].[CTL_DOC_Destinatari_View]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CTL_DOC_Destinatari_View] as 
select 
	idrow, idHeader, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb, CDDStato, Seleziona, NumRiga, StatoIscrizione, DataIscrizione, DataScadenzaIscrizione, DataSollecito, Id_Doc, DataConferma, NumeroInviti,
	ISNULL(CodiceFiscale,vatValore_FT) as CodiceFiscale
from CTL_DOC_Destinatari CD
	left join DM_Attributi A on A.lnk=CD.IdAzi and idApp=1 and dztNome='Codicefiscale'
GO
