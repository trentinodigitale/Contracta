USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[RicercheArticoli]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RicercheArticoli](
	[racIdRic] [int] NOT NULL,
	[racIdArt] [int] NOT NULL,
	[racSegnato] [bit] NOT NULL,
 CONSTRAINT [PK_RicercheArticoli] PRIMARY KEY NONCLUSTERED 
(
	[racIdRic] ASC,
	[racIdArt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RicercheArticoli] ADD  CONSTRAINT [DF_RichercheArticoli_racSegnato]  DEFAULT (0) FOR [racSegnato]
GO
ALTER TABLE [dbo].[RicercheArticoli]  WITH CHECK ADD  CONSTRAINT [FK_RicercheArticoli_Ricerche] FOREIGN KEY([racIdRic])
REFERENCES [dbo].[Ricerche] ([IdRic])
GO
ALTER TABLE [dbo].[RicercheArticoli] CHECK CONSTRAINT [FK_RicercheArticoli_Ricerche]
GO
