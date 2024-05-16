USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Modelli]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Modelli](
	[IdMdl] [int] IDENTITY(1,1) NOT NULL,
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
	[mdlDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_Modelli] PRIMARY KEY NONCLUSTERED 
(
	[IdMdl] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UN_ModelliNome] UNIQUE NONCLUSTERED 
(
	[mdlIdPfu] ASC,
	[mdlNome] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Modelli] ADD  CONSTRAINT [DF_Modelli_mdlNome]  DEFAULT ('Default') FOR [mdlNome]
GO
ALTER TABLE [dbo].[Modelli] ADD  CONSTRAINT [DF_Modelli_mdlStato]  DEFAULT (0) FOR [mdlStato]
GO
ALTER TABLE [dbo].[Modelli] ADD  CONSTRAINT [DF_Modelli_mdlNRdo]  DEFAULT (0) FOR [mdlNRdo]
GO
ALTER TABLE [dbo].[Modelli] ADD  CONSTRAINT [DF_Modelli_mdlNOfferte]  DEFAULT (0) FOR [mdlNOfferte]
GO
ALTER TABLE [dbo].[Modelli] ADD  CONSTRAINT [DF_Modelli_mdlXCPubLeg]  DEFAULT (0) FOR [mdlXCPubLeg]
GO
ALTER TABLE [dbo].[Modelli] ADD  CONSTRAINT [DF_Modelli_mdlYCPubLeg]  DEFAULT (0) FOR [mdlYCPubLeg]
GO
ALTER TABLE [dbo].[Modelli] ADD  CONSTRAINT [DF_Modelli_mdlXCLogo]  DEFAULT (0) FOR [mdlXCLogo]
GO
ALTER TABLE [dbo].[Modelli] ADD  CONSTRAINT [DF_Modelli_mdlYCLogo]  DEFAULT (0) FOR [mdlYCLogo]
GO
ALTER TABLE [dbo].[Modelli] ADD  CONSTRAINT [DF_Modelli_mdlXCProtocollo]  DEFAULT (0) FOR [mdlXCProtocollo]
GO
ALTER TABLE [dbo].[Modelli] ADD  CONSTRAINT [DF_Modelli_mdlYCProtocollo]  DEFAULT (0) FOR [mdlYCProtocollo]
GO
ALTER TABLE [dbo].[Modelli] ADD  CONSTRAINT [DF_Modelli_mdlXCData]  DEFAULT (0) FOR [mdlXCData]
GO
ALTER TABLE [dbo].[Modelli] ADD  CONSTRAINT [DF_Modelli_mdlYCData]  DEFAULT (0) FOR [mdlYCData]
GO
ALTER TABLE [dbo].[Modelli] ADD  CONSTRAINT [DF_Modelli_mdlDeleted]  DEFAULT (0) FOR [mdlDeleted]
GO
ALTER TABLE [dbo].[Modelli]  WITH NOCHECK ADD  CONSTRAINT [FK_Modelli_ProfiliUtente] FOREIGN KEY([mdlIdPfu])
REFERENCES [dbo].[ProfiliUtente] ([IdPfu])
GO
ALTER TABLE [dbo].[Modelli] CHECK CONSTRAINT [FK_Modelli_ProfiliUtente]
GO
