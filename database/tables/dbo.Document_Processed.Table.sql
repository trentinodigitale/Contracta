USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Processed]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Processed](
	[iType] [int] NOT NULL,
	[iSubType] [int] NOT NULL,
	[idMsg] [int] NOT NULL,
	[Esito] [tinyint] NOT NULL,
 CONSTRAINT [PK_DOCUMENT_PROCESSED] PRIMARY KEY CLUSTERED 
(
	[iType] ASC,
	[iSubType] ASC,
	[idMsg] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Processed] ADD  CONSTRAINT [DF_DOCUMENT_PROCESSED_Esito]  DEFAULT (0) FOR [Esito]
GO
