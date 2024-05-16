USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[LingueAttivabili]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LingueAttivabili](
	[laSuffix] [varchar](5) NOT NULL,
	[laDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_LingueAttivabili] PRIMARY KEY CLUSTERED 
(
	[laSuffix] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LingueAttivabili] ADD  CONSTRAINT [DF_LingueAttivabili_Deleted]  DEFAULT (0) FOR [laDeleted]
GO
