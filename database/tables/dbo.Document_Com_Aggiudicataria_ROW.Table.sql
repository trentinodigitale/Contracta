USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Com_Aggiudicataria_ROW]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Com_Aggiudicataria_ROW](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idHeader] [int] NULL,
	[DescrizioneEstesa] [ntext] NULL,
	[SelRow] [varchar](1) NULL,
	[Pos] [int] NULL,
 CONSTRAINT [PK_Document_Com_Aggiudicataria_ROW] PRIMARY KEY CLUSTERED 
(
	[idRow] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
