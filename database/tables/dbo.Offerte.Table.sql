USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Offerte]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Offerte](
	[IdOff] [int] IDENTITY(1,1) NOT NULL,
	[offIdPfu] [int] NOT NULL,
	[offStato] [tinyint] NOT NULL,
	[offProtocollo] [nvarchar](9) NULL,
	[offOggetto] [nvarchar](200) NULL,
	[offNote] [ntext] NULL,
	[offIdQvtBuyer] [int] NULL,
	[offIdQvtSeller] [int] NULL,
	[offIdMdl] [int] NOT NULL,
	[offDeleted] [bit] NOT NULL,
	[offScadenza] [datetime] NULL,
 CONSTRAINT [PK_Offerte] PRIMARY KEY NONCLUSTERED 
(
	[IdOff] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Offerte] ADD  CONSTRAINT [DF_Offerte_offStato]  DEFAULT (0) FOR [offStato]
GO
ALTER TABLE [dbo].[Offerte] ADD  CONSTRAINT [DF_Offerte_offDeleted]  DEFAULT (0) FOR [offDeleted]
GO
ALTER TABLE [dbo].[Offerte]  WITH CHECK ADD  CONSTRAINT [FK_Offerte_Modelli] FOREIGN KEY([offIdMdl])
REFERENCES [dbo].[Modelli] ([IdMdl])
GO
ALTER TABLE [dbo].[Offerte] CHECK CONSTRAINT [FK_Offerte_Modelli]
GO
ALTER TABLE [dbo].[Offerte]  WITH NOCHECK ADD  CONSTRAINT [FK_Offerte_ProfiliUtente] FOREIGN KEY([offIdPfu])
REFERENCES [dbo].[ProfiliUtente] ([IdPfu])
GO
ALTER TABLE [dbo].[Offerte] CHECK CONSTRAINT [FK_Offerte_ProfiliUtente]
GO
ALTER TABLE [dbo].[Offerte]  WITH CHECK ADD  CONSTRAINT [FK_Offerte_QuestValutativi1] FOREIGN KEY([offIdQvtBuyer])
REFERENCES [dbo].[QuestValutativi] ([IdQvt])
GO
ALTER TABLE [dbo].[Offerte] CHECK CONSTRAINT [FK_Offerte_QuestValutativi1]
GO
ALTER TABLE [dbo].[Offerte]  WITH CHECK ADD  CONSTRAINT [FK_Offerte_QuestValutativi2] FOREIGN KEY([offIdQvtSeller])
REFERENCES [dbo].[QuestValutativi] ([IdQvt])
GO
ALTER TABLE [dbo].[Offerte] CHECK CONSTRAINT [FK_Offerte_QuestValutativi2]
GO
