USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TipiDatiRange]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipiDatiRange](
	[IdTdr] [int] IDENTITY(1,1) NOT NULL,
	[tdrIdTid] [smallint] NOT NULL,
	[tdrIdDsc] [int] NOT NULL,
	[tdrRelOrdine] [smallint] NOT NULL,
	[tdrUltimaMod] [datetime] NOT NULL,
	[tdrCodice] [varchar](50) NULL,
	[tdrDeleted] [bit] NOT NULL,
	[tdrCodiceEsterno] [varchar](20) NULL,
	[tdrCodiceRaccordo] [varchar](20) NULL,
 CONSTRAINT [PK_TipiDatiRange] PRIMARY KEY NONCLUSTERED 
(
	[IdTdr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TipiDatiRange] ADD  CONSTRAINT [DF_TipiDatiRange_tdrUltimaMod]  DEFAULT (getdate()) FOR [tdrUltimaMod]
GO
ALTER TABLE [dbo].[TipiDatiRange] ADD  CONSTRAINT [DF_TipiDatiRange_tdrDeleted]  DEFAULT (0) FOR [tdrDeleted]
GO
ALTER TABLE [dbo].[TipiDatiRange]  WITH NOCHECK ADD  CONSTRAINT [FK_TipiDati_DescsI] FOREIGN KEY([tdrIdDsc])
REFERENCES [dbo].[DescsI] ([IdDsc])
GO
ALTER TABLE [dbo].[TipiDatiRange] CHECK CONSTRAINT [FK_TipiDati_DescsI]
GO
ALTER TABLE [dbo].[TipiDatiRange]  WITH NOCHECK ADD  CONSTRAINT [FK_TipiDatiRange_TipiDati] FOREIGN KEY([tdrIdTid])
REFERENCES [dbo].[TipiDati] ([IdTid])
GO
ALTER TABLE [dbo].[TipiDatiRange] CHECK CONSTRAINT [FK_TipiDatiRange_TipiDati]
GO
