USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TEMP_sblocco_istanze]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TEMP_sblocco_istanze](
	[incharge] [nvarchar](530) NULL,
	[compilatore] [nvarchar](530) NULL,
	[ID_istanza] [int] NOT NULL
) ON [PRIMARY]
GO
