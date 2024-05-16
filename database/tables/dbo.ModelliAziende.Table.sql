USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ModelliAziende]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModelliAziende](
	[IdMaz] [int] IDENTITY(1,1) NOT NULL,
	[mazIdMdl] [int] NOT NULL,
	[mazIdAzi] [int] NOT NULL,
	[mazProg] [smallint] NULL,
	[mazProtocollo] [nvarchar](12) NULL,
	[mazDataInvio] [datetime] NULL,
	[mazRank] [tinyint] NULL,
	[mazIdOff] [int] NULL,
 CONSTRAINT [PK_ModelliAziende] PRIMARY KEY NONCLUSTERED 
(
	[IdMaz] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModelliAziende] ADD  CONSTRAINT [DF_ModelliAziende_mazDataInvio]  DEFAULT (getdate()) FOR [mazDataInvio]
GO
ALTER TABLE [dbo].[ModelliAziende]  WITH NOCHECK ADD  CONSTRAINT [FK_ModelliAziende_Aziende] FOREIGN KEY([mazIdAzi])
REFERENCES [dbo].[Aziende] ([IdAzi])
GO
ALTER TABLE [dbo].[ModelliAziende] CHECK CONSTRAINT [FK_ModelliAziende_Aziende]
GO
ALTER TABLE [dbo].[ModelliAziende]  WITH CHECK ADD  CONSTRAINT [FK_ModelliAziende_Modelli] FOREIGN KEY([mazIdMdl])
REFERENCES [dbo].[Modelli] ([IdMdl])
GO
ALTER TABLE [dbo].[ModelliAziende] CHECK CONSTRAINT [FK_ModelliAziende_Modelli]
GO
ALTER TABLE [dbo].[ModelliAziende]  WITH CHECK ADD  CONSTRAINT [FK_ModelliAziende_Offerte] FOREIGN KEY([mazIdOff])
REFERENCES [dbo].[Offerte] ([IdOff])
GO
ALTER TABLE [dbo].[ModelliAziende] CHECK CONSTRAINT [FK_ModelliAziende_Offerte]
GO
