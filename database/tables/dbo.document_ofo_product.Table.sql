USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[document_ofo_product]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[document_ofo_product](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[CatalogType] [varchar](100) NULL,
	[CatalogId] [varchar](100) NULL,
	[ProductParentId] [varchar](100) NULL,
	[ProductId] [varchar](100) NULL,
	[CatalogProjectId] [varchar](100) NULL,
	[Amount] [decimal](28, 12) NULL,
	[Quantity] [decimal](28, 12) NULL,
	[Price] [decimal](28, 12) NULL,
	[WorkBreakdownElementId] [varchar](100) NULL,
	[UnitId] [varchar](100) NULL,
	[CostCenterId] [varchar](100) NULL,
	[ExpenseItemId] [varchar](100) NULL,
	[ProductDescription] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
