USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Aziende_Esecutrici]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Aziende_Esecutrici](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idAzi] [int] NULL,
	[idMsg] [int] NULL,
	[ProtocolloBando] [varchar](50) NULL,
	[idAziEsecutrice] [int] NULL,
	[Esecutrice] [varchar](20) NULL,
	[idHeader] [int] NULL,
 CONSTRAINT [PK_Document_Aziende_Esecutrici] PRIMARY KEY CLUSTERED 
(
	[idRow] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Aziende_Esecutrici] ADD  CONSTRAINT [DF_Document_Aziende_Esecutrici_Deleted]  DEFAULT ('si') FOR [Esecutrice]
GO
