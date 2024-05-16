USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[GARBAGE_COLLECTOR_LOG]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GARBAGE_COLLECTOR_LOG](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Elab_Key] [varchar](100) NULL,
	[Step_Descr] [varchar](300) NULL,
	[Step_Type] [varchar](20) NULL,
	[DataExec] [datetime] NULL,
	[Duration] [int] NULL
) ON [PRIMARY]
GO
