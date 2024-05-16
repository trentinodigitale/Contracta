USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Esito_Qualificazione_Allegati]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Esito_Qualificazione_Allegati](
	[IdComAll] [int] IDENTITY(1,1) NOT NULL,
	[IdCom] [int] NULL,
	[LinguaAll] [varchar](50) NULL,
	[Allegato] [varchar](255) NULL,
 CONSTRAINT [PK_Document_Esito_Qualificazione_Allegati] PRIMARY KEY CLUSTERED 
(
	[IdComAll] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
