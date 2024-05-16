USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempModelliAziende]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempModelliAziende](
	[IdMaz] [int] IDENTITY(1,1) NOT NULL,
	[mazIdMdl] [int] NOT NULL,
	[mazIdAzi] [int] NOT NULL,
	[mazProg] [smallint] NULL,
	[mazProtocollo] [nvarchar](12) NULL,
	[mazDataInvio] [datetime] NULL,
	[mazRank] [tinyint] NULL,
	[mazIdOff] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempModelliAziende] ADD  CONSTRAINT [DF_TempModelliAziende_mazDataInvio]  DEFAULT (getdate()) FOR [mazDataInvio]
GO
