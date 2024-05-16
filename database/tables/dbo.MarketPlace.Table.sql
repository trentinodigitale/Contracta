USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MarketPlace]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MarketPlace](
	[IdMp] [int] IDENTITY(1,1) NOT NULL,
	[mpLog] [nvarchar](12) NOT NULL,
	[mpRagioneSociale] [nvarchar](1000) NULL,
	[mpURL] [nvarchar](300) NOT NULL,
	[mpAlias] [nvarchar](50) NOT NULL,
	[mpIdAziMaster] [int] NOT NULL,
	[mpIdLng] [int] NOT NULL,
	[mpTenderMaxAziende] [int] NOT NULL,
	[mpTenderggScadenza] [smallint] NOT NULL,
	[mpCatalogoUnico] [bit] NOT NULL,
	[mpVisibilitaInterna] [bit] NOT NULL,
	[mpVisibilitaEsterna] [bit] NOT NULL,
	[mpOpzioni] [char](20) NOT NULL,
	[mpDeleted] [bit] NOT NULL,
	[mpUltimaMod] [datetime] NOT NULL,
 CONSTRAINT [PK_MarketPlace] PRIMARY KEY NONCLUSTERED 
(
	[IdMp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MarketPlace] ADD  CONSTRAINT [DF_MarketPlace_MpTenderMaxAziende]  DEFAULT (1000) FOR [mpTenderMaxAziende]
GO
ALTER TABLE [dbo].[MarketPlace] ADD  CONSTRAINT [DF_MarketPlace_MpTenderggScadenza]  DEFAULT (15) FOR [mpTenderggScadenza]
GO
ALTER TABLE [dbo].[MarketPlace] ADD  CONSTRAINT [DF_MarketPlace_mpCatalogoUnico]  DEFAULT (0) FOR [mpCatalogoUnico]
GO
ALTER TABLE [dbo].[MarketPlace] ADD  CONSTRAINT [DF_MarketPlace_mpVisibilitaInterna]  DEFAULT (0) FOR [mpVisibilitaInterna]
GO
ALTER TABLE [dbo].[MarketPlace] ADD  CONSTRAINT [DF_MarketPlace_mpVisibilitaEsterna]  DEFAULT (0) FOR [mpVisibilitaEsterna]
GO
ALTER TABLE [dbo].[MarketPlace] ADD  CONSTRAINT [DF_MarketPlace_mpOpzioni]  DEFAULT ('00000000100000000000') FOR [mpOpzioni]
GO
ALTER TABLE [dbo].[MarketPlace] ADD  CONSTRAINT [DF_MarketPlace_mpDeleted]  DEFAULT (0) FOR [mpDeleted]
GO
ALTER TABLE [dbo].[MarketPlace] ADD  CONSTRAINT [DF_MarketPlace_mpUltimaMod]  DEFAULT (getdate()) FOR [mpUltimaMod]
GO
ALTER TABLE [dbo].[MarketPlace]  WITH NOCHECK ADD  CONSTRAINT [FK_MarketPlace_Aziende] FOREIGN KEY([mpIdAziMaster])
REFERENCES [dbo].[Aziende] ([IdAzi])
GO
ALTER TABLE [dbo].[MarketPlace] CHECK CONSTRAINT [FK_MarketPlace_Aziende]
GO
ALTER TABLE [dbo].[MarketPlace]  WITH CHECK ADD  CONSTRAINT [FK_MarketPlace_Lingue] FOREIGN KEY([mpIdLng])
REFERENCES [dbo].[Lingue] ([IdLng])
GO
ALTER TABLE [dbo].[MarketPlace] CHECK CONSTRAINT [FK_MarketPlace_Lingue]
GO
