USE [AFLink_TND]
GO
/****** Object:  Table [dbo].[Document_Notes]    Script Date: 5/16/2024 2:42:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document_Notes](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Deleted] [int] NULL,
	[Data] [datetime] NULL,
	[Descrizione] [nvarchar](200) NULL,
	[Protocollo] [nvarchar](50) NULL,
	[Referente] [nvarchar](50) NULL,
	[TypeNote] [varchar](20) NULL,
	[Color] [varchar](20) NULL,
	[Idpfu] [int] NULL,
	[DataOperazione] [datetime] NULL,
 CONSTRAINT [PK_Document_Notes] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Document_Notes] ADD  CONSTRAINT [DF_Document_Notes_Deleted]  DEFAULT (0) FOR [Deleted]
GO
