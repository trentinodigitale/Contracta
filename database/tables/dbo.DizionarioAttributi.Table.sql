USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DizionarioAttributi]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DizionarioAttributi](
	[IdDzt] [int] IDENTITY(1,1) NOT NULL,
	[dztNome] [varchar](50) NOT NULL,
	[dztValoreDef] [varchar](50) NULL,
	[dztIdDsc] [int] NOT NULL,
	[dztDataCreazione] [datetime] NOT NULL,
	[dztIdTid] [smallint] NOT NULL,
	[dztIstanzeTotali] [int] NOT NULL,
	[dztValidita] [smallint] NULL,
	[dztIdGum] [int] NULL,
	[dztIdUmsDefault] [int] NULL,
	[dztLunghezza] [smallint] NULL,
	[dztCifreDecimali] [tinyint] NULL,
	[dztFRegObblig] [bit] NOT NULL,
	[dztFAziende] [bit] NOT NULL,
	[dztFArticoli] [bit] NOT NULL,
	[dztFOFID] [bit] NOT NULL,
	[dztFValutazione] [bit] NOT NULL,
	[dztFIndicatoreQTA] [bit] NOT NULL,
	[dztPesoFvaDefault] [tinyint] NULL,
	[dztTabellaSpeciale] [varchar](40) NULL,
	[dztCampoSpeciale] [varchar](40) NULL,
	[_dztFIndicatore] [bit] NOT NULL,
	[dztFMascherato] [bit] NOT NULL,
	[_dztFOfferta] [bit] NOT NULL,
	[_verso] [varchar](10) NULL,
	[_dztAppartenenza] [smallint] NULL,
	[dztUltimaMod] [datetime] NOT NULL,
	[dztFQualita] [tinyint] NOT NULL,
	[dztProfili] [varchar](20) NULL,
	[dztMultiValue] [bit] NOT NULL,
	[dztLocked] [bit] NOT NULL,
	[dztDeleted] [bit] NOT NULL,
	[dztVersoNavig] [varchar](5) NULL,
	[dztInterno] [bit] NOT NULL,
	[dztTipologiaStorico] [char](3) NULL,
	[dztMemStorico] [smallint] NOT NULL,
	[dztIsUnicode] [bit] NOT NULL,
 CONSTRAINT [PK_DizionarioAttributi] PRIMARY KEY NONCLUSTERED 
(
	[IdDzt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_DizionarioAttributi_dztDataCreazione]  DEFAULT (getdate()) FOR [dztDataCreazione]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_DizionarioAttributi_dazIstanzeTotali]  DEFAULT (0) FOR [dztIstanzeTotali]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_DizionarioAttributi_dazFOpzionale]  DEFAULT (0) FOR [dztFRegObblig]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_DizionarioAttributi_dazFAzienda]  DEFAULT (0) FOR [dztFAziende]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_DizionarioAttributi_dazFProdotto]  DEFAULT (0) FOR [dztFArticoli]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_DizionarioAttributi_dazFGlobaleOfferta]  DEFAULT (0) FOR [dztFOFID]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_DizionarioAttributi_dazFValutazione]  DEFAULT (0) FOR [dztFValutazione]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_DizionarioAttributi_dztFIndicatoreQTA]  DEFAULT (0) FOR [dztFIndicatoreQTA]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_DizionarioAttributi_dazFIndicatore]  DEFAULT (0) FOR [_dztFIndicatore]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_DizionarioAttributi_dazFMascherato]  DEFAULT (0) FOR [dztFMascherato]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_DizionarioAttributi_dazFOfferta]  DEFAULT (0) FOR [_dztFOfferta]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_DizionarioAttributi_dztUltimaMod]  DEFAULT (getdate()) FOR [dztUltimaMod]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_DizionarioAttributi_dztFQualita]  DEFAULT (0) FOR [dztFQualita]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_DizionarioAttributi_dztMultiValue]  DEFAULT (0) FOR [dztMultiValue]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_DizionarioAttributi_dztLocked]  DEFAULT (0) FOR [dztLocked]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_DizionarioAttributi_dztDeleted]  DEFAULT (0) FOR [dztDeleted]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF_dztInterno]  DEFAULT (0) FOR [dztInterno]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF__Dizionari__dztMe__122052C0]  DEFAULT ((-1)) FOR [dztMemStorico]
GO
ALTER TABLE [dbo].[DizionarioAttributi] ADD  CONSTRAINT [DF__Dizionari__dztIs__5D01B3B4]  DEFAULT (0) FOR [dztIsUnicode]
GO
ALTER TABLE [dbo].[DizionarioAttributi]  WITH CHECK ADD  CONSTRAINT [FK_DizionarioAttributi_DescsI] FOREIGN KEY([dztIdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[DizionarioAttributi] CHECK CONSTRAINT [FK_DizionarioAttributi_DescsI]
GO
ALTER TABLE [dbo].[DizionarioAttributi]  WITH CHECK ADD  CONSTRAINT [FK_DizionarioAttributi_TipiDati] FOREIGN KEY([dztIdTid])
REFERENCES [dbo].[TipiDati] ([IdTid])
GO
ALTER TABLE [dbo].[DizionarioAttributi] CHECK CONSTRAINT [FK_DizionarioAttributi_TipiDati]
GO
ALTER TABLE [dbo].[DizionarioAttributi]  WITH CHECK ADD  CONSTRAINT [CK_DizionarioAttributi] CHECK  (([dztLunghezza] <= 8000))
GO
ALTER TABLE [dbo].[DizionarioAttributi] CHECK CONSTRAINT [CK_DizionarioAttributi]
GO
