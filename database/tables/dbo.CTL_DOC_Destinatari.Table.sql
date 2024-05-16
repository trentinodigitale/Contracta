USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_DOC_Destinatari]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_DOC_Destinatari](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[IdPfu] [int] NULL,
	[IdAzi] [int] NULL,
	[aziRagioneSociale] [nvarchar](1000) NULL,
	[aziPartitaIVA] [nvarchar](50) NULL,
	[aziE_Mail] [nvarchar](200) NULL,
	[aziIndirizzoLeg] [nvarchar](80) NULL,
	[aziLocalitaLeg] [nvarchar](80) NULL,
	[aziProvinciaLeg] [nvarchar](80) NULL,
	[aziStatoLeg] [nvarchar](80) NULL,
	[aziCAPLeg] [nvarchar](20) NULL,
	[aziTelefono1] [nvarchar](50) NULL,
	[aziFAX] [nvarchar](50) NULL,
	[aziDBNumber] [int] NULL,
	[aziSitoWeb] [nvarchar](300) NULL,
	[CDDStato] [nvarchar](300) NULL,
	[Seleziona] [varchar](50) NULL,
	[NumRiga] [varchar](200) NULL,
	[CodiceFiscale] [varchar](50) NULL,
	[StatoIscrizione] [varchar](20) NULL,
	[DataIscrizione] [datetime] NULL,
	[DataScadenzaIscrizione] [datetime] NULL,
	[DataSollecito] [datetime] NULL,
	[Id_Doc] [int] NULL,
	[DataConferma] [datetime] NULL,
	[NumeroInviti] [int] NULL,
	[ordinamento] [int] NULL,
	[Is_Group] [varchar](2) NULL
) ON [PRIMARY]
GO
