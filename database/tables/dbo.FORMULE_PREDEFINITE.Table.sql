USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[FORMULE_PREDEFINITE]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FORMULE_PREDEFINITE](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Formula] [varchar](1000) NOT NULL,
	[Descrizione] [varchar](1000) NOT NULL,
	[Idpfu] [int] NULL,
	[Sistema] [varchar](50) NOT NULL,
	[Raccordo] [varchar](100) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FORMULE_PREDEFINITE] ADD  CONSTRAINT [DF_FORMULE_PREDEFINITE_Sistema]  DEFAULT ('si') FOR [Sistema]
GO
ALTER TABLE [dbo].[FORMULE_PREDEFINITE] ADD  CONSTRAINT [DF_FORMULE_PREDEFINITE_Raccordo]  DEFAULT ('') FOR [Raccordo]
GO
