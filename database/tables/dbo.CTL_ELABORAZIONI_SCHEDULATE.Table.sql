USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_ELABORAZIONI_SCHEDULATE]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_ELABORAZIONI_SCHEDULATE](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdDoc] [int] NOT NULL,
	[TipoDoc] [varchar](50) NOT NULL,
	[Idpfu] [int] NOT NULL,
	[Azienda] [int] NOT NULL,
	[Titolo] [nvarchar](500) NOT NULL,
	[DataInizio] [datetime] NOT NULL,
	[PercAvanzamento] [int] NOT NULL,
	[Deleted] [smallint] NOT NULL,
	[StatoFunzionale] [varchar](50) NOT NULL,
	[DataUltimaElaborazione] [datetime] NULL,
	[DPR_DOC_ID] [varchar](200) NOT NULL,
	[DPR_ID] [nvarchar](200) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_ELABORAZIONI_SCHEDULATE] ADD  CONSTRAINT [DF_CTL_ELABORAZIONI_SCHEDULATE_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
