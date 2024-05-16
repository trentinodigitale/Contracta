USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Esclusione]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Esclusione](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[DataCreazione] [datetime] NULL,
	[ID_MSG_PDA] [int] NULL,
	[ID_MSG_BANDO] [int] NULL,
	[StatoEsclusione] [varchar](20) NULL,
	[Oggetto] [ntext] NULL,
	[DataAperturaOfferte] [datetime] NULL,
	[DataIISeduta] [datetime] NULL,
	[Segretario] [nvarchar](50) NULL,
	[Protocol] [varchar](50) NULL,
	[StatoGara] [varchar](20) NULL,
	[Versione] [int] NULL,
	[Fascicolo] [varchar](30) NULL,
 CONSTRAINT [PK_Document_Esclusione] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Esclusione] ADD  CONSTRAINT [DF_Document_Esclusione_DataCreazione]  DEFAULT (getdate()) FOR [DataCreazione]
GO
ALTER TABLE [dbo].[Document_Esclusione] ADD  CONSTRAINT [DF_Document_Esclusione_StatoEsclusione]  DEFAULT ('Saved') FOR [StatoEsclusione]
GO
ALTER TABLE [dbo].[Document_Esclusione] ADD  CONSTRAINT [DF_Document_Esclusione_Versione]  DEFAULT (2) FOR [Versione]
GO
