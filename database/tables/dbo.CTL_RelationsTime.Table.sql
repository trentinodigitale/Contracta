USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_RelationsTime]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_RelationsTime](
	[REL_idRow] [int] IDENTITY(1,1) NOT NULL,
	[REL_Type] [varchar](50) NOT NULL,
	[REL_ValueInput] [varchar](250) NOT NULL,
	[REL_ValueOutput] [varchar](250) NOT NULL,
	[REL_Data_I] [datetime] NULL,
	[REL_Data_F] [datetime] NULL
) ON [PRIMARY]
GO
