USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[PluginDetails]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PluginDetails](
	[IdPD] [int] IDENTITY(1,1) NOT NULL,
	[pdIdPlg] [int] NOT NULL,
	[pdIdMp] [int] NULL,
	[pdIdDcm] [int] NULL,
	[pdDocParms] [smallint] NULL,
	[pdActivation] [varchar](50) NULL,
	[PdImageName] [varchar](100) NULL,
	[pdType] [smallint] NOT NULL,
	[pdStartPage] [varchar](100) NOT NULL,
	[pdURLParms] [varchar](1000) NULL,
	[pdIsAbsolute] [tinyint] NOT NULL,
	[pdOrder] [int] NOT NULL,
	[pdVisualAttrib] [varchar](1000) NULL,
 CONSTRAINT [PK_PluginDetails] PRIMARY KEY CLUSTERED 
(
	[IdPD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PluginDetails] ADD  CONSTRAINT [DF_PluginDetails_pdIsAbsolute]  DEFAULT (0) FOR [pdIsAbsolute]
GO
ALTER TABLE [dbo].[PluginDetails] ADD  CONSTRAINT [DF_PluginDetails_pdOrder]  DEFAULT (0) FOR [pdOrder]
GO
ALTER TABLE [dbo].[PluginDetails]  WITH CHECK ADD  CONSTRAINT [FK_PluginDetails_Plugin] FOREIGN KEY([pdIdPlg])
REFERENCES [dbo].[Plugin] ([IdPlg])
GO
ALTER TABLE [dbo].[PluginDetails] CHECK CONSTRAINT [FK_PluginDetails_Plugin]
GO
