USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Budget_Valute]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Budget_Valute](
	[BDV_BDG_Periodo] [nvarchar](10) NOT NULL,
	[BDV_CodiceValutaSource] [nvarchar](20) NOT NULL,
	[BDV_CodiceValutaDest] [nvarchar](20) NOT NULL,
	[BDV_ValueDest] [float] NULL,
	[BDV_DataCreazione] [datetime] NULL,
	[BDV_id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_Budget_Valute] PRIMARY KEY CLUSTERED 
(
	[BDV_BDG_Periodo] ASC,
	[BDV_CodiceValutaSource] ASC,
	[BDV_CodiceValutaDest] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Budget_Valute] ADD  CONSTRAINT [DF_Budget_Valute_BDV_DataCreazione]  DEFAULT (getdate()) FOR [BDV_DataCreazione]
GO
