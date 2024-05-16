USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TAB_OBJ]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TAB_OBJ](
	[IdObj] [int] IDENTITY(1,1) NOT NULL,
	[objFile] [image] NULL,
	[objName] [nvarchar](250) NULL,
	[objAttachInfo] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
