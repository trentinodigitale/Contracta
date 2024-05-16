USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Com_DPE]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Com_DPE](
	[IdCom] [int] IDENTITY(1,1) NOT NULL,
	[Owner] [int] NULL,
	[Name] [nvarchar](500) NULL,
	[DataCreazione] [datetime] NULL,
	[Protocollo] [varchar](50) NULL,
	[StatoCom] [varchar](50) NULL,
	[Obbligo] [varchar](1) NULL,
	[DataObbligo] [datetime] NULL,
	[BloccoAccesso] [varchar](1) NULL,
	[DataScadenzaCom] [datetime] NULL,
	[TipologiaAllegati] [varchar](50) NULL,
	[NotaCom] [nvarchar](max) NULL,
	[TipoComDPE] [varchar](50) NULL,
	[Deleted] [bit] NULL,
	[IsPublic] [bit] NOT NULL,
	[RichiestaRisposta] [varchar](50) NULL,
	[DataScadenza] [datetime] NULL,
	[Richiesta_del_Prec] [varchar](50) NULL,
	[TipoDestinatarioMail] [varchar](30) NULL,
	[fascicoloSecondario] [varchar](100) NULL,
	[ProfiloUtentiCom] [varchar](max) NULL,
	[RichiestaProtocollo] [varchar](10) NULL,
	[RuoloUtentiCom] [varchar](max) NULL,
 CONSTRAINT [PK_Document_Com_DPE] PRIMARY KEY CLUSTERED 
(
	[IdCom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Com_DPE] ADD  CONSTRAINT [DF_Document_Com_DPE_Data]  DEFAULT (getdate()) FOR [DataCreazione]
GO
ALTER TABLE [dbo].[Document_Com_DPE] ADD  CONSTRAINT [DF_Document_Com_DPE_StatoCom]  DEFAULT ('Salvato') FOR [StatoCom]
GO
ALTER TABLE [dbo].[Document_Com_DPE] ADD  CONSTRAINT [DF_Document_Com_DPE_DataObbligo]  DEFAULT (getdate()) FOR [DataObbligo]
GO
ALTER TABLE [dbo].[Document_Com_DPE] ADD  CONSTRAINT [DF_Document_Com_DPE_DataScadenza]  DEFAULT (getdate()) FOR [DataScadenzaCom]
GO
ALTER TABLE [dbo].[Document_Com_DPE] ADD  CONSTRAINT [DF_Document_Deleted]  DEFAULT (0) FOR [Deleted]
GO
ALTER TABLE [dbo].[Document_Com_DPE] ADD  CONSTRAINT [DF_Document_Com_DPE_IsPublic]  DEFAULT (0) FOR [IsPublic]
GO
ALTER TABLE [dbo].[Document_Com_DPE] ADD  DEFAULT ('') FOR [ProfiloUtentiCom]
GO
ALTER TABLE [dbo].[Document_Com_DPE] ADD  DEFAULT ('si') FOR [RichiestaProtocollo]
GO
ALTER TABLE [dbo].[Document_Com_DPE] ADD  DEFAULT ('') FOR [RuoloUtentiCom]
GO
