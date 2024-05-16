USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Aziende_Documentazione]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Aziende_Documentazione](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idAzi] [int] NULL,
	[idChainDocStory] [int] NULL,
	[AnagDoc] [nvarchar](150) NULL,
	[Descrizione] [nvarchar](250) NULL,
	[Allegato] [nvarchar](255) NULL,
	[DataEmissione] [datetime] NULL,
	[DataInserimento] [datetime] NULL,
	[LinkedDoc] [int] NULL,
	[TipoDoc] [varchar](50) NULL,
	[StatoDocumentazione] [varchar](20) NULL,
	[deleted] [int] NULL,
	[DataSollecito] [datetime] NULL,
	[Interno] [int] NULL,
	[DataScadenza] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Aziende_Documentazione] ADD  CONSTRAINT [DF_Aziende_Documentazione_Interno]  DEFAULT (0) FOR [Interno]
GO
