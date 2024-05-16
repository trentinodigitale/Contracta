USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[TempOfferte]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempOfferte](
	[IdOff] [int] NOT NULL,
	[offIdPfu] [int] NOT NULL,
	[offStato] [tinyint] NOT NULL,
	[offProtocollo] [nvarchar](9) NULL,
	[offOggetto] [nvarchar](200) NULL,
	[offNote] [ntext] NULL,
	[offIdQvtBuyer] [int] NULL,
	[offIdQvtSeller] [int] NULL,
	[offIdMdl] [int] NOT NULL,
	[offDeleted] [bit] NOT NULL,
	[offScadenza] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[TempOfferte] ADD  CONSTRAINT [DF_TempOfferte_offStato]  DEFAULT (0) FOR [offStato]
GO
ALTER TABLE [dbo].[TempOfferte] ADD  CONSTRAINT [DF_TempOfferte_offDeleted]  DEFAULT (0) FOR [offDeleted]
GO
