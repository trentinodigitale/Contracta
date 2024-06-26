USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_eCertis_evidence_lavoro]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_eCertis_evidence_lavoro](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[idPfu] [int] NULL,
	[dateIns] [datetime] NOT NULL,
	[deleted] [int] NOT NULL,
	[evidenceId] [varchar](100) NULL,
	[criterionId] [varchar](100) NULL,
	[criterionVersionId] [int] NULL,
	[criterionNationalEntity] [varchar](5) NULL,
	[typeCode] [varchar](100) NULL,
	[name] [varchar](500) NULL,
	[description] [nvarchar](max) NULL,
	[idCritDetail] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_eCertis_evidence_lavoro] ADD  CONSTRAINT [DF_Document_eCertis_evidence_lavoro_dateIns]  DEFAULT (getdate()) FOR [dateIns]
GO
ALTER TABLE [dbo].[Document_eCertis_evidence_lavoro] ADD  CONSTRAINT [DF_Document_eCertis_evidence_lavoro_deleted]  DEFAULT ((0)) FOR [deleted]
GO
