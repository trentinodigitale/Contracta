USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DWH_Get_Fornitori]    Script Date: 5/16/2024 2:45:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[DWH_Get_Fornitori]
AS

	select 

			azilog as [Codice Fornitore],
			a1.vatValore_FT as [Codice Fiscale],
			z1.dscTesto  as [Forma Giuridica],
			aziPartitaIVA as [Partita IVA],
			aziRagioneSociale  as [Ragione Sociale],
			aziCAPLeg as CAP,
			aziStatoLeg as Stato,
			dd1.DMV_DescML  as Regione,
			aziprovincialeg as Provincia,
			azilocalitaleg as Comune,
			a2.vatValore_FT as [Partecipant ID PEPPOL],
			Substring(isnull(aziLocalitaLeg2,''), LEN(isnull(aziLocalitaLeg2,'')) - Charindex('-',Reverse(isnull(aziLocalitaLeg2,'')) ) + 2, 30 ) as [Codice ISTAT Comune],
			NUTS as [Codice Stato],
			a3.vatValore_FT as [Sede iscrizione camera di commercio],		
			a4.vatValore_FT as [Anno iscrizione],	
			a5.vatValore_FT as [Numero REA],					
			'' as [Stato Registrazione Camera di Commercio],	--- ??????????????????
			case when azideleted=0 then 'Attivo' else 'Cessato' end as [Stato Registrazione  SATER]


	from aziende with (nolock)

		-- codice fiscale
		left outer join DM_Attributi a1 with (nolock) on a1.idapp=1 
															and a1.lnk=idazi 
															and a1.dztnome='codicefiscale'
		-- forma giuridica
		left outer join dizionarioattributi x1 with (nolock) on x1.dztNome = 'NAGI'
		left outer join tipidatirange y1 with (nolock) on x1.dztIdTid = y1.tdrIdTid 
															and y1.tdrCodice = cast(aziIdDscFormaSoc as varchar)
		left outer join descsi z1 with (nolock) on z1.IdDsc = y1.tdrIdDsc 

		--regione
		left outer join LIB_DomainValues dd1 with (nolock) on dd1.DMV_DM_ID = 'GEO' 
														and dd1.DMV_Cod = Substring(isnull(aziprovincialeg2,''),1, LEN(isnull(aziprovincialeg2,'')) - Charindex('-',Reverse(isnull(aziprovincialeg2,'')) ) )
		--PARTICIPANTID
		left outer join DM_Attributi a2 with (nolock) on a2.idapp=1 and a2.lnk=idazi and a2.dztnome='PARTICIPANTID'

		--Codice Stato
		left outer join GEO_RaccordoStati with (nolock) on 'M-' + CodContinente + '-' + CodArea + '-' + ISO_3166_1_3_LetterCode = isnull(aziStatoLeg2,'')

		--sede iscrizione 
		left outer join DM_Attributi a3 with (nolock) on a3.idapp=1 and a3.lnk=idazi and a3.dztnome='SedeCCIAA'

		--Anno iscrizione
		left outer join DM_Attributi a4 with (nolock) on a4.idapp=1 and a4.lnk=idazi and a4.dztnome='annocostituzione'

		--Numero iscrizione
		left outer join DM_Attributi a5 with (nolock) on a5.idapp=1 and a5.lnk=idazi and a5.dztnome='IscrCCIAA'

	where aziVenditore <> 0 and aziacquirente = 0  and aziiddscformasoc <> 845326
GO
