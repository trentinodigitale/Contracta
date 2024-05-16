USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Indicatori]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Indicatori](
	[IdInd] [int] IDENTITY(1,1) NOT NULL,
	[indIdDsc] [int] NOT NULL,
	[indIdDscFormula] [int] NOT NULL,
	[indNome] [char](30) NOT NULL,
	[indTip] [tinyint] NOT NULL,
	[indNatura] [tinyint] NOT NULL,
	[indValuta] [int] NULL,
	[indFormula] [varchar](100) NOT NULL,
	[indBestSol] [tinyint] NOT NULL,
	[indPesoDef] [int] NOT NULL,
	[indDI] [datetime] NOT NULL,
	[indDF] [datetime] NOT NULL,
	[indUltimaMod] [datetime] NOT NULL,
	[indDeleted] [bit] NOT NULL,
	[indTipo] [char](1) NOT NULL,
	[indMin] [varchar](30) NULL,
	[indMax] [varchar](30) NULL,
	[indCalcolo] [char](1) NOT NULL,
	[indFunc] [text] NULL,
	[indFuncParms] [text] NULL,
 CONSTRAINT [PK_Indicatori] PRIMARY KEY NONCLUSTERED 
(
	[IdInd] ASC,
	[indDI] ASC,
	[indDF] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Indicatori] ADD  CONSTRAINT [DF_Indicatori_indDI]  DEFAULT (getdate()) FOR [indDI]
GO
ALTER TABLE [dbo].[Indicatori] ADD  CONSTRAINT [DF_Indicatori_indDF]  DEFAULT ('99991231') FOR [indDF]
GO
ALTER TABLE [dbo].[Indicatori] ADD  CONSTRAINT [DF_Indicatori_indUltimaMod]  DEFAULT (getdate()) FOR [indUltimaMod]
GO
ALTER TABLE [dbo].[Indicatori] ADD  CONSTRAINT [DF_Indicatori_indDeleted]  DEFAULT (0) FOR [indDeleted]
GO
ALTER TABLE [dbo].[Indicatori] ADD  CONSTRAINT [DF_Indicatori_indTipo]  DEFAULT ('D') FOR [indTipo]
GO
ALTER TABLE [dbo].[Indicatori] ADD  CONSTRAINT [DF_Indicatori_indCalcolo]  DEFAULT ('E') FOR [indCalcolo]
GO
ALTER TABLE [dbo].[Indicatori]  WITH CHECK ADD  CONSTRAINT [FK_Indicatori_DescsI] FOREIGN KEY([indIdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[Indicatori] CHECK CONSTRAINT [FK_Indicatori_DescsI]
GO
ALTER TABLE [dbo].[Indicatori]  WITH CHECK ADD  CONSTRAINT [FK_Indicatori_DescsI1] FOREIGN KEY([indIdDscFormula])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[Indicatori] CHECK CONSTRAINT [FK_Indicatori_DescsI1]
GO
