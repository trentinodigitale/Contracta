USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[document_convenzione_parametri_soglie]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[document_convenzione_parametri_soglie](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[Soglia] [int] NOT NULL,
	[Deleted] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[document_convenzione_parametri_soglie] ADD  CONSTRAINT [DF_document_convenzione_parametri_soglie_Deleted]  DEFAULT ((1)) FOR [Deleted]
GO
