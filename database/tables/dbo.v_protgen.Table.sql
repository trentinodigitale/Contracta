USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[v_protgen]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[v_protgen](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Modalita] [char](1) NULL,
	[Data_Documento] [datetime] NULL,
	[Oggetto] [nvarchar](max) NULL,
	[Id_Classificazione] [varchar](50) NULL,
	[Tipo] [char](1) NULL,
	[Descrizione] [nvarchar](max) NULL,
	[Indirizzo] [varchar](8000) NULL,
	[CAP] [varchar](15) NULL,
	[Localita] [varchar](100) NULL,
	[Appl_Id_Evento] [varchar](50) NULL,
	[Flag_Annullato] [char](1) NULL,
	[Prot_Acquisito] [char](2) NULL,
	[Appl_Sigla] [varchar](500) NULL,
	[jumpCheck] [varchar](500) NULL,
	[sottoTipo] [varchar](500) NULL,
	[Path] [image] NULL,
	[Cod_Ass_Uff] [varchar](20) NULL,
	[Numero_Protocollo] [varchar](150) NULL,
	[Data_Protocollo] [datetime] NULL,
	[Tipo_Documento_Codice] [varchar](20) NULL,
	[Codice_Fiscale] [varchar](16) NULL,
	[Mime_Type] [varchar](50) NOT NULL,
	[Nome] [nvarchar](800) NULL,
	[Cognome] [nvarchar](800) NULL,
	[Denominazione] [nvarchar](800) NULL,
	[UnitaOrganizzativa] [varchar](100) NULL,
	[NaturaGiuridica] [varchar](100) NULL,
	[Email] [nvarchar](1000) NULL,
	[CodiceAmministrazione] [varchar](500) NULL,
	[cod_aoo] [varchar](100) NULL,
	[cod_ente] [varchar](100) NULL,
	[des_aoo] [varchar](1000) NULL,
	[UO_denominazione] [varchar](500) NULL,
	[UO_ident] [varchar](500) NULL,
	[idpfu] [int] NULL,
	[fascicolo] [varchar](250) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[v_protgen] ADD  CONSTRAINT [DF_v_protgen_Mime_Type]  DEFAULT ('PDF') FOR [Mime_Type]
GO
