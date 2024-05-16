USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Sistemazione_Contabile]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Sistemazione_Contabile](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DataCreazione] [datetime] NULL,
	[ID_Repertorio] [int] NULL,
	[Stato] [varchar](20) NULL,
	[Oggetto] [ntext] NULL,
	[OggettoDet] [ntext] NULL,
	[TestoDetermina] [ntext] NULL,
	[ResponsabileContratto] [nvarchar](50) NULL,
	[idAggiudicatrice] [int] NULL,
	[Importo] [float] NULL,
	[ProtocolloGenerale] [varchar](30) NULL,
	[DataProt] [datetime] NULL,
	[NumReversale] [varchar](30) NULL,
	[DataReversale] [datetime] NULL,
	[Rep] [nvarchar](100) NULL,
	[DataStipula] [datetime] NULL,
	[DataDetermina] [datetime] NULL,
	[NRDeterminazione] [varchar](50) NULL,
	[NumMandato] [varchar](30) NULL,
	[DataMandato] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
