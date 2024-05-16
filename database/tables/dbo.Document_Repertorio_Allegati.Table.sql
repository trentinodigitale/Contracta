USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Repertorio_Allegati]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Repertorio_Allegati](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdRepertorio] [int] NOT NULL,
	[Descrizione] [nvarchar](250) NULL,
	[Allegato] [nvarchar](250) NULL
) ON [PRIMARY]
GO
