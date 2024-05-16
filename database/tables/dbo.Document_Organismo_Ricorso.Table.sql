USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Organismo_Ricorso]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Organismo_Ricorso](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idAzi] [int] NOT NULL,
	[Name] [nvarchar](2000) NULL,
	[CompanyID] [varchar](100) NULL,
	[CityName] [nvarchar](1000) NULL,
	[countryCode] [varchar](10) NULL,
	[ElectronicMail] [nvarchar](1000) NULL,
	[Telephone] [varchar](200) NULL,
	[bDeleted] [int] NULL,
	[insertDate] [datetime] NULL,
	[postalCode] [varchar](100) NULL,
	[codNuts] [varchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Organismo_Ricorso] ADD  CONSTRAINT [DF_Document_Organismo_Ricorso_bDeleted]  DEFAULT ((0)) FOR [bDeleted]
GO
ALTER TABLE [dbo].[Document_Organismo_Ricorso] ADD  CONSTRAINT [DF_Document_Organismo_Ricorso_insertDate]  DEFAULT (getdate()) FOR [insertDate]
GO
