USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_RICERCA_ENTI_ESITI_DESTINATARI]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD2_RICERCA_ENTI_ESITI_DESTINATARI] AS
select 
	idrow, 
	idHeader, 
	d.IdPfu, 
	d.IdAzi, 
	d.aziRagioneSociale, 
	d.aziPartitaIVA, 
	d.aziE_Mail, 
	d.aziIndirizzoLeg, 
	d.aziLocalitaLeg, 
	d.aziProvinciaLeg, 
	d.aziStatoLeg, 
	d.aziCAPLeg, 
	d.aziTelefono1, 
	d.aziFAX, 
	d.aziDBNumber, 
	d.aziSitoWeb, 
	CDDStato, 	
	NumRiga, 
	CodiceFiscale, 
	StatoIscrizione, 
	DataIscrizione, 
	DataScadenzaIscrizione, 
	DataSollecito, 
	Id_Doc,
	case 
		when b.TipoDoc = 'BANDO_FABBISOGNI' 
			then dbo.VerificaProfiloEnte(idazi,'FabbOperativo') 
			else dbo.VerificaProfiloEnte(idazi,'FabbQualOperativo') 
		end
	as PresenzaReferente,

	case 
		when b.TipoDoc = 'BANDO_FABBISOGNI' 
			then case when dbo.VerificaProfiloEnte(idazi,'FabbOperativo') = '0' then ' Seleziona ' else ''  end 
			else case when dbo.VerificaProfiloEnte(idazi,'FabbQualOperativo') = '0' then ' Seleziona ' else ''  end 
		end
	as NonEditabili,
	
	
	case 
		when b.TipoDoc = 'BANDO_FABBISOGNI' 
			then case when dbo.VerificaProfiloEnte(idazi,'FabbOperativo') = '0' then 'escludi' else Seleziona end 
			else case when dbo.VerificaProfiloEnte(idazi,'FabbQualOperativo') = '0' then 'escludi' else Seleziona end 
		end			
	as Seleziona

from CTL_DOC_Destinatari d 
	inner join CTL_DOC r on r.Id = d.idHeader
	inner join CTL_DOC b on b.Id = r.LinkedDoc




GO
