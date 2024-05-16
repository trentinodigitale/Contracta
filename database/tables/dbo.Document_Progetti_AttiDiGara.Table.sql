USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Progetti_AttiDiGara]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Progetti_AttiDiGara](
	[idRow] [int] IDENTITY(1,1) NOT NULL,
	[idProgetto] [int] NOT NULL,
	[Descrizione] [nvarchar](255) NULL,
	[Allegato] [varchar](255) NULL,
	[Storico] [int] NULL,
	[NotEditable] [varchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Progetti_AttiDiGara] ADD  CONSTRAINT [DF_Document_Progetti_AttiDiGara_Storico]  DEFAULT (0) FOR [Storico]
GO
