USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_comunicazione_StatoLotti]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_comunicazione_StatoLotti](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[NumeroLotto] [varchar](50) NOT NULL,
	[IdAziAggiudicataria] [int] NOT NULL,
	[Importo] [float] NULL,
	[IdAziIIClassificata] [int] NOT NULL,
	[Deleted] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_comunicazione_StatoLotti] ADD  CONSTRAINT [DF_Document_comunicazione_StatoLotti_Deleted]  DEFAULT (0) FOR [Deleted]
GO
