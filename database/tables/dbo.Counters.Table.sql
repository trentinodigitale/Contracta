USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Counters]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Counters](
	[IdCnt] [int] IDENTITY(1,1) NOT NULL,
	[cntIdDzt] [int] NOT NULL,
	[cntIdCr] [int] NOT NULL,
	[cntStartValue] [varchar](50) NULL,
	[cntEndValue] [varchar](50) NULL,
	[cntUltimaMod] [datetime] NOT NULL,
	[cntDeleted] [bit] NOT NULL,
	[Algoritmo] [varchar](100) NULL,
 CONSTRAINT [PK_Counters] PRIMARY KEY CLUSTERED 
(
	[IdCnt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Counters] ADD  CONSTRAINT [DF_Counters_cntUltimaMod]  DEFAULT (getdate()) FOR [cntUltimaMod]
GO
ALTER TABLE [dbo].[Counters] ADD  CONSTRAINT [DF_Counters_cntDeleted]  DEFAULT (0) FOR [cntDeleted]
GO
ALTER TABLE [dbo].[Counters] ADD  DEFAULT ('') FOR [Algoritmo]
GO
ALTER TABLE [dbo].[Counters]  WITH CHECK ADD  CONSTRAINT [FK_Counters_CountersRules] FOREIGN KEY([cntIdCr])
REFERENCES [dbo].[CountersRules] ([IdCr])
GO
ALTER TABLE [dbo].[Counters] CHECK CONSTRAINT [FK_Counters_CountersRules]
GO
ALTER TABLE [dbo].[Counters]  WITH CHECK ADD  CONSTRAINT [FK_Counters_DizionarioAttributi] FOREIGN KEY([cntIdDzt])
REFERENCES [dbo].[DizionarioAttributi] ([IdDzt])
GO
ALTER TABLE [dbo].[Counters] CHECK CONSTRAINT [FK_Counters_DizionarioAttributi]
GO
