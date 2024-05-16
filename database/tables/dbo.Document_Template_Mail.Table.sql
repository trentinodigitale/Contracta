USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Template_Mail]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Template_Mail](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NULL,
	[LinguaDom] [varchar](100) NULL,
	[Template] [ntext] NULL,
	[Oggetto] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
