USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TabContatoriOrdini]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TabContatoriOrdini](
	[IdAzi] [int] NOT NULL,
	[CntOrdine] [int] NOT NULL,
	[CntConfermaOrdine] [int] NOT NULL,
	[CntPromozione] [int] NOT NULL,
	[CntNumOfferte] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TabContatoriOrdini] ADD  CONSTRAINT [DF_TabContatoriOrdini_CntOrdine]  DEFAULT (0) FOR [CntOrdine]
GO
ALTER TABLE [dbo].[TabContatoriOrdini] ADD  CONSTRAINT [DF_TabContatoriOrdini_CntConfermaOrdine]  DEFAULT (0) FOR [CntConfermaOrdine]
GO
ALTER TABLE [dbo].[TabContatoriOrdini] ADD  CONSTRAINT [DF_TabContatoriOrdini_cntPromozione]  DEFAULT (0) FOR [CntPromozione]
GO
ALTER TABLE [dbo].[TabContatoriOrdini] ADD  CONSTRAINT [DF_TabContatoriOrdini_CntNumOfferte]  DEFAULT (0) FOR [CntNumOfferte]
GO
ALTER TABLE [dbo].[TabContatoriOrdini]  WITH NOCHECK ADD  CONSTRAINT [FK_TabContatoriOrdini_Aziende] FOREIGN KEY([IdAzi])
REFERENCES [dbo].[Aziende] ([IdAzi])
GO
ALTER TABLE [dbo].[TabContatoriOrdini] CHECK CONSTRAINT [FK_TabContatoriOrdini_Aziende]
GO
