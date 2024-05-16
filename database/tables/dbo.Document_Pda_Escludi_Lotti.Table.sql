USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Pda_Escludi_Lotti]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Pda_Escludi_Lotti](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[NumeroLotto] [varchar](50) NULL,
	[CIG] [nvarchar](50) NULL,
	[Descrizione] [nvarchar](1000) NULL,
	[StatoLotto] [varchar](20) NULL,
	[Motivazione] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
