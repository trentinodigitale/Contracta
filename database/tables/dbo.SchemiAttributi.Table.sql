USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[SchemiAttributi]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SchemiAttributi](
	[satIdSc] [int] NOT NULL,
	[satIdDzt] [int] NOT NULL,
	[satIdUse] [int] NOT NULL,
	[satIdAccess] [int] NOT NULL,
 CONSTRAINT [PK_SchemiAttributi] PRIMARY KEY NONCLUSTERED 
(
	[satIdSc] ASC,
	[satIdDzt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SchemiAttributi]  WITH CHECK ADD  CONSTRAINT [FK_SchemiAttributi_DizionarioAttributi1] FOREIGN KEY([satIdDzt])
REFERENCES [dbo].[DizionarioAttributi] ([IdDzt])
GO
ALTER TABLE [dbo].[SchemiAttributi] CHECK CONSTRAINT [FK_SchemiAttributi_DizionarioAttributi1]
GO
ALTER TABLE [dbo].[SchemiAttributi]  WITH CHECK ADD  CONSTRAINT [FK_SchemiAttributi_Schemi] FOREIGN KEY([satIdSc])
REFERENCES [dbo].[Schemi] ([IdSc])
GO
ALTER TABLE [dbo].[SchemiAttributi] CHECK CONSTRAINT [FK_SchemiAttributi_Schemi]
GO
ALTER TABLE [dbo].[SchemiAttributi]  WITH CHECK ADD  CONSTRAINT [FK_SchemiAttributi_SchemiAccesso] FOREIGN KEY([satIdAccess])
REFERENCES [dbo].[SchemiAccesso] ([IdAccess])
GO
ALTER TABLE [dbo].[SchemiAttributi] CHECK CONSTRAINT [FK_SchemiAttributi_SchemiAccesso]
GO
ALTER TABLE [dbo].[SchemiAttributi]  WITH CHECK ADD  CONSTRAINT [FK_SchemiAttributi_SchemiUso] FOREIGN KEY([satIdUse])
REFERENCES [dbo].[SchemiUso] ([IdUse])
GO
ALTER TABLE [dbo].[SchemiAttributi] CHECK CONSTRAINT [FK_SchemiAttributi_SchemiUso]
GO
