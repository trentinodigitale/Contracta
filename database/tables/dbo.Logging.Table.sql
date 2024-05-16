USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Logging]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Logging](
	[lggIdPfu] [int] NOT NULL,
	[lggQuando] [datetime] NOT NULL,
	[lggIdLgt] [tinyint] NOT NULL,
	[lggIdObj] [int] NULL,
	[lggEvaso] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Logging] ADD  CONSTRAINT [DF_Logging_lggQuando]  DEFAULT (getdate()) FOR [lggQuando]
GO
ALTER TABLE [dbo].[Logging] ADD  CONSTRAINT [DF_Logging_lggCosa]  DEFAULT (0) FOR [lggIdLgt]
GO
ALTER TABLE [dbo].[Logging] ADD  CONSTRAINT [DF_Logging_lggEvaso]  DEFAULT (0) FOR [lggEvaso]
GO
ALTER TABLE [dbo].[Logging]  WITH CHECK ADD  CONSTRAINT [FK_Logging_LoggingTipo] FOREIGN KEY([lggIdLgt])
REFERENCES [dbo].[LoggingTipo] ([IdLgt])
GO
ALTER TABLE [dbo].[Logging] CHECK CONSTRAINT [FK_Logging_LoggingTipo]
GO
ALTER TABLE [dbo].[Logging]  WITH NOCHECK ADD  CONSTRAINT [FK_Logging_ProfiliUtente] FOREIGN KEY([lggIdPfu])
REFERENCES [dbo].[ProfiliUtente] ([IdPfu])
GO
ALTER TABLE [dbo].[Logging] CHECK CONSTRAINT [FK_Logging_ProfiliUtente]
GO
