USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_LOG_UTENTE]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_LOG_UTENTE](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ip] [varchar](100) NULL,
	[idpfu] [int] NULL,
	[datalog] [datetime] NULL,
	[paginaDiArrivo] [varchar](400) NULL,
	[paginaDiPartenza] [varchar](4000) NULL,
	[querystring] [varchar](4000) NULL,
	[form] [ntext] NULL,
	[browserUsato] [varchar](1000) NULL,
	[descrizione] [varchar](4000) NULL,
	[sessionID] [varchar](4000) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_LOG_UTENTE] ADD  CONSTRAINT [DF_CTL_LOG_UTENTE_datalog]  DEFAULT (getdate()) FOR [datalog]
GO
