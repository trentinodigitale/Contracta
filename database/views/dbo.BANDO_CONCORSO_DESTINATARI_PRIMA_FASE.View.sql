USE [AFLink_TND]
GO
/****** Object:  View [dbo].[BANDO_CONCORSO_DESTINATARI_PRIMA_FASE]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[BANDO_CONCORSO_DESTINATARI_PRIMA_FASE] as

select distinct b.id as idBando , 
    --d.*
    
    --tabella CTL_DOC_Destinatari
    d.idrow, d.idHeader, d.IdPfu, 
    
    --tabella aziende per prenderee le info aggiornate
    a.IdAzi, a.aziRagioneSociale, a.aziPartitaIVA, a.aziE_Mail, a.aziIndirizzoLeg, a.aziLocalitaLeg, a.aziProvinciaLeg, 
    a.aziStatoLeg, a.aziCAPLeg, a.aziTelefono1, a.aziFAX, a.aziDBNumber, a.aziSitoWeb, 
    
    --tabella CTL_DOC_Destinatari
    d.CDDStato, d.Seleziona, d.NumRiga, ISNULL(d.CodiceFiscale,DM.vatValore_FT) as codicefiscale, d.StatoIscrizione, d.DataIscrizione, 
    d.DataScadenzaIscrizione, d.DataSollecito, d.Id_Doc, d.DataConferma, d.NumeroInviti
	,o.TipoDoc
	,o.Titolo as Progressivo_Risposta

from CTL_DOC b with (nolock)
	inner join CTL_DOC_Destinatari d with (nolock) on b.LinkedDoc = d.idHeader and isnull(d.StatoIscrizione,'') <> 'Cancellato'
	inner join aziende a  with (nolock) on d.idazi=a.idazi
	inner join CTL_DOC o  with (nolock) on o.TipoDoc in ('RISPOSTA_CONCORSO') and o.StatoDoc = 'Sended' and o.LinkedDoc = b.LinkedDoc and d.IdAzi = o.Azienda
	left join CTL_DOC PD  with (nolock) on PD.LinkedDoc=b.LinkedDoc and PD.TipoDoc = 'PDA_CONCORSO' and PD.deleted=0
	left join document_pda_offerte DPO  with (nolock) on DPO.IdHeader=PD.id and DPO.StatoPDA='2' and DPO.idAziPartecipante=D.idazi
	left join DM_Attributi DM  with (nolock) on DM.lnk=D.IdAzi and DM.idApp=1 and DM.dztNome='Codicefiscale'
GO
