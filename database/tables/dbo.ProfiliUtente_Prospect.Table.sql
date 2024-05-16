USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ProfiliUtente_Prospect]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProfiliUtente_Prospect](
	[IdPfu] [int] IDENTITY(2000000,1) NOT NULL,
	[pfuIdAzi] [int] NOT NULL,
	[pfuLogin] [nvarchar](12) NOT NULL,
	[pfuPassword] [nvarchar](250) NOT NULL,
	[pfuIdLng] [int] NOT NULL,
	[pfuDeleted] [smallint] NOT NULL,
	[pfuNome] [nvarchar](30) NULL,
	[pfuE_Mail] [nvarchar](50) NULL,
 CONSTRAINT [PK_ProfiliUtente_Prospect] PRIMARY KEY NONCLUSTERED 
(
	[IdPfu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProfiliUtente_Prospect] ADD  CONSTRAINT [DF_ProfiliUtente_Prospect_pfuIdLng]  DEFAULT (1) FOR [pfuIdLng]
GO
ALTER TABLE [dbo].[ProfiliUtente_Prospect] ADD  CONSTRAINT [DF_ProfiliUtente_Prospect_pfuDeleted]  DEFAULT (0) FOR [pfuDeleted]
GO
ALTER TABLE [dbo].[ProfiliUtente_Prospect] ADD  CONSTRAINT [DF_ProfiliUtente_Prospect_pfuNome]  DEFAULT ('') FOR [pfuNome]
GO
ALTER TABLE [dbo].[ProfiliUtente_Prospect] ADD  CONSTRAINT [DF_ProfiliUtente_Prospect_pfuE_Mail]  DEFAULT ('') FOR [pfuE_Mail]
GO
ALTER TABLE [dbo].[ProfiliUtente_Prospect]  WITH NOCHECK ADD  CONSTRAINT [FK_ProfiliUtente_Prospect_Aziende] FOREIGN KEY([pfuIdAzi])
REFERENCES [dbo].[Aziende] ([IdAzi])
GO
ALTER TABLE [dbo].[ProfiliUtente_Prospect] CHECK CONSTRAINT [FK_ProfiliUtente_Prospect_Aziende]
GO
