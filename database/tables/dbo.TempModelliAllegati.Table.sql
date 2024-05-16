USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempModelliAllegati]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempModelliAllegati](
	[magIdMdl] [int] NOT NULL,
	[magIdMgr] [int] NOT NULL,
	[magNome] [nvarchar](20) NOT NULL,
	[magAllegato] [image] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
