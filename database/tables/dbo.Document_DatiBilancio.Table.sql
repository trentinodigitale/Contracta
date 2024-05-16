USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_DatiBilancio]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_DatiBilancio](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[BP_Anno] [varchar](4) NULL,
	[CP_Nr] [int] NULL,
	[CP_Data] [varchar](20) NULL,
	[BP_Triennio] [varchar](50) NULL,
	[GP_Nr] [int] NULL,
	[GP_Data] [varchar](20) NULL,
	[RPP_Triennio] [varchar](50) NULL,
	[BE_Anno] [varchar](50) NULL,
	[ImportoAccMax] [varchar](20) NULL,
	[NR_Acc] [int] NULL,
	[Impegno] [varchar](20) NULL,
	[NotaRag] [int] NULL,
	[DataRag] [varchar](20) NULL,
	[TassaReg] [varchar](20) NULL,
	[DataDecreto] [varchar](20) NULL,
	[NR_GU] [int] NULL,
	[Data_GU] [varchar](20) NULL,
	[DataDifferimento] [varchar](20) NULL,
	[Importo_AE] [varchar](20) NULL,
	[Data_AE] [varchar](20) NULL,
	[Det_ImpBollo] [varchar](20) NULL,
	[Data_ImpBollo] [varchar](20) NULL
) ON [PRIMARY]
GO
