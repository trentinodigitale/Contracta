USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[AFFIDAMENTI_DIRETTI_SCHEDULATI]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AFFIDAMENTI_DIRETTI_SCHEDULATI](
	[pfunome] [nvarchar](530) NULL,
	[pfuLastLogin] [datetime] NULL,
	[http_fiscalnumber] [varchar](50) NULL,
	[dataInsRecord] [datetime] NULL,
	[LOA] [varchar](500) NULL,
	[Canale] [varchar](500) NULL,
	[Id] [int] NOT NULL,
	[IdPfu] [bigint] NULL,
	[IdDoc] [int] NULL,
	[TipoDoc] [varchar](50) NULL,
	[StatoDoc] [varchar](20) NULL,
	[Data] [datetime] NULL,
	[Protocollo] [varchar](50) NULL,
	[PrevDoc] [int] NULL,
	[Deleted] [bit] NULL,
	[Titolo] [nvarchar](500) NULL,
	[Body] [nvarchar](max) NULL,
	[Azienda] [varchar](50) NULL,
	[StrutturaAziendale] [varchar](max) NULL,
	[DataInvio] [datetime] NULL,
	[DataScadenza] [datetime] NULL,
	[ProtocolloRiferimento] [varchar](50) NULL,
	[ProtocolloGenerale] [varchar](50) NULL,
	[Fascicolo] [varchar](50) NULL,
	[Note] [nvarchar](max) NULL,
	[DataProtocolloGenerale] [datetime] NULL,
	[LinkedDoc] [int] NULL,
	[SIGN_HASH] [varchar](255) NULL,
	[SIGN_ATTACH] [nvarchar](255) NULL,
	[SIGN_LOCK] [int] NULL,
	[JumpCheck] [nvarchar](255) NULL,
	[StatoFunzionale] [varchar](50) NULL,
	[Destinatario_User] [int] NULL,
	[Destinatario_Azi] [int] NULL,
	[RichiestaFirma] [varchar](2) NULL,
	[NumeroDocumento] [nvarchar](50) NULL,
	[DataDocumento] [datetime] NULL,
	[Versione] [varchar](50) NULL,
	[VersioneLinkedDoc] [varchar](1000) NULL,
	[GUID] [uniqueidentifier] NOT NULL,
	[idPfuInCharge] [int] NULL,
	[CanaleNotifica] [varchar](50) NULL,
	[URL_CLIENT] [nvarchar](150) NULL,
	[Caption] [varchar](255) NULL,
	[FascicoloGenerale] [varchar](50) NULL,
	[CRYPT_VER] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
