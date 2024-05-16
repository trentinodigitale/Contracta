USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[document_pr]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[document_pr](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idheader] [int] NULL,
	[CompanyCF] [nvarchar](50) NULL,
	[ProjectId] [nvarchar](50) NULL,
	[ProjectDescription] [nvarchar](500) NULL,
	[NominativeCF] [nvarchar](50) NULL,
	[NominativeDescription] [nvarchar](500) NULL,
	[Applicant] [nvarchar](500) NULL,
	[ApplicantCF] [nvarchar](500) NULL,
	[DeliveryAddress] [nvarchar](550) NULL,
	[DeliveryLocation] [nvarchar](550) NULL,
	[PurchaseRequestNotes] [nvarchar](max) NULL,
	[DocumentTypeId] [nvarchar](1000) NULL,
	[ERPProjectId] [nvarchar](1000) NULL,
	[SenderType] [nvarchar](1000) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
