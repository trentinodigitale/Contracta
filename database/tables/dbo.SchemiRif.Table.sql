USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[SchemiRif]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SchemiRif](
	[srIdScChild] [int] NOT NULL,
	[srIdScPar] [int] NOT NULL,
	[srMinOccurs] [char](10) NOT NULL,
	[srMaxOccurs] [char](10) NOT NULL,
 CONSTRAINT [PK_SchemiRif] PRIMARY KEY NONCLUSTERED 
(
	[srIdScChild] ASC,
	[srIdScPar] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SchemiRif]  WITH CHECK ADD  CONSTRAINT [FK_SchemiRif_Schemi] FOREIGN KEY([srIdScChild])
REFERENCES [dbo].[Schemi] ([IdSc])
GO
ALTER TABLE [dbo].[SchemiRif] CHECK CONSTRAINT [FK_SchemiRif_Schemi]
GO
ALTER TABLE [dbo].[SchemiRif]  WITH CHECK ADD  CONSTRAINT [FK_SchemiRif_Schemi1] FOREIGN KEY([srIdScPar])
REFERENCES [dbo].[Schemi] ([IdSc])
GO
ALTER TABLE [dbo].[SchemiRif] CHECK CONSTRAINT [FK_SchemiRif_Schemi1]
GO
