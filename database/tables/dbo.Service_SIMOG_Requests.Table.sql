USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Service_SIMOG_Requests]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Service_SIMOG_Requests](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idRichiesta] [int] NULL,
	[operazioneRichiesta] [varchar](50) NULL,
	[statoRichiesta] [varchar](50) NULL,
	[datoRichiesto] [varchar](100) NULL,
	[msgError] [nvarchar](max) NULL,
	[numRetry] [int] NULL,
	[inputWS] [nvarchar](max) NULL,
	[outputWS] [nvarchar](max) NULL,
	[isOld] [int] NULL,
	[dateIn] [datetime] NULL,
	[DataExecuted] [datetime] NULL,
	[DataFinalizza] [datetime] NULL,
	[idPfuRup] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Service_SIMOG_Requests] ADD  CONSTRAINT [DF_Service_SIMOG_Requests_numRetry]  DEFAULT ((0)) FOR [numRetry]
GO
ALTER TABLE [dbo].[Service_SIMOG_Requests] ADD  CONSTRAINT [DF_Service_SIMOG_Requests_isOld]  DEFAULT ((0)) FOR [isOld]
GO
ALTER TABLE [dbo].[Service_SIMOG_Requests] ADD  CONSTRAINT [DF_Service_SIMOG_Requests_dateIn]  DEFAULT (getdate()) FOR [dateIn]
GO
