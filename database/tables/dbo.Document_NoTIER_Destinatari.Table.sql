USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_NoTIER_Destinatari]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_NoTIER_Destinatari](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ID_NOTIER] [varchar](1000) NULL,
	[ID_PEPPOL] [varchar](500) NULL,
	[ID_IPA] [varchar](1000) NULL,
	[piva_cf] [varchar](100) NULL,
	[denominazione] [nvarchar](4000) NULL,
	[bDeleted] [int] NOT NULL,
	[sorgente] [varchar](20) NULL,
	[EmailReferenteIPA] [nvarchar](1000) NULL,
	[ReferenteIPA] [nvarchar](1000) NULL,
	[pecIPA] [nvarchar](1000) NULL,
	[TelefonoIPA] [nvarchar](100) NULL,
	[IndirizzoIPA] [nvarchar](1000) NULL,
	[DenominazioneIPA] [nvarchar](1000) NULL,
	[Peppol_Invio_DDT] [char](1) NULL,
	[Peppol_Ricezione_DDT] [char](1) NULL,
	[Peppol_Invio_Ordine] [char](1) NULL,
	[Peppol_Ricezione_Ordine] [char](1) NULL,
	[Peppol_Invio_Fatture] [char](1) NULL,
	[Peppol_Invio_NoteDiCredito] [char](1) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_NoTIER_Destinatari] ADD  DEFAULT ((0)) FOR [bDeleted]
GO
ALTER TABLE [dbo].[Document_NoTIER_Destinatari] ADD  DEFAULT ('') FOR [sorgente]
GO
