USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[EgdEventDoc]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EgdEventDoc](
	[IdEventDoc] [int] IDENTITY(1,1) NOT NULL,
	[EdIDocType] [int] NOT NULL,
	[EdIDocsubType] [int] NOT NULL,
	[EdSez] [varchar](50) NULL,
	[EdSort] [int] NOT NULL,
	[EdIdHae] [int] NOT NULL,
	[EdUltimaMod] [datetime] NOT NULL,
	[EdDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_EventDoc] PRIMARY KEY CLUSTERED 
(
	[IdEventDoc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EgdEventDoc] ADD  CONSTRAINT [DF_EventDoc_EdUltimaMod]  DEFAULT (getdate()) FOR [EdUltimaMod]
GO
ALTER TABLE [dbo].[EgdEventDoc] ADD  CONSTRAINT [DF_EventDoc_EdDeleted]  DEFAULT (0) FOR [EdDeleted]
GO
ALTER TABLE [dbo].[EgdEventDoc]  WITH CHECK ADD  CONSTRAINT [FK_EventDoc_HandlerAnagEvent] FOREIGN KEY([EdIdHae])
REFERENCES [dbo].[EgdHandlerAnagEvent] ([IdHae])
GO
ALTER TABLE [dbo].[EgdEventDoc] CHECK CONSTRAINT [FK_EventDoc_HandlerAnagEvent]
GO
