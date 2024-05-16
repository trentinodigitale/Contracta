USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_ModF23_Tributi]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_ModF23_Tributi](
	[idrow] [int] IDENTITY(1,1) NOT NULL,
	[idheader] [int] NOT NULL,
	[codicetributo] [nvarchar](50) NULL,
	[descrizione] [nvarchar](100) NULL,
	[importo] [money] NULL
) ON [PRIMARY]
GO
