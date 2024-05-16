USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPDocumenti]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPDocumenti](
	[IdDoc] [int] IDENTITY(1,1) NOT NULL,
	[docIdMp] [int] NOT NULL,
	[docItype] [smallint] NULL,
	[docPath] [varchar](100) NOT NULL,
	[docIdMpMod] [int] NOT NULL,
	[docDeleted] [bit] NOT NULL,
	[docDataUltimaMod] [datetime] NOT NULL,
	[docISubType] [smallint] NULL,
	[docIsReplicable] [bit] NOT NULL,
 CONSTRAINT [PK_MpDocumenti] PRIMARY KEY NONCLUSTERED 
(
	[IdDoc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPDocumenti] ADD  CONSTRAINT [DF_MPDocumenti_docDeleted]  DEFAULT (0) FOR [docDeleted]
GO
ALTER TABLE [dbo].[MPDocumenti] ADD  CONSTRAINT [DF_MpDocumenti_DocDataUltimaMod]  DEFAULT (getdate()) FOR [docDataUltimaMod]
GO
ALTER TABLE [dbo].[MPDocumenti] ADD  CONSTRAINT [DF_MPDocumenti_docISubType]  DEFAULT ((-1)) FOR [docISubType]
GO
ALTER TABLE [dbo].[MPDocumenti] ADD  CONSTRAINT [DF_MPDocumenti_docIsReplicable]  DEFAULT (0) FOR [docIsReplicable]
GO
ALTER TABLE [dbo].[MPDocumenti]  WITH NOCHECK ADD  CONSTRAINT [FK_MPDocumenti_MPModelli] FOREIGN KEY([docIdMpMod])
REFERENCES [dbo].[MPModelli] ([IdMpMod])
GO
ALTER TABLE [dbo].[MPDocumenti] CHECK CONSTRAINT [FK_MPDocumenti_MPModelli]
GO
