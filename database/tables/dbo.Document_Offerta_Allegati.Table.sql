USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Offerta_Allegati]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Offerta_Allegati](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[Idheader] [int] NOT NULL,
	[SectionName] [nvarchar](200) NOT NULL,
	[Attach_Hash] [nvarchar](1000) NULL,
	[Attach_attOrderFile] [int] NULL,
	[Attach_Name] [nvarchar](250) NOT NULL,
	[Attach_Description] [nvarchar](500) NOT NULL,
	[Attach_Signers] [nvarchar](500) NOT NULL,
	[Attach_Signers_CF] [nvarchar](500) NOT NULL,
	[RapLegInSigners] [varchar](10) NOT NULL,
	[Elaborato] [varchar](50) NULL,
	[Obbligatorio] [int] NULL,
	[RichiediFirma] [int] NULL,
	[statoFirma] [varchar](100) NULL,
	[numeroLotto] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Offerta_Allegati] ADD  CONSTRAINT [DF_Table_1_Signers]  DEFAULT ('') FOR [Attach_Signers]
GO
ALTER TABLE [dbo].[Document_Offerta_Allegati] ADD  CONSTRAINT [DF_Table_1_CodiceFiscaleSigners]  DEFAULT ('') FOR [Attach_Signers_CF]
GO
ALTER TABLE [dbo].[Document_Offerta_Allegati] ADD  CONSTRAINT [DF_Document_Offerta_Allegati_RapLegInSigners]  DEFAULT ('no') FOR [RapLegInSigners]
GO
ALTER TABLE [dbo].[Document_Offerta_Allegati] ADD  CONSTRAINT [DF_Document_Offerta_Allegati_Elaborato]  DEFAULT (0) FOR [Elaborato]
GO
