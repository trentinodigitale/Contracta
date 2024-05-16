USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Parix_Dati]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Parix_Dati](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sessionid] [varchar](250) NULL,
	[codice_fiscale] [varchar](250) NULL,
	[nome_campo] [varchar](150) NULL,
	[valore] [varchar](max) NULL,
	[dataInserimento] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Parix_Dati] ADD  CONSTRAINT [DF_Parix_Dati_dataInserimento]  DEFAULT (getdate()) FOR [dataInserimento]
GO
