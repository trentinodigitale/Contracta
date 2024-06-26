USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Fascicolo_Gara_Documenti]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Fascicolo_Gara_Documenti](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[IdDoc] [int] NOT NULL,
	[TipoDoc] [varchar](50) NOT NULL,
	[Protocollo] [varchar](50) NOT NULL,
	[Titolo] [nvarchar](500) NOT NULL,
	[DataInvio] [datetime] NULL,
	[Esito] [varchar](20) NOT NULL,
	[NumRetry] [int] NOT NULL,
	[GeneraPdf] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Fascicolo_Gara_Documenti] ADD  CONSTRAINT [DF_Document_Fascicolo_Gara_Documenti_Esito]  DEFAULT ('') FOR [Esito]
GO
ALTER TABLE [dbo].[Document_Fascicolo_Gara_Documenti] ADD  CONSTRAINT [DF_Document_Fascicolo_Gara_Documenti_NumRetry]  DEFAULT ((0)) FOR [NumRetry]
GO
ALTER TABLE [dbo].[Document_Fascicolo_Gara_Documenti] ADD  CONSTRAINT [DF_Document_Fascicolo_Gara_Documenti_GeneraPdf]  DEFAULT ((0)) FOR [GeneraPdf]
GO
