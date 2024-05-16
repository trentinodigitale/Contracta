USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Modelli_MicroLotti]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Modelli_MicroLotti](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[StatoDoc] [varchar](50) NOT NULL,
	[Deleted] [int] NOT NULL,
	[DataCreazione] [datetime] NOT NULL,
	[Codice] [varchar](500) NOT NULL,
	[Descrizione] [varchar](200) NOT NULL,
	[ModelloBando] [varchar](500) NULL,
	[ModelloOfferta] [varchar](500) NULL,
	[ColonneCauzione] [varchar](500) NOT NULL,
	[Allegato] [nvarchar](255) NOT NULL,
	[ModelloPDA] [varchar](500) NULL,
	[ModelloPDA_DrillTestata] [varchar](500) NULL,
	[ModelloPDA_DrillLista] [varchar](500) NULL,
	[ModelloOfferta_Drill] [varchar](500) NULL,
	[ModelloConformitaTestata] [varchar](500) NULL,
	[ModelloConformitaDettagli] [varchar](500) NULL,
	[CriterioAggiudicazioneGara] [varchar](255) NULL,
	[Conformita] [varchar](255) NULL,
	[Help_Bando] [nvarchar](255) NULL,
	[Help_Offerte] [nvarchar](255) NULL,
	[Help_Offerte_Indicativa] [nvarchar](255) NULL,
	[Complex] [int] NULL,
	[LinkedDoc] [int] NULL,
	[Base] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Modelli_MicroLotti] ADD  CONSTRAINT [DF_Document_Modelli_Lotti_StatoDoc]  DEFAULT ('Saved') FOR [StatoDoc]
GO
ALTER TABLE [dbo].[Document_Modelli_MicroLotti] ADD  CONSTRAINT [DF_Document_Modelli_Lotti_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[Document_Modelli_MicroLotti] ADD  CONSTRAINT [DF_Document_Modelli_Lotti_DataCreazione]  DEFAULT (getdate()) FOR [DataCreazione]
GO
ALTER TABLE [dbo].[Document_Modelli_MicroLotti] ADD  CONSTRAINT [DF_Document_Modelli_MicroLotti_ColonneCauzione]  DEFAULT ('') FOR [ColonneCauzione]
GO
ALTER TABLE [dbo].[Document_Modelli_MicroLotti] ADD  CONSTRAINT [DF_Document_Modelli_MicroLotti_Complex]  DEFAULT ((0)) FOR [Complex]
GO
ALTER TABLE [dbo].[Document_Modelli_MicroLotti] ADD  CONSTRAINT [DF_Document_Modelli_MicroLotti_Base]  DEFAULT ((1)) FOR [Base]
GO
