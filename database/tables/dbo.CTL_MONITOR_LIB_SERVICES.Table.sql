USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_MONITOR_LIB_SERVICES]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_MONITOR_LIB_SERVICES](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SRV_id] [int] NULL,
	[NumeroProcessiCoda] [int] NULL,
	[Descrizione] [nvarchar](max) NULL,
	[SRV_SecIntervalEsteso] [nvarchar](max) NULL,
	[DATA_APERTURA_ALERT] [datetime] NULL,
	[DATA_CHIUSURA_ALERT] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
