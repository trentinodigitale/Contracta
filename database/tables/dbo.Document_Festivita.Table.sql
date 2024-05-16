USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Festivita]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Festivita](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Deleted] [int] NULL,
	[Data] [datetime] NULL,
	[Ricorrente] [int] NULL,
	[Descrizione] [nvarchar](200) NULL,
	[TipoFesta] [varchar](20) NULL,
	[Color] [varchar](110) NULL,
	[idHeader] [int] NULL,
	[Copy] [int] NULL,
	[NumGiorni] [int] NULL,
 CONSTRAINT [PK__Document_Festivi__46B14CC8] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Festivita] ADD  CONSTRAINT [DF__Document___Delet__47A57101]  DEFAULT (0) FOR [Deleted]
GO
ALTER TABLE [dbo].[Document_Festivita] ADD  CONSTRAINT [DF__Document___Ricor__4899953A]  DEFAULT (0) FOR [Ricorrente]
GO
ALTER TABLE [dbo].[Document_Festivita] ADD  CONSTRAINT [DF_Document_Festivita_Copy]  DEFAULT (0) FOR [Copy]
GO
