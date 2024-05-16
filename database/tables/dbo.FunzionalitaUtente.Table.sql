USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[FunzionalitaUtente]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FunzionalitaUtente](
	[IdFnzu] [int] IDENTITY(1,1) NOT NULL,
	[FnzuPadre] [int] NOT NULL,
	[FnzuFiglio] [int] NOT NULL,
	[FnzuIdMultiLng] [char](101) NOT NULL,
	[FnzuPos] [int] NOT NULL,
	[FnzuOrdine] [int] NULL,
	[FnzuProfili] [varchar](20) NULL,
	[FnzuDeleted] [bit] NOT NULL,
	[FnzuUltimaMod] [datetime] NOT NULL,
	[FnzuIType] [smallint] NOT NULL,
	[FnzuProfiloAzi] [varchar](20) NULL,
	[FnzuSource] [varchar](50) NULL,
	[FnzuIcona] [varchar](50) NULL,
	[FnzuHidden] [bit] NOT NULL,
	[FnzuISubType] [int] NOT NULL,
	[FnzuUse] [tinyint] NOT NULL,
	[FnzuIsPrimary] [bit] NOT NULL,
	[FnzuCodice] [varchar](20) NOT NULL,
	[FnzuSystem] [bit] NOT NULL,
	[FnzuUpdatePos] [bit] NOT NULL,
 CONSTRAINT [PK_FunzionalitaUtente] PRIMARY KEY NONCLUSTERED 
(
	[IdFnzu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FunzionalitaUtente] ADD  CONSTRAINT [DF_FunzionalitaUtente_FnzuDeletede]  DEFAULT (0) FOR [FnzuDeleted]
GO
ALTER TABLE [dbo].[FunzionalitaUtente] ADD  CONSTRAINT [DF_FunzionalitaUtente_FnzuUltima]  DEFAULT (getdate()) FOR [FnzuUltimaMod]
GO
ALTER TABLE [dbo].[FunzionalitaUtente] ADD  CONSTRAINT [DF_FunzionalitaUtente_FnzuHidden]  DEFAULT (0) FOR [FnzuHidden]
GO
ALTER TABLE [dbo].[FunzionalitaUtente] ADD  CONSTRAINT [DF_FunzionalitaUtente_FnzuISubType]  DEFAULT ((-1)) FOR [FnzuISubType]
GO
ALTER TABLE [dbo].[FunzionalitaUtente] ADD  CONSTRAINT [DF_FunzionalitaUtente_FnzuUse]  DEFAULT (0) FOR [FnzuUse]
GO
ALTER TABLE [dbo].[FunzionalitaUtente] ADD  CONSTRAINT [DF_FunzionalitaUtente_FnzuIsPrimary]  DEFAULT (1) FOR [FnzuIsPrimary]
GO
ALTER TABLE [dbo].[FunzionalitaUtente] ADD  CONSTRAINT [DF__Funzional__FnzuC__3A39FC69]  DEFAULT (0) FOR [FnzuCodice]
GO
ALTER TABLE [dbo].[FunzionalitaUtente] ADD  CONSTRAINT [DF__Funzional__FnzuS__4BF0FA55]  DEFAULT (0) FOR [FnzuSystem]
GO
ALTER TABLE [dbo].[FunzionalitaUtente] ADD  CONSTRAINT [DF__Funzional__FnzuU__4CE51E8E]  DEFAULT (0) FOR [FnzuUpdatePos]
GO
