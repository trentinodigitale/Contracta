USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_DECRYPT_ATTACH]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_DECRYPT_ATTACH](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[keyFile] [varbinary](4000) NOT NULL,
	[idX] [int] NOT NULL
) ON [PRIMARY]
GO
