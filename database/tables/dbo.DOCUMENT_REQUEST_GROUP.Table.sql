USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DOCUMENT_REQUEST_GROUP]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DOCUMENT_REQUEST_GROUP](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [bigint] NULL,
	[ItemLevel] [int] NULL,
	[ItemPath] [nvarchar](500) NULL,
	[Domanda_Elenco] [nvarchar](50) NULL,
	[TypeRequest] [varchar](50) NULL,
	[idCriterion] [int] NULL,
	[GL1] [int] NULL,
	[RL1] [int] NULL,
	[GL2] [int] NULL,
	[RL2] [int] NULL,
	[GL3] [int] NULL,
	[RL3] [int] NULL,
	[GL4] [int] NULL,
	[RL4] [int] NULL,
	[O1] [int] NULL,
	[O2] [int] NULL,
	[ITEM_ID] [varchar](50) NULL,
	[CRITERION_CODE] [varchar](500) NULL,
	[UUID] [varchar](500) NULL,
	[DescrizioneEstesa] [nvarchar](max) NULL,
	[Related] [varchar](50) NULL,
	[RG_FLD_TYPE] [varchar](50) NULL,
	[DescrizioneEstesaUK] [nvarchar](max) NULL,
	[Iterabile] [int] NULL,
	[Obbligatorio] [int] NULL,
	[InCaricoA] [varchar](20) NULL,
	[SorgenteCampo] [varchar](100) NULL,
	[RegExp] [varchar](max) NULL,
	[Edit] [nvarchar](5) NULL,
	[Note] [nvarchar](max) NULL,
	[Note_UK] [nvarchar](max) NULL,
	[Condizione] [varchar](200) NULL,
	[Multivalore] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
