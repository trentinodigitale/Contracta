USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_eCertis_Legislations_lavoro]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_eCertis_Legislations_lavoro](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idCritDetail] [int] NULL,
	[deleted] [int] NULL,
	[title] [varchar](500) NULL,
	[description] [nvarchar](max) NULL,
	[jurisdictionLevelCode] [varchar](10) NULL,
	[uri] [varchar](500) NULL,
	[idPfu] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_eCertis_Legislations_lavoro] ADD  CONSTRAINT [DF_Document_eCertis_Legislations_lavoro_deleted]  DEFAULT ((0)) FOR [deleted]
GO
