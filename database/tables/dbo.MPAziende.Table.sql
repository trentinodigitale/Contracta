USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPAziende]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPAziende](
	[IdMpa] [int] IDENTITY(1,1) NOT NULL,
	[mpaIdMp] [int] NOT NULL,
	[mpaIdAzi] [int] NOT NULL,
	[mpaAcquirente] [smallint] NOT NULL,
	[mpaVenditore] [smallint] NOT NULL,
	[mpaProspect] [smallint] NOT NULL,
	[mpaDeleted] [tinyint] NOT NULL,
	[mpaDataCreazione] [datetime] NOT NULL,
	[mpaProfili] [varchar](20) NULL,
 CONSTRAINT [PK_MPAziende] PRIMARY KEY NONCLUSTERED 
(
	[IdMpa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPAziende] ADD  CONSTRAINT [DF_MPAziende_mpaAcquirente]  DEFAULT (0) FOR [mpaAcquirente]
GO
ALTER TABLE [dbo].[MPAziende] ADD  CONSTRAINT [DF_MPAziende_mpaVenditore]  DEFAULT (0) FOR [mpaVenditore]
GO
ALTER TABLE [dbo].[MPAziende] ADD  CONSTRAINT [DF_MPAziende_mpaProspect]  DEFAULT (0) FOR [mpaProspect]
GO
ALTER TABLE [dbo].[MPAziende] ADD  CONSTRAINT [DF_MPAziende_mpaDeleted]  DEFAULT (0) FOR [mpaDeleted]
GO
ALTER TABLE [dbo].[MPAziende] ADD  CONSTRAINT [DF_MPAziende_mpaDataCreazione]  DEFAULT (getdate()) FOR [mpaDataCreazione]
GO
ALTER TABLE [dbo].[MPAziende]  WITH NOCHECK ADD  CONSTRAINT [FK_MPAziende_Aziende] FOREIGN KEY([mpaIdAzi])
REFERENCES [dbo].[Aziende] ([IdAzi])
GO
ALTER TABLE [dbo].[MPAziende] CHECK CONSTRAINT [FK_MPAziende_Aziende]
GO
ALTER TABLE [dbo].[MPAziende]  WITH CHECK ADD  CONSTRAINT [FK_MPAziende_MarketPlace] FOREIGN KEY([mpaIdMp])
REFERENCES [dbo].[MarketPlace] ([IdMp])
GO
ALTER TABLE [dbo].[MPAziende] CHECK CONSTRAINT [FK_MPAziende_MarketPlace]
GO
