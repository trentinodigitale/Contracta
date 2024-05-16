USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Macro_Convenzione]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Macro_Convenzione](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ID_CONVENZIONE] [int] NULL,
	[DESCRIZIONE_CONVENZIONE] [nvarchar](500) NULL,
	[CONVENZIONE_MADRE] [nvarchar](500) NULL,
	[GARA] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
