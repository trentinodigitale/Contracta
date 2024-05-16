USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DescsUK]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DescsUK](
	[IdDsc] [int] NOT NULL,
	[dscTesto] [nvarchar](4000) NOT NULL,
	[dscUltimaMod] [datetime] NOT NULL,
	[dscObjectId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DescsUK] ADD  CONSTRAINT [DF_DescsUK_dscUltimaMod]  DEFAULT (getdate()) FOR [dscUltimaMod]
GO
ALTER TABLE [dbo].[DescsUK]  WITH CHECK ADD  CONSTRAINT [FK_DescsUK_DescsI] FOREIGN KEY([IdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[DescsUK] CHECK CONSTRAINT [FK_DescsUK_DescsI]
GO
