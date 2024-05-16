USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_eCertis_log]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_eCertis_log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[dateIns] [datetime] NOT NULL,
	[url] [varchar](4000) NOT NULL,
	[responseBody] [nvarchar](max) NULL,
	[responseStatusCode] [varchar](10) NULL,
	[responseStatusDescription] [varchar](4000) NULL,
	[responseTime] [int] NULL,
	[esitoImportCriterion] [nvarchar](max) NULL,
	[totInseriti] [int] NULL,
	[totCancellati] [int] NULL,
	[totModificati] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_eCertis_log] ADD  CONSTRAINT [DF_Document_eCertis_log_dateIns]  DEFAULT (getdate()) FOR [dateIns]
GO
