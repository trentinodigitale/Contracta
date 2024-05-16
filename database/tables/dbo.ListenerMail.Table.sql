USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ListenerMail]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ListenerMail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Host] [varchar](255) NOT NULL,
	[Login] [varchar](255) NOT NULL,
	[KeyMail] [varchar](255) NOT NULL,
	[From] [varchar](255) NOT NULL,
	[Subject] [varchar](max) NULL,
	[DateMail] [datetime] NULL,
	[DateElab] [datetime] NULL,
	[Process] [varchar](255) NULL,
 CONSTRAINT [PK_ListenerMail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ListenerMail] ADD  CONSTRAINT [DF_ListenerMail_DateElab]  DEFAULT (getdate()) FOR [DateElab]
GO
