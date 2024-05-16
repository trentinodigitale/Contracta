USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DBVersion]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DBVersion](
	[dbvModule] [varchar](50) NOT NULL,
	[dbvRelease] [varchar](20) NOT NULL,
	[dbvFatRelease] [varchar](150) NULL,
	[dbvLastUpdate] [datetime] NOT NULL,
 CONSTRAINT [PK_DBVersion] PRIMARY KEY CLUSTERED 
(
	[dbvModule] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DBVersion] ADD  CONSTRAINT [DF_DBVersion_dbvLastUpdate]  DEFAULT (getdate()) FOR [dbvLastUpdate]
GO
