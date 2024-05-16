USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Comunicazione]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Comunicazione](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[DataCreazione] [datetime] NULL,
	[ID_MSG_Tabulato] [int] NULL,
	[ID_MSG_BANDO] [int] NULL,
	[StatoEsclusione] [varchar](20) NULL,
	[Oggetto] [ntext] NULL,
	[Segretario] [nvarchar](255) NULL,
	[Protocol] [varchar](50) NULL,
	[ProtocolloGenerale] [varchar](30) NULL,
	[DataProt] [datetime] NULL,
	[NoteProgetto] [ntext] NULL,
	[Allegato] [nvarchar](255) NULL,
	[StatoGara] [varchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Comunicazione] ADD  CONSTRAINT [DF__Document___DataC__03F75698]  DEFAULT (getdate()) FOR [DataCreazione]
GO
ALTER TABLE [dbo].[Document_Comunicazione] ADD  CONSTRAINT [DF__Document___Stato__04EB7AD1]  DEFAULT ('Saved') FOR [StatoEsclusione]
GO
