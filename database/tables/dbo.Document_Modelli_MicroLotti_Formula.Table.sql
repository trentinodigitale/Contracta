USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Modelli_MicroLotti_Formula]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Modelli_MicroLotti_Formula](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[StatoDoc] [varchar](50) NULL,
	[Deleted] [int] NULL,
	[DataCreazione] [datetime] NULL,
	[Codice] [varchar](500) NULL,
	[FormulaEconomica] [nvarchar](1500) NULL,
	[CriterioFormulazioneOfferte] [varchar](10) NULL,
	[IdHeader] [int] NULL,
	[FieldBaseAsta] [varchar](100) NULL,
	[Quantita] [varchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Modelli_MicroLotti_Formula] ADD  CONSTRAINT [DF_Document_Modelli_MicroLotti_Formula_StatoDoc]  DEFAULT ('Saved') FOR [StatoDoc]
GO
ALTER TABLE [dbo].[Document_Modelli_MicroLotti_Formula] ADD  CONSTRAINT [DF_Document_Modelli_MicroLotti_Formula_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[Document_Modelli_MicroLotti_Formula] ADD  CONSTRAINT [DF_Document_Modelli_MicroLotti_Formula_DataCreazione]  DEFAULT (getdate()) FOR [DataCreazione]
GO
