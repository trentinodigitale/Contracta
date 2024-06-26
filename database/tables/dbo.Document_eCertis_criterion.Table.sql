USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_eCertis_criterion]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_eCertis_criterion](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[dateIns] [datetime] NOT NULL,
	[lastUpdate] [datetime] NULL,
	[deleted] [int] NOT NULL,
	[criterionId] [varchar](100) NULL,
	[versionId] [int] NULL,
	[nationalEntity] [varchar](5) NULL,
	[nation] [varchar](500) NULL,
	[startDate] [date] NULL,
	[endDate] [date] NULL,
	[name] [varchar](500) NULL,
	[description] [nvarchar](max) NULL,
	[parentCriterionId] [varchar](100) NULL,
	[parentCriterionVersionId] [int] NULL,
	[note] [varchar](4000) NULL,
	[dataUpdEvidence] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_eCertis_criterion] ADD  CONSTRAINT [DF_Document_eCertis_criterion_dateIns]  DEFAULT (getdate()) FOR [dateIns]
GO
ALTER TABLE [dbo].[Document_eCertis_criterion] ADD  CONSTRAINT [DF_Document_eCertis_criterion_lastUpdate]  DEFAULT (getdate()) FOR [lastUpdate]
GO
ALTER TABLE [dbo].[Document_eCertis_criterion] ADD  CONSTRAINT [DF_Document_eCertis_criterion_deleted]  DEFAULT ((0)) FOR [deleted]
GO
