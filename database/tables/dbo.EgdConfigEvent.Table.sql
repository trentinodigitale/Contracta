USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[EgdConfigEvent]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EgdConfigEvent](
	[IdConfEvent] [int] IDENTITY(1,1) NOT NULL,
	[CeParam] [varchar](4000) NOT NULL,
	[CeValue] [varchar](4000) NOT NULL,
	[CeIdEventDoc] [int] NOT NULL,
	[CeUltimamod] [datetime] NOT NULL,
	[CeDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_ConfigEvent] PRIMARY KEY CLUSTERED 
(
	[IdConfEvent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EgdConfigEvent] ADD  CONSTRAINT [DF_ConfigEvent_CeUltimamod]  DEFAULT (getdate()) FOR [CeUltimamod]
GO
ALTER TABLE [dbo].[EgdConfigEvent] ADD  CONSTRAINT [DF_ConfigEvent_CeDeleted]  DEFAULT (0) FOR [CeDeleted]
GO
ALTER TABLE [dbo].[EgdConfigEvent]  WITH CHECK ADD  CONSTRAINT [FK_ConfigEvent_EventDoc] FOREIGN KEY([CeIdEventDoc])
REFERENCES [dbo].[EgdEventDoc] ([IdEventDoc])
GO
ALTER TABLE [dbo].[EgdConfigEvent] CHECK CONSTRAINT [FK_ConfigEvent_EventDoc]
GO
