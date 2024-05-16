USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Srv_UltimaMod]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Srv_UltimaMod](
	[IdUmd] [int] NOT NULL,
	[umdNome] [nvarchar](128) NULL,
	[umdUltimaMod] [datetime] NOT NULL,
	[umdSistema] [bit] NOT NULL,
	[umdUtente] [bit] NOT NULL,
	[umdCaching] [bit] NOT NULL,
	[umdNomeStored] [nvarchar](128) NULL,
	[umdLingua] [bit] NOT NULL,
	[umdProfili] [varchar](20) NULL,
 CONSTRAINT [PK_Srv_UltimaMod] PRIMARY KEY NONCLUSTERED 
(
	[IdUmd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Srv_UltimaMod] ADD  CONSTRAINT [DF_Srv_UltimaMod_umdUltimaMod]  DEFAULT (getdate()) FOR [umdUltimaMod]
GO
ALTER TABLE [dbo].[Srv_UltimaMod] ADD  CONSTRAINT [DF_Srv_UltimaMod_umdSistema]  DEFAULT (0) FOR [umdSistema]
GO
ALTER TABLE [dbo].[Srv_UltimaMod] ADD  CONSTRAINT [DF_Srv_UltimaMod_umdUtente]  DEFAULT (0) FOR [umdUtente]
GO
ALTER TABLE [dbo].[Srv_UltimaMod] ADD  CONSTRAINT [DF_Srv_UltimaMod_umdCaching]  DEFAULT (0) FOR [umdCaching]
GO
ALTER TABLE [dbo].[Srv_UltimaMod] ADD  CONSTRAINT [DF_Srv_UltimaMod_umdLingua]  DEFAULT (0) FOR [umdLingua]
GO
