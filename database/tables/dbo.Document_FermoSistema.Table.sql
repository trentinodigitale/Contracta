USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_FermoSistema]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_FermoSistema](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[DataInizio] [datetime] NULL,
	[DataFine] [datetime] NULL,
	[DataComunicazione] [datetime] NULL,
	[DataAnnullamento] [datetime] NULL,
	[DataSysMsgDA] [datetime] NULL,
	[DataAvvisoDal] [datetime] NULL,
	[DataAvvisoAl] [datetime] NULL,
	[Fermo_Avviso] [varchar](20) NULL
) ON [PRIMARY]
GO
