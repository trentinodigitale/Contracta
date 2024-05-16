USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[PublicFolders]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PublicFolders](
	[IdPf] [int] IDENTITY(1,1) NOT NULL,
	[pfIdGrp] [int] NULL,
	[pfPath] [varchar](100) NULL,
	[pfIdMultiLng] [char](101) NULL,
	[pfFoglia] [bit] NOT NULL,
	[pfIdMpfc] [int] NULL,
	[pfUltimaMod] [datetime] NOT NULL,
	[pfDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_PublicFolders] PRIMARY KEY CLUSTERED 
(
	[IdPf] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PublicFolders] ADD  CONSTRAINT [DF_PublicFolders_pfuFoglia]  DEFAULT (0) FOR [pfFoglia]
GO
ALTER TABLE [dbo].[PublicFolders] ADD  CONSTRAINT [DF_PublicFolders_pfUltimaMod]  DEFAULT (getdate()) FOR [pfUltimaMod]
GO
ALTER TABLE [dbo].[PublicFolders] ADD  CONSTRAINT [DF_PublicFolders_pfDeleted]  DEFAULT (0) FOR [pfDeleted]
GO
