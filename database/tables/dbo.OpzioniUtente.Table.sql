USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[OpzioniUtente]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OpzioniUtente](
	[IdOut] [int] IDENTITY(1,1) NOT NULL,
	[outNome] [varchar](40) NULL,
	[outPos] [int] NULL
) ON [PRIMARY]
GO
