USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Progetti]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Progetti](
	[IdProgetto] [int] IDENTITY(1,1) NOT NULL,
	[StatoProgetto] [varchar](40) NULL,
	[DataInvio] [datetime] NULL,
	[Protocol] [varchar](20) NULL,
	[UserDirigente] [varchar](20) NULL,
	[Peg] [varchar](40) NULL,
	[Importo] [float] NULL,
	[Tipologia] [varchar](20) NULL,
	[TipoProcedura] [varchar](20) NULL,
	[NumLotti] [int] NULL,
	[Oggetto] [text] NULL,
	[Versione] [varchar](20) NULL,
	[NumDetermina] [int] NULL,
	[DataDetermina] [datetime] NULL,
	[ProtocolloBando] [varchar](50) NULL,
	[ReferenteUffAppalti] [varchar](50) NULL,
	[UserProvveditore] [varchar](20) NULL,
	[AllegatoDpe] [nvarchar](255) NULL,
	[NoteProgetto] [text] NULL,
	[DataCompilazione] [datetime] NULL,
	[Storico] [int] NULL,
	[DataOperazione] [datetime] NULL,
	[User] [int] NULL,
	[Deleted] [int] NULL,
	[LinkModified] [int] NULL,
	[Pratica] [nvarchar](50) NULL,
	[CriterioAggiudicazione] [varchar](20) NULL,
	[EmailComunicazioni] [nvarchar](50) NULL,
	[ScadenzaIstanza] [datetime] NULL,
	[ScadenzaOfferta] [datetime] NULL,
	[NumDeterminaAggiudica] [int] NULL,
	[DataDeterminaAggiudica] [datetime] NULL,
	[ProceduraScelta] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Progetti] ADD  CONSTRAINT [DF_Document_Progetti_StatoProgetto]  DEFAULT ('Saved') FOR [StatoProgetto]
GO
ALTER TABLE [dbo].[Document_Progetti] ADD  CONSTRAINT [DF_Document_Progetti_Storico]  DEFAULT (0) FOR [Storico]
GO
ALTER TABLE [dbo].[Document_Progetti] ADD  CONSTRAINT [DF_Document_Progetti_Deleted]  DEFAULT (0) FOR [Deleted]
GO
ALTER TABLE [dbo].[Document_Progetti] ADD  CONSTRAINT [DF_Document_Progetti_ProceduraScelta]  DEFAULT ('1') FOR [ProceduraScelta]
GO
