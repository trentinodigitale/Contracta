USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Controlli_OE_Controlli]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Controlli_OE_Controlli](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[NomeDocumento] [nvarchar](500) NULL,
	[Allegato] [nvarchar](255) NULL,
	[DataEmissione] [datetime] NULL,
	[DataScadenza] [datetime] NULL,
	[StatoControlli] [varchar](20) NULL,
	[Motivazione] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
