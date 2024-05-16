USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Report_Storico]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Report_Storico](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[TipoAnalisi] [varchar](20) NULL,
	[Periodo] [datetime] NULL,
	[Tipologia] [varchar](20) NULL,
	[TipoProcedura] [varchar](20) NULL,
	[Importo] [float] NULL,
	[N_Bandi] [int] NULL,
	[N_Rettifiche] [int] NULL,
	[N_Annullamenti] [int] NULL,
	[N_Ricorsi] [int] NULL,
	[N_Deserte] [int] NULL,
 CONSTRAINT [PK_Document_Report_Storico] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
