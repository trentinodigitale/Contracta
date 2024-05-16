USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CompanyLink]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyLink](
	[clCurIdAzi] [int] NOT NULL,
	[clPrevIdAzi] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyLink]  WITH NOCHECK ADD  CONSTRAINT [FK_CompanyLink_Aziende] FOREIGN KEY([clCurIdAzi])
REFERENCES [dbo].[Aziende] ([IdAzi])
GO
ALTER TABLE [dbo].[CompanyLink] CHECK CONSTRAINT [FK_CompanyLink_Aziende]
GO
ALTER TABLE [dbo].[CompanyLink]  WITH NOCHECK ADD  CONSTRAINT [FK_CompanyLink_Aziende1] FOREIGN KEY([clPrevIdAzi])
REFERENCES [dbo].[Aziende] ([IdAzi])
GO
ALTER TABLE [dbo].[CompanyLink] CHECK CONSTRAINT [FK_CompanyLink_Aziende1]
GO
