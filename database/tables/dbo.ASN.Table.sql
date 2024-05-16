USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ASN]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ASN](
	[IdAsn] [int] IDENTITY(1,1) NOT NULL,
	[asnOrderType] [varchar](20) NOT NULL,
	[asnOrderCode] [varchar](250) NOT NULL,
	[asnRowKey] [int] NOT NULL,
	[asnProtocol] [nvarchar](20) NOT NULL,
	[asnIdAziMitt] [int] NOT NULL,
	[asnIdAziDest] [int] NOT NULL,
	[asnIdMp] [int] NOT NULL,
	[asnRequestDate] [char](8) NOT NULL,
	[asnArtCode] [nvarchar](30) NOT NULL,
	[asnArtDesc] [nvarchar](3000) NULL,
	[asnTargetSite] [varchar](200) NOT NULL,
	[asnSourceSite] [varchar](200) NULL,
	[asnRequiredAmount] [float] NOT NULL,
	[asnReceivedAmount] [float] NOT NULL,
	[asnRowStatus] [varchar](20) NOT NULL,
	[asnOrderNumber] [nvarchar](20) NOT NULL,
	[asnClassMerc] [varchar](20) NULL,
	[asnDeleted] [bit] NOT NULL,
	[asnChangeStatusDate] [datetime] NOT NULL,
	[asnIdPfuMitt] [int] NOT NULL,
 CONSTRAINT [PK_ASN] PRIMARY KEY CLUSTERED 
(
	[IdAsn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ASN] ADD  CONSTRAINT [DF_ASN_asnOrderType]  DEFAULT ('1') FOR [asnOrderType]
GO
ALTER TABLE [dbo].[ASN] ADD  CONSTRAINT [DF_ASN_asnReceivedAmount]  DEFAULT (0) FOR [asnReceivedAmount]
GO
ALTER TABLE [dbo].[ASN] ADD  CONSTRAINT [DF_ASN_asnRowStatus]  DEFAULT ('0') FOR [asnRowStatus]
GO
ALTER TABLE [dbo].[ASN] ADD  CONSTRAINT [DF_ASN_asnDeleted]  DEFAULT (0) FOR [asnDeleted]
GO
ALTER TABLE [dbo].[ASN] ADD  CONSTRAINT [DF_ASN_asnChangeStatusDate]  DEFAULT (getdate()) FOR [asnChangeStatusDate]
GO
