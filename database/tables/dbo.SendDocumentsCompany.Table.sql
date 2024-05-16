USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[SendDocumentsCompany]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SendDocumentsCompany](
	[ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[sdcSediDest] [varchar](255) NOT NULL,
	[sdcCodPlant] [varchar](2) NOT NULL,
	[sdcIdAzi] [int] NOT NULL,
	[sdcCodice] [varchar](6) NOT NULL,
	[sdcType] [smallint] NOT NULL,
	[sdcSubType] [smallint] NOT NULL,
	[sdcObject] [varchar](255) NOT NULL,
	[sdcRiferimento] [varchar](255) NOT NULL,
	[sdcEmail] [varchar](255) NOT NULL,
	[sdcFax] [varchar](255) NOT NULL,
 CONSTRAINT [PK_SendDocumentsCompany] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
