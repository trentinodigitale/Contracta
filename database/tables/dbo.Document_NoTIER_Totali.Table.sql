USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_NoTIER_Totali]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_NoTIER_Totali](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[AnticipatedMonetaryTotal_LineExtensionAmount] [decimal](18, 2) NULL,
	[AnticipatedMonetaryTotal_TaxExclusiveAmount] [decimal](18, 2) NULL,
	[AnticipatedMonetaryTotal_TaxInclusiveAmount] [decimal](18, 2) NULL,
	[AnticipatedMonetaryTotal_PayableAmount] [decimal](18, 2) NULL,
	[TaxTotal] [decimal](18, 2) NULL,
	[AnticipatedMonetaryTotal_AllowanceTotalAmount] [decimal](18, 2) NULL,
	[AnticipatedMonetaryTotal_ChargeTotalAmount] [decimal](18, 2) NULL,
	[AnticipatedMonetaryTotal_TotaleRitenuta] [decimal](18, 2) NULL,
	[AnticipatedMonetaryTotal_TotaleCPA] [decimal](18, 2) NULL,
	[AnticipatedMonetaryTotal_TotaleContributi] [decimal](18, 2) NULL
) ON [PRIMARY]
GO
