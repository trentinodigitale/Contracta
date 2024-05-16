USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_EsitoGara_Allegati]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_EsitoGara_Allegati](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[Data] [datetime] NULL,
	[Descrizione] [varchar](1000) NULL,
	[Attach] [nvarchar](255) NULL
) ON [PRIMARY]
GO
