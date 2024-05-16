USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[StorageManager_BlobEntryModelType]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StorageManager_BlobEntryModelType](
	[id] [varchar](450) NOT NULL,
	[data] [varbinary](max) NULL,
	[creationdate] [datetime] NOT NULL,
	[filename] [varchar](max) NULL,
	[settings] [nvarchar](max) NULL,
	[uploaded] [bigint] NOT NULL,
	[size] [bigint] NOT NULL,
	[status] [int] NULL,
	[message] [varchar](max) NULL,
	[hashlist] [varchar](max) NULL,
	[pid] [varchar](max) NULL,
	[ipaddress] [varchar](max) NULL,
	[pdfhash] [varchar](max) NULL,
 CONSTRAINT [PK_StorageManager_BlobEntryModelType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
