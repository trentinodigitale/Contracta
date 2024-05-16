USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_RicPrevPubblic_Quotidiani]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_RicPrevPubblic_Quotidiani](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[idRicPubblic] [int] NULL,
	[Giornale] [varchar](20) NULL,
	[NumMod] [int] NULL,
	[Importo] [float] NULL,
	[StatoQuotidiano] [varchar](20) NULL,
	[PEG] [varchar](40) NULL,
	[RDP_VDS] [varchar](40) NULL,
	[Fornitore] [varchar](20) NULL,
	[Disponibilita] [varchar](20) NULL,
	[Ticket] [int] NULL,
	[Added] [char](1) NULL,
	[NonEditabili] [varchar](255) NULL,
	[DataPubblicazione] [datetime] NULL,
	[Storico] [int] NULL,
	[Tipo] [varchar](50) NULL,
	[CIG] [varchar](20) NULL,
	[Allegato] [nvarchar](255) NULL,
	[CostoBollo] [float] NULL,
	[NumeroGazzetta] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_RicPrevPubblic_Quotidiani] ADD  CONSTRAINT [DF_Document_RicPrevPubblic_Quotidiani_Added]  DEFAULT ('0') FOR [Added]
GO
ALTER TABLE [dbo].[Document_RicPrevPubblic_Quotidiani] ADD  CONSTRAINT [DF_Document_RicPrevPubblic_Quotidiani_Storico]  DEFAULT (0) FOR [Storico]
GO
