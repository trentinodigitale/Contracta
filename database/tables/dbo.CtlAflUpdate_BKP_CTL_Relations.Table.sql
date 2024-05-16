USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CtlAflUpdate_BKP_CTL_Relations]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CtlAflUpdate_BKP_CTL_Relations](
	[REL_idRow] [int] IDENTITY(1,1) NOT NULL,
	[REL_Type] [varchar](50) NOT NULL,
	[REL_ValueInput] [varchar](250) NOT NULL,
	[REL_ValueOutput] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
