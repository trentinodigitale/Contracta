USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Spese_Contratto]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Spese_Contratto](
	[Id] [int] NOT NULL,
	[Conto] [varchar](50) NULL,
	[Descrizione] [varchar](50) NULL,
	[Marche] [int] NULL,
	[ValoreMarca] [float] NULL,
	[Ruoli] [int] NULL,
	[Dovute] [float] NULL,
	[Versato] [float] NULL,
	[Saldo] [float] NULL,
	[Not_Editable] [varchar](50) NULL,
	[idDoc] [int] NULL,
	[IdRepertorio] [int] NULL,
	[indrow] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Spese_Contratto] ADD  CONSTRAINT [DF_Document_Spese_Contratto_Not_Editable]  DEFAULT ('Marche ValoreMarca Dovute') FOR [Not_Editable]
GO
