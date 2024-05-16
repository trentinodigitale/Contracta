USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_AGGIORNAMENTI]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_AGGIORNAMENTI](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Num_Attivita] [int] NULL,
	[Oggetto] [ntext] NULL,
	[data] [datetime] NULL,
	[Utente] [int] NULL,
	[Note] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_AGGIORNAMENTI] ADD  CONSTRAINT [DF_CTL_AGGIORNAMENTI_data]  DEFAULT (getdate()) FOR [data]
GO
