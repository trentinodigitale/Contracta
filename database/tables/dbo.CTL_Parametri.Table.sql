USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Parametri]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Parametri](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NULL,
	[Contesto] [varchar](500) NOT NULL,
	[Oggetto] [varchar](1000) NOT NULL,
	[Proprieta] [varchar](500) NOT NULL,
	[Valore] [nvarchar](max) NOT NULL,
	[ValoriAmmessi] [nvarchar](max) NOT NULL,
	[Descrizione] [nvarchar](max) NOT NULL,
	[Idpfu] [int] NULL,
	[DataLastUpdate] [datetime] NOT NULL,
	[Deleted] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_Parametri] ADD  CONSTRAINT [DF_CTL_Parametri_DataLastUpdate]  DEFAULT (getdate()) FOR [DataLastUpdate]
GO
ALTER TABLE [dbo].[CTL_Parametri] ADD  CONSTRAINT [DF_CTL_Parametri_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
