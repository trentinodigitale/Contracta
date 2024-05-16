USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MIGR_ANAG_ENTE]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MIGR_ANAG_ENTE](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CODIPA] [varchar](255) NULL,
	[CODFISC] [varchar](255) NULL,
	[RAGSOC] [varchar](8000) NULL,
	[NATGIU] [varchar](255) NULL,
	[PIVA] [varchar](255) NULL,
	[EMAIL] [varchar](255) NULL,
	[TIPO_AMM] [varchar](255) NULL,
	[CODCAT] [varchar](255) NULL,
	[TIPO_AMM_ER_L1] [varchar](500) NULL,
	[TIPO_AMM_ER_L2] [varchar](500) NULL,
	[STRUTT] [varchar](255) NULL,
	[STATO] [varchar](255) NULL,
	[LOC] [varchar](255) NULL,
	[PROV] [varchar](255) NULL,
	[CAP] [varchar](255) NULL,
	[IND] [varchar](8000) NULL,
	[TEL] [varchar](255) NULL,
	[NOTE] [varchar](max) NOT NULL,
	[CARICATO] [smallint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[MIGR_ANAG_ENTE] ADD  CONSTRAINT [DF__MIGR_ANAG___Note__1DD989F6]  DEFAULT ('') FOR [NOTE]
GO
ALTER TABLE [dbo].[MIGR_ANAG_ENTE] ADD  CONSTRAINT [DF__MIGR_ANAG__Caric__1ECDAE2F]  DEFAULT ((1)) FOR [CARICATO]
GO
