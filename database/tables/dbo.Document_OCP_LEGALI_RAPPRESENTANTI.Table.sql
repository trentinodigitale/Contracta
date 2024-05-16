USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_OCP_LEGALI_RAPPRESENTANTI]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_OCP_LEGALI_RAPPRESENTANTI](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[idAzi] [int] NULL,
	[CFTIM] [varchar](100) NULL,
	[COGTIM] [nvarchar](1000) NULL,
	[NOMETIM] [nvarchar](1000) NULL,
	[datiOK] [int] NULL,
	[esitoRI] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
