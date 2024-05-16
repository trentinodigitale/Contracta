USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[LIB_DocumentSections]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LIB_DocumentSections](
	[DSE_idRow] [int] IDENTITY(1,1) NOT NULL,
	[DSE_DOC_ID] [nvarchar](50) NULL,
	[DSE_ID] [nvarchar](50) NULL,
	[DSE_DescML] [nvarchar](50) NULL,
	[DSE_MOD_ID] [nvarchar](50) NULL,
	[DES_LFN_GroupFunction] [nvarchar](200) NULL,
	[DES_PosPermission] [int] NULL,
	[DES_Table] [nvarchar](50) NULL,
	[DES_FieldIdDoc] [nvarchar](50) NULL,
	[DES_FieldIdRow] [nvarchar](150) NULL,
	[DES_TableFilter] [varchar](600) NULL,
	[DES_ProgID] [nvarchar](50) NULL,
	[DSE_Param] [ntext] NULL,
	[DES_Order] [int] NULL,
	[DES_Module] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
