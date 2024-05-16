USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[FunzioniValutazione]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FunzioniValutazione](
	[IdFva] [int] IDENTITY(1,1) NOT NULL,
	[fvaIdDsc] [int] NOT NULL,
	[fvaValori] [text] NULL,
	[fvaUltimaMod] [datetime] NOT NULL,
	[fvaDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_FunzioniValutazione] PRIMARY KEY NONCLUSTERED 
(
	[IdFva] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[FunzioniValutazione] ADD  CONSTRAINT [DF_FunzioniValutazione_fvaUltimaMod]  DEFAULT (getdate()) FOR [fvaUltimaMod]
GO
ALTER TABLE [dbo].[FunzioniValutazione] ADD  CONSTRAINT [DF_FunzioniValutazione_fvaDeleted]  DEFAULT (0) FOR [fvaDeleted]
GO
ALTER TABLE [dbo].[FunzioniValutazione]  WITH CHECK ADD  CONSTRAINT [FK_FunzioniValutazione_DescsI] FOREIGN KEY([fvaIdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[FunzioniValutazione] CHECK CONSTRAINT [FK_FunzioniValutazione_DescsI]
GO
