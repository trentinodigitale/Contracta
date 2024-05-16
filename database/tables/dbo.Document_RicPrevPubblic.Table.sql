USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_RicPrevPubblic]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_RicPrevPubblic](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[StatoRicPrevPubblic] [varchar](40) NULL,
	[PEG] [varchar](40) NULL,
	[Protocol] [varchar](20) NULL,
	[Oggetto] [text] NULL,
	[Importo] [float] NULL,
	[FAX] [nvarchar](50) NOT NULL,
	[NumQuotReg] [int] NULL,
	[NumQuotNaz] [int] NULL,
	[NumCaratteri] [int] NOT NULL,
	[RigoLungo] [int] NOT NULL,
	[NumRighe] [int] NOT NULL,
	[Allegato] [nvarchar](255) NULL,
	[UserDirigente] [varchar](20) NULL,
	[DataInvio] [datetime] NULL,
	[Pratica] [nvarchar](50) NOT NULL,
	[UserProvveditore] [varchar](20) NULL,
	[DataCompilazione] [datetime] NULL,
	[NumRigheBollo] [int] NULL,
	[AllegatoBURC] [nvarchar](255) NULL,
	[AllegatoGURI] [nvarchar](255) NULL,
	[LinkModified] [int] NULL,
	[StatoDataPubb] [varchar](20) NULL,
	[Deleted] [int] NULL,
	[NumRigheGuri] [int] NULL,
	[TipoDocumento] [varchar](20) NULL,
	[Tipologia] [varchar](20) NULL,
	[CostoBurc] [float] NULL,
	[BudgetProgettoBurc] [float] NULL,
	[BudgetPegBurc] [float] NULL,
	[CoperturaBurc] [varchar](20) NULL,
	[CostoGuri] [float] NULL,
	[BudgetProgettoGuri] [float] NULL,
	[BudgetPegGuri] [float] NULL,
	[CoperturaGuri] [varchar](20) NULL,
	[NoteRicPrev] [text] NULL,
	[Storico] [int] NULL,
	[RicPubDPE] [int] NULL,
	[RicPubECO] [int] NULL,
	[DataOperazione] [datetime] NULL,
	[User] [int] NULL,
	[StatoDataPubbBG] [varchar](20) NULL,
	[LinkDocRdBE] [int] NULL,
	[IdHeader] [int] NULL,
	[DomCodiceIPA] [varchar](20) NULL,
	[MandatoPagDett] [varchar](2) NULL,
	[allegatoVistoContabile] [nvarchar](255) NULL,
	[AllegatoIOL] [nvarchar](255) NULL,
	[allegatoFirmato] [nvarchar](255) NULL,
	[AllegatoDetermina] [nvarchar](255) NULL,
	[IdentificativoIniziativa] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_RicPrevPubblic] ADD  CONSTRAINT [DF_Document_RicPrevPubblic_StatoRicPrevPubblic]  DEFAULT ('Saved') FOR [StatoRicPrevPubblic]
GO
ALTER TABLE [dbo].[Document_RicPrevPubblic] ADD  CONSTRAINT [DF_Document_RicPrevPubblic_StatoDataPubb]  DEFAULT ('Saved') FOR [StatoDataPubb]
GO
ALTER TABLE [dbo].[Document_RicPrevPubblic] ADD  CONSTRAINT [DF_Document_RicPrevPubblic_Deleted]  DEFAULT (0) FOR [Deleted]
GO
ALTER TABLE [dbo].[Document_RicPrevPubblic] ADD  CONSTRAINT [DF_Document_RicPrevPubblic_NumRigheGuri]  DEFAULT (0) FOR [NumRigheGuri]
GO
ALTER TABLE [dbo].[Document_RicPrevPubblic] ADD  CONSTRAINT [DF_Document_RicPrevPubblic_CoperturaBurc]  DEFAULT ('') FOR [CoperturaBurc]
GO
ALTER TABLE [dbo].[Document_RicPrevPubblic] ADD  CONSTRAINT [DF_Document_RicPrevPubblic_CoperturaGuri]  DEFAULT ('') FOR [CoperturaGuri]
GO
ALTER TABLE [dbo].[Document_RicPrevPubblic] ADD  CONSTRAINT [DF_Document_RicPrevPubblic_Storico]  DEFAULT (0) FOR [Storico]
GO
ALTER TABLE [dbo].[Document_RicPrevPubblic] ADD  CONSTRAINT [DF_Document_RicPrevPubblic_RicPubDPE]  DEFAULT (0) FOR [RicPubDPE]
GO
ALTER TABLE [dbo].[Document_RicPrevPubblic] ADD  CONSTRAINT [DF_Document_RicPrevPubblic_RicPubECO]  DEFAULT (0) FOR [RicPubECO]
GO
ALTER TABLE [dbo].[Document_RicPrevPubblic] ADD  CONSTRAINT [DF_Document_RicPrevPubblic_StatoDataPubb1]  DEFAULT ('Saved') FOR [StatoDataPubbBG]
GO
