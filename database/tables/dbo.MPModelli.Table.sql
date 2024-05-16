USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPModelli]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPModelli](
	[IdMpMod] [int] IDENTITY(1,1) NOT NULL,
	[mpmIdMp] [int] NOT NULL,
	[mpmDesc] [varchar](500) NOT NULL,
	[mpmTipo] [tinyint] NOT NULL,
	[mpmidmpmodvisual] [int] NULL,
	[mpmDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_MpModelli] PRIMARY KEY NONCLUSTERED 
(
	[IdMpMod] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPModelli] ADD  CONSTRAINT [DF_MpModelli_MdlTipo]  DEFAULT (0) FOR [mpmTipo]
GO
ALTER TABLE [dbo].[MPModelli] ADD  CONSTRAINT [DF_MPModelli_mpmDeleted]  DEFAULT (0) FOR [mpmDeleted]
GO
