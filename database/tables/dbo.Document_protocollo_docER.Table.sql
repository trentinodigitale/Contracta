USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_protocollo_docER]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_protocollo_docER](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[tipoDoc] [varchar](200) NULL,
	[jumpCheck] [varchar](255) NULL,
	[sottoTipo] [varchar](255) NULL,
	[aoo] [varchar](200) NULL,
	[denomAOO] [varchar](500) NULL,
	[repertorio] [varchar](500) NULL,
	[uo] [varchar](200) NULL,
	[denomUO] [varchar](500) NULL,
	[indiceTitolario] [varchar](50) NULL,
	[titolario] [varchar](500) NULL,
	[fascicolo] [varchar](500) NULL,
	[deleted] [int] NULL,
	[data] [date] NULL,
	[algoritmo] [varchar](100) NULL,
	[attivo] [int] NULL,
	[contesto] [varchar](200) NULL,
	[verificaFascicolo] [int] NOT NULL,
	[generaFascicolo] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_protocollo_docER] ADD  DEFAULT ((0)) FOR [deleted]
GO
ALTER TABLE [dbo].[Document_protocollo_docER] ADD  DEFAULT (getdate()) FOR [data]
GO
ALTER TABLE [dbo].[Document_protocollo_docER] ADD  DEFAULT ((1)) FOR [attivo]
GO
ALTER TABLE [dbo].[Document_protocollo_docER] ADD  DEFAULT ((1)) FOR [verificaFascicolo]
GO
