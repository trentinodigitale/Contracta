USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_TED_AMMINISTRAZIONE]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_TED_AMMINISTRAZIONE](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[TED_OFFICIALNAME] [nvarchar](500) NULL,
	[TED_NATIONALID] [varchar](100) NULL,
	[TED_ADDRESS] [nvarchar](500) NULL,
	[TED_TOWN] [nvarchar](200) NULL,
	[TED_NUTS] [varchar](50) NULL,
	[TED_POSTAL_CODE] [varchar](20) NULL,
	[TED_COUNTRY] [varchar](5) NULL,
	[TED_CONTACT_POINT] [nvarchar](500) NULL,
	[TED_PHONE] [nvarchar](100) NULL,
	[TED_FAX] [nvarchar](100) NULL,
	[TED_E_MAIL] [nvarchar](500) NULL,
	[TED_URL_GENERAL] [nvarchar](500) NULL,
	[TED_URL_BUYER] [nvarchar](500) NULL
) ON [PRIMARY]
GO
