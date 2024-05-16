USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_AVCP_CONFIG]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_AVCP_CONFIG](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idheader] [int] NULL,
	[URL_CLIENT] [nvarchar](1000) NULL,
	[FileNameIndice] [varchar](100) NULL,
	[PercorsoDiRete] [varchar](1000) NULL,
	[FTP] [nvarchar](1000) NULL,
	[Porta] [int] NULL,
	[Login] [varchar](100) NULL,
	[PasswordFtp] [nvarchar](250) NULL,
	[Metodo] [varchar](50) NULL
) ON [PRIMARY]
GO
