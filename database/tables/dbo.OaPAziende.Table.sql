USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[OaPAziende]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OaPAziende](
	[IdOaPLast] [int] NOT NULL,
	[IdAzi] [int] NOT NULL,
	[DataOaP] [datetime] NOT NULL,
	[NumeroOaP] [int] NOT NULL,
	[CodicePlant] [varchar](20) NULL,
	[TipologiaOAP] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OaPAziende] ADD  CONSTRAINT [DF__OAPAziend__Tipol__73D0D5CA]  DEFAULT (1) FOR [TipologiaOAP]
GO
