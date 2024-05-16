USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Attach]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Attach](
	[ATT_IdRow] [int] IDENTITY(1,1) NOT NULL,
	[ATT_Obj] [image] NULL,
	[ATT_Hash] [nvarchar](250) NULL,
	[ATT_Size] [float] NULL,
	[ATT_Name] [nvarchar](250) NULL,
	[ATT_Type] [nvarchar](50) NULL,
	[ATT_DataInsert] [datetime] NULL,
	[URL_CLIENT] [nvarchar](500) NULL,
	[ATT_Cifrato] [int] NULL,
	[ATT_IdDoc] [int] NULL,
	[ATT_Pubblico] [int] NULL,
	[ATT_FileHash] [nvarchar](1000) NULL,
	[ATT_Deleted] [bit] NULL,
	[ATT_AlgoritmoHash] [varchar](20) NULL,
	[ATT_VerificaEstensione] [varchar](20) NULL,
 CONSTRAINT [IX_CTL_Attach_Att_IdRow] PRIMARY KEY CLUSTERED 
(
	[ATT_IdRow] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_Attach] ADD  CONSTRAINT [DF_LIB_Attach_ATT_DataInsert]  DEFAULT (getdate()) FOR [ATT_DataInsert]
GO
ALTER TABLE [dbo].[CTL_Attach] ADD  DEFAULT ((0)) FOR [ATT_Cifrato]
GO
ALTER TABLE [dbo].[CTL_Attach] ADD  DEFAULT ((0)) FOR [ATT_Pubblico]
GO
ALTER TABLE [dbo].[CTL_Attach] ADD  DEFAULT ((0)) FOR [ATT_Deleted]
GO
