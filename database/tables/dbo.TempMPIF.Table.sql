USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempMPIF]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempMPIF](
	[IdMpIf] [int] IDENTITY(1,1) NOT NULL,
	[mpifIdMp] [int] NOT NULL,
	[mpifITypeSource] [smallint] NOT NULL,
	[mpifISubTypeSource] [smallint] NOT NULL,
	[mpifITypeDest] [smallint] NOT NULL,
	[mpifISubTypeDest] [smallint] NOT NULL,
	[mpifFieldNameSource] [varchar](30) NOT NULL,
	[mpifFieldNameDest] [varchar](30) NOT NULL
) ON [PRIMARY]
GO
