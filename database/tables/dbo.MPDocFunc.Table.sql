USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPDocFunc]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPDocFunc](
	[IdMpDF] [int] IDENTITY(1,1) NOT NULL,
	[mpdfIdMp] [int] NOT NULL,
	[mpdfIdDcm] [int] NOT NULL,
	[mpdfFunc] [varchar](100) NOT NULL,
	[mpdfObjectType] [varchar](5) NOT NULL,
	[mpdfHide] [bit] NOT NULL,
	[mpdfIdFnzu] [int] NULL,
	[mpdfUltimaMod] [datetime] NOT NULL,
	[mpdfDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_MPDocFunc] PRIMARY KEY CLUSTERED 
(
	[IdMpDF] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPDocFunc] ADD  CONSTRAINT [DF_MPDocFunc_mpdfIdMp]  DEFAULT (0) FOR [mpdfIdMp]
GO
ALTER TABLE [dbo].[MPDocFunc] ADD  CONSTRAINT [DF_MPDocFunc_mpdfHide]  DEFAULT (0) FOR [mpdfHide]
GO
ALTER TABLE [dbo].[MPDocFunc] ADD  CONSTRAINT [DF_MPDocFunc_mpdfUltimaMod]  DEFAULT (getdate()) FOR [mpdfUltimaMod]
GO
ALTER TABLE [dbo].[MPDocFunc] ADD  CONSTRAINT [DF_MPDocFunc_mpdfDeleted]  DEFAULT (0) FOR [mpdfDeleted]
GO
