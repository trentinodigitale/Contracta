USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_LOG_UTENTE_STORICO_CONSERVAZIONE]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_LOG_UTENTE_STORICO_CONSERVAZIONE](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NULL,
	[Input] [ntext] NULL,
	[AltroInput] [ntext] NULL,
	[Output] [ntext] NULL,
	[DataElab] [datetime] NULL,
	[Esito] [tinyint] NULL,
	[DescrizioneEsito] [nvarchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_LOG_UTENTE_STORICO_CONSERVAZIONE] ADD  CONSTRAINT [DF_CTL_LOG_UTENTE_STORICO_CONSERVAZIONE_DataElab]  DEFAULT (getdate()) FOR [DataElab]
GO
