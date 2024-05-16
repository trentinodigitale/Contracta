USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DominiGerarchici]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DominiGerarchici](
	[IdDg] [int] IDENTITY(1,1) NOT NULL,
	[dgTipoGerarchia] [smallint] NOT NULL,
	[dgCodiceInterno] [varchar](30) NOT NULL,
	[dgCodiceEsterno] [varchar](30) NOT NULL,
	[dgPath] [varchar](100) NOT NULL,
	[dgLivello] [smallint] NOT NULL,
	[dgFoglia] [bit] NOT NULL,
	[dgLenPathPadre] [smallint] NOT NULL,
	[dgIdDsc] [int] NOT NULL,
	[dgDeleted] [bit] NOT NULL,
	[dgUltimaMod] [datetime] NOT NULL,
	[dgCodiceRaccordo] [varchar](20) NULL,
 CONSTRAINT [PK_DominiGerarchici] PRIMARY KEY NONCLUSTERED 
(
	[IdDg] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DominiGerarchici] ADD  CONSTRAINT [DF_DominiGerarchici_dgFoglia]  DEFAULT (0) FOR [dgFoglia]
GO
ALTER TABLE [dbo].[DominiGerarchici] ADD  CONSTRAINT [DF_DominiGerarchici_dgDeleted]  DEFAULT (0) FOR [dgDeleted]
GO
ALTER TABLE [dbo].[DominiGerarchici] ADD  CONSTRAINT [DF_DominiGerarchici_dgUltimaMod]  DEFAULT (getdate()) FOR [dgUltimaMod]
GO
ALTER TABLE [dbo].[DominiGerarchici]  WITH NOCHECK ADD  CONSTRAINT [FK_DominiGerarchici_DescsI] FOREIGN KEY([dgIdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[DominiGerarchici] CHECK CONSTRAINT [FK_DominiGerarchici_DescsI]
GO
