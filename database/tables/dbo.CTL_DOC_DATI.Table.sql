USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_DOC_DATI]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_DOC_DATI](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[CDD_Field] [varchar](50) NULL,
	[CDD_Riga] [int] NULL,
	[CDD_Value] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
