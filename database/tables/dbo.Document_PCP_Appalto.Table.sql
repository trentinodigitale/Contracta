USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_PCP_Appalto]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_PCP_Appalto](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[pcp_test] [nvarchar](1000) NULL,
	[pcp_CodiceCentroDiCosto] [nvarchar](1000) NULL,
	[pcp_FunzioniSvolte] [nvarchar](1000) NULL,
	[pcp_MotivoUrgenza] [nvarchar](1000) NULL,
	[pcp_LinkDocumenti] [nvarchar](1000) NULL,
	[pcp_CondizioniNegoziata] [nvarchar](1000) NULL,
	[pcp_ContrattiDisposizioniParticolari] [nvarchar](1000) NULL,
	[pcp_ModalitaAcquisizione] [nvarchar](1000) NULL,
	[pcp_OggettoPrincipaleContratto] [nvarchar](1000) NULL,
	[pcp_PrestazioniComprese] [nvarchar](1000) NULL,
	[pcp_ServizioPubblicoLocale] [nvarchar](1000) NULL,
	[pcp_PrevedeRipetizioniCompl] [nvarchar](1000) NULL,
	[pcp_Dl50] [nvarchar](1000) NULL,
	[pcp_CodiceCUI] [nvarchar](1000) NULL,
	[pcp_TipologiaLavoro] [nvarchar](1000) NULL,
	[pcp_PrevedeRipetizioniOpzioni] [nvarchar](1000) NULL,
	[pcp_Categoria] [nvarchar](1000) NULL,
	[test_federico] [varchar](100) NULL,
	[pcp_CodiceAppalto] [nvarchar](1000) NULL,
	[pcp_TipoScheda] [nvarchar](200) NULL,
	[pcp_VersioneScheda] [varchar](50) NULL,
	[pcp_Codice_Ausa] [varchar](100) NULL,
	[pcp_CodiceScheda] [nvarchar](100) NULL,
	[pcp_CodiceAvviso] [nvarchar](100) NULL,
	[pcp_RelazioneUnicaSulleProcedure] [nvarchar](1000) NULL,
	[pcp_OpereUrbanizzateScomputo] [nvarchar](1000) NULL,
	[MOTIVO_COLLEGAMENTO] [nvarchar](1000) NULL,
	[MOTIVAZIONE_CIG] [nvarchar](1000) NULL,
	[TIPO_FINANZIAMENTO] [nvarchar](1000) NULL,
	[pcp_iniziativeNonSoddisfacenti] [varchar](10) NULL,
	[pcp_saNonSoggettaObblighi24Dicembre2015] [varchar](10) NULL,
	[pcp_lavoroOAcquistoPrevistoInProgrammazione] [varchar](10) NULL,
	[pcp_cigCollegato] [varchar](100) NULL,
	[pcp_ImportoFinanziamento] [float] NULL,
	[pcp_proceduraAccelerata] [varchar](10) NULL,
	[strumentiSvolgimentoProcedure] [varchar](20) NULL,
	[pcp_SommeADisposizione] [float] NULL,
	[GIUSTIFICAZIONE_AGG_DIRETTA] [varchar](100) NULL,
	[ContractingType] [varchar](20) NULL
) ON [PRIMARY]
GO
