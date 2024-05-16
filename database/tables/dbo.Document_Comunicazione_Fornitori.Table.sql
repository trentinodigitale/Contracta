USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Comunicazione_Fornitori]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Comunicazione_Fornitori](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[ProtocolloGenerale] [varchar](30) NULL,
	[DataInvio] [datetime] NULL,
	[Fornitore] [varchar](20) NULL,
	[Stato] [varchar](20) NULL,
	[DataProt] [datetime] NULL,
	[isATI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Comunicazione_Fornitori] ADD  DEFAULT (0) FOR [isATI]
GO
