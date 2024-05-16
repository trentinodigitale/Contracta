USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Pda_Offerte_Anomalie]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Pda_Offerte_Anomalie](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[IdRowOfferta] [int] NOT NULL,
	[IdDocOff] [int] NOT NULL,
	[IdFornitore] [int] NOT NULL,
	[Descrizione] [nvarchar](max) NULL,
	[Data] [datetime] NULL,
	[TipoAnomalia] [varchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Pda_Offerte_Anomalie] ADD  CONSTRAINT [DF_Document_Pda_Offerte_Anomalie_Data]  DEFAULT (getdate()) FOR [Data]
GO
ALTER TABLE [dbo].[Document_Pda_Offerte_Anomalie] ADD  CONSTRAINT [DF_Document_Pda_Offerte_Anomalie_TipoAnomalia]  DEFAULT ('') FOR [TipoAnomalia]
GO
