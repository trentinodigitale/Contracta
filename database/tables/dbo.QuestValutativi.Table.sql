USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[QuestValutativi]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuestValutativi](
	[IdQvt] [int] IDENTITY(1,1) NOT NULL,
	[qvtTipo] [tinyint] NOT NULL,
	[qvtData] [datetime] NULL,
	[qvtCompletato] [bit] NOT NULL,
 CONSTRAINT [PK_QuestValutativi] PRIMARY KEY NONCLUSTERED 
(
	[IdQvt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[QuestValutativi] ADD  CONSTRAINT [DF_QuestValutativi_qvtTipo]  DEFAULT (0) FOR [qvtTipo]
GO
ALTER TABLE [dbo].[QuestValutativi] ADD  CONSTRAINT [DF_QuestValutativi_qvtCompletato]  DEFAULT (0) FOR [qvtCompletato]
GO
