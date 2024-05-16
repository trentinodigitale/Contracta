USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Aziende_Sedi]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Aziende_Sedi](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idAzi] [int] NULL,
	[TipoSede] [varchar](50) NULL,
	[Sede] [nvarchar](150) NULL,
	[Ufficio] [nvarchar](150) NULL,
	[Indirizzo] [nvarchar](150) NULL,
	[Telefono] [varchar](30) NULL,
	[FAX] [varchar](30) NULL,
	[Matricola] [varchar](30) NULL
) ON [PRIMARY]
GO
