USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Ctl_Event_Log_Report]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ctl_Event_Log_Report](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Messaggio] [nvarchar](4000) NULL,
	[Hash_Messaggio] [nvarchar](255) NULL,
	[TipologiaErrore] [varchar](1000) NULL,
	[Num_U3Mesi] [int] NULL,
	[Num_UMese] [int] NULL,
	[Num_USettimana] [int] NULL,
	[Num_Oggi] [int] NULL
) ON [PRIMARY]
GO
