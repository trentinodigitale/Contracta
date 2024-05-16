USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_E_FORM_BUFFER]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_E_FORM_BUFFER](
	[guid] [varchar](100) NOT NULL,
	[idRow] [int] NULL,
	[infoType] [varchar](100) NULL,
	[strData1] [nvarchar](500) NULL,
	[strData2] [nvarchar](500) NULL,
	[dtDate1] [datetime] NULL,
	[intData1] [int] NULL,
	[strData3] [nvarchar](500) NULL,
	[intData2] [int] NULL,
	[idRowBuffer] [int] IDENTITY(1,1) NOT NULL,
	[decimalData1] [decimal](18, 2) NULL,
	[IdProc] [int] NULL
) ON [PRIMARY]
GO
