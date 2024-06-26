USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_TED_Aggiudicatari]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_TED_Aggiudicatari](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[idDoc] [int] NULL,
	[TED_AWARDED_IS_SME] [varchar](10) NULL,
	[TED_NATIONALID] [nvarchar](1000) NULL,
	[TED_NUTS] [nvarchar](100) NULL,
	[TED_E_MAIL] [nvarchar](500) NULL,
	[TED_PHONE] [nvarchar](200) NULL,
	[TED_URL] [nvarchar](2000) NULL,
	[TED_FAX] [nvarchar](200) NULL,
	[TED_AZIRAGIONESOCIALE] [nvarchar](1000) NULL,
	[TED_AZIINDIRIZZOLEG] [nvarchar](80) NULL
) ON [PRIMARY]
GO
