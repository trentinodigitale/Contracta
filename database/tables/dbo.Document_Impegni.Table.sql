USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Impegni]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Impegni](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DataCreazione] [datetime] NULL,
	[ID_Esito] [int] NULL,
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
ALTER TABLE [dbo].[Document_Impegni] ADD  CONSTRAINT [DF__Document___DataC__4E559BEC]  DEFAULT (getdate()) FOR [DataCreazione]
GO
ALTER TABLE [dbo].[Document_Impegni] ADD  CONSTRAINT [DF__Document___Stato__4F49C025]  DEFAULT ('Saved') FOR [Stato]
GO
