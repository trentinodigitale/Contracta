USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ListenerMail_Queue]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ListenerMail_Queue](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Host] [varchar](255) NOT NULL,
	[KeyMail] [varchar](255) NOT NULL,
	[Process] [varchar](255) NULL,
 CONSTRAINT [PK_ListenerMail_Queue] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
