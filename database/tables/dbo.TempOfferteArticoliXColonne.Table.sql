USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempOfferteArticoliXColonne]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempOfferteArticoliXColonne](
	[oacIdOar] [int] NOT NULL,
	[oacIdMcl] [int] NOT NULL,
	[oacIdVat] [int] NOT NULL,
	[oacWarning] [bit] NOT NULL,
	[oacObblig] [bit] NULL,
	[oacIdProd] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempOfferteArticoliXColonne] ADD  CONSTRAINT [DF__TempOffer__oacWa__509BDCCF]  DEFAULT (0) FOR [oacWarning]
GO
ALTER TABLE [dbo].[TempOfferteArticoliXColonne] ADD  CONSTRAINT [DF__TempOffer__oacOb__51900108]  DEFAULT (0) FOR [oacObblig]
GO
