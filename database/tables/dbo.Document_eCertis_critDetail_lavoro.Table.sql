USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_eCertis_critDetail_lavoro]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_eCertis_critDetail_lavoro](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[idPfu] [int] NULL,
	[dateIns] [datetime] NULL,
	[deleted] [int] NULL,
	[criterionId] [varchar](100) NULL,
	[versionID] [int] NULL,
	[language] [varchar](10) NULL,
	[nationalEntity] [varchar](10) NULL,
	[nation] [varchar](10) NULL,
	[typeCodeId] [int] NULL,
	[typeCode] [nvarchar](50) NULL,
	[startDate] [datetime] NULL,
	[endDate] [datetime] NULL,
	[name] [varchar](500) NULL,
	[description] [nvarchar](max) NULL,
	[parentCriterionId] [varchar](100) NULL,
	[parentCriterionVersionId] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_eCertis_critDetail_lavoro] ADD  CONSTRAINT [DF_Document_eCertis_critDetail_lavoro_dateIns]  DEFAULT (getdate()) FOR [dateIns]
GO
ALTER TABLE [dbo].[Document_eCertis_critDetail_lavoro] ADD  CONSTRAINT [DF_Document_eCertis_critDetail_lavoro_deleted]  DEFAULT ((0)) FOR [deleted]
GO
