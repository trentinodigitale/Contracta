USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[document_CommissionePda_Blocco]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[document_CommissionePda_Blocco](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdHeader] [int] NOT NULL,
	[Busta] [varchar](50) NOT NULL,
	[BloccoBusta] [varchar](50) NOT NULL
) ON [PRIMARY]
GO
