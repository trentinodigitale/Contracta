USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPCounters]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPCounters](
	[IdMpc] [int] IDENTITY(1,1) NOT NULL,
	[mpcIdMp] [int] NOT NULL,
	[mpcIdCnt] [int] NOT NULL,
 CONSTRAINT [PK_MPCounters] PRIMARY KEY CLUSTERED 
(
	[IdMpc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPCounters]  WITH CHECK ADD  CONSTRAINT [FK_MPCounters_Counters] FOREIGN KEY([mpcIdCnt])
REFERENCES [dbo].[Counters] ([IdCnt])
GO
ALTER TABLE [dbo].[MPCounters] CHECK CONSTRAINT [FK_MPCounters_Counters]
GO
ALTER TABLE [dbo].[MPCounters]  WITH CHECK ADD  CONSTRAINT [FK_MPCounters_MarketPlace] FOREIGN KEY([mpcIdMp])
REFERENCES [dbo].[MarketPlace] ([IdMp])
GO
ALTER TABLE [dbo].[MPCounters] CHECK CONSTRAINT [FK_MPCounters_MarketPlace]
GO
