USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TAB_AUCTION_OFFER]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TAB_AUCTION_OFFER](
	[IdAuct] [varchar](40) NOT NULL,
	[IdAzi] [int] NOT NULL,
	[auoData] [datetime] NOT NULL,
	[auoValore] [float] NOT NULL,
	[auoSigned] [image] NULL,
	[auoGridValue] [image] NULL,
	[auoGridProp] [image] NULL,
	[auoValoreParziale1] [float] NULL,
	[auoValoreParziale2] [float] NULL,
	[auoId] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAB_AUCTION_OFFER] ADD  CONSTRAINT [DF_TAB_AUCTION_OFFER_auoData]  DEFAULT (getdate()) FOR [auoData]
GO
