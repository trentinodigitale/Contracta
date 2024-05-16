USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[MPMailCensimento]    Script Date: 5/16/2024 2:42:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MPMailCensimento](
	[IdMpMc] [int] IDENTITY(1,1) NOT NULL,
	[mpmcIdMp] [int] NOT NULL,
	[mpmcIdAzi] [int] NOT NULL,
	[mpmcMail] [ntext] NOT NULL,
	[mpmcOggetto] [nvarchar](100) NOT NULL,
	[mpmcDataIns] [datetime] NOT NULL,
	[mpmcDeleted] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[MPMailCensimento] ADD  CONSTRAINT [DF_MPMailCensimento_mpmcDataIns]  DEFAULT (getdate()) FOR [mpmcDataIns]
GO
ALTER TABLE [dbo].[MPMailCensimento] ADD  CONSTRAINT [DF_MPMailCensimento_mpmcDeleted]  DEFAULT (0) FOR [mpmcDeleted]
GO
ALTER TABLE [dbo].[MPMailCensimento]  WITH CHECK ADD  CONSTRAINT [FK_MPMailCensimento_MarketPlace] FOREIGN KEY([mpmcIdMp])
REFERENCES [dbo].[MarketPlace] ([IdMp])
GO
ALTER TABLE [dbo].[MPMailCensimento] CHECK CONSTRAINT [FK_MPMailCensimento_MarketPlace]
GO
