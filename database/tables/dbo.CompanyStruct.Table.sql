USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CompanyStruct]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyStruct](
	[csVatValore] [varchar](150) NOT NULL,
	[csIdAzi] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyStruct]  WITH NOCHECK ADD  CONSTRAINT [FK_Struttura_Aziende_Aziende] FOREIGN KEY([csIdAzi])
REFERENCES [dbo].[Aziende] ([IdAzi])
GO
ALTER TABLE [dbo].[CompanyStruct] CHECK CONSTRAINT [FK_Struttura_Aziende_Aziende]
GO
