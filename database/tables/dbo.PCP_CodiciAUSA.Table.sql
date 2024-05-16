USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[PCP_CodiciAUSA]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PCP_CodiciAUSA](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[codice_fiscale] [varchar](16) NOT NULL,
	[partita_IVA] [varchar](11) NOT NULL,
	[denominazione] [varchar](255) NOT NULL,
	[codice_ausa] [varchar](100) NOT NULL,
	[natura_giuridica_codice] [varchar](10) NOT NULL,
	[natura_giuridica_descrizione] [varchar](300) NOT NULL,
	[soggetto_estero] [bit] NOT NULL,
	[provincia_codice] [varchar](10) NOT NULL,
	[provincia_nome] [varchar](100) NOT NULL,
	[citta_codice] [varchar](20) NOT NULL,
	[citta_nome] [varchar](50) NOT NULL,
	[indirizzo_odonimo] [varchar](150) NOT NULL,
	[cap] [varchar](10) NOT NULL,
	[flag_inHouse] [bit] NOT NULL,
	[flag_partecipata] [bit] NOT NULL,
	[stato] [varchar](50) NOT NULL,
	[data_inizio] [varchar](20) NULL,
	[data_fine] [varchar](20) NULL,
 CONSTRAINT [PK_PCP_CodiciAUSA] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PCP_CodiciAUSA] ADD  CONSTRAINT [DF_PCP_CodiciAUSA_soggetto_estero]  DEFAULT ((0)) FOR [soggetto_estero]
GO
