USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPMail]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPMail](
	[IdMpm] [int] IDENTITY(1,1) NOT NULL,
	[mpmIdMp] [int] NOT NULL,
	[mpmEvento] [varchar](30) NOT NULL,
	[mpmLng] [varchar](5) NOT NULL,
	[mpmTo] [nvarchar](100) NOT NULL,
	[mpmFrom] [nvarchar](100) NULL,
	[mpmCC] [nvarchar](100) NULL,
	[mpmCCN] [nvarchar](100) NULL,
	[idAzi] [int] NULL,
 CONSTRAINT [PK_MPMail] PRIMARY KEY CLUSTERED 
(
	[IdMpm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
