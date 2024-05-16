USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Documents]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Documents](
	[DOC_idRow] [int] IDENTITY(1,1) NOT NULL,
	[DOC_ID] [nvarchar](50) NULL,
	[DOC_DescML] [nvarchar](50) NULL,
	[DOC_Table] [nvarchar](50) NULL,
	[DOC_FieldID] [nvarchar](50) NULL,
	[DOC_LFN_GroupFunction] [nvarchar](50) NULL,
	[DOC_ProgIdCustomizer] [nvarchar](50) NULL,
	[DOC_Help] [nvarchar](50) NULL,
	[DOC_Param] [nvarchar](max) NULL,
	[DOC_Module] [nvarchar](50) NULL,
	[DOC_DocPermission] [varchar](50) NULL,
	[DOC_PosPermission] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_Documents] ADD  CONSTRAINT [DF_CTL_Documents_dcmDocPermission]  DEFAULT ('') FOR [DOC_DocPermission]
GO
