USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Documentazione]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Documentazione](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Owner] [int] NULL,
	[Name] [varchar](50) NULL,
	[DataCreazione] [datetime] NULL,
	[Protocollo] [varchar](50) NULL,
	[StatoDoc] [varchar](50) NULL,
	[DataScadenza] [datetime] NULL,
	[Nome] [varchar](500) NULL,
	[Note] [ntext] NULL,
	[TipoDocumentazione] [varchar](50) NULL,
	[VisibilitaDoc] [varchar](50) NULL,
	[Deleted] [bit] NULL,
 CONSTRAINT [PK_Document_Documentazione] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Documentazione] ADD  CONSTRAINT [DF__Document___DataC__1F9CAB74]  DEFAULT (getdate()) FOR [DataCreazione]
GO
ALTER TABLE [dbo].[Document_Documentazione] ADD  CONSTRAINT [DF__Document___Stato__2090CFAD]  DEFAULT ('Saved') FOR [StatoDoc]
GO
ALTER TABLE [dbo].[Document_Documentazione] ADD  CONSTRAINT [DF__Document___Delet__2184F3E6]  DEFAULT ((0)) FOR [Deleted]
GO
