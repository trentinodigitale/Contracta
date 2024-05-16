USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[document_AVCP_XML]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[document_AVCP_XML](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Ente] [int] NOT NULL,
	[Tipo_File] [nvarchar](50) NULL,
	[Anno] [nvarchar](50) NULL,
	[Oggetto] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
