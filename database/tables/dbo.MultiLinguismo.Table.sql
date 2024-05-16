USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MultiLinguismo]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MultiLinguismo](
	[IdMultiLng] [char](101) NOT NULL,
	[mlngDesc_I] [ntext] NULL,
	[mlngDesc_UK] [ntext] NULL,
	[mlngDesc_E] [ntext] NULL,
	[mlngUltimaMod] [datetime] NOT NULL,
	[mlngCancellato] [bit] NOT NULL,
	[multi_identity] [int] IDENTITY(1,1) NOT NULL,
	[mlngdesc_FRA] [ntext] NULL,
	[mlngSistema] [bit] NOT NULL,
	[mlngDesc_Lng1] [ntext] NULL,
	[mlngDesc_Lng2] [ntext] NULL,
	[mlngDesc_Lng3] [ntext] NULL,
	[mlngDesc_Lng4] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[MultiLinguismo] ADD  CONSTRAINT [DF_MultiLinguismo_mlngUltimaMod]  DEFAULT (getdate()) FOR [mlngUltimaMod]
GO
ALTER TABLE [dbo].[MultiLinguismo] ADD  CONSTRAINT [DF_MultiLinguismo_mlngCancellato]  DEFAULT (0) FOR [mlngCancellato]
GO
ALTER TABLE [dbo].[MultiLinguismo] ADD  CONSTRAINT [DF_MultiLinguismo_mlngSistema]  DEFAULT (0) FOR [mlngSistema]
GO
