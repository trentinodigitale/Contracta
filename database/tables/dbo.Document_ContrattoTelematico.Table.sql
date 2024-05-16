USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_ContrattoTelematico]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_ContrattoTelematico](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DataCreazione] [datetime] NULL,
	[ID_MSG_PDA] [int] NULL,
	[ID_MSG_BANDO] [int] NULL,
	[idAggiudicatrice] [int] NULL,
	[Protocol] [varchar](50) NULL,
	[Stato] [varchar](20) NULL,
	[Oggetto] [ntext] NULL,
	[UffRogante] [varchar](100) NULL,
	[Datainvio] [datetime] NULL,
	[ResponsabileContratto] [nvarchar](50) NULL,
	[DataStipula] [datetime] NULL,
	[Rep] [int] NULL,
	[PDFContratto] [varchar](250) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_ContrattoTelematico] ADD  CONSTRAINT [DF_Document_ContrattoTelematico_DataCreazione]  DEFAULT (getdate()) FOR [DataCreazione]
GO
ALTER TABLE [dbo].[Document_ContrattoTelematico] ADD  CONSTRAINT [DF_Document_ContrattoTelematico_Stato]  DEFAULT ('Saved') FOR [Stato]
GO
