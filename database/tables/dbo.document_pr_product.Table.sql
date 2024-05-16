USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[document_pr_product]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[document_pr_product](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idheader] [int] NULL,
	[PurchaseRequestMeasurementId] [int] NULL,
	[ProductId] [nvarchar](100) NULL,
	[ProductDescription] [nvarchar](500) NULL,
	[ProductDescriptionText] [nvarchar](max) NULL,
	[ProductUnitId] [varchar](50) NULL,
	[ProductUnitDescription] [nvarchar](500) NULL,
	[Quantity] [decimal](28, 12) NULL,
	[UnitCost] [decimal](28, 12) NULL,
	[DeliveryDate] [datetime] NULL,
	[DescriptionText] [nvarchar](max) NULL,
	[WorkBreakdownElementId] [varchar](50) NULL,
	[WorkBreakdownElementDescription] [nvarchar](500) NULL,
	[CatalogType] [nvarchar](1000) NULL,
	[CatalogProjectId] [nvarchar](1000) NULL,
	[CatalogId] [nvarchar](1000) NULL,
	[ProductParentId] [nvarchar](1000) NULL,
	[ERPWorkBreakdownElementId] [nvarchar](1000) NULL,
	[NodeTypeId] [nvarchar](1000) NULL,
	[ERPProductId] [nvarchar](25) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
