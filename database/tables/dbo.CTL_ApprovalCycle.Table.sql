USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_ApprovalCycle]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_ApprovalCycle](
	[APC_ID_ROW] [int] IDENTITY(1,1) NOT NULL,
	[APC_Doc_Type] [varchar](50) NOT NULL,
	[APC_Value] [varchar](50) NOT NULL,
	[APC_Cod_Node] [varchar](50) NOT NULL,
	[APC_Path] [varchar](8000) NOT NULL,
	[APC_Level] [tinyint] NOT NULL,
	[APC_Expression] [text] NULL,
	[APC_Doc_State] [varchar](20) NULL,
	[APC_Need] [nchar](1) NULL,
 CONSTRAINT [PK_CTL_ApprovalCycle] PRIMARY KEY CLUSTERED 
(
	[APC_ID_ROW] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
