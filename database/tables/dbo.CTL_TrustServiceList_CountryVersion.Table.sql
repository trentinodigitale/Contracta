USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_TrustServiceList_CountryVersion]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_TrustServiceList_CountryVersion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CountryName] [varchar](20) NULL,
	[Version] [int] NULL,
	[LastSequenceNumber] [int] NULL,
	[DateLastElab] [datetime] NULL,
	[CertifiersNumbers] [int] NULL,
	[Url] [varchar](max) NULL,
	[AlternativeUrl] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_TrustServiceList_CountryVersion] ADD  CONSTRAINT [DF_CTL_TrustServiceList_CountryVersion_DateLastElab]  DEFAULT (getdate()) FOR [DateLastElab]
GO
