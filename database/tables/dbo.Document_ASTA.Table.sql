USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_ASTA]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_ASTA](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[NumeroLotto] [int] NULL,
	[StatoAsta] [nvarchar](20) NULL,
	[Importo] [float] NULL,
	[DataInizio] [datetime] NULL,
	[DataScadenzaAsta] [datetime] NULL,
	[RilancioMinimo] [float] NULL,
	[BaseCalcolo] [float] NULL,
	[AutoExt] [int] NULL,
	[Ext] [int] NULL,
	[TipoExt] [nvarchar](20) NULL,
	[RaggTarget] [int] NULL,
	[TipoAsta] [nvarchar](20) NULL,
	[UltimaMod] [datetime] NULL,
	[DataScadOrig] [datetime] NULL,
	[TryClose] [int] NULL,
	[DataStartTryClose] [datetime] NULL
) ON [PRIMARY]
GO
