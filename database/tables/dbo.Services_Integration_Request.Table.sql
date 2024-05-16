USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Services_Integration_Request]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Services_Integration_Request](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idRichiesta] [int] NULL,
	[integrazione] [varchar](50) NULL,
	[operazioneRichiesta] [varchar](50) NULL,
	[statoRichiesta] [varchar](50) NULL,
	[datoRichiesto] [nvarchar](max) NULL,
	[msgError] [nvarchar](max) NULL,
	[numRetry] [int] NULL,
	[inputWS] [nvarchar](max) NULL,
	[outputWS] [nvarchar](max) NULL,
	[isOld] [int] NULL,
	[dateIn] [datetime] NULL,
	[DataExecuted] [datetime] NULL,
	[DataFinalizza] [datetime] NULL,
	[idPfu] [int] NULL,
	[idAzi] [int] NULL,
	[InOut] [varchar](10) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Services_Integration_Request] ADD  CONSTRAINT [DF_Services_Integration_Request_numRetry]  DEFAULT ((0)) FOR [numRetry]
GO
ALTER TABLE [dbo].[Services_Integration_Request] ADD  CONSTRAINT [DF_Services_Integration_Request_isOld]  DEFAULT ((0)) FOR [isOld]
GO
ALTER TABLE [dbo].[Services_Integration_Request] ADD  CONSTRAINT [DF_Services_Integration_Request_dateIn]  DEFAULT (getdate()) FOR [dateIn]
GO
ALTER TABLE [dbo].[Services_Integration_Request] ADD  DEFAULT ('OUT') FOR [InOut]
GO
