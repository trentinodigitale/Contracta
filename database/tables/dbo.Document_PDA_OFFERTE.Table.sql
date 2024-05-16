USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_PDA_OFFERTE]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_PDA_OFFERTE](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NULL,
	[NumRiga] [varchar](15) NULL,
	[aziRagioneSociale] [nvarchar](2000) NULL,
	[ProtocolloOfferta] [varchar](40) NULL,
	[ReceivedDataMsg] [datetime] NULL,
	[IdMsg] [int] NULL,
	[IdMittente] [int] NULL,
	[idAziPartecipante] [int] NULL,
	[StatoPDA] [varchar](15) NULL,
	[Motivazione] [ntext] NULL,
	[IdMsgFornitore] [int] NULL,
	[Sostituita] [varchar](5) NULL,
	[TipoDoc] [varchar](50) NULL,
	[VerificaCampionatura] [varchar](20) NULL,
	[Warning] [nvarchar](max) NULL,
	[EsclusioneLotti] [varchar](20) NULL,
	[Avvalimento] [varchar](2) NULL,
	[Stato_Firma_PDA_AMM] [nvarchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_PDA_OFFERTE] ADD  CONSTRAINT [DF_Document_PDA_OFFERTE_Sostituita]  DEFAULT ('') FOR [Sostituita]
GO
