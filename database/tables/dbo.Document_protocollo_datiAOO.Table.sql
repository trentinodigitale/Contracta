USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_protocollo_datiAOO]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_protocollo_datiAOO](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[codiceAOO] [varchar](100) NOT NULL,
	[denominazioneAOO] [varchar](500) NULL,
	[username] [varchar](100) NULL,
	[password] [varchar](100) NULL,
	[codiceEnte] [varchar](100) NULL,
	[application] [varchar](100) NULL,
	[uo] [varchar](100) NULL,
	[denomUO] [varchar](500) NULL,
	[codiceAmministr] [varchar](100) NULL,
	[denomAmministr] [varchar](500) NULL,
 CONSTRAINT [IX_Document_protocollo_datiAOO_codiceAOO] UNIQUE NONCLUSTERED 
(
	[codiceAOO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
