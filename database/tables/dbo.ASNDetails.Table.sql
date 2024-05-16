USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ASNDetails]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ASNDetails](
	[IdAd] [int] IDENTITY(1,1) NOT NULL,
	[adIdAsn] [int] NOT NULL,
	[adProg] [int] NOT NULL,
	[adIdPs] [tinyint] NOT NULL,
	[adBillNumber] [int] NULL,
	[adInDate] [char](8) NULL,
	[adInTime] [char](6) NULL,
	[adProductType] [varchar](20) NULL,
	[adReceivedAmount] [float] NULL,
	[adFlagSA] [varchar](20) NULL,
	[adOperationDate] [char](8) NULL,
	[adReturnAmount] [float] NULL,
	[adQTSum] [float] NOT NULL,
	[adChangeStatusDate] [datetime] NOT NULL,
	[adIdPfu] [int] NULL,
	[adDeleted] [bit] NOT NULL,
	[adNote] [ntext] NULL,
	[adVal] [varchar](20) NULL,
	[adPrice] [float] NULL,
 CONSTRAINT [PK_ASNDetails] PRIMARY KEY CLUSTERED 
(
	[IdAd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ASNDetails] ADD  CONSTRAINT [DF_ASNDetails_adChangeStatusDate]  DEFAULT (getdate()) FOR [adChangeStatusDate]
GO
ALTER TABLE [dbo].[ASNDetails] ADD  CONSTRAINT [DF_ASNDetails_adDeleted]  DEFAULT (0) FOR [adDeleted]
GO
ALTER TABLE [dbo].[ASNDetails] ADD  CONSTRAINT [DF__asnDetail__adPri__73F0D15B]  DEFAULT (0) FOR [adPrice]
GO
ALTER TABLE [dbo].[ASNDetails]  WITH CHECK ADD  CONSTRAINT [FK_ASNDetails_ASN] FOREIGN KEY([adIdAsn])
REFERENCES [dbo].[ASN] ([IdAsn])
GO
ALTER TABLE [dbo].[ASNDetails] CHECK CONSTRAINT [FK_ASNDetails_ASN]
GO
ALTER TABLE [dbo].[ASNDetails]  WITH CHECK ADD  CONSTRAINT [FK_ASNDetails_ProductStatus] FOREIGN KEY([adIdPs])
REFERENCES [dbo].[ProductStatus] ([IdPs])
GO
ALTER TABLE [dbo].[ASNDetails] CHECK CONSTRAINT [FK_ASNDetails_ProductStatus]
GO
