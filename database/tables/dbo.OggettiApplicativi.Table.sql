USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[OggettiApplicativi]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OggettiApplicativi](
	[IdOap] [int] IDENTITY(1,1) NOT NULL,
	[oapVersione] [smallint] NOT NULL,
	[oapNomeOggetto] [nvarchar](30) NOT NULL,
	[oapCriterio] [char](1) NOT NULL,
	[oapDatiCriterio] [text] NOT NULL,
	[oapProfilo] [varchar](20) NOT NULL,
	[oapCancellato] [bit] NOT NULL,
	[oapUltimaMod] [datetime] NOT NULL,
 CONSTRAINT [PK_OggettiApplicativi] PRIMARY KEY NONCLUSTERED 
(
	[IdOap] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[OggettiApplicativi] ADD  CONSTRAINT [DF_OggettiApplicativi_oapCancellato]  DEFAULT (0) FOR [oapCancellato]
GO
ALTER TABLE [dbo].[OggettiApplicativi] ADD  CONSTRAINT [DF_OggettiApplicativi_oapUltimaMod]  DEFAULT (getdate()) FOR [oapUltimaMod]
GO
