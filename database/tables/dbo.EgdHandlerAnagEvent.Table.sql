USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[EgdHandlerAnagEvent]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EgdHandlerAnagEvent](
	[IdHae] [int] IDENTITY(1,1) NOT NULL,
	[HaeName] [varchar](200) NOT NULL,
	[HaeProgIdWeb] [varchar](50) NULL,
	[HaeProgIdFat] [varchar](50) NULL,
	[HaeDescr] [varchar](101) NULL,
	[HaeIdEvent] [int] NOT NULL,
	[HaeUltimaMod] [datetime] NOT NULL,
	[HaeDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_HandlerAnagEvent] PRIMARY KEY CLUSTERED 
(
	[IdHae] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EgdHandlerAnagEvent] ADD  CONSTRAINT [DF_HandlerAnagEvent_HaeUltimaMod]  DEFAULT (getdate()) FOR [HaeUltimaMod]
GO
ALTER TABLE [dbo].[EgdHandlerAnagEvent] ADD  CONSTRAINT [DF_HandlerAnagEvent_HaeDeleted]  DEFAULT (0) FOR [HaeDeleted]
GO
ALTER TABLE [dbo].[EgdHandlerAnagEvent]  WITH CHECK ADD  CONSTRAINT [FK_HandlerAnagEvent_Eventi] FOREIGN KEY([HaeIdEvent])
REFERENCES [dbo].[EgdEvent] ([IdEvent])
GO
ALTER TABLE [dbo].[EgdHandlerAnagEvent] CHECK CONSTRAINT [FK_HandlerAnagEvent_Eventi]
GO
