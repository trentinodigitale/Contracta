USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_DOC_READ]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_DOC_READ](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[DOC_NAME] [nvarchar](50) NULL,
	[id_Doc] [int] NULL,
	[idPfu] [int] NULL,
	[data] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_DOC_READ] ADD  DEFAULT (getdate()) FOR [data]
GO
