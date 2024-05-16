USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Percentuali]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Percentuali](
	[IdPerc] [int] IDENTITY(1,1) NOT NULL,
	[IdAzi] [int] NOT NULL,
	[CodSocietaListino] [varchar](20) NULL,
	[CodicePlant] [varchar](1000) NULL,
	[CodiceArticolo] [nvarchar](30) NULL,
	[CodOperFase] [varchar](20) NULL,
	[Utilizzo] [varchar](20) NULL,
	[Fase] [varchar](20) NULL,
	[DataIniArt] [datetime] NULL,
	[DataFineArt] [datetime] NULL,
	[Perc] [varchar](50) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[LastUpdate] [datetime] NOT NULL,
	[IsAssigned] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Percentuali] ADD  CONSTRAINT [DF_Percentuali_Fase]  DEFAULT (0) FOR [Fase]
GO
ALTER TABLE [dbo].[Percentuali] ADD  CONSTRAINT [DF_Percentuali_DataFineArt]  DEFAULT (2050 - 12 - 31) FOR [DataFineArt]
GO
ALTER TABLE [dbo].[Percentuali] ADD  CONSTRAINT [DF_Percentuali_Perc]  DEFAULT (0) FOR [Perc]
GO
ALTER TABLE [dbo].[Percentuali] ADD  CONSTRAINT [DF_Percentuali_Deleted]  DEFAULT (0) FOR [Deleted]
GO
ALTER TABLE [dbo].[Percentuali] ADD  CONSTRAINT [DF_Percentuali_LastUpdate]  DEFAULT (getdate()) FOR [LastUpdate]
GO
ALTER TABLE [dbo].[Percentuali] ADD  CONSTRAINT [DF__Percentua__IsAss__6ECC298B]  DEFAULT (10099) FOR [IsAssigned]
GO
