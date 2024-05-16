USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[AppartenenzaAttributi]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppartenenzaAttributi](
	[IdApAt] [int] IDENTITY(1,1) NOT NULL,
	[apatIdDzt] [int] NOT NULL,
	[apatIdApp] [int] NOT NULL,
	[apatDeleted] [bit] NOT NULL,
	[apatUltimaMod] [datetime] NOT NULL,
	[apatTabellaSpeciale] [varchar](255) NULL,
	[apatCampoSpeciale] [varchar](255) NULL,
	[apatIsUnicode] [bit] NOT NULL,
 CONSTRAINT [PK__AppartenenzaAttr__6680FC4D] PRIMARY KEY CLUSTERED 
(
	[IdApAt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppartenenzaAttributi] ADD  CONSTRAINT [DF_AppartenenzaAttributi_apatDeleted]  DEFAULT (0) FOR [apatDeleted]
GO
ALTER TABLE [dbo].[AppartenenzaAttributi] ADD  CONSTRAINT [DF_AppartenenzaAttributi_apatUltimaMod]  DEFAULT (getdate()) FOR [apatUltimaMod]
GO
ALTER TABLE [dbo].[AppartenenzaAttributi] ADD  CONSTRAINT [DF__Appartene__apatI__5DF5D7ED]  DEFAULT (0) FOR [apatIsUnicode]
GO
ALTER TABLE [dbo].[AppartenenzaAttributi]  WITH CHECK ADD  CONSTRAINT [FK__Appartene__apatI__686944BF] FOREIGN KEY([apatIdApp])
REFERENCES [dbo].[Appartenenze] ([IdApp])
GO
ALTER TABLE [dbo].[AppartenenzaAttributi] CHECK CONSTRAINT [FK__Appartene__apatI__686944BF]
GO
ALTER TABLE [dbo].[AppartenenzaAttributi]  WITH CHECK ADD  CONSTRAINT [FK__Appartene__apatI__695D68F8] FOREIGN KEY([apatIdDzt])
REFERENCES [dbo].[DizionarioAttributi] ([IdDzt])
GO
ALTER TABLE [dbo].[AppartenenzaAttributi] CHECK CONSTRAINT [FK__Appartene__apatI__695D68F8]
GO
