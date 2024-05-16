USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Budget_ValuteSocieta]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Budget_ValuteSocieta](
	[BDS_BDG_Periodo] [nvarchar](10) NOT NULL,
	[BDS_CodiceValuta] [nvarchar](20) NOT NULL,
	[BDS_CodSoc] [nvarchar](20) NOT NULL,
	[BDS_DataCreazione] [datetime] NULL,
	[BDS_id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_Budget_ValuteSocieta] PRIMARY KEY CLUSTERED 
(
	[BDS_BDG_Periodo] ASC,
	[BDS_CodSoc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Budget_ValuteSocieta] ADD  CONSTRAINT [DF_Budget_ValuteSocieta_BDS_DataCreazione]  DEFAULT (getdate()) FOR [BDS_DataCreazione]
GO
