USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_LOG_PROC]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_LOG_PROC](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[DOC_NAME] [varchar](50) NULL,
	[PROC_NAME] [varchar](50) NULL,
	[id_Doc] [varchar](50) NULL,
	[idPfu] [int] NULL,
	[Parametri] [nvarchar](1000) NULL,
	[data] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_LOG_PROC] ADD  CONSTRAINT [DF_CTL_LOG_PROC_data]  DEFAULT (getdate()) FOR [data]
GO
