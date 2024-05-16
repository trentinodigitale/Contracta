USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPAttributiControlli]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPAttributiControlli](
	[IdMpAc] [int] IDENTITY(1,1) NOT NULL,
	[mpacIdMdlAtt] [int] NOT NULL,
	[mpacIdDzt] [int] NOT NULL,
	[mpacValue] [nvarchar](1000) NOT NULL,
	[mpacUltimaMod] [datetime] NOT NULL,
	[mpacDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_MPAttributiControlli] PRIMARY KEY NONCLUSTERED 
(
	[IdMpAc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPAttributiControlli] ADD  CONSTRAINT [DF_MPAttributiControlli_mpacUltimaMod]  DEFAULT (getdate()) FOR [mpacUltimaMod]
GO
ALTER TABLE [dbo].[MPAttributiControlli] ADD  CONSTRAINT [DF_MPAttributiControlli_mpacDeleted]  DEFAULT (0) FOR [mpacDeleted]
GO
ALTER TABLE [dbo].[MPAttributiControlli]  WITH NOCHECK ADD  CONSTRAINT [FK_MPAttributiControlli_DizionarioAttributi] FOREIGN KEY([mpacIdDzt])
REFERENCES [dbo].[DizionarioAttributi] ([IdDzt])
GO
ALTER TABLE [dbo].[MPAttributiControlli] CHECK CONSTRAINT [FK_MPAttributiControlli_DizionarioAttributi]
GO
ALTER TABLE [dbo].[MPAttributiControlli]  WITH NOCHECK ADD  CONSTRAINT [FK_MPAttributiControlli_MPModelliAttributi] FOREIGN KEY([mpacIdMdlAtt])
REFERENCES [dbo].[MPModelliAttributi] ([IdMdlAtt])
GO
ALTER TABLE [dbo].[MPAttributiControlli] CHECK CONSTRAINT [FK_MPAttributiControlli_MPModelliAttributi]
GO
