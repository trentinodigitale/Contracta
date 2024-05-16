USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[document_ofo]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[document_ofo](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NOT NULL,
	[CurrencyId] [varchar](100) NULL,
	[PaymentConditionId] [varchar](100) NULL,
	[PaymentConditionDescription] [nvarchar](500) NULL,
	[TotalAmount] [decimal](28, 12) NULL,
	[ProjectId] [varchar](100) NULL,
	[ProjectDescription] [nvarchar](max) NULL,
	[OrderId] [varchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
