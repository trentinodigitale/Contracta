USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[PEG]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PEG](
	[CodProgramma] [varchar](100) NULL,
	[CodProgetto] [varchar](100) NULL,
	[ProPro] [varchar](1000) NULL,
	[Programma] [varchar](1000) NULL,
	[Cdr_Responsabile] [varchar](1000) NULL,
	[Progetto] [varchar](1000) NULL,
	[PEG_Email] [nvarchar](50) NULL,
	[Deleted] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEG] ADD  DEFAULT (0) FOR [Deleted]
GO
