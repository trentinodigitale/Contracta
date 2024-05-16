USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_RicPubblic]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_RicPubblic](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idRicPrevPubblic] [int] NULL,
	[StatoRicPubblic] [varchar](20) NULL,
	[PEG] [varchar](40) NULL,
	[Bando] [nvarchar](20) NULL,
	[Pratica] [nvarchar](50) NULL,
	[Fornitore] [varchar](20) NULL,
	[Fax] [nvarchar](20) NULL,
	[Oggetto] [text] NULL,
	[Allegato] [nvarchar](255) NULL,
	[UserDirigente] [varchar](20) NULL,
	[Num] [int] NULL,
	[Data] [datetime] NULL,
	[Prog] [int] NULL,
	[Imp] [nvarchar](20) NULL,
	[Bil] [nvarchar](50) NULL,
	[Owner] [varchar](20) NULL,
	[TipoPubblic] [varchar](50) NULL,
	[DataInvio] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_RicPubblic] ADD  CONSTRAINT [DF_Document_RicPubblic_StatoRicPubblic]  DEFAULT ('Saved') FOR [StatoRicPubblic]
GO
ALTER TABLE [dbo].[Document_RicPubblic] ADD  CONSTRAINT [DF_Document_RicPubblic_TipoPubblic]  DEFAULT ('ALTRI') FOR [TipoPubblic]
GO
