USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_dati_protocollo]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_dati_protocollo](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[aoo] [varchar](100) NULL,
	[denomAOO] [varchar](500) NULL,
	[repertorio] [varchar](100) NULL,
	[uo] [varchar](50) NULL,
	[denomUO] [varchar](500) NULL,
	[titolarioPrimario] [varchar](100) NULL,
	[titolarioSecondario] [varchar](100) NULL,
	[fascicoloSecondario] [varchar](100) NULL,
	[protocolloGeneraleSecondario] [varchar](100) NULL,
	[dataProtocolloGeneraleSecondario] [datetime] NULL,
	[NotEditable] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
