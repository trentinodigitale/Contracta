USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[PDND_Contesti]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PDND_Contesti](
	[IDContestoAzi] [int] IDENTITY(1,1) NOT NULL,
	[NomeContesto] [nvarchar](150) NOT NULL,
	[Kid] [nvarchar](100) NOT NULL,
	[PurposeId] [nvarchar](100) NOT NULL,
	[ClientId] [nvarchar](100) NOT NULL,
	[IdContesti] [int] NOT NULL,
	[BaseAddress] [nvarchar](200) NOT NULL,
	[idAzi] [int] NULL,
 CONSTRAINT [PK_PDND_Contesti] PRIMARY KEY CLUSTERED 
(
	[IDContestoAzi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
