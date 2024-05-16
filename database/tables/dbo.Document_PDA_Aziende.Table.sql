USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_PDA_Aziende]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_PDA_Aziende](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdPdA] [varchar](15) NULL,
	[NumRiga] [varchar](15) NULL,
	[RagSoc] [varchar](500) NULL,
	[ProtocolloOfferta] [varchar](40) NULL,
	[EconomicScoreClassic] [varchar](15) NULL,
	[ReceivedDataMsg] [varchar](30) NULL,
	[StatoPDA] [varchar](15) NULL,
	[SogliaAnomalia] [varchar](15) NULL,
	[IdMsg] [varchar](15) NULL,
	[ISubType] [varchar](15) NULL,
	[IdMittente] [varchar](15) NULL
) ON [PRIMARY]
GO
