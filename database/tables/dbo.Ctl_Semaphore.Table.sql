USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Ctl_Semaphore]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ctl_Semaphore](
	[Name] [varchar](500) NOT NULL,
	[OwnerGuid] [varchar](100) NOT NULL,
	[CreationDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Ctl_Semaphore] PRIMARY KEY CLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Ctl_Semaphore] ADD  CONSTRAINT [DF_Ctl_Semaphore_CreationDate]  DEFAULT (getdate()) FOR [CreationDate]
GO
