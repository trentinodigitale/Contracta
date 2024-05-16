USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_TrustServiceList]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_TrustServiceList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[CertificateName] [varchar](1000) NULL,
	[FullServiceName] [varchar](4000) NULL,
	[StatusStartingTime] [datetime] NULL,
	[StatusEndTime] [datetime] NULL,
	[X509CertificateBase64] [varchar](8000) NULL,
	[TSLSequenceNumber] [int] NULL,
	[TSLVersionIdentifier] [int] NULL,
	[deleted] [tinyint] NULL,
	[dataInserimento] [datetime] NOT NULL,
	[dataAggiornamento] [datetime] NULL,
	[CountryName] [varchar](20) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_TrustServiceList] ADD  CONSTRAINT [DF_CTL_TrustServiceList_dataInserimento]  DEFAULT (getdate()) FOR [dataInserimento]
GO
