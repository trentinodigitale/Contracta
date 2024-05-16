USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPInheritFields]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPInheritFields](
	[IdMpIf] [int] IDENTITY(1,1) NOT NULL,
	[mpifIdMp] [int] NOT NULL,
	[mpifITypeSource] [smallint] NOT NULL,
	[mpifISubTypeSource] [smallint] NOT NULL,
	[mpifITypeDest] [smallint] NOT NULL,
	[mpifISubTypeDest] [smallint] NOT NULL,
	[mpifFieldNameSource] [varchar](30) NOT NULL,
	[mpifFieldNameDest] [varchar](30) NOT NULL,
	[mpifScript] [text] NULL,
	[mpifDeleted] [bit] NOT NULL,
	[mpifUltimaMod] [datetime] NOT NULL,
 CONSTRAINT [PK_MPInheritFields] PRIMARY KEY CLUSTERED 
(
	[IdMpIf] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPInheritFields] ADD  CONSTRAINT [DF_MPInheritFields_mpifDeleted]  DEFAULT (0) FOR [mpifDeleted]
GO
ALTER TABLE [dbo].[MPInheritFields] ADD  CONSTRAINT [DF_MPInheritFields_mpifUltimaMod]  DEFAULT (getdate()) FOR [mpifUltimaMod]
GO
