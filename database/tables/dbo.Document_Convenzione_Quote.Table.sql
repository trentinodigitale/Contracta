USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Convenzione_Quote]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Convenzione_Quote](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[Importo] [float] NULL,
	[ImportoRichiesto] [float] NULL,
	[Value_tec__Azi] [nvarchar](50) NULL,
	[Motivazione] [ntext] NULL,
	[Importo_Allocato_Prec] [float] NULL,
	[datascadenzaQ] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
