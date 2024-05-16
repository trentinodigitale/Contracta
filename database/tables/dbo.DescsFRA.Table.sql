USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DescsFRA]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DescsFRA](
	[IdDsc] [int] NOT NULL,
	[dscTesto] [nvarchar](4000) NOT NULL,
	[dscUltimaMod] [datetime] NOT NULL,
	[dscObjectId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DescsFRA] ADD  CONSTRAINT [DF_DescsFRA_dscUltimaMod]  DEFAULT (getdate()) FOR [dscUltimaMod]
GO
ALTER TABLE [dbo].[DescsFRA]  WITH CHECK ADD  CONSTRAINT [FK_DescsFRA_DescsI] FOREIGN KEY([IdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[DescsFRA] CHECK CONSTRAINT [FK_DescsFRA_DescsI]
GO
