USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TipiDati]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipiDati](
	[IdTid] [smallint] NOT NULL,
	[tidNome] [char](101) NOT NULL,
	[tidTipoMem] [tinyint] NULL,
	[tidUltimaMod] [datetime] NOT NULL,
	[tidTipoDom] [varchar](5) NOT NULL,
	[tidDeleted] [bit] NOT NULL,
	[tidSistema] [bit] NOT NULL,
	[tidOper] [bit] NOT NULL,
	[tidQuery] [text] NULL,
 CONSTRAINT [PK_TipiDati] PRIMARY KEY NONCLUSTERED 
(
	[IdTid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[TipiDati] ADD  CONSTRAINT [DF_TipiDati_tidUltimaMod]  DEFAULT (getdate()) FOR [tidUltimaMod]
GO
ALTER TABLE [dbo].[TipiDati] ADD  CONSTRAINT [DF_TipiDati_tidDeleted]  DEFAULT (0) FOR [tidDeleted]
GO
ALTER TABLE [dbo].[TipiDati] ADD  CONSTRAINT [DF_TipiDati_tidSistema]  DEFAULT (0) FOR [tidSistema]
GO
ALTER TABLE [dbo].[TipiDati] ADD  CONSTRAINT [DF__tipidati__tidOpe__0996C50E]  DEFAULT (0) FOR [tidOper]
GO
