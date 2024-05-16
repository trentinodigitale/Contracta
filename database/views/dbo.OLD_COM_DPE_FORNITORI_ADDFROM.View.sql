USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_COM_DPE_FORNITORI_ADDFROM]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






--Versione=2&data=2014-01-16&Attivita=50092&Nominativo=Sabato
CREATE VIEW [dbo].[OLD_COM_DPE_FORNITORI_ADDFROM]
AS
SELECT 
	IdAzi                                                        AS IndRow
     --, IdAzi 
     --, aziRagioneSociale
     , aziIndirizzoLeg + ' - ' + aziLocalitaLeg + ' - ' + aziStatoLeg   AS Indirizzo
     , DM_1.vatvalore_ft     AS codicefiscale
     --, *
	-- ,aziragionesociale
		,[IdAzi], [aziTs], [aziLog], [aziDataCreazione], [aziRagioneSociale], [aziRagioneSocialeNorm], [aziIdDscFormaSoc], [aziPartitaIVA], [aziE_Mail], [aziAcquirente], [aziVenditore], [aziProspect], [aziIndirizzoLeg], [aziIndirizzoOp], [aziLocalitaLeg], [aziLocalitaOp], [aziProvinciaLeg], [aziProvinciaOp], [aziStatoLeg], [aziStatoOp], [aziCAPLeg], [aziCapOp], [aziPrefisso], [aziTelefono1], [aziTelefono2], [aziFAX], [aziLogo], [aziIdDscDescrizione], [aziProssimoProtRdo], [aziProssimoProtOff], [aziGphValueOper], [aziDeleted], [aziDBNumber], [aziAtvAtecord], [aziSitoWeb], [aziCodEurocredit], [aziProfili], [aziProvinciaLeg2], [aziStatoLeg2], [aziFunzionalita], [CertificatoIscrAtt], [TipoDiAmministr], [aziLocalitaLeg2], [daValutare], [aziNumeroCivico]
	  ,case when d5.idVat is null and not d4.idVat is null then '10' -- hanno un participant id ma non hanno un idnotier
		  when not d5.idVat is null then '11'-- hanno un idnotier 
		  when not d4.idVat is null then '1_'-- hanno un participant id 
		  when d4.idVat is null then '00' -- non hanno un participant id
     end as iscrittoPeppol
  FROM 
     Aziende with (nolock)
	--cross join (
	--	select top 12 IdPfu  from ProfiliUtente with (nolock) ) as V
		 LEFT OUTER JOIN DM_Attributi  DM_1 with (nolock)ON Aziende.IdAzi = DM_1.lnk AND DM_1.idApp = 1 AND DM_1.dztNome = 'codicefiscale' 
		 left outer join dbo.DM_Attributi d4 with(nolock) on d4.dztNome = 'PARTICIPANTID' and d4.idApp = 1 and d4.lnk = idazi and isnull(d4.vatValore_FT,'') <> ''
		 left outer join dbo.DM_Attributi d5 with(nolock) on d5.dztNome = 'IDNOTIER' and d5.idApp = 1 and d5.lnk = idazi and isnull(d5.vatValore_FT,'') <> ''

	WHERE 
    aziDeleted = 0 and azivenditore > 0       and aziacquirente = 0
		--ESCLUDO LE RTI
		and aziIdDscFormaSoc <> '845326' 

   





GO
