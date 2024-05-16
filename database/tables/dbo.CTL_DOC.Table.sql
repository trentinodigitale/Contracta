USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_DOC]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_DOC](
	[Id] [int] IDENTITY(1,1) NOT NULL,
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
ALTER TABLE [dbo].[CTL_DOC] ADD  CONSTRAINT [DF__CTL_DOC__StatoDo__4316F928]  DEFAULT ('Saved') FOR [StatoDoc]
GO
ALTER TABLE [dbo].[CTL_DOC] ADD  CONSTRAINT [DF_CTL_DOC_Data]  DEFAULT (getdate()) FOR [Data]
GO
ALTER TABLE [dbo].[CTL_DOC] ADD  CONSTRAINT [DF__CTL_DOC__PrevDoc__44FF419A]  DEFAULT ((0)) FOR [PrevDoc]
GO
ALTER TABLE [dbo].[CTL_DOC] ADD  CONSTRAINT [DF__CTL_DOC__Deleted__45F365D3]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[CTL_DOC] ADD  CONSTRAINT [DF__CTL_DOC__Azienda__46E78A0C]  DEFAULT ((0)) FOR [Azienda]
GO
ALTER TABLE [dbo].[CTL_DOC] ADD  CONSTRAINT [DF_CTL_DOC_SIGN_HASH]  DEFAULT ('') FOR [SIGN_HASH]
GO
ALTER TABLE [dbo].[CTL_DOC] ADD  CONSTRAINT [DF_CTL_DOC_SIGN_ATTACH]  DEFAULT ('') FOR [SIGN_ATTACH]
GO
ALTER TABLE [dbo].[CTL_DOC] ADD  CONSTRAINT [DF_CTL_DOC_SIGN_LOCK]  DEFAULT ((0)) FOR [SIGN_LOCK]
GO
ALTER TABLE [dbo].[CTL_DOC] ADD  CONSTRAINT [DF_CTL_DOC_StatoFunzionale]  DEFAULT ('InLavorazione') FOR [StatoFunzionale]
GO
ALTER TABLE [dbo].[CTL_DOC] ADD  CONSTRAINT [DF_CTL_DOC_Destinatario_User]  DEFAULT ((0)) FOR [Destinatario_User]
GO
ALTER TABLE [dbo].[CTL_DOC] ADD  CONSTRAINT [DF_CTL_DOC_Destinatario_Azi]  DEFAULT ((0)) FOR [Destinatario_Azi]
GO
ALTER TABLE [dbo].[CTL_DOC] ADD  CONSTRAINT [DF__CTL_DOC__GUID__6153F725]  DEFAULT (newid()) FOR [GUID]
GO
ALTER TABLE [dbo].[CTL_DOC] ADD  CONSTRAINT [DF_CTL_DOC_CanaleNotifica]  DEFAULT ('mail') FOR [CanaleNotifica]
GO
