USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[StorageManager_BlobChunkEntryModelType]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StorageManager_BlobChunkEntryModelType](
	[id] [varchar](450) NOT NULL,
	[blobid] [varchar](max) NULL,
	[creationdate] [datetime] NOT NULL,
	[position] [bigint] NOT NULL,
	[data] [varbinary](max) NULL,
 CONSTRAINT [PK_StorageManager_BlobChunkEntryModelType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
