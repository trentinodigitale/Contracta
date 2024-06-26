USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempModelli]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempModelli](
	[IdMdl] [int] NOT NULL,
	[mdlIdPfu] [int] NOT NULL,
	[mdlNome] [nvarchar](20) NOT NULL,
	[mdlStato] [tinyint] NOT NULL,
	[mdlProt] [smallint] NULL,
	[mdlOggetto] [nvarchar](200) NULL,
	[mdlDTO] [datetime] NULL,
	[mdlNote] [ntext] NULL,
	[mdlNRdo] [smallint] NOT NULL,
	[mdlNOfferte] [smallint] NOT NULL,
	[mdlXCPubLeg] [tinyint] NOT NULL,
	[mdlYCPubLeg] [tinyint] NOT NULL,
	[mdlXCLogo] [tinyint] NOT NULL,
	[mdlYCLogo] [tinyint] NOT NULL,
	[mdlXCProtocollo] [tinyint] NOT NULL,
	[mdlYCProtocollo] [tinyint] NOT NULL,
	[mdlXCData] [tinyint] NOT NULL,
	[mdlYCData] [tinyint] NOT NULL,
	[mdlDeleted] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempModelli] ADD  CONSTRAINT [DF_TempModelli_mdlNome]  DEFAULT ('Default') FOR [mdlNome]
GO
ALTER TABLE [dbo].[TempModelli] ADD  CONSTRAINT [DF_TempModelli_mdlStato]  DEFAULT (0) FOR [mdlStato]
GO
ALTER TABLE [dbo].[TempModelli] ADD  CONSTRAINT [DF_TempModelli_mdlNRdo]  DEFAULT (0) FOR [mdlNRdo]
GO
ALTER TABLE [dbo].[TempModelli] ADD  CONSTRAINT [DF_TempModelli_mdlNOfferte]  DEFAULT (0) FOR [mdlNOfferte]
GO
ALTER TABLE [dbo].[TempModelli] ADD  CONSTRAINT [DF_TempModelli_mdlXCPubLeg]  DEFAULT (0) FOR [mdlXCPubLeg]
GO
ALTER TABLE [dbo].[TempModelli] ADD  CONSTRAINT [DF_TempModelli_mdlYCPubLeg]  DEFAULT (0) FOR [mdlYCPubLeg]
GO
ALTER TABLE [dbo].[TempModelli] ADD  CONSTRAINT [DF_TempModelli_mdlXCLogo]  DEFAULT (0) FOR [mdlXCLogo]
GO
ALTER TABLE [dbo].[TempModelli] ADD  CONSTRAINT [DF_TempModelli_mdlYCLogo]  DEFAULT (0) FOR [mdlYCLogo]
GO
ALTER TABLE [dbo].[TempModelli] ADD  CONSTRAINT [DF_TempModelli_mdlXCProtocollo]  DEFAULT (0) FOR [mdlXCProtocollo]
GO
ALTER TABLE [dbo].[TempModelli] ADD  CONSTRAINT [DF_TempModelli_mdlYCProtocollo]  DEFAULT (0) FOR [mdlYCProtocollo]
GO
ALTER TABLE [dbo].[TempModelli] ADD  CONSTRAINT [DF_TempModelli_mdlXCData]  DEFAULT (0) FOR [mdlXCData]
GO
ALTER TABLE [dbo].[TempModelli] ADD  CONSTRAINT [DF_TempModelli_mdlYCData]  DEFAULT (0) FOR [mdlYCData]
GO
ALTER TABLE [dbo].[TempModelli] ADD  CONSTRAINT [DF_TempModelli_mdlDeleted]  DEFAULT (0) FOR [mdlDeleted]
GO
