USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TAB_AUCTION]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TAB_AUCTION](
	[IdAuct] [varchar](40) NOT NULL,
	[aucStatus] [tinyint] NOT NULL,
	[aucImporto] [float] NOT NULL,
	[aucValuta] [varchar](20) NOT NULL,
	[aucDataIni] [datetime] NOT NULL,
	[aucDataScad] [datetime] NOT NULL,
	[aucRilMin] [float] NOT NULL,
	[aucTarget] [float] NOT NULL,
	[aucAutoExt] [smallint] NOT NULL,
	[aucExt] [smallint] NOT NULL,
	[aucRaggTarget] [bit] NOT NULL,
	[aucTipoAsta] [tinyint] NOT NULL,
	[aucUltimaMod] [datetime] NOT NULL,
	[aucDataScadOrig] [datetime] NOT NULL,
	[aucTryClose] [tinyint] NOT NULL,
	[aucDataStartTryClose] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAB_AUCTION] ADD  CONSTRAINT [DF_TAB_AUCTION_aucRaggTarget]  DEFAULT (0) FOR [aucRaggTarget]
GO
ALTER TABLE [dbo].[TAB_AUCTION] ADD  CONSTRAINT [DF_TAB_AUCTION_aucTipoAsta]  DEFAULT (0) FOR [aucTipoAsta]
GO
ALTER TABLE [dbo].[TAB_AUCTION] ADD  CONSTRAINT [DF_TAB_AUCTION_aucUltimaModifica]  DEFAULT (getdate()) FOR [aucUltimaMod]
GO
ALTER TABLE [dbo].[TAB_AUCTION] ADD  CONSTRAINT [DF_TAB_AUCTION_aucTryClose]  DEFAULT (0) FOR [aucTryClose]
GO
