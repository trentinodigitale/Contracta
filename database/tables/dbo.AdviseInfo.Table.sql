USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[AdviseInfo]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AdviseInfo](
	[IdAi] [int] IDENTITY(1,1) NOT NULL,
	[aiIdDi] [int] NOT NULL,
	[aiName] [varchar](50) NOT NULL,
	[aiDescription] [char](101) NOT NULL,
	[aiFieldName] [varchar](50) NOT NULL,
	[aiCommand] [varchar](50) NULL,
	[aiCommandParam] [varchar](50) NULL,
	[aiPriority] [tinyint] NOT NULL,
	[aiRegKey] [varchar](255) NULL,
	[aiContext] [tinyint] NOT NULL,
	[aiModifiable] [bit] NOT NULL,
	[aiText] [text] NOT NULL,
	[aiStatusValue] [tinyint] NOT NULL,
	[aiStatusDescription] [char](101) NOT NULL,
	[aiRequiredFromSender] [bit] NOT NULL,
	[aiDeleted] [bit] NOT NULL,
	[aiUltimaMod] [datetime] NOT NULL,
 CONSTRAINT [PK_AdviseInfo] PRIMARY KEY CLUSTERED 
(
	[IdAi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AdviseInfo] ADD  CONSTRAINT [DF_AdviseInfo_aiModifiable]  DEFAULT (0) FOR [aiModifiable]
GO
ALTER TABLE [dbo].[AdviseInfo] ADD  CONSTRAINT [DF_AdviseInfo_aiRequiredFromSender]  DEFAULT (0) FOR [aiRequiredFromSender]
GO
ALTER TABLE [dbo].[AdviseInfo] ADD  CONSTRAINT [DF_AdviseInfo_aiDeleted]  DEFAULT (0) FOR [aiDeleted]
GO
ALTER TABLE [dbo].[AdviseInfo] ADD  CONSTRAINT [DF_AdviseInfo_aiUltimaMod]  DEFAULT (getdate()) FOR [aiUltimaMod]
GO
ALTER TABLE [dbo].[AdviseInfo]  WITH CHECK ADD  CONSTRAINT [FK_AdviseInfo_DocumentInfo] FOREIGN KEY([aiIdDi])
REFERENCES [dbo].[DocumentInfo] ([IdDi])
GO
ALTER TABLE [dbo].[AdviseInfo] CHECK CONSTRAINT [FK_AdviseInfo_DocumentInfo]
GO
