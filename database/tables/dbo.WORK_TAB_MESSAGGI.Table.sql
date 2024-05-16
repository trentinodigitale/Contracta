USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[WORK_TAB_MESSAGGI]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WORK_TAB_MESSAGGI](
	[IdMsg] [int] IDENTITY(1,1) NOT NULL,
	[msgText] [ntext] NULL,
	[msgDataIns] [datetime] NOT NULL,
	[msgElabWithSuccess] [smallint] NOT NULL,
	[msgiType] [smallint] NULL,
	[msgPriorita] [smallint] NOT NULL,
	[msgIdMp] [int] NOT NULL,
	[msgIdCDO] [varchar](100) NULL,
	[msgiSubType] [smallint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[WORK_TAB_MESSAGGI] ADD  CONSTRAINT [DF_WORK_TAB_MESSAGGI_DataIns]  DEFAULT (getdate()) FOR [msgDataIns]
GO
ALTER TABLE [dbo].[WORK_TAB_MESSAGGI] ADD  CONSTRAINT [DF_WORK_TAB_MESSAGGI_ElabWithSuccess]  DEFAULT ((-1)) FOR [msgElabWithSuccess]
GO
ALTER TABLE [dbo].[WORK_TAB_MESSAGGI] ADD  CONSTRAINT [DF_WORK_TAB_MESSAGGI_iPriorita]  DEFAULT (0) FOR [msgPriorita]
GO
ALTER TABLE [dbo].[WORK_TAB_MESSAGGI] ADD  CONSTRAINT [DF_WORK_TAB_MESSAGGI_magIdCDO]  DEFAULT ('') FOR [msgIdCDO]
GO
ALTER TABLE [dbo].[WORK_TAB_MESSAGGI] ADD  CONSTRAINT [DF_TWORK_AB_MESSAGGI_msgiSubType]  DEFAULT ((-1)) FOR [msgiSubType]
GO
