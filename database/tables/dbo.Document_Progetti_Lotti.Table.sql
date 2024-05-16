USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Progetti_Lotti]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Progetti_Lotti](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdProgetto] [int] NOT NULL,
	[Lotto] [int] NULL,
	[ScadenzaIstanza] [datetime] NULL,
	[ScadenzaOfferta] [datetime] NULL,
	[Importo] [float] NULL,
	[NoteLotto] [text] NULL,
	[DataConsegnaVerbale] [datetime] NULL,
	[Rettifica] [varchar](10) NULL,
	[Annullamento] [varchar](10) NULL,
	[Ricorso] [varchar](50) NULL,
	[Deserta_MaiIndetta] [varchar](20) NULL,
	[DataTrasmContratto] [datetime] NULL,
	[DataAvvioIstr] [datetime] NULL,
	[DurataIstruttoria] [float] NULL,
	[NoteAggiudicazione] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
