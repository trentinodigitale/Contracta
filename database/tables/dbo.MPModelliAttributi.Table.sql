USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPModelliAttributi]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPModelliAttributi](
	[IdMdlAtt] [int] IDENTITY(1,1) NOT NULL,
	[mpmaIdMpMod] [int] NOT NULL,
	[mpmaIdDzt] [int] NOT NULL,
	[mpmaRegObblig] [bit] NOT NULL,
	[mpmaOrdine] [int] NOT NULL,
	[mpmaValoreDef] [varchar](8000) NULL,
	[mpmaPesoDef] [tinyint] NULL,
	[mpmaIdFva] [int] NULL,
	[mpmaIdUmsDef] [int] NULL,
	[mpmaDeleted] [bit] NOT NULL,
	[mpmaDataUltimaMod] [datetime] NOT NULL,
	[mpmaLocked] [bit] NOT NULL,
	[mpmaShadow] [bit] NOT NULL,
	[mpmaOpzioni] [varchar](20) NOT NULL,
	[mpmaOper] [varchar](20) NULL,
 CONSTRAINT [PK_MpModelliAttributi] PRIMARY KEY NONCLUSTERED 
(
	[IdMdlAtt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPModelliAttributi] ADD  CONSTRAINT [DF_MPModelliAttributi_mpmaDeleted]  DEFAULT (0) FOR [mpmaDeleted]
GO
ALTER TABLE [dbo].[MPModelliAttributi] ADD  CONSTRAINT [DF_MPModelliAttributi_mpmaUltimaMod]  DEFAULT (getdate()) FOR [mpmaDataUltimaMod]
GO
ALTER TABLE [dbo].[MPModelliAttributi] ADD  CONSTRAINT [DF_MPModelliAttributi_mpmaLocked]  DEFAULT (0) FOR [mpmaLocked]
GO
ALTER TABLE [dbo].[MPModelliAttributi] ADD  CONSTRAINT [DF_MPModelliAttributi_mpmaShadow]  DEFAULT (0) FOR [mpmaShadow]
GO
ALTER TABLE [dbo].[MPModelliAttributi] ADD  CONSTRAINT [DF_MPModelliAttributi_mpmaOpzioni]  DEFAULT ('10010000000000000000') FOR [mpmaOpzioni]
GO
ALTER TABLE [dbo].[MPModelliAttributi]  WITH NOCHECK ADD  CONSTRAINT [FK_MPModelliAttributi_FunzioniValutazione] FOREIGN KEY([mpmaIdFva])
REFERENCES [dbo].[FunzioniValutazione] ([IdFva])
GO
ALTER TABLE [dbo].[MPModelliAttributi] CHECK CONSTRAINT [FK_MPModelliAttributi_FunzioniValutazione]
GO
ALTER TABLE [dbo].[MPModelliAttributi]  WITH NOCHECK ADD  CONSTRAINT [FK_MPModelliAttributi_MPModelli] FOREIGN KEY([mpmaIdMpMod])
REFERENCES [dbo].[MPModelli] ([IdMpMod])
GO
ALTER TABLE [dbo].[MPModelliAttributi] CHECK CONSTRAINT [FK_MPModelliAttributi_MPModelli]
GO
