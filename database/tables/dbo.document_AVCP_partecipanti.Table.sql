USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[document_AVCP_partecipanti]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[document_AVCP_partecipanti](
	[Idrow] [int] IDENTITY(1,1) NOT NULL,
	[Idheader] [int] NOT NULL,
	[Ruolopartecipante] [nvarchar](200) NULL,
	[Estero] [char](1) NULL,
	[Codicefiscale] [varchar](50) NULL,
	[Ragionesociale] [nvarchar](1000) NULL,
	[aggiudicatario] [char](1) NULL
) ON [PRIMARY]
GO
