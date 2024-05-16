USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[ValiditaAttributi]    Script Date: 5/16/2024 2:42:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValiditaAttributi](
	[IdVa] [int] IDENTITY(1,1) NOT NULL,
	[vaIdVat] [int] NOT NULL,
	[vaTipo] [smallint] NOT NULL,
	[vaValore] [varchar](50) NOT NULL,
	[vaDeleted] [bit] NOT NULL,
	[vaDataInizio] [datetime] NOT NULL,
	[vaDataFine] [datetime] NOT NULL,
 CONSTRAINT [PK_ValiditaAttributi] PRIMARY KEY CLUSTERED 
(
	[IdVa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ValiditaAttributi] ADD  CONSTRAINT [DF__ValiditaA__vaDel__00EED279]  DEFAULT (0) FOR [vaDeleted]
GO
