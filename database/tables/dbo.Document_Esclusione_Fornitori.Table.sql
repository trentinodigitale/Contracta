USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Esclusione_Fornitori]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Esclusione_Fornitori](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[ProtocolloGenerale] [varchar](30) NULL,
	[DataInvio] [datetime] NULL,
	[Fornitore] [varchar](20) NULL,
	[Motivazione] [ntext] NULL,
	[Stato] [varchar](20) NULL,
	[ID_MSG_OFFERTA] [int] NULL,
	[DataProt] [datetime] NULL,
	[isATI] [int] NULL,
	[StatoFax] [varchar](1) NULL,
 CONSTRAINT [PK_Document_Esclusione_Fornitori] PRIMARY KEY CLUSTERED 
(
	[idRow] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Esclusione_Fornitori] ADD  CONSTRAINT [DF_Document_Esclusione_Fornitori_isATI]  DEFAULT (0) FOR [isATI]
GO
