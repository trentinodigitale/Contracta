USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[IntegrationData]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IntegrationData](
	[IdInt] [int] IDENTITY(1,1) NOT NULL,
	[intIType] [smallint] NOT NULL,
	[intISubType] [smallint] NOT NULL,
	[intKeyElement] [varchar](255) NOT NULL,
	[intIdDzt] [int] NOT NULL,
	[intValue] [varchar](255) NULL
) ON [PRIMARY]
GO
