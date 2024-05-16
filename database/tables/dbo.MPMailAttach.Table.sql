USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPMailAttach]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPMailAttach](
	[IdMpma] [int] IDENTITY(1,1) NOT NULL,
	[mpmaIdMpm] [int] NOT NULL,
	[mpmaAttachCode] [varchar](20) NOT NULL,
	[mpmaAttachOrder] [smallint] NOT NULL,
	[mpmaAttachOpt] [varchar](20) NOT NULL,
	[mpmaAttachName] [nvarchar](255) NULL,
 CONSTRAINT [PK_MPMailAttach] PRIMARY KEY CLUSTERED 
(
	[IdMpma] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPMailAttach] ADD  CONSTRAINT [DF_MPMailAttach_mpmaAttachOpt]  DEFAULT ('00000000000000000000') FOR [mpmaAttachOpt]
GO
