USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_ModF23]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_ModF23](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[id_repertorio] [int] NOT NULL,
	[cognome] [nvarchar](200) NULL,
	[comune] [nvarchar](200) NULL,
	[provincia] [nvarchar](50) NULL,
	[codiceufficio] [nvarchar](10) NULL,
	[causale] [nvarchar](5) NULL,
	[annostipula] [nvarchar](50) NULL,
	[Rep] [int] NULL,
	[Total] [int] NULL,
	[eurolettere] [varchar](200) NULL,
	[azipartitaiva] [varchar](50) NULL,
	[StatoGara] [varchar](20) NULL
) ON [PRIMARY]
GO
