USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Quotidiani_Riferimenti]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Quotidiani_Riferimenti](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdAzi] [int] NOT NULL,
	[Nome] [nvarchar](20) NULL,
	[Cognome] [nvarchar](30) NOT NULL,
	[Telefono] [nvarchar](20) NOT NULL,
	[Cellulare] [nvarchar](20) NULL,
	[Fax] [nvarchar](20) NOT NULL,
	[Email] [nvarchar](50) NULL,
 CONSTRAINT [PK_Document_Quotidiani_Riferimenti] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
