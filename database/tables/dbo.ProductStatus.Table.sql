USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ProductStatus]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductStatus](
	[IdPs] [tinyint] NOT NULL,
	[psIdMultilng] [char](101) NOT NULL,
	[psOrder] [tinyint] NOT NULL,
	[psNextStatus] [char](20) NOT NULL,
	[psProfile] [varchar](10) NULL,
	[psIdMpMod] [int] NULL,
	[psStatus] [char](1) NOT NULL,
 CONSTRAINT [PK_ProductStatus] PRIMARY KEY CLUSTERED 
(
	[IdPs] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductStatus] ADD  CONSTRAINT [DF_ProductStatus_psNextStatus]  DEFAULT ('00000000000000000000') FOR [psNextStatus]
GO
