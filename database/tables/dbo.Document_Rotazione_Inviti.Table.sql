USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Rotazione_Inviti]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Rotazione_Inviti](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdEnte] [int] NOT NULL,
	[IdAzi] [int] NOT NULL,
	[NumeroInviti] [int] NOT NULL,
	[TipoAppalto] [varchar](50) NOT NULL,
	[DataUltimaModifica] [datetime] NOT NULL
) ON [PRIMARY]
GO
