USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Liquidazioni]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Liquidazioni](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DataCreazione] [datetime] NULL,
	[Fornitore] [int] NOT NULL,
	[ID_Esito] [int] NULL,
	[ID_Pubblicazione] [int] NULL,
	[Stato] [varchar](20) NULL,
	[OggettoDet] [ntext] NULL,
	[TestoDetermina] [ntext] NULL,
	[NRDeterminazione] [varchar](50) NULL,
	[DataDetermina] [datetime] NULL,
	[ProtocolloGenerale] [varchar](30) NULL,
	[DataProt] [datetime] NULL,
	[ResponsabileContratto] [nvarchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Liquidazioni] ADD  CONSTRAINT [DF__Document___DataC__51320897]  DEFAULT (getdate()) FOR [DataCreazione]
GO
ALTER TABLE [dbo].[Document_Liquidazioni] ADD  CONSTRAINT [DF__Document___Stato__52262CD0]  DEFAULT ('Saved') FOR [Stato]
GO
