USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CompanyModels]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyModels](
	[cmIdAzi] [int] NULL,
	[cmIdMpMod] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyModels]  WITH NOCHECK ADD  CONSTRAINT [FK_CompanyModels_Aziende] FOREIGN KEY([cmIdAzi])
REFERENCES [dbo].[Aziende] ([IdAzi])
GO
ALTER TABLE [dbo].[CompanyModels] CHECK CONSTRAINT [FK_CompanyModels_Aziende]
GO
