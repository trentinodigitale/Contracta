USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DescsLng2]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DescsLng2](
	[IdDsc] [int] NOT NULL,
	[dscTesto] [nvarchar](4000) NOT NULL,
	[dscUltimaMod] [datetime] NOT NULL,
	[dscObjectId] [int] NULL,
 CONSTRAINT [PK_DescsLng2] PRIMARY KEY NONCLUSTERED 
(
	[IdDsc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DescsLng2] ADD  CONSTRAINT [DF_DescsLng2_dscUltimaMod]  DEFAULT (getdate()) FOR [dscUltimaMod]
GO
ALTER TABLE [dbo].[DescsLng2]  WITH CHECK ADD  CONSTRAINT [FK_DescsLng2_DescsI] FOREIGN KEY([IdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[DescsLng2] CHECK CONSTRAINT [FK_DescsLng2_DescsI]
GO
