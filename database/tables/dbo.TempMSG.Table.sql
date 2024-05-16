USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempMSG]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempMSG](
	[IdPfu] [int] NULL,
	[IdMsg] [int] NULL,
	[Obj] [image] NULL,
	[FileName] [nvarchar](250) NULL,
	[OrderFile] [int] NULL,
	[AttachInfo] [text] NULL,
	[IdObj] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
