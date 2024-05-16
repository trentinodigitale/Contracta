USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Parix]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Parix](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[codiceFiscale] [varchar](50) NOT NULL,
	[xmlParix] [text] NULL,
	[dataInserimento] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Parix] ADD  CONSTRAINT [DF_Parix_dataInserimento]  DEFAULT (getdate()) FOR [dataInserimento]
GO
