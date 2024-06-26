USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Multilinguismo]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Multilinguismo](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ML_KEY] [nvarchar](800) NULL,
	[ML_LNG] [varchar](5) NOT NULL,
	[ML_Description] [nvarchar](max) NOT NULL,
	[ML_Context] [int] NOT NULL,
	[ML_Module] [varchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_Multilinguismo] ADD  DEFAULT ((0)) FOR [ML_Context]
GO
