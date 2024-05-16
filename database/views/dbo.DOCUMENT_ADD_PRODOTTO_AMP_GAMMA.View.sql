USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DOCUMENT_ADD_PRODOTTO_AMP_GAMMA]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









--drop view [DOCUMENT_ADD_PRODOTTO]




CREATE      view [dbo].[DOCUMENT_ADD_PRODOTTO_AMP_GAMMA] as 

	select    a.id 
			, a.id as indRow
			--, a.TipoDoc
			,'OFFERTA_AMPIEZZA' as TipoDoc
			, case 
				when b.RichiestaCigSimog = 'si' or dbo.attivo_INTEROP_Gara(a.id)=1 then ' CIG ' 
				else '' 
			   end as NotEditable
			, d.pcp_ContrattiDisposizioniParticolari
			, c.Value as DESC_LUOGO_ISTAT
			, d.pcp_ModalitaAcquisizione
			, d.pcp_OggettoPrincipaleContratto
			, d.pcp_PrevedeRipetizioniCompl
			, d.pcp_TipologiaLavoro
			, d.pcp_PrevedeRipetizioniOpzioni
			, d.pcp_Categoria
			, b.CUP
			, e.CATEGORIE_MERC
			, b.TipoAppaltoGara as pcp_TipoAppaltoGara
			, d.MOTIVAZIONE_CIG
			, d.MOTIVO_COLLEGAMENTO
			, d.TIPO_FINANZIAMENTO
			, d.pcp_ImportoFinanziamento
			, d.pcp_cigCollegato
			, d.pcp_iniziativeNonSoddisfacenti
			, d.pcp_CondizioniNegoziata
			, d.pcp_saNonSoggettaObblighi24Dicembre2015
			, d.pcp_lavoroOAcquistoPrevistoInProgrammazione
			, d.pcp_ServizioPubblicoLocale
			, CPV.Value as CODICE_CPV
			, d.pcp_Dl50

		from CTL_DOC a with(nolock)
				left join document_bando b with(nolock) on b.idHeader = a.Id
				left join CTL_DOC_Value c with(nolock) on c.idHeader = a.Id and c.DSE_ID='InfoTec_SIMOG' and c.DZT_Name = 'DESC_LUOGO_ISTAT'
				left join Document_PCP_Appalto d with(nolock) on d.idHeader = a.Id
				left join BANDO_GARA_TESTATA_VIEW e with(nolock) on e.idHeader = a.Id
				left join CTL_DOC_Value CPV with(nolock) on CPV.idHeader = a.Id and CPV.DSE_ID='InfoTec_SIMOG' and CPV.DZT_Name = 'CODICE_CPV'


GO
