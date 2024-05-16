USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Convenzioni]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Convenzioni](
	[IdCnv] [smallint] NOT NULL,
	[cnvIdDsc] [int] NOT NULL,
	[DeleteAG] [bit] NOT NULL,
	[DeleteAE] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Convenzioni] ADD  CONSTRAINT [DF_Convenzioni_DeleteAG]  DEFAULT (0) FOR [DeleteAG]
GO
ALTER TABLE [dbo].[Convenzioni] ADD  CONSTRAINT [DF_Convenzioni_DeleteAE]  DEFAULT (0) FOR [DeleteAE]
GO
ALTER TABLE [dbo].[Convenzioni]  WITH CHECK ADD  CONSTRAINT [FK_Convenzioni_DescsI] FOREIGN KEY([cnvIdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[Convenzioni] CHECK CONSTRAINT [FK_Convenzioni_DescsI]
GO
