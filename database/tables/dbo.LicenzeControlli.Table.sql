USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[LicenzeControlli]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LicenzeControlli](
	[IdLic] [int] IDENTITY(1,1) NOT NULL,
	[LicSource] [varchar](50) NOT NULL,
	[LicKeyLicense] [varchar](50) NULL,
	[LicTipo] [char](1) NOT NULL,
	[LicProfilo] [varchar](10) NOT NULL,
	[LicUltimaMod] [datetime] NOT NULL,
	[LicDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_LicenzeControlli] PRIMARY KEY NONCLUSTERED 
(
	[IdLic] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LicenzeControlli] ADD  CONSTRAINT [DF_LicenzeControlli_LicUltimaMod]  DEFAULT (getdate()) FOR [LicUltimaMod]
GO
ALTER TABLE [dbo].[LicenzeControlli] ADD  CONSTRAINT [DF_LicenzeControlli_LicCancellato]  DEFAULT (0) FOR [LicDeleted]
GO
