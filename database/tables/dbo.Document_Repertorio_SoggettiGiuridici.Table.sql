USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Repertorio_SoggettiGiuridici]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Repertorio_SoggettiGiuridici](
	[IdRow] [int] IDENTITY(1,1) NOT NULL,
	[IdRepertorio] [int] NOT NULL,
	[IdAzi] [int] NOT NULL,
	[aziRagioneSociale] [nvarchar](1000) NULL,
	[aziPartitaIVA] [varchar](50) NULL,
	[aziIndirizzoLeg] [varchar](150) NULL,
	[aziLocalitaLeg] [varchar](150) NULL,
 CONSTRAINT [PK_Document_Repertorio_SoggettiGiuridici] PRIMARY KEY CLUSTERED 
(
	[IdRow] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
