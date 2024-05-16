USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Convenzione_Quota_Lotti]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Convenzione_Quota_Lotti](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[NumeroLotto] [varchar](50) NULL,
	[Descrizione] [nvarchar](1000) NULL,
	[Importo_Q_Lotto] [float] NULL,
	[Importo] [float] NULL,
	[ImportoRichiesto] [float] NULL,
	[Importo_Allocato_Prec] [float] NULL
) ON [PRIMARY]
GO
