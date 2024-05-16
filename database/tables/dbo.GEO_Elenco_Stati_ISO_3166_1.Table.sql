USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[GEO_Elenco_Stati_ISO_3166_1]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GEO_Elenco_Stati_ISO_3166_1](
	[SortOrder] [nvarchar](4000) NULL,
	[CommonName] [nvarchar](4000) NULL,
	[FormalName] [nvarchar](4000) NULL,
	[Type] [nvarchar](4000) NULL,
	[SubType] [nvarchar](4000) NULL,
	[Sovereignty] [nvarchar](4000) NULL,
	[Capital] [nvarchar](4000) NULL,
	[ISO_4217_CurrencyCode] [nvarchar](4000) NULL,
	[ISO_4217_CurrencyName] [nvarchar](4000) NULL,
	[ITU_T_TelephoneCode] [nvarchar](4000) NULL,
	[ISO_3166_1_2_LetterCode] [nvarchar](4000) NULL,
	[ISO_3166_1_3_LetterCode] [nvarchar](4000) NULL,
	[ISO_3166_1_Number] [nvarchar](4000) NULL,
	[IANA_CountryCodeTLD] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
