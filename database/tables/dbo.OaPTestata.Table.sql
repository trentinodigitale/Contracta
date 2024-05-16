USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[OaPTestata]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OaPTestata](
	[IdOaP] [int] IDENTITY(1,1) NOT NULL,
	[IdAzi] [int] NOT NULL,
	[CodicePlant] [varchar](20) NULL,
	[SediDest] [varchar](500) NULL,
	[CodiceFornitore] [nvarchar](6) NULL,
	[DataOaP] [datetime] NULL,
	[Protocol] [nvarchar](12) NULL,
	[IdPfuDest] [int] NOT NULL,
	[TipologiaOAP] [int] NOT NULL,
	[AcceptedSchedule] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OaPTestata] ADD  CONSTRAINT [DF__OAPTestat__Tipol__74C4FA03]  DEFAULT (1) FOR [TipologiaOAP]
GO
ALTER TABLE [dbo].[OaPTestata] ADD  CONSTRAINT [DF__OAPTestat__Accep__0532CDFB]  DEFAULT (0) FOR [AcceptedSchedule]
GO
