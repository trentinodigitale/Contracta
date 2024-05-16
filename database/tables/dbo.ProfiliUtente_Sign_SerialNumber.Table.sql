USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ProfiliUtente_Sign_SerialNumber]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProfiliUtente_Sign_SerialNumber](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdPfu] [int] NOT NULL,
	[Tipo_SerialNumber] [varchar](50) NULL,
	[SerialNumber] [nvarchar](500) NOT NULL,
	[AllegatoFirmato] [nvarchar](500) NULL,
	[Data] [datetime] NOT NULL,
	[CodiceFiscale] [varchar](100) NOT NULL,
	[Deleted] [bit] NULL,
	[IdHeader] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProfiliUtente_Sign_SerialNumber] ADD  CONSTRAINT [DF_ProfiliUtente_Sign_SerialNumber_Data]  DEFAULT (getdate()) FOR [Data]
GO
ALTER TABLE [dbo].[ProfiliUtente_Sign_SerialNumber] ADD  CONSTRAINT [DF_ProfiliUtente_Sign_SerialNumber_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
