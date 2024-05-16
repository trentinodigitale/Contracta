USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Aziende_SOA]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Aziende_SOA](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[ClassificaSOA] [varchar](20) NULL,
	[CategoriaSOA] [varchar](20) NULL,
	[isOld] [int] NULL,
	[idAziSOA] [int] NULL,
 CONSTRAINT [PK_Document_Aziende_SOA] PRIMARY KEY CLUSTERED 
(
	[idRow] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Aziende_SOA] ADD  CONSTRAINT [DF_Document_Aziende_SOA_isOld]  DEFAULT (0) FOR [isOld]
GO
