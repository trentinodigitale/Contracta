USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[LIB_Multilinguismo]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LIB_Multilinguismo](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ML_KEY] [varchar](255) NOT NULL,
	[ML_LNG] [varchar](5) NOT NULL,
	[ML_Description] [ntext] NOT NULL,
	[ML_Context] [int] NOT NULL,
	[ML_Module] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[LIB_Multilinguismo] ADD  CONSTRAINT [DF_LIB_Multilinguismo_ML_Context]  DEFAULT (0) FOR [ML_Context]
GO
