USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_LOG_UTENTE_LAVORO]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_LOG_UTENTE_LAVORO](
	[id] [int] NOT NULL,
	[ip] [nchar](100) NULL,
	[idpfu] [int] NULL,
	[datalog] [datetime] NULL,
	[paginaDiArrivo] [varchar](400) NULL,
	[paginaDiPartenza] [ntext] NULL,
	[querystring] [ntext] NULL,
	[form] [ntext] NULL,
	[browserUsato] [varchar](1000) NULL,
	[descrizione] [nvarchar](max) NULL,
	[sessionID] [ntext] NULL,
	[Fascicolo] [varchar](50) NULL,
	[Protocollo] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
