USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_LOG_UTENTE_STORICO]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_LOG_UTENTE_STORICO](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idRowStart] [int] NULL,
	[idRowEnd] [int] NULL,
	[datalogStart] [datetime] NULL,
	[datalogEnd] [datetime] NULL,
	[dataElabStart] [datetime] NULL,
	[dataElabEnd] [datetime] NULL,
	[pathFile] [varchar](400) NULL,
	[NumFiles] [int] NULL,
	[ProgFile] [int] NULL,
	[OraInizio] [varchar](20) NULL,
	[OraFine] [varchar](20) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_LOG_UTENTE_STORICO] ADD  DEFAULT ((1)) FOR [NumFiles]
GO
ALTER TABLE [dbo].[CTL_LOG_UTENTE_STORICO] ADD  DEFAULT ((1)) FOR [ProgFile]
GO
ALTER TABLE [dbo].[CTL_LOG_UTENTE_STORICO] ADD  DEFAULT ('') FOR [OraInizio]
GO
ALTER TABLE [dbo].[CTL_LOG_UTENTE_STORICO] ADD  DEFAULT ('') FOR [OraFine]
GO
