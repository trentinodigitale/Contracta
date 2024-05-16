USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DescsE]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DescsE](
	[IdDsc] [int] NOT NULL,
	[dscTesto] [nvarchar](4000) NOT NULL,
	[dscUltimaMod] [datetime] NOT NULL,
	[dscObjectId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DescsE] ADD  CONSTRAINT [DF_DescsE_dscUltimaMod]  DEFAULT (getdate()) FOR [dscUltimaMod]
GO
ALTER TABLE [dbo].[DescsE]  WITH CHECK ADD  CONSTRAINT [FK_DescsE_DescsI] FOREIGN KEY([IdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[DescsE] CHECK CONSTRAINT [FK_DescsE_DescsI]
GO
