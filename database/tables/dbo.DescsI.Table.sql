USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[DescsI]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DescsI](
	[IdDsc] [int] IDENTITY(1,1) NOT NULL,
	[dscTesto] [nvarchar](4000) NOT NULL,
	[dscUltimaMod] [datetime] NOT NULL,
	[dscObjectId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DescsI] ADD  CONSTRAINT [DF_DescsI_dscUltimaMod]  DEFAULT (getdate()) FOR [dscUltimaMod]
GO
