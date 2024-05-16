USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_COM_DPE_Allegati_Protocollo]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_COM_DPE_Allegati_Protocollo](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NULL,
	[DSE_ID] [nvarchar](50) NULL,
	[Row] [int] NULL,
	[DZT_Name] [varchar](50) NULL,
	[Value] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
