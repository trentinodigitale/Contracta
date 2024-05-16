USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[document_ofo_attach]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[document_ofo_attach](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[OrderAttachmentId] [varchar](500) NULL,
	[MnemonicId] [varchar](500) NULL,
	[Attachment] [nvarchar](max) NULL,
	[Attach_Description] [nvarchar](max) NULL,
	[Name] [nvarchar](max) NULL,
	[Date] [datetime] NULL,
	[AttachmentId] [varchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
