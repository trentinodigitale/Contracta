USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[CTL_Formule]    Script Date: 5/16/2024 2:42:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CTL_Formule](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Formula] [nvarchar](4000) NULL,
	[deleted] [int] NULL,
	[CategorieUSO] [varchar](500) NULL,
	[Descrizione] [varchar](500) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTL_Formule] ADD  CONSTRAINT [DF_CTL_Formule_deleted]  DEFAULT (0) FOR [deleted]
GO
