USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_CommissionePda_Utenti]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_CommissionePda_Utenti](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[UtenteCommissione] [nvarchar](200) NOT NULL,
	[RuoloCommissione] [nvarchar](200) NOT NULL,
	[TipoCommissione] [varchar](1) NOT NULL,
	[CodiceFiscale] [varchar](20) NULL,
	[Nome] [nvarchar](255) NULL,
	[Cognome] [nvarchar](255) NULL,
	[RagioneSociale] [nvarchar](1000) NULL,
	[RuoloUtente] [nvarchar](200) NULL,
	[Registra] [char](1) NULL,
	[EMAIL] [nvarchar](255) NULL,
	[Allegato] [nvarchar](255) NULL,
	[UtentePresente] [int] NULL,
	[AllegatoFirmato] [nvarchar](255) NULL
) ON [PRIMARY]
GO
