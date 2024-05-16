USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[BACKUP_AFFIDAMENTI_SENZA_CDC_2004_04_15]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BACKUP_AFFIDAMENTI_SENZA_CDC_2004_04_15](
	[id] [int] NOT NULL,
	[pcp_tiposcheda] [nvarchar](200) NULL,
	[Data] [datetime] NULL,
	[protocollo] [varchar](50) NULL,
	[cig] [varchar](50) NULL,
	[statofunzionale] [varchar](50) NULL,
	[pfunome] [nvarchar](530) NULL,
	[RUP] [int] NOT NULL,
	[pcp_CodiceCentroDiCosto] [nvarchar](1000) NULL,
	[azienda] [varchar](50) NULL
) ON [PRIMARY]
GO
